import { Prisma } from "@prisma/client";
import prisma from "../config/database.config.js";
export class ReminderRepository {
    /**
     * Tạo reminder mới
     */
    async create(data) {
        return prisma.reminder.create({
            data,
            include: {
                event: true,
            },
        });
    }
    /**
     * Tạo nhiều reminders cùng lúc
     */
    async createMany(data) {
        const result = await prisma.reminder.createMany({
            data,
        });
        return result.count;
    }
    /**
     * Tìm reminder theo ID
     */
    async findById(id) {
        return prisma.reminder.findUnique({
            where: { id },
            include: {
                event: true,
            },
        });
    }
    /**
     * Lấy reminders của event
     */
    async findByEventId(eventId) {
        return prisma.reminder.findMany({
            where: { eventId },
            orderBy: {
                minutesBefore: "asc",
            },
        });
    }
    /**
     * Lấy reminders cần trigger trong X phút tới
     */
    async findUpcoming(minutesAhead = 15) {
        const now = new Date();
        const future = new Date(now.getTime() + minutesAhead * 60000);
        return prisma.reminder.findMany({
            where: {
                event: {
                    startTime: {
                        gte: now,
                        lte: future,
                    },
                },
            },
            include: {
                event: {
                    include: {
                        calendar: {
                            include: {
                                user: true,
                            },
                        },
                        attendees: true,
                    },
                },
            },
            orderBy: {
                event: {
                    startTime: "asc",
                },
            },
        });
    }
    /**
     * Cập nhật reminder
     */
    async update(id, data) {
        return prisma.reminder.update({
            where: { id },
            data,
        });
    }
    /**
     * Xóa reminder
     */
    async delete(id) {
        return prisma.reminder.delete({
            where: { id },
        });
    }
    /**
     * Xóa tất cả reminders của event
     */
    async deleteByEventId(eventId) {
        const result = await prisma.reminder.deleteMany({
            where: { eventId },
        });
        return result.count;
    }
}
export default new ReminderRepository();
//# sourceMappingURL=reminder.repository.js.map