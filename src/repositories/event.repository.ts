import { type Event, Prisma } from "@prisma/client";
import prisma from "../config/database.config.js";

export interface EventFilters {
  calendarId?: string;
  creatorId?: string;
  startTime?: Date;
  endTime?: Date;
  search?: string;
  isRecurring?: boolean;
}

export class EventRepository {
  /**
   * Tạo event mới (với recurrence rule, attendees, reminders)
   */
  async create(data: Prisma.EventCreateInput): Promise<Event> {
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
  async findById(id: string): Promise<Event | null> {
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
  async findInRange(
    startTime: Date,
    endTime: Date,
    filters?: EventFilters
  ): Promise<Event[]> {
    const where: Prisma.EventWhereInput = {
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
  async findByCalendarId(
    calendarId: string,
    skip: number = 0,
    take: number = 50
  ): Promise<Event[]> {
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
  async findUpcomingByUserId(
    userId: string,
    limit: number = 10
  ): Promise<Event[]> {
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
  async search(
    userId: string,
    query: string,
    skip: number = 0,
    take: number = 20
  ): Promise<Event[]> {
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
  async update(id: string, data: Prisma.EventUpdateInput): Promise<Event> {
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
  async delete(id: string): Promise<Event> {
    return prisma.event.delete({
      where: { id },
    });
  }

  /**
   * Đếm events theo filter
   */
  async count(filters?: EventFilters): Promise<number> {
    const where: Prisma.EventWhereInput = {
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
  async findConflicts(
    calendarId: string,
    startTime: Date,
    endTime: Date,
    excludeEventId?: string
  ): Promise<Event[]> {
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
  async findByCalendarAndDateRange(
    calendarId: string,
    startTime: Date,
    endTime: Date
  ): Promise<Event[]> {
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
  async findByCreatorAndDateRange(
    creatorId: string,
    startTime: Date,
    endTime: Date
  ): Promise<Event[]> {
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
  async findByCreator(creatorId: string): Promise<Event[]> {
    return prisma.event.findMany({
      where: { creatorId },
      orderBy: { startTime: "desc" },
    });
  }
}

export default new EventRepository();
