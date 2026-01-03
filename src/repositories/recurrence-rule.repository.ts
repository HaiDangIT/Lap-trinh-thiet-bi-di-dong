import { type RecurrenceRule, Prisma } from "@prisma/client";
import prisma from "../config/database.config.js";

export class RecurrenceRuleRepository {
  /**
   * Tạo recurrence rule mới
   */
  async create(
    data: Prisma.RecurrenceRuleCreateInput
  ): Promise<RecurrenceRule> {
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
  async findById(id: string): Promise<RecurrenceRule | null> {
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
  async findByEventId(eventId: string): Promise<RecurrenceRule | null> {
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
  async update(
    id: string,
    data: Prisma.RecurrenceRuleUpdateInput
  ): Promise<RecurrenceRule> {
    return prisma.recurrenceRule.update({
      where: { id },
      data,
    });
  }

  /**
   * Xóa recurrence rule
   */
  async delete(id: string): Promise<RecurrenceRule> {
    return prisma.recurrenceRule.delete({
      where: { id },
    });
  }

  /**
   * Xóa recurrence rule theo event ID
   */
  async deleteByEventId(eventId: string): Promise<RecurrenceRule | null> {
    try {
      return await prisma.recurrenceRule.delete({
        where: { eventId },
      });
    } catch {
      return null;
    }
  }
}

export default new RecurrenceRuleRepository();
