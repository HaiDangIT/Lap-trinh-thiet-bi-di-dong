import { type Event } from "@prisma/client";
import { type RecurrenceOptions } from "../utils/rrule.util.js";
type EventWithRelations = Event & {
    calendar: {
        id: string;
        name: string;
        userId: string;
        user: {
            id: string;
            email: string;
            fullName: string | null;
        };
    };
    creator: {
        id: string;
        email: string;
        fullName: string | null;
    };
    recurrenceRule: {
        id: string;
        frequency: string;
        interval: number;
        byDay: string | null;
        byMonthDay: string | null;
        byMonth: string | null;
        untilDate: Date | null;
        count: number | null;
    } | null;
    attendees: Array<{
        id: string;
        email: string;
        name: string | null;
        responseStatus: string;
    }>;
    reminders: Array<{
        id: string;
        minutesBefore: number;
        method: string;
    }>;
    exceptions: Array<{
        id: string;
        originalStartTime: Date;
        newStartTime: Date | null;
        newEndTime: Date | null;
        updatedTitle: string | null;
        updatedLocation: string | null;
        isCancelled: boolean;
    }>;
};
export interface CreateEventDto {
    calendarId: string;
    title: string;
    description?: string;
    location?: string;
    startTime: Date;
    endTime: Date;
    isAllDay?: boolean;
    isRecurring?: boolean;
    recurrenceRule?: RecurrenceOptions;
    attendees?: Array<{
        email: string;
        displayName?: string;
        isOrganizer?: boolean;
    }>;
    reminders?: Array<{
        minutesBefore: number;
        method?: string;
    }>;
    checkConflicts?: boolean;
}
export interface UpdateEventDto {
    title?: string;
    description?: string;
    location?: string;
    startTime?: Date;
    endTime?: Date;
    isAllDay?: boolean;
    updateType?: "single" | "thisAndFuture" | "all";
}
export interface UpdateRecurringOccurrenceDto {
    originalStartTime: Date;
    newStartTime?: Date;
    newEndTime?: Date;
    updatedTitle?: string;
    updatedLocation?: string;
    isCancelled?: boolean;
}
export declare class EventService {
    /**
     * Tạo event mới
     */
    createEvent(userId: string, dto: CreateEventDto): Promise<Event>;
    /**
     * Lấy event theo ID
     */
    getEventById(id: string, userId: string): Promise<EventWithRelations>;
    /**
     * Lấy events trong khoảng thời gian
     */
    getEventsInRange(userId: string, startTime: Date, endTime: Date, calendarId?: string): Promise<Event[]>;
    /**
     * Cập nhật event
     */
    updateEvent(id: string, userId: string, dto: UpdateEventDto): Promise<Event>;
    /**
     * Update một occurrence của recurring event
     */
    updateRecurringOccurrence(eventId: string, userId: string, dto: UpdateRecurringOccurrenceDto): Promise<void>;
    /**
     * Xóa event
     */
    deleteEvent(id: string, userId: string): Promise<void>;
    /**
     * Tìm kiếm events
     */
    searchEvents(userId: string, query: string, page?: number, pageSize?: number): Promise<{
        events: {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            title: string;
            description: string | null;
            location: string | null;
            startTime: Date;
            endTime: Date;
            isAllDay: boolean;
            isRecurring: boolean;
            calendarId: string;
            creatorId: string;
        }[];
        page: number;
        pageSize: number;
    }>;
    /**
     * Lấy upcoming events
     */
    getUpcomingEvents(userId: string, limit?: number): Promise<Event[]>;
}
declare const _default: EventService;
export default _default;
//# sourceMappingURL=event.service.d.ts.map