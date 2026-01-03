import { type User, Prisma } from "@prisma/client";
import prisma from "../config/database.config.js";

export class UserRepository {
  /**
   * Tạo user mới
   */
  async create(data: Prisma.UserCreateInput): Promise<User> {
    return prisma.user.create({ data });
  }

  /**
   * Tìm user theo ID
   */
  async findById(id: string): Promise<User | null> {
    return prisma.user.findUnique({
      where: { id },
      include: {
        calendars: true,
      },
    });
  }

  /**
   * Tìm user theo email
   */
  async findByEmail(email: string): Promise<User | null> {
    return prisma.user.findUnique({
      where: { email },
    });
  }

  /**
   * Lấy tất cả users (có phân trang)
   */
  async findAll(
    skip: number = 0,
    take: number = 20,
    where: any = {}
  ): Promise<User[]> {
    return prisma.user.findMany({
      skip,
      take,
      where,
      orderBy: { createdAt: "desc" },
    });
  }

  /**
   * Đếm tổng số users
   */
  async count(where: any = {}): Promise<number> {
    return prisma.user.count({ where });
  }

  /**
   * Cập nhật user
   */
  async update(id: string, data: Prisma.UserUpdateInput): Promise<User> {
    return prisma.user.update({
      where: { id },
      data,
    });
  }

  /**
   * Xóa user
   */
  async delete(id: string): Promise<User> {
    return prisma.user.delete({
      where: { id },
    });
  }

  /**
   * Kiểm tra email đã tồn tại chưa
   */
  async emailExists(email: string, excludeId?: string): Promise<boolean> {
    const count = await prisma.user.count({
      where: {
        email,
        ...(excludeId && { id: { not: excludeId } }),
      },
    });
    return count > 0;
  }

  /**
   * Search users by email or name
   */
  async searchUsers(query: string, limit: number = 10): Promise<User[]> {
    return prisma.user.findMany({
      where: {
        OR: [
          { email: { contains: query, mode: "insensitive" } },
          { fullName: { contains: query, mode: "insensitive" } },
        ],
      },
      take: limit,
      orderBy: { createdAt: "desc" },
    });
  }

  /**
   * Get user statistics
   */
  async getUserStatistics(userId: string) {
    const [calendarsCount, eventsCount, attendeeCount] = await Promise.all([
      prisma.calendar.count({ where: { userId } }),
      prisma.event.count({ where: { creatorId: userId } }),
      prisma.attendee.count({ where: { userId } }),
    ]);

    return {
      calendarsCount,
      eventsCreated: eventsCount,
      eventsAttending: attendeeCount,
    };
  }

  /**
   * Bulk delete users
   */
  async bulkDelete(userIds: string[]): Promise<number> {
    const result = await prisma.user.deleteMany({
      where: {
        id: { in: userIds },
      },
    });
    return result.count;
  }
}

export default new UserRepository();
