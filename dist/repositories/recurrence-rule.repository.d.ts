import { type RecurrenceRule, Prisma } from "@prisma/client";
export declare class RecurrenceRuleRepository {
    /**
     * Tạo recurrence rule mới
     */
    create(data: Prisma.RecurrenceRuleCreateInput): Promise<RecurrenceRule>;
    /**
     * Tìm recurrence rule theo ID
     */
    findById(id: string): Promise<RecurrenceRule | null>;
    /**
     * Tìm recurrence rule theo event ID
     */
    findByEventId(eventId: string): Promise<RecurrenceRule | null>;
    /**
     * Cập nhật recurrence rule
     */
    update(id: string, data: Prisma.RecurrenceRuleUpdateInput): Promise<RecurrenceRule>;
    /**
     * Xóa recurrence rule
     */
    delete(id: string): Promise<RecurrenceRule>;
    /**
     * Xóa recurrence rule theo event ID
     */
    deleteByEventId(eventId: string): Promise<RecurrenceRule | null>;
}
declare const _default: RecurrenceRuleRepository;
export default _default;
//# sourceMappingURL=recurrence-rule.repository.d.ts.map