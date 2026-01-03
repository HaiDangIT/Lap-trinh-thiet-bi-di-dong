import { type Reminder, Prisma } from "@prisma/client";
export declare class ReminderRepository {
    /**
     * Tạo reminder mới
     */
    create(data: Prisma.ReminderCreateInput): Promise<Reminder>;
    /**
     * Tạo nhiều reminders cùng lúc
     */
    createMany(data: Prisma.ReminderCreateManyInput[]): Promise<number>;
    /**
     * Tìm reminder theo ID
     */
    findById(id: string): Promise<Reminder | null>;
    /**
     * Lấy reminders của event
     */
    findByEventId(eventId: string): Promise<Reminder[]>;
    /**
     * Lấy reminders cần trigger trong X phút tới
     */
    findUpcoming(minutesAhead?: number): Promise<Reminder[]>;
    /**
     * Cập nhật reminder
     */
    update(id: string, data: Prisma.ReminderUpdateInput): Promise<Reminder>;
    /**
     * Xóa reminder
     */
    delete(id: string): Promise<Reminder>;
    /**
     * Xóa tất cả reminders của event
     */
    deleteByEventId(eventId: string): Promise<number>;
}
declare const _default: ReminderRepository;
export default _default;
//# sourceMappingURL=reminder.repository.d.ts.map