import { Prisma } from "@prisma/client";
import prisma from "../config/database.config.js";
export class RecurrenceRuleRepository {
    /**
     * Tạo recurrence rule mới
     */
    async create(data) {
        return prisma.recurrenceRule.create({
            data,
            include: {
                event: true,
            },
        });
    }
    /**
     * Tìm recurrence rule theo ID
     */
    async findById(id) {
        return prisma.recurrenceRule.findUnique({
            where: { id },
            include: {
                event: true,
            },
        });
    }
    /**
     * Tìm recurrence rule theo event ID
     */
    async findByEventId(eventId) {
        return prisma.recurrenceRule.findUnique({
            where: { eventId },
            include: {
                event: true,
            },
        });
    }
    /**
     * Cập nhật recurrence rule
     */
    async update(id, data) {
        return prisma.recurrenceRule.update({
            where: { id },
            data,
        });
    }
    /**
     * Xóa recurrence rule
     */
    async delete(id) {
        return prisma.recurrenceRule.delete({
            where: { id },
        });
    }
    /**
     * Xóa recurrence rule theo event ID
     */
    async deleteByEventId(eventId) {
        try {
            return await prisma.recurrenceRule.delete({
                where: { eventId },
            });
        }
        catch {
            return null;
        }
    }
}
export default new RecurrenceRuleRepository();
//# sourceMappingURL=recurrence-rule.repository.js.map