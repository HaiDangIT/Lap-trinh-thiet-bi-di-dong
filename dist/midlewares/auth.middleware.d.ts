import type { Request, Response, NextFunction } from "express";
/**
 * Simple auth middleware (mock implementation)
 * In production, use JWT tokens
 */
declare global {
    namespace Express {
        interface Request {
            userId?: string;
            user?: {
                id: string;
                email: string;
            };
        }
    }
}
/**
 * Mock authentication middleware
 * In production, verify JWT token here
 */
export declare function authenticate(req: Request, res: Response, next: NextFunction): Promise<void>;
/**
 * Optional authentication - doesn't fail if no auth provided
 */
export declare function optionalAuth(req: Request, res: Response, next: NextFunction): void;
/**
 * Check if user owns the resource
 */
export declare function authorize(resourceUserIdField?: string): (req: Request, res: Response, next: NextFunction) => void;
//# sourceMappingURL=auth.middleware.d.ts.map