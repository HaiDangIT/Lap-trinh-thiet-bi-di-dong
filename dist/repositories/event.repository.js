import { Prisma } from "@prisma/client";
import prisma from "../config/database.config.js";
export class EventRepository {
    /**
     * Tạo event mới (với recurrence rule, attendees, reminders)
     */
    async create(data) {
        return prisma.event.create({
            data,
            include: {
                calendar: true,
                creator: true,
                recurrenceRule: true,
                attendees: true,
                reminders: true,
                exceptions: true,
            },
        });
    }
    /**
     * Tìm event theo ID
     */
    async findById(id) {
        return prisma.event.findUnique({
            where: { id },
            include: {
                calendar: {
                    include: {
                        user: true,
                    },
                },
                creator: true,
                recurrenceRule: true,
                attendees: {
                    include: {
                        user: true,
                    },
                },
                reminders: true,
                exceptions: {
                    orderBy: { originalStartTime: "asc" },
                },
            },
        });
    }
    /**
     * Lấy events trong khoảng thời gian
     */
    async findInRange(startTime, endTime, filters) {
        const where = {
            AND: [
                {
                    startTime: {
                        lte: endTime,
                    },
                },
                {
                    endTime: {
                        gte: startTime,
                    },
                },
            ],
            ...(filters?.calendarId && { calendarId: filters.calendarId }),
            ...(filters?.creatorId && { creatorId: filters.creatorId }),
            ...(filters?.isRecurring !== undefined && {
                isRecurring: filters.isRecurring,
            }),
            ...(filters?.search && {
                OR: [
                    { title: { contains: filters.search, mode: "insensitive" } },
                    { description: { contains: filters.search, mode: "insensitive" } },
                    { location: { contains: filters.search, mode: "insensitive" } },
                ],
            }),
        };
        return prisma.event.findMany({
            where,
            include: {
                calendar: true,
                creator: true,
                recurrenceRule: true,
                attendees: true,
                reminders: true,
                exceptions: true,
            },
            orderBy: {
                startTime: "asc",
            },
        });
    }
    /**
     * Lấy events của một calendar
     */
    async findByCalendarId(calendarId, skip = 0, take = 50) {
        return prisma.event.findMany({
            where: { calendarId },
            skip,
            take,
            include: {
                recurrenceRule: true,
                attendees: true,
                reminders: true,
            },
            orderBy: {
                startTime: "asc",
            },
        });
    }
    /**
     * Lấy upcoming events của user
     */
    async findUpcomingByUserId(userId, limit = 10) {
        const now = new Date();
        return prisma.event.findMany({
            where: {
                calendar: {
                    userId,
                },
                startTime: {
                    gte: now,
                },
            },
            take: limit,
            include: {
                calendar: true,
                recurrenceRule: true,
                attendees: true,
                reminders: true,
            },
            orderBy: {
                startTime: "asc",
            },
        });
    }
    /**
     * Tìm kiếm events
     */
    async search(userId, query, skip = 0, take = 20) {
        return prisma.event.findMany({
            where: {
                calendar: {
                    userId,
                },
                OR: [
                    { title: { contains: query, mode: "insensitive" } },
                    { description: { contains: query, mode: "insensitive" } },
                    { location: { contains: query, mode: "insensitive" } },
                ],
            },
            skip,
            take,
            include: {
                calendar: true,
                recurrenceRule: true,
                attendees: true,
            },
            orderBy: {
                startTime: "desc",
            },
        });
    }
    /**
     * Cập nhật event
     */
    async update(id, data) {
        return prisma.event.update({
            where: { id },
            data,
            include: {
                calendar: true,
                recurrenceRule: true,
                attendees: true,
                reminders: true,
                exceptions: true,
            },
        });
    }
    /**
     * Xóa event
     */
    async delete(id) {
        return prisma.event.delete({
            where: { id },
        });
    }
    /**
     * Đếm events theo filter
     */
    async count(filters) {
        const where = {
            ...(filters?.calendarId && { calendarId: filters.calendarId }),
            ...(filters?.creatorId && { creatorId: filters.creatorId }),
            ...(filters?.isRecurring !== undefined && {
                isRecurring: filters.isRecurring,
            }),
        };
        return prisma.event.count({ where });
    }
    /**
     * Kiểm tra event conflict (trùng thời gian)
     */
    async findConflicts(calendarId, startTime, endTime, excludeEventId) {
        return prisma.event.findMany({
            where: {
                calendarId,
                AND: [
                    {
                        startTime: {
                            lt: endTime,
                        },
                    },
                    {
                        endTime: {
                            gt: startTime,
                        },
                    },
                ],
                ...(excludeEventId && {
                    id: {
                        not: excludeEventId,
                    },
                }),
            },
            include: {
                calendar: true,
            },
        });
    }
    /**
     * Find events by calendar and date range (for Smart Assistant)
     */
    async findByCalendarAndDateRange(calendarId, startTime, endTime) {
        return prisma.event.findMany({
            where: {
                calendarId,
                AND: [{ startTime: { lte: endTime } }, { endTime: { gte: startTime } }],
            },
            orderBy: { startTime: "asc" },
        });
    }
    /**
     * Find events by creator and date range (for statistics)
     */
    async findByCreatorAndDateRange(creatorId, startTime, endTime) {
        return prisma.event.findMany({
            where: {
                creatorId,
                AND: [{ startTime: { gte: startTime } }, { endTime: { lte: endTime } }],
            },
            orderBy: { startTime: "asc" },
        });
    }
    /**
     * Find all events by creator (for auto-categorization)
     */
    async findByCreator(creatorId) {
        return prisma.event.findMany({
            where: { creatorId },
            orderBy: { startTime: "desc" },
        });
    }
}
export default new EventRepository();
//# sourceMappingURL=event.repository.js.map