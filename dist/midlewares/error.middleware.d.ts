import type { Request, Response, NextFunction } from "express";
import { AppError } from "../utils/errors.js";
/**
 * Global error handler middleware
 */
export declare function errorHandler(err: Error | AppError, req: Request, res: Response, next: NextFunction): Response<any, Record<string, any>>;
/**
 * Not found handler
 */
export declare function notFoundHandler(req: Request, res: Response): void;
/**
 * Async handler wrapper to catch errors in async route handlers
 */
export declare function asyncHandler(fn: (req: Request, res: Response, next: NextFunction) => Promise<any>): (req: Request, res: Response, next: NextFunction) => void;
//# sourceMappingURL=error.middleware.d.ts.map