import { type Event, Prisma } from "@prisma/client";
export interface EventFilters {
    calendarId?: string;
    creatorId?: string;
    startTime?: Date;
    endTime?: Date;
    search?: string;
    isRecurring?: boolean;
}
export declare class EventRepository {
    /**
     * Tạo event mới (với recurrence rule, attendees, reminders)
     */
    create(data: Prisma.EventCreateInput): Promise<Event>;
    /**
     * Tìm event theo ID
     */
    findById(id: string): Promise<Event | null>;
    /**
     * Lấy events trong khoảng thời gian
     */
    findInRange(startTime: Date, endTime: Date, filters?: EventFilters): Promise<Event[]>;
    /**
     * Lấy events của một calendar
     */
    findByCalendarId(calendarId: string, skip?: number, take?: number): Promise<Event[]>;
    /**
     * Lấy upcoming events của user
     */
    findUpcomingByUserId(userId: string, limit?: number): Promise<Event[]>;
    /**
     * Tìm kiếm events
     */
    search(userId: string, query: string, skip?: number, take?: number): Promise<Event[]>;
    /**
     * Cập nhật event
     */
    update(id: string, data: Prisma.EventUpdateInput): Promise<Event>;
    /**
     * Xóa event
     */
    delete(id: string): Promise<Event>;
    /**
     * Đếm events theo filter
     */
    count(filters?: EventFilters): Promise<number>;
    /**
     * Kiểm tra event conflict (trùng thời gian)
     */
    findConflicts(calendarId: string, startTime: Date, endTime: Date, excludeEventId?: string): Promise<Event[]>;
    /**
     * Find events by calendar and date range (for Smart Assistant)
     */
    findByCalendarAndDateRange(calendarId: string, startTime: Date, endTime: Date): Promise<Event[]>;
    /**
     * Find events by creator and date range (for statistics)
     */
    findByCreatorAndDateRange(creatorId: string, startTime: Date, endTime: Date): Promise<Event[]>;
    /**
     * Find all events by creator (for auto-categorization)
     */
    findByCreator(creatorId: string): Promise<Event[]>;
}
declare const _default: EventRepository;
export default _default;
//# sourceMappingURL=event.repository.d.ts.map