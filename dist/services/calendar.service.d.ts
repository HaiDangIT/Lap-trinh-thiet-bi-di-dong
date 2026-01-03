import { type Calendar } from "@prisma/client";
export interface CreateCalendarDto {
    name: string;
    colorCode?: string;
    isPrimary?: boolean;
}
export interface UpdateCalendarDto {
    name?: string;
    colorCode?: string;
    isPrimary?: boolean;
}
export declare class CalendarService {
    /**
     * Tạo calendar mới
     */
    createCalendar(userId: string, dto: CreateCalendarDto): Promise<Calendar>;
    /**
     * Lấy tất cả calendars của user
     */
    getUserCalendars(userId: string): Promise<Calendar[]>;
    /**
     * Lấy calendar theo ID
     */
    getCalendarById(id: string, userId: string): Promise<Calendar>;
    /**
     * Cập nhật calendar
     */
    updateCalendar(id: string, userId: string, dto: UpdateCalendarDto): Promise<Calendar>;
    /**
     * Xóa calendar
     */
    deleteCalendar(id: string, userId: string): Promise<void>;
    /**
     * Set calendar làm primary
     */
    setPrimaryCalendar(id: string, userId: string): Promise<Calendar>;
}
declare const _default: CalendarService;
export default _default;
//# sourceMappingURL=calendar.service.d.ts.map