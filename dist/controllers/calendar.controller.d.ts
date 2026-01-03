import type { Request, Response } from "express";
/**
 * Create calendar
 * POST /api/calendars
 */
export declare const createCalendar: (req: Request, res: Response, next: import("express").NextFunction) => void;
/**
 * Get all calendars for current user
 * GET /api/calendars
 */
export declare const getUserCalendars: (req: Request, res: Response, next: import("express").NextFunction) => void;
/**
 * Get calendar by ID
 * GET /api/calendars/:id
 */
export declare const getCalendarById: (req: Request, res: Response, next: import("express").NextFunction) => void;
/**
 * Update calendar
 * PUT /api/calendars/:id
 */
export declare const updateCalendar: (req: Request, res: Response, next: import("express").NextFunction) => void;
/**
 * Delete calendar
 * DELETE /api/calendars/:id
 */
export declare const deleteCalendar: (req: Request, res: Response, next: import("express").NextFunction) => void;
/**
 * Set calendar as primary
 * POST /api/calendars/:id/primary
 */
export declare const setPrimaryCalendar: (req: Request, res: Response, next: import("express").NextFunction) => void;
//# sourceMappingURL=calendar.controller.d.ts.map