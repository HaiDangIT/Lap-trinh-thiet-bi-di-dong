import type { Request, Response, NextFunction } from "express";
import type { Permission } from "../config/permissions.config.js";
/**
 * Middleware kiểm tra quyền truy cập
 */
export declare const authorize: (...requiredPermissions: Permission[]) => (req: Request, res: Response, next: NextFunction) => Promise<void>;
/**
 * Middleware kiểm tra role
 */
export declare const requireRole: (...requiredRoles: string[]) => (req: Request, res: Response, next: NextFunction) => Promise<void>;
/**
 * Helper để lấy permissions của user
 */
export declare const getUserPermissions: (userId: string) => Promise<Set<string>>;
/**
 * Helper để kiểm tra user có role không
 */
export declare const hasRole: (userId: string, roleName: string) => Promise<boolean>;
//# sourceMappingURL=authorization.middleware.d.ts.map