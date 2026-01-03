import type { Request, Response } from "express";
/**
 * Register new user
 * POST /api/users/register
 */
export declare const register: (req: Request, res: Response, next: import("express").NextFunction) => void;
/**
 * Login user
 * POST /api/users/login
 */
export declare const login: (req: Request, res: Response, next: import("express").NextFunction) => void;
/**
 * Get current user profile
 * GET /api/users/me
 */
export declare const getMe: (req: Request, res: Response, next: import("express").NextFunction) => void;
/**
 * Get user by ID
 * GET /api/users/:id
 */
export declare const getUserById: (req: Request, res: Response, next: import("express").NextFunction) => void;
/**
 * Update user
 * PUT /api/users/:id
 */
export declare const updateUser: (req: Request, res: Response, next: import("express").NextFunction) => void;
/**
 * Delete user
 * DELETE /api/users/:id
 */
export declare const deleteUser: (req: Request, res: Response, next: import("express").NextFunction) => void;
/**
 * Get all users (with pagination)
 * GET /api/users
 */
export declare const getUsers: (req: Request, res: Response, next: import("express").NextFunction) => void;
/**
 * Change password
 * POST /api/users/change-password
 */
export declare const changePassword: (req: Request, res: Response, next: import("express").NextFunction) => void;
/**
 * Verify 2FA during login
 * POST /api/users/verify-2fa
 */
export declare const verify2FA: (req: Request, res: Response, next: import("express").NextFunction) => void;
/**
 * Get user statistics
 * GET /api/users/:id/stats
 */
export declare const getUserStats: (req: Request, res: Response, next: import("express").NextFunction) => void;
/**
 * Search users
 * GET /api/users/search
 */
export declare const searchUsers: (req: Request, res: Response, next: import("express").NextFunction) => void;
/**
 * Bulk delete users
 * POST /api/users/bulk-delete
 */
export declare const bulkDeleteUsers: (req: Request, res: Response, next: import("express").NextFunction) => void;
//# sourceMappingURL=user.controller.d.ts.map