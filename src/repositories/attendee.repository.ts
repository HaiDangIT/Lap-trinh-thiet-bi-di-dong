import { type Attendee, Prisma } from "@prisma/client";
import prisma from "../config/database.config.js";

export class AttendeeRepository {
  /**
   * Tạo attendee mới
   */
  async create(data: Prisma.AttendeeCreateInput): Promise<Attendee> {
    return prisma.attendee.create({
      data,
      include: {
        event: true,
        user: true,
      },
    });
  }

  /**
   * Tạo nhiều attendees cùng lúc
   */
  async createMany(data: Prisma.AttendeeCreateManyInput[]): Promise<number> {
    const result = await prisma.attendee.createMany({
      data,
      skipDuplicates: true,
    });
    return result.count;
  }

  /**
   * Tìm attendee theo ID
   */
  async findById(id: string): Promise<Attendee | null> {
    return prisma.attendee.findUnique({
      where: { id },
      include: {
        event: true,
        user: true,
      },
    });
  }

  /**
   * Lấy attendees của event
   */
  async findByEventId(eventId: string): Promise<Attendee[]> {
    return prisma.attendee.findMany({
      where: { eventId },
      include: {
        user: true,
      },
      orderBy: { createdAt: "asc" },
    });
  }

  /**
   * Lấy events mà user tham gia
   */
  async findByUserId(userId: string): Promise<Attendee[]> {
    return prisma.attendee.findMany({
      where: { userId },
      include: {
        event: {
          include: {
            calendar: true,
          },
        },
      },
      orderBy: {
        createdAt: "desc",
      },
    });
  }

  /**
   * Cập nhật status của attendee
   */
  async updateStatus(id: string, responseStatus: string): Promise<Attendee> {
    return prisma.attendee.update({
      where: { id },
      data: { responseStatus },
    });
  }

  /**
   * Cập nhật attendee
   */
  async update(
    id: string,
    data: Prisma.AttendeeUpdateInput
  ): Promise<Attendee> {
    return prisma.attendee.update({
      where: { id },
      data,
    });
  }

  /**
   * Xóa attendee
   */
  async delete(id: string): Promise<Attendee> {
    return prisma.attendee.delete({
      where: { id },
    });
  }

  /**
   * Xóa tất cả attendees của event
   */
  async deleteByEventId(eventId: string): Promise<number> {
    const result = await prisma.attendee.deleteMany({
      where: { eventId },
    });
    return result.count;
  }

  /**
   * Kiểm tra user đã là attendee của event chưa
   */
  async isAttendee(eventId: string, email: string): Promise<boolean> {
    const count = await prisma.attendee.count({
      where: {
        eventId,
        email,
      },
    });
    return count > 0;
  }

  /**
   * Lấy attendee theo event và email
   */
  async findByEventAndEmail(
    eventId: string,
    email: string
  ): Promise<Attendee | null> {
    return prisma.attendee.findFirst({
      where: {
        eventId,
        email,
      },
      include: {
        user: true,
      },
    });
  }
}

export default new AttendeeRepository();
