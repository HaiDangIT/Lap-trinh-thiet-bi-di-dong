import { Prisma } from "@prisma/client";
import prisma from "../config/database.config.js";
export class UserRepository {
    /**
     * Tạo user mới
     */
    async create(data) {
        return prisma.user.create({ data });
    }
    /**
     * Tìm user theo ID
     */
    async findById(id) {
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
    async findByEmail(email) {
        return prisma.user.findUnique({
            where: { email },
        });
    }
    /**
     * Lấy tất cả users (có phân trang)
     */
    async findAll(skip = 0, take = 20, where = {}) {
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
    async count(where = {}) {
        return prisma.user.count({ where });
    }
    /**
     * Cập nhật user
     */
    async update(id, data) {
        return prisma.user.update({
            where: { id },
            data,
        });
    }
    /**
     * Xóa user
     */
    async delete(id) {
        return prisma.user.delete({
            where: { id },
        });
    }
    /**
     * Kiểm tra email đã tồn tại chưa
     */
    async emailExists(email, excludeId) {
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
    async searchUsers(query, limit = 10) {
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
    async getUserStatistics(userId) {
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
    async bulkDelete(userIds) {
        const result = await prisma.user.deleteMany({
            where: {
                id: { in: userIds },
            },
        });
        return result.count;
    }
}
export default new UserRepository();
//# sourceMappingURL=user.repository.js.map