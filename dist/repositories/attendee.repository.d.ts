import { type Attendee, Prisma } from "@prisma/client";
export declare class AttendeeRepository {
    /**
     * Tạo attendee mới
     */
    create(data: Prisma.AttendeeCreateInput): Promise<Attendee>;
    /**
     * Tạo nhiều attendees cùng lúc
     */
    createMany(data: Prisma.AttendeeCreateManyInput[]): Promise<number>;
    /**
     * Tìm attendee theo ID
     */
    findById(id: string): Promise<Attendee | null>;
    /**
     * Lấy attendees của event
     */
    findByEventId(eventId: string): Promise<Attendee[]>;
    /**
     * Lấy events mà user tham gia
     */
    findByUserId(userId: string): Promise<Attendee[]>;
    /**
     * Cập nhật status của attendee
     */
    updateStatus(id: string, responseStatus: string): Promise<Attendee>;
    /**
     * Cập nhật attendee
     */
    update(id: string, data: Prisma.AttendeeUpdateInput): Promise<Attendee>;
    /**
     * Xóa attendee
     */
    delete(id: string): Promise<Attendee>;
    /**
     * Xóa tất cả attendees của event
     */
    deleteByEventId(eventId: string): Promise<number>;
    /**
     * Kiểm tra user đã là attendee của event chưa
     */
    isAttendee(eventId: string, email: string): Promise<boolean>;
    /**
     * Lấy attendee theo event và email
     */
    findByEventAndEmail(eventId: string, email: string): Promise<Attendee | null>;
}
declare const _default: AttendeeRepository;
export default _default;
//# sourceMappingURL=attendee.repository.d.ts.map