import type { Request, Response, NextFunction } from "express";
/**
 * Analyze event and get smart suggestions
 * POST /api/smart/analyze-event
 */
export declare const analyzeEvent: (req: Request, res: Response, next: NextFunction) => void;
/**
 * Check for scheduling conflicts
 * POST /api/smart/check-conflicts
 */
export declare const checkConflicts: (req: Request, res: Response, next: NextFunction) => void;
/**
 * Find free time slots
 * POST /api/smart/find-free-slots
 */
export declare const findFreeSlots: (req: Request, res: Response, next: NextFunction) => void;
/**
 * Suggest best time for an event
 * POST /api/smart/suggest-time
 */
export declare const suggestBestTime: (req: Request, res: Response, next: NextFunction) => void;
/**
 * Generate user statistics and insights
 * GET /api/smart/user-stats
 */
export declare const getUserStats: (req: Request, res: Response, next: NextFunction) => void;
/**
 * Auto-categorize user's events
 * POST /api/smart/auto-categorize
 */
export declare const autoCategorizeEvents: (req: Request, res: Response, next: NextFunction) => void;
//# sourceMappingURL=smart-assistant.controller.d.ts.map