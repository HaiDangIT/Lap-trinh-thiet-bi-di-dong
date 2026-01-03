import smartAssistantService from "../services/smart-assistant.service.js";
import { successResponse } from "../utils/response.util.js";
import { asyncHandler } from "../midlewares/error.middleware.js";
/**
 * Analyze event and get smart suggestions
 * POST /api/smart/analyze-event
 */
export const analyzeEvent = asyncHandler(async (req, res) => {
    const userId = req.userId;
    const { title, description, startTime, location } = req.body;
    const eventData = {
        title,
        description,
        location,
        ...(startTime && { startTime: new Date(startTime) }),
    };
    const analysis = await smartAssistantService.analyzeEvent(userId, eventData);
    res.json(successResponse(analysis, "Event analyzed successfully. Here are smart suggestions!"));
});
/**
 * Check for scheduling conflicts
 * POST /api/smart/check-conflicts
 */
export const checkConflicts = asyncHandler(async (req, res) => {
    const userId = req.userId;
    const { calendarId, startTime, endTime, excludeEventId } = req.body;
    const conflicts = await smartAssistantService.checkConflicts(userId, calendarId, new Date(startTime), new Date(endTime), excludeEventId);
    res.json(successResponse(conflicts, conflicts.hasConflict
        ? "Conflict detected! See conflicting events below."
        : "No conflicts found. You're good to schedule!"));
});
/**
 * Find free time slots
 * POST /api/smart/find-free-slots
 */
export const findFreeSlots = asyncHandler(async (req, res) => {
    const userId = req.userId;
    const { calendarId, date, duration, workingHoursStart, workingHoursEnd } = req.body;
    const freeSlots = await smartAssistantService.findFreeSlots(userId, calendarId, new Date(date), duration, workingHoursStart, workingHoursEnd);
    res.json(successResponse({ freeSlots, count: freeSlots.length }, `Found ${freeSlots.length} free time slot(s)`));
});
/**
 * Suggest best time for an event
 * POST /api/smart/suggest-time
 */
export const suggestBestTime = asyncHandler(async (req, res) => {
    const userId = req.userId;
    const { calendarId, preferredDate, duration, preferences } = req.body;
    const suggestion = await smartAssistantService.suggestBestTime(userId, calendarId, new Date(preferredDate), duration, preferences);
    if (suggestion) {
        res.json(successResponse(suggestion, "Best time slot found! Consider scheduling at this time."));
    }
    else {
        res.json(successResponse(null, "No suitable time slots found. Try a different date."));
    }
});
/**
 * Generate user statistics and insights
 * GET /api/smart/user-stats
 */
export const getUserStats = asyncHandler(async (req, res) => {
    const userId = req.userId;
    const { startDate, endDate } = req.query;
    // Default to last 30 days if not specified
    const end = endDate ? new Date(endDate) : new Date();
    const start = startDate
        ? new Date(startDate)
        : new Date(end.getTime() - 30 * 24 * 60 * 60 * 1000);
    const stats = await smartAssistantService.generateUserStats(userId, start, end);
    res.json(successResponse(stats, "Here's your time analytics and insights!"));
});
/**
 * Auto-categorize user's events
 * POST /api/smart/auto-categorize
 */
export const autoCategorizeEvents = asyncHandler(async (req, res) => {
    const userId = req.userId;
    const result = await smartAssistantService.autoCategorizeEvents(userId);
    res.json(successResponse(result, `AI analyzed ${result.categorized} events and suggested categories!`));
});
//# sourceMappingURL=smart-assistant.controller.js.map