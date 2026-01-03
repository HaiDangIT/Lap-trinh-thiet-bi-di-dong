import eventService from "../services/event.service.js";
import { successResponse } from "../utils/response.util.js";
import { asyncHandler } from "../midlewares/error.middleware.js";
/**
 * Create event
 * POST /api/events
 */
export const createEvent = asyncHandler(async (req, res) => {
    const userId = req.userId;
    const event = await eventService.createEvent(userId, req.body);
    res.status(201).json(successResponse(event, "Event created successfully"));
});
/**
 * Get event by ID
 * GET /api/events/:id
 */
export const getEventById = asyncHandler(async (req, res) => {
    const userId = req.userId;
    const event = await eventService.getEventById(req.params.id, userId);
    res.json(successResponse(event));
});
/**
 * Get events in time range
 * GET /api/events/range?startTime=...&endTime=...&calendarId=...
 */
export const getEventsInRange = asyncHandler(async (req, res) => {
    const userId = req.userId;
    const startTime = new Date(req.query.startTime);
    const endTime = new Date(req.query.endTime);
    const calendarId = req.query.calendarId;
    const events = await eventService.getEventsInRange(userId, startTime, endTime, calendarId);
    res.json(successResponse(events));
});
/**
 * Update event
 * PUT /api/events/:id
 */
export const updateEvent = asyncHandler(async (req, res) => {
    const userId = req.userId;
    const event = await eventService.updateEvent(req.params.id, userId, req.body);
    res.json(successResponse(event, "Event updated successfully"));
});
/**
 * Update recurring occurrence
 * PUT /api/events/:id/occurrence
 */
export const updateRecurringOccurrence = asyncHandler(async (req, res) => {
    const userId = req.userId;
    await eventService.updateRecurringOccurrence(req.params.id, userId, req.body);
    res.json(successResponse(null, "Occurrence updated successfully"));
});
/**
 * Delete event
 * DELETE /api/events/:id
 */
export const deleteEvent = asyncHandler(async (req, res) => {
    const userId = req.userId;
    await eventService.deleteEvent(req.params.id, userId);
    res.json(successResponse(null, "Event deleted successfully"));
});
/**
 * Search events
 * GET /api/events/search?q=...&page=1&pageSize=20
 */
export const searchEvents = asyncHandler(async (req, res) => {
    const userId = req.userId;
    const query = req.query.q;
    const page = parseInt(req.query.page) || 1;
    const pageSize = parseInt(req.query.pageSize) || 20;
    const result = await eventService.searchEvents(userId, query, page, pageSize);
    res.json(successResponse(result));
});
/**
 * Get upcoming events
 * GET /api/events/upcoming?limit=10
 */
export const getUpcomingEvents = asyncHandler(async (req, res) => {
    const userId = req.userId;
    const limit = parseInt(req.query.limit) || 10;
    const events = await eventService.getUpcomingEvents(userId, limit);
    res.json(successResponse(events));
});
//# sourceMappingURL=event.controller.js.map