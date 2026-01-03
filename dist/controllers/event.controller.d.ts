import type { Request, Response } from "express";
/**
 * Create event
 * POST /api/events
 */
export declare const createEvent: (req: Request, res: Response, next: import("express").NextFunction) => void;
/**
 * Get event by ID
 * GET /api/events/:id
 */
export declare const getEventById: (req: Request, res: Response, next: import("express").NextFunction) => void;
/**
 * Get events in time range
 * GET /api/events/range?startTime=...&endTime=...&calendarId=...
 */
export declare const getEventsInRange: (req: Request, res: Response, next: import("express").NextFunction) => void;
/**
 * Update event
 * PUT /api/events/:id
 */
export declare const updateEvent: (req: Request, res: Response, next: import("express").NextFunction) => void;
/**
 * Update recurring occurrence
 * PUT /api/events/:id/occurrence
 */
export declare const updateRecurringOccurrence: (req: Request, res: Response, next: import("express").NextFunction) => void;
/**
 * Delete event
 * DELETE /api/events/:id
 */
export declare const deleteEvent: (req: Request, res: Response, next: import("express").NextFunction) => void;
/**
 * Search events
 * GET /api/events/search?q=...&page=1&pageSize=20
 */
export declare const searchEvents: (req: Request, res: Response, next: import("express").NextFunction) => void;
/**
 * Get upcoming events
 * GET /api/events/upcoming?limit=10
 */
export declare const getUpcomingEvents: (req: Request, res: Response, next: import("express").NextFunction) => void;
//# sourceMappingURL=event.controller.d.ts.map