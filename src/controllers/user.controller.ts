import type { Request, Response } from "express";
import userService from "../services/user.service.js";
import { successResponse, paginatedResponse } from "../utils/response.util.js";
import { asyncHandler } from "../midlewares/error.middleware.js";

/**
 * Register new user
 * POST /api/users/register
 */
export const register = asyncHandler(async (req: Request, res: Response) => {
  const user = await userService.register(req.body);

  res.status(201).json(
    successResponse(
      {
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        timezone: user.timezone,
      },
      "User registered successfully"
    )
  );
});

/**
 * Login user
 * POST /api/users/login
 */
export const login = asyncHandler(async (req: Request, res: Response) => {
  const result = await userService.login(req.body);

  // If 2FA is enabled, return partial response
  if (result.requires2FA) {
    res.json(
      successResponse(
        {
          userId: result.user.id,
          email: result.user.email,
          requires2FA: true,
          message: "Please provide 2FA token to complete login",
        },
        "2FA required"
      )
    );
    return;
  }

  // Normal login without 2FA
  res.json(
    successResponse(
      {
        id: result.user.id,
        email: result.user.email,
        fullName: result.user.fullName,
        timezone: result.user.timezone,
      },
      "Login successful"
    )
  );
});

/**
 * Get current user profile
 * GET /api/users/me
 */
export const getMe = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.userId!;
  const user = await userService.getUserById(userId);

  res.json(
    successResponse({
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      timezone: user.timezone,
      createdAt: user.createdAt,
    })
  );
});

/**
 * Get user by ID
 * GET /api/users/:id
 */
export const getUserById = asyncHandler(async (req: Request, res: Response) => {
  const user = await userService.getUserById(req.params.id!);

  res.json(
    successResponse({
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      timezone: user.timezone,
      createdAt: user.createdAt,
    })
  );
});

/**
 * Update user
 * PUT /api/users/:id
 */
export const updateUser = asyncHandler(async (req: Request, res: Response) => {
  const user = await userService.updateUser(req.params.id!, req.body);

  res.json(
    successResponse(
      {
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        timezone: user.timezone,
      },
      "User updated successfully"
    )
  );
});

/**
 * Delete user
 * DELETE /api/users/:id
 */
export const deleteUser = asyncHandler(async (req: Request, res: Response) => {
  await userService.deleteUser(req.params.id!);

  res.json(successResponse(null, "User deleted successfully"));
});

/**
 * Get all users (with pagination)
 * GET /api/users
 */
export const getUsers = asyncHandler(async (req: Request, res: Response) => {
  const page = parseInt(req.query.page as string) || 1;
  const pageSize = parseInt(req.query.pageSize as string) || 20;
  const search = req.query.search as string;

  const result = await userService.getUsers(page, pageSize, search);

  const users = result.users.map((u) => ({
    id: u.id,
    email: u.email,
    fullName: u.fullName,
    timezone: u.timezone,
    createdAt: u.createdAt,
  }));

  res.json(paginatedResponse(users, page, pageSize, result.total));
});

/**
 * Change password
 * POST /api/users/change-password
 */
export const changePassword = asyncHandler(
  async (req: Request, res: Response) => {
    const userId = req.userId!;
    const { currentPassword, newPassword } = req.body;

    await userService.changePassword(userId, currentPassword, newPassword);

    res.json(successResponse(null, "Password changed successfully"));
  }
);

/**
 * Verify 2FA during login
 * POST /api/users/verify-2fa
 */
export const verify2FA = asyncHandler(async (req: Request, res: Response) => {
  const { userId, token } = req.body;

  const result = await userService.verifyLoginWith2FA(userId, token);

  res.json(
    successResponse(
      {
        id: result.user.id,
        email: result.user.email,
        fullName: result.user.fullName,
        timezone: result.user.timezone,
        token: result.token,
      },
      "Login successful"
    )
  );
});

/**
 * Get user statistics
 * GET /api/users/:id/stats
 */
export const getUserStats = asyncHandler(
  async (req: Request, res: Response) => {
    const stats = await userService.getUserStats(req.params.id!);

    res.json(successResponse(stats, "User statistics retrieved"));
  }
);

/**
 * Search users
 * GET /api/users/search
 */
export const searchUsers = asyncHandler(async (req: Request, res: Response) => {
  const query = req.query.q as string;
  const limit = parseInt(req.query.limit as string) || 10;

  if (!query || query.trim().length < 2) {
    res.json(successResponse([], "Please provide at least 2 characters"));
    return;
  }

  const users = await userService.searchUsers(query, limit);

  const results = users.map((u) => ({
    id: u.id,
    email: u.email,
    fullName: u.fullName,
    timezone: u.timezone,
  }));

  res.json(successResponse(results));
});

/**
 * Bulk delete users
 * POST /api/users/bulk-delete
 */
export const bulkDeleteUsers = asyncHandler(
  async (req: Request, res: Response) => {
    const { userIds } = req.body;

    if (!Array.isArray(userIds) || userIds.length === 0) {
      res.status(400).json({
        success: false,
        message: "userIds must be a non-empty array",
      });
      return;
    }

    const result = await userService.bulkDeleteUsers(userIds);

    res.json(
      successResponse(
        { deletedCount: result },
        `Successfully deleted ${result} user(s)`
      )
    );
  }
);
