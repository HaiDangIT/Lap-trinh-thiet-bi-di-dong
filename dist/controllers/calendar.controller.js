import calendarService from "../services/calendar.service.js";
import { successResponse } from "../utils/response.util.js";
import { asyncHandler } from "../midlewares/error.middleware.js";
/**
 * Create calendar
 * POST /api/calendars
 */
export const createCalendar = asyncHandler(async (req, res) => {
    const userId = req.userId;
    const calendar = await calendarService.createCalendar(userId, req.body);
    res
        .status(201)
        .json(successResponse(calendar, "Calendar created successfully"));
});
/**
 * Get all calendars for current user
 * GET /api/calendars
 */
export const getUserCalendars = asyncHandler(async (req, res) => {
    const userId = req.userId;
    const calendars = await calendarService.getUserCalendars(userId);
    res.json(successResponse(calendars));
});
/**
 * Get calendar by ID
 * GET /api/calendars/:id
 */
export const getCalendarById = asyncHandler(async (req, res) => {
    const userId = req.userId;
    const calendar = await calendarService.getCalendarById(req.params.id, userId);
    res.json(successResponse(calendar));
});
/**
 * Update calendar
 * PUT /api/calendars/:id
 */
export const updateCalendar = asyncHandler(async (req, res) => {
    const userId = req.userId;
    const calendar = await calendarService.updateCalendar(req.params.id, userId, req.body);
    res.json(successResponse(calendar, "Calendar updated successfully"));
});
/**
 * Delete calendar
 * DELETE /api/calendars/:id
 */
export const deleteCalendar = asyncHandler(async (req, res) => {
    const userId = req.userId;
    await calendarService.deleteCalendar(req.params.id, userId);
    res.json(successResponse(null, "Calendar deleted successfully"));
});
/**
 * Set calendar as primary
 * POST /api/calendars/:id/primary
 */
export const setPrimaryCalendar = asyncHandler(async (req, res) => {
    const userId = req.userId;
    const calendar = await calendarService.setPrimaryCalendar(req.params.id, userId);
    res.json(successResponse(calendar, "Primary calendar updated"));
});
//# sourceMappingURL=calendar.controller.js.map