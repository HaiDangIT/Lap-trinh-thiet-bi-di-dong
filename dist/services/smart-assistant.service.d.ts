import { type SmartSuggestion, type TimeSlot, type ConflictInfo } from "../utils/smart-assistant.util.js";
declare class SmartAssistantService {
    /**
     * Analyze an event and provide smart suggestions
     */
    analyzeEvent(userId: string, eventData: {
        title: string;
        description?: string;
        startTime?: Date;
        location?: string;
    }): Promise<{
        category: any;
        suggestions: SmartSuggestion[];
        duration: any;
    }>;
    /**
     * Check for conflicts when creating/updating an event
     */
    checkConflicts(userId: string, calendarId: string, startTime: Date, endTime: Date, excludeEventId?: string): Promise<ConflictInfo>;
    /**
     * Find free time slots for scheduling
     */
    findFreeSlots(userId: string, calendarId: string, date: Date, duration: number, workingHoursStart?: number, workingHoursEnd?: number): Promise<TimeSlot[]>;
    /**
     * Suggest best time for an event
     */
    suggestBestTime(userId: string, calendarId: string, preferredDate: Date, duration: number, preferences?: {
        preferMorning?: boolean;
        preferAfternoon?: boolean;
        avoidLunchTime?: boolean;
    }): Promise<TimeSlot | null>;
    /**
     * Generate statistics for user's events
     */
    generateUserStats(userId: string, startDate: Date, endDate: Date): Promise<any>;
    /**
     * Generate insights from statistics
     */
    private generateInsights;
    /**
     * Auto-categorize all uncategorized events for a user
     */
    autoCategorizeEvents(userId: string): Promise<{
        categorized: number;
        categories: Record<string, number>;
    }>;
}
declare const _default: SmartAssistantService;
export default _default;
//# sourceMappingURL=smart-assistant.service.d.ts.map