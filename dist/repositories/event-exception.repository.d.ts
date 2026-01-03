import { type EventException, Prisma } from "@prisma/client";
export declare class EventExceptionRepository {
    /**
     * Tạo exception mới
     */
    create(data: Prisma.EventExceptionCreateInput): Promise<EventException>;
    /**
     * Tìm exception theo ID
     */
    findById(id: string): Promise<EventException | null>;
    /**
     * Lấy exceptions của event
     */
    findByEventId(eventId: string): Promise<EventException[]>;
    /**
     * Tìm exception cho một occurrence cụ thể
     */
    findByEventAndDate(eventId: string, originalStartTime: Date): Promise<EventException | null>;
    /**
     * Cập nhật exception
     */
    update(id: string, data: Prisma.EventExceptionUpdateInput): Promise<EventException>;
    /**
     * Xóa exception
     */
    delete(id: string): Promise<EventException>;
    /**
     * Xóa tất cả exceptions của event
     */
    deleteByEventId(eventId: string): Promise<number>;
    /**
     * Kiểm tra có exception cho date này không
     */
    hasException(eventId: string, originalStartTime: Date): Promise<boolean>;
}
declare const _default: EventExceptionRepository;
export default _default;
//# sourceMappingURL=event-exception.repository.d.ts.map