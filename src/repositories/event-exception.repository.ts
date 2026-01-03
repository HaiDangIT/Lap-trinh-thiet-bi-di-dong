import { type EventException, Prisma } from "@prisma/client";
import prisma from "../config/database.config.js";

export class EventExceptionRepository {
  /**
   * Tạo exception mới
   */
  async create(
    data: Prisma.EventExceptionCreateInput
  ): Promise<EventException> {
    return prisma.eventException.create({
      data,
      include: {
        event: true,
      },
    });
  }

  /**
   * Tìm exception theo ID
   */
  async findById(id: string): Promise<EventException | null> {
    return prisma.eventException.findUnique({
      where: { id },
      include: {
        event: true,
      },
    });
  }

  /**
   * Lấy exceptions của event
   */
  async findByEventId(eventId: string): Promise<EventException[]> {
    return prisma.eventException.findMany({
      where: { eventId },
      orderBy: {
        originalStartTime: "asc",
      },
    });
  }

  /**
   * Tìm exception cho một occurrence cụ thể
   */
  async findByEventAndDate(
    eventId: string,
    originalStartTime: Date
  ): Promise<EventException | null> {
    return prisma.eventException.findFirst({
      where: {
        eventId,
        originalStartTime,
      },
    });
  }

  /**
   * Cập nhật exception
   */
  async update(
    id: string,
    data: Prisma.EventExceptionUpdateInput
  ): Promise<EventException> {
    return prisma.eventException.update({
      where: { id },
      data,
    });
  }

  /**
   * Xóa exception
   */
  async delete(id: string): Promise<EventException> {
    return prisma.eventException.delete({
      where: { id },
    });
  }

  /**
   * Xóa tất cả exceptions của event
   */
  async deleteByEventId(eventId: string): Promise<number> {
    const result = await prisma.eventException.deleteMany({
      where: { eventId },
    });
    return result.count;
  }

  /**
   * Kiểm tra có exception cho date này không
   */
  async hasException(
    eventId: string,
    originalStartTime: Date
  ): Promise<boolean> {
    const count = await prisma.eventException.count({
      where: {
        eventId,
        originalStartTime,
      },
    });
    return count > 0;
  }
}

export default new EventExceptionRepository();
