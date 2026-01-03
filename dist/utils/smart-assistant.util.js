/**
 * Smart Event Assistant Utility
 * AI-powered features to help users manage events
 */
/**
 * Detect event category from title and description
 */
export function detectEventCategory(title, description) {
    const text = `${title} ${description || ""}`.toLowerCase();
    // Meeting patterns
    if (/meeting|họp|conference|call|zoom|teams|discussion/i.test(text)) {
        return {
            category: "Meeting",
            icon: "👥",
            color: "#4285F4",
            confidence: 0.9,
        };
    }
    // Work patterns
    if (/work|làm việc|project|task|deadline|sprint|review/i.test(text)) {
        return {
            category: "Work",
            icon: "💼",
            color: "#F4B400",
            confidence: 0.85,
        };
    }
    // Travel patterns
    if (/flight|bay|travel|trip|du lịch|đi|airport|hotel|booking/i.test(text)) {
        return {
            category: "Travel",
            icon: "✈️",
            color: "#0F9D58",
            confidence: 0.95,
        };
    }
    // Health patterns
    if (/doctor|dentist|hospital|bác sĩ|khám|health|medical|checkup/i.test(text)) {
        return {
            category: "Health",
            icon: "🏥",
            color: "#DB4437",
            confidence: 0.9,
        };
    }
    // Education patterns
    if (/class|học|study|exam|course|lesson|training|workshop/i.test(text)) {
        return {
            category: "Education",
            icon: "📚",
            color: "#9C27B0",
            confidence: 0.85,
        };
    }
    // Sports patterns
    if (/gym|workout|exercise|sport|football|yoga|fitness|run/i.test(text)) {
        return {
            category: "Sports",
            icon: "⚽",
            color: "#FF6D00",
            confidence: 0.8,
        };
    }
    // Birthday/Celebration patterns
    if (/birthday|sinh nhật|party|celebration|anniversary|wedding/i.test(text)) {
        return {
            category: "Celebration",
            icon: "🎉",
            color: "#E91E63",
            confidence: 0.95,
        };
    }
    // Food patterns
    if (/lunch|dinner|breakfast|ăn|restaurant|food|café/i.test(text)) {
        return {
            category: "Food",
            icon: "🍽️",
            color: "#FF5722",
            confidence: 0.85,
        };
    }
    // Entertainment patterns
    if (/movie|concert|show|entertainment|cinema|theater|game/i.test(text)) {
        return {
            category: "Entertainment",
            icon: "🎬",
            color: "#3F51B5",
            confidence: 0.8,
        };
    }
    // Default
    return {
        category: "Other",
        icon: "📅",
        color: "#607D8B",
        confidence: 0.5,
    };
}
/**
 * Generate smart suggestions for an event
 */
export function generateSmartSuggestions(title, description, startTime, location) {
    const suggestions = [];
    const text = `${title} ${description || ""}`.toLowerCase();
    // Category suggestion
    const category = detectEventCategory(title, description);
    if (category.confidence > 0.7) {
        suggestions.push({
            type: "category",
            suggestion: `${category.icon} ${category.category}`,
            confidence: category.confidence,
            reason: `Detected as ${category.category} event`,
        });
    }
    // Reminder suggestions based on event type
    if (/flight|bay|airport/i.test(text)) {
        suggestions.push({
            type: "reminder",
            suggestion: "Set reminder 2 hours before (for airport check-in)",
            confidence: 0.9,
            reason: "Travel events need early preparation",
        });
    }
    else if (/meeting|họp/i.test(text)) {
        suggestions.push({
            type: "reminder",
            suggestion: "Set reminder 15 minutes before",
            confidence: 0.85,
            reason: "Standard meeting reminder",
        });
    }
    else if (/doctor|dentist|bác sĩ/i.test(text)) {
        suggestions.push({
            type: "reminder",
            suggestion: "Set reminder 1 day before + 1 hour before",
            confidence: 0.9,
            reason: "Medical appointments often need confirmation",
        });
    }
    // Location suggestions
    if (/zoom|teams|meet|online/i.test(text) && !location) {
        suggestions.push({
            type: "location",
            suggestion: "Online Meeting",
            confidence: 0.95,
            reason: "Detected online meeting keywords",
        });
    }
    // Time suggestions
    if (startTime) {
        const hour = startTime.getHours();
        if (hour < 7 && /meeting|họp/i.test(text)) {
            suggestions.push({
                type: "time",
                suggestion: "Consider scheduling after 9 AM for better attendance",
                confidence: 0.75,
                reason: "Early morning meetings have lower attendance",
            });
        }
        if (hour > 18 && /work|meeting|họp/i.test(text)) {
            suggestions.push({
                type: "time",
                suggestion: "Consider scheduling during business hours",
                confidence: 0.7,
                reason: "Evening meetings may conflict with personal time",
            });
        }
    }
    return suggestions;
}
/**
 * Find free time slots in a given date range
 */
export function findFreeTimeSlots(existingEvents, searchDate, duration, // in minutes
workingHoursStart = 9, // 9 AM
workingHoursEnd = 18 // 6 PM
) {
    const freeSlots = [];
    // Sort events by start time
    const sortedEvents = [...existingEvents].sort((a, b) => a.start.getTime() - b.start.getTime());
    // Start of working hours
    const dayStart = new Date(searchDate);
    dayStart.setHours(workingHoursStart, 0, 0, 0);
    // End of working hours
    const dayEnd = new Date(searchDate);
    dayEnd.setHours(workingHoursEnd, 0, 0, 0);
    let currentTime = dayStart;
    for (const event of sortedEvents) {
        // If there's a gap before this event
        if (event.start > currentTime) {
            const gapDuration = (event.start.getTime() - currentTime.getTime()) / (1000 * 60);
            if (gapDuration >= duration) {
                freeSlots.push({
                    start: new Date(currentTime),
                    end: new Date(event.start),
                    duration: Math.floor(gapDuration),
                });
            }
        }
        // Move current time to after this event
        if (event.end > currentTime) {
            currentTime = new Date(event.end);
        }
    }
    // Check for time after last event
    if (currentTime < dayEnd) {
        const gapDuration = (dayEnd.getTime() - currentTime.getTime()) / (1000 * 60);
        if (gapDuration >= duration) {
            freeSlots.push({
                start: new Date(currentTime),
                end: new Date(dayEnd),
                duration: Math.floor(gapDuration),
            });
        }
    }
    return freeSlots;
}
/**
 * Detect scheduling conflicts
 */
export function detectConflicts(newEventStart, newEventEnd, existingEvents) {
    const conflicts = existingEvents.filter((event) => {
        // Check if events overlap
        return ((newEventStart >= event.start && newEventStart < event.end) ||
            (newEventEnd > event.start && newEventEnd <= event.end) ||
            (newEventStart <= event.start && newEventEnd >= event.end));
    });
    return {
        hasConflict: conflicts.length > 0,
        conflictingEvents: conflicts,
    };
}
/**
 * Suggest best time for an event based on existing events
 */
export function suggestBestTime(existingEvents, preferredDate, duration, // in minutes
preferences) {
    const freeSlots = findFreeTimeSlots(existingEvents, preferredDate, duration);
    if (freeSlots.length === 0) {
        return null;
    }
    // Apply preferences
    let filteredSlots = freeSlots;
    if (preferences?.preferMorning) {
        filteredSlots = freeSlots.filter((slot) => slot.start.getHours() < 12);
    }
    if (preferences?.preferAfternoon) {
        filteredSlots = freeSlots.filter((slot) => slot.start.getHours() >= 13);
    }
    if (preferences?.avoidLunchTime) {
        filteredSlots = freeSlots.filter((slot) => slot.start.getHours() < 11 || slot.start.getHours() >= 14);
    }
    // Return the first suitable slot (or fallback to any free slot)
    const result = filteredSlots.length > 0 ? filteredSlots[0] : freeSlots[0];
    return result || null;
}
/**
 * Calculate optimal event duration based on type
 */
export function suggestEventDuration(title, description) {
    const text = `${title} ${description || ""}`.toLowerCase();
    if (/standup|daily/i.test(text)) {
        return {
            duration: 15,
            reason: "Daily standup meetings are typically 15 minutes",
        };
    }
    if (/1-on-1|one on one/i.test(text)) {
        return { duration: 30, reason: "1-on-1 meetings are usually 30 minutes" };
    }
    if (/review|retrospective/i.test(text)) {
        return { duration: 60, reason: "Review meetings typically need 1 hour" };
    }
    if (/workshop|training/i.test(text)) {
        return { duration: 120, reason: "Workshops usually last 2 hours" };
    }
    if (/lunch|ăn trưa/i.test(text)) {
        return { duration: 60, reason: "Standard lunch duration" };
    }
    if (/doctor|dentist/i.test(text)) {
        return {
            duration: 30,
            reason: "Medical appointments typically 30 minutes",
        };
    }
    // Default
    return { duration: 60, reason: "Standard meeting duration" };
}
/**
 * Generate event summary statistics
 */
export function generateEventStats(events) {
    const stats = {
        totalEvents: events.length,
        totalHours: 0,
        categoryBreakdown: {},
        busiestDay: "",
        averageEventDuration: 0,
    };
    const dayCount = {};
    let totalDuration = 0;
    for (const event of events) {
        // Calculate duration
        const duration = (event.end.getTime() - event.start.getTime()) / (1000 * 60 * 60);
        totalDuration += duration;
        // Category breakdown
        const category = detectEventCategory(event.title, event.description);
        stats.categoryBreakdown[category.category] =
            (stats.categoryBreakdown[category.category] || 0) + 1;
        // Day count
        const dayKey = event.start.toLocaleDateString();
        dayCount[dayKey] = (dayCount[dayKey] || 0) + 1;
    }
    stats.totalHours = Math.round(totalDuration * 10) / 10;
    stats.averageEventDuration =
        events.length > 0 ? Math.round((totalDuration / events.length) * 60) : 0;
    // Find busiest day
    let maxCount = 0;
    for (const [day, count] of Object.entries(dayCount)) {
        if (count > maxCount) {
            maxCount = count;
            stats.busiestDay = day;
        }
    }
    return stats;
}
//# sourceMappingURL=smart-assistant.util.js.map