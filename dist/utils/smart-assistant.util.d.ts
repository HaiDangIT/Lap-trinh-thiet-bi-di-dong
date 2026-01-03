/**
 * Smart Event Assistant Utility
 * AI-powered features to help users manage events
 */
export interface EventCategory {
    category: string;
    icon: string;
    color: string;
    confidence: number;
}
export interface SmartSuggestion {
    type: "category" | "time" | "location" | "reminder";
    suggestion: string;
    confidence: number;
    reason?: string;
}
export interface TimeSlot {
    start: Date;
    end: Date;
    duration: number;
}
export interface ConflictInfo {
    hasConflict: boolean;
    conflictingEvents: Array<{
        id: string;
        title: string;
        start: Date;
        end: Date;
    }>;
}
/**
 * Detect event category from title and description
 */
export declare function detectEventCategory(title: string, description?: string): EventCategory;
/**
 * Generate smart suggestions for an event
 */
export declare function generateSmartSuggestions(title: string, description?: string, startTime?: Date, location?: string): SmartSuggestion[];
/**
 * Find free time slots in a given date range
 */
export declare function findFreeTimeSlots(existingEvents: Array<{
    start: Date;
    end: Date;
}>, searchDate: Date, duration: number, // in minutes
workingHoursStart?: number, // 9 AM
workingHoursEnd?: number): TimeSlot[];
/**
 * Detect scheduling conflicts
 */
export declare function detectConflicts(newEventStart: Date, newEventEnd: Date, existingEvents: Array<{
    id: string;
    title: string;
    start: Date;
    end: Date;
}>): ConflictInfo;
/**
 * Suggest best time for an event based on existing events
 */
export declare function suggestBestTime(existingEvents: Array<{
    start: Date;
    end: Date;
}>, preferredDate: Date, duration: number, // in minutes
preferences?: {
    preferMorning?: boolean;
    preferAfternoon?: boolean;
    avoidLunchTime?: boolean;
}): TimeSlot | null;
/**
 * Calculate optimal event duration based on type
 */
export declare function suggestEventDuration(title: string, description?: string): {
    duration: number;
    reason: string;
};
/**
 * Generate event summary statistics
 */
export declare function generateEventStats(events: Array<{
    title: string;
    description?: string;
    start: Date;
    end: Date;
}>): {
    totalEvents: number;
    totalHours: number;
    categoryBreakdown: Record<string, number>;
    busiestDay: string;
    averageEventDuration: number;
};
//# sourceMappingURL=smart-assistant.util.d.ts.map