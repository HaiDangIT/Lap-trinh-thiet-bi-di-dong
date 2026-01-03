import type { Request, Response, NextFunction } from "express";
/**
 * Request logging middleware
 */
export declare function requestLogger(req: Request, res: Response, next: NextFunction): void;
/**
 * CORS middleware (simple implementation)
 */
export declare function cors(req: Request, res: Response, next: NextFunction): Response<any, Record<string, any>> | undefined;
export declare function rateLimit(maxRequests?: number, windowMs?: number): (req: Request, res: Response, next: NextFunction) => Response<any, Record<string, any>> | undefined;
/**
 * Body parser size limit
 */
export declare function bodyLimit(req: Request, res: Response, next: NextFunction): Response<any, Record<string, any>> | undefined;
//# sourceMappingURL=common.middleware.d.ts.map