import { type Reminder, Prisma } from "@prisma/client";
import prisma from "../config/database.config.js";

export class ReminderRepository {
  /**
   * Tạo reminder mới
   */
  async create(data: Prisma.ReminderCreateInput): Promise<Reminder> {
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
  async createMany(data: Prisma.ReminderCreateManyInput[]): Promise<number> {
    const result = await prisma.reminder.createMany({
      data,
    });
    return result.count;
  }

  /**
   * Tìm reminder theo ID
   */
  async findById(id: string): Promise<Reminder | null> {
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
  async findByEventId(eventId: string): Promise<Reminder[]> {
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
  async findUpcoming(minutesAhead: number = 15): Promise<Reminder[]> {
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
  async update(
    id: string,
    data: Prisma.ReminderUpdateInput
  ): Promise<Reminder> {
    return prisma.reminder.update({
      where: { id },
      data,
    });
  }

  /**
   * Xóa reminder
   */
  async delete(id: string): Promise<Reminder> {
    return prisma.reminder.delete({
      where: { id },
    });
  }

  /**
   * Xóa tất cả reminders của event
   */
  async deleteByEventId(eventId: string): Promise<number> {
    const result = await prisma.reminder.deleteMany({
      where: { eventId },
    });
    return result.count;
  }
}

export default new ReminderRepository();
