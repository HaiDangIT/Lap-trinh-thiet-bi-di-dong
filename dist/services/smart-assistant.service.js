import eventRepository from "../repositories/event.repository.js";
import { detectEventCategory, generateSmartSuggestions, findFreeTimeSlots, detectConflicts, suggestBestTime, suggestEventDuration, generateEventStats, } from "../utils/smart-assistant.util.js";
import { NotFoundError } from "../utils/errors.js";
class SmartAssistantService {
    /**
     * Analyze an event and provide smart suggestions
     */
    async analyzeEvent(userId, eventData) {
        const { title, description, startTime, location } = eventData;
        // Detect category
        const category = detectEventCategory(title, description);
        // Generate suggestions
        const suggestions = generateSmartSuggestions(title, description, startTime, location);
        // Suggest duration
        const duration = suggestEventDuration(title, description);
        return {
            category,
            suggestions,
            duration,
        };
    }
    /**
     * Check for conflicts when creating/updating an event
     */
    async checkConflicts(userId, calendarId, startTime, endTime, excludeEventId) {
        // Get user's events in that calendar
        const events = await eventRepository.findByCalendarAndDateRange(calendarId, startTime, endTime);
        // Filter out the event being updated
        const existingEvents = events
            .filter((e) => e.id !== excludeEventId)
            .map((e) => ({
            id: e.id,
            title: e.title,
            start: e.startTime,
            end: e.endTime,
        }));
        return detectConflicts(startTime, endTime, existingEvents);
    }
    /**
     * Find free time slots for scheduling
     */
    async findFreeSlots(userId, calendarId, date, duration, workingHoursStart, workingHoursEnd) {
        const dayStart = new Date(date);
        dayStart.setHours(0, 0, 0, 0);
        const dayEnd = new Date(date);
        dayEnd.setHours(23, 59, 59, 999);
        // Get all events for that day
        const events = await eventRepository.findByCalendarAndDateRange(calendarId, dayStart, dayEnd);
        const existingEvents = events.map((e) => ({
            start: e.startTime,
            end: e.endTime,
        }));
        return findFreeTimeSlots(existingEvents, date, duration, workingHoursStart, workingHoursEnd);
    }
    /**
     * Suggest best time for an event
     */
    async suggestBestTime(userId, calendarId, preferredDate, duration, preferences) {
        const dayStart = new Date(preferredDate);
        dayStart.setHours(0, 0, 0, 0);
        const dayEnd = new Date(preferredDate);
        dayEnd.setHours(23, 59, 59, 999);
        // Get all events for that day
        const events = await eventRepository.findByCalendarAndDateRange(calendarId, dayStart, dayEnd);
        const existingEvents = events.map((e) => ({
            start: e.startTime,
            end: e.endTime,
        }));
        return suggestBestTime(existingEvents, preferredDate, duration, preferences);
    }
    /**
     * Generate statistics for user's events
     */
    async generateUserStats(userId, startDate, endDate) {
        // Get all user's events in date range
        const events = await eventRepository.findByCreatorAndDateRange(userId, startDate, endDate);
        const eventData = events.map((e) => ({
            title: e.title,
            ...(e.description && { description: e.description }),
            start: e.startTime,
            end: e.endTime,
        }));
        const stats = generateEventStats(eventData);
        return {
            ...stats,
            period: {
                start: startDate,
                end: endDate,
            },
            insights: this.generateInsights(stats),
        };
    }
    /**
     * Generate insights from statistics
     */
    generateInsights(stats) {
        const insights = [];
        // Total hours insight
        if (stats.totalHours > 40) {
            insights.push(`You have ${stats.totalHours} hours of events. Consider if you're over-scheduled.`);
        }
        else if (stats.totalHours < 10) {
            insights.push(`You have ${stats.totalHours} hours of events. You have plenty of free time.`);
        }
        // Category insights
        const topCategory = Object.entries(stats.categoryBreakdown).sort(([, a], [, b]) => b - a)[0];
        if (topCategory) {
            const [category, count] = topCategory;
            const percentage = (count / stats.totalEvents) * 100;
            insights.push(`${Math.round(percentage)}% of your events are ${category}-related.`);
        }
        // Average duration insight
        if (stats.averageEventDuration > 120) {
            insights.push(`Your average event is ${stats.averageEventDuration} minutes. Consider breaking longer meetings into shorter sessions.`);
        }
        // Busiest day
        if (stats.busiestDay) {
            insights.push(`Your busiest day is ${stats.busiestDay}.`);
        }
        return insights;
    }
    /**
     * Auto-categorize all uncategorized events for a user
     */
    async autoCategorizeEvents(userId) {
        // This would update events with detected categories
        // For now, just return analysis
        const events = await eventRepository.findByCreator(userId);
        const categories = {};
        let categorized = 0;
        for (const event of events) {
            const category = detectEventCategory(event.title, event.description || undefined);
            if (category.confidence > 0.7) {
                categories[category.category] =
                    (categories[category.category] || 0) + 1;
                categorized++;
            }
        }
        return {
            categorized,
            categories,
        };
    }
}
export default new SmartAssistantService();
//# sourceMappingURL=smart-assistant.service.js.map