import { type Calendar, Prisma } from "@prisma/client";
export declare class CalendarRepository {
    /**
     * Tạo calendar mới
     */
    create(data: Prisma.CalendarCreateInput): Promise<Calendar>;
    /**
     * Tìm calendar theo ID
     */
    findById(id: string): Promise<Calendar | null>;
    /**
     * Lấy tất cả calendars của user
     */
    findByUserId(userId: string): Promise<Calendar[]>;
    /**
     * Lấy primary calendar của user
     */
    findPrimaryByUserId(userId: string): Promise<Calendar | null>;
    /**
     * Cập nhật calendar
     */
    update(id: string, data: Prisma.CalendarUpdateInput): Promise<Calendar>;
    /**
     * Xóa calendar
     */
    delete(id: string): Promise<Calendar>;
    /**
     * Set làm primary calendar (và unset các calendar khác)
     */
    setPrimary(id: string, userId: string): Promise<Calendar>;
    /**
     * Đếm số calendars của user
     */
    countByUserId(userId: string): Promise<number>;
    /**
     * Kiểm tra calendar có thuộc user không
     */
    belongsToUser(id: string, userId: string): Promise<boolean>;
}
declare const _default: CalendarRepository;
export default _default;
//# sourceMappingURL=calendar.repository.d.ts.map