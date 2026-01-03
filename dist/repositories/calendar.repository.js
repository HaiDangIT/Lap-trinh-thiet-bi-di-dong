import { Prisma } from "@prisma/client";
import prisma from "../config/database.config.js";
export class CalendarRepository {
    /**
     * Tạo calendar mới
     */
    async create(data) {
        return prisma.calendar.create({
            data,
            include: {
                user: true,
            },
        });
    }
    /**
     * Tìm calendar theo ID
     */
    async findById(id) {
        return prisma.calendar.findUnique({
            where: { id },
            include: {
                user: true,
                events: {
                    orderBy: { startTime: "asc" },
                    take: 10,
                },
            },
        });
    }
    /**
     * Lấy tất cả calendars của user
     */
    async findByUserId(userId) {
        return prisma.calendar.findMany({
            where: { userId },
            orderBy: [{ isPrimary: "desc" }, { name: "asc" }],
        });
    }
    /**
     * Lấy primary calendar của user
     */
    async findPrimaryByUserId(userId) {
        return prisma.calendar.findFirst({
            where: {
                userId,
                isPrimary: true,
            },
        });
    }
    /**
     * Cập nhật calendar
     */
    async update(id, data) {
        return prisma.calendar.update({
            where: { id },
            data,
        });
    }
    /**
     * Xóa calendar
     */
    async delete(id) {
        return prisma.calendar.delete({
            where: { id },
        });
    }
    /**
     * Set làm primary calendar (và unset các calendar khác)
     */
    async setPrimary(id, userId) {
        // Sử dụng transaction để đảm bảo data consistency
        return prisma.$transaction(async (tx) => {
            // Unset tất cả primary calendars của user
            await tx.calendar.updateMany({
                where: {
                    userId,
                    isPrimary: true,
                },
                data: {
                    isPrimary: false,
                },
            });
            // Set calendar này là primary
            return tx.calendar.update({
                where: { id },
                data: { isPrimary: true },
            });
        });
    }
    /**
     * Đếm số calendars của user
     */
    async countByUserId(userId) {
        return prisma.calendar.count({
            where: { userId },
        });
    }
    /**
     * Kiểm tra calendar có thuộc user không
     */
    async belongsToUser(id, userId) {
        const calendar = await prisma.calendar.findUnique({
            where: { id },
            select: { userId: true },
        });
        return calendar?.userId === userId;
    }
}
export default new CalendarRepository();
//# sourceMappingURL=calendar.repository.js.map