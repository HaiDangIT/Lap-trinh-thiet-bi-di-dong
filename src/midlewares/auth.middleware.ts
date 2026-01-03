import type { Request, Response, NextFunction } from "express";
import { UnauthorizedError } from "../utils/errors.js";

/**
 * Simple auth middleware (mock implementation)
 * In production, use JWT tokens
 */

// Extend Express Request type
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
export async function authenticate(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    // Mock: Get user ID from header (in production, decode from JWT)
    // Support both x-user-id and Authorization: Bearer <userId>
    let userId = req.headers["x-user-id"] as string;

    if (!userId) {
      const authHeader = req.headers["authorization"] as string;
      if (authHeader && authHeader.startsWith("Bearer ")) {
        userId = authHeader.substring(7);
      }
    }

    if (!userId) {
      throw new UnauthorizedError(
        "Authentication required. Please provide userId in 'Authorization: Bearer <userId>' header"
      );
    }

    // Get user from database to get real email
    const { default: userRepository } = await import(
      "../repositories/user.repository.js"
    );
    const user = await userRepository.findById(userId);

    if (!user) {
      throw new UnauthorizedError("User not found");
    }

    // Attach user info to request
    req.userId = userId;
    req.user = {
      id: user.id,
      email: user.email,
    };

    next();
  } catch (error) {
    next(error);
  }
}

/**
 * Optional authentication - doesn't fail if no auth provided
 */
export function optionalAuth(req: Request, res: Response, next: NextFunction) {
  let userId = req.headers["x-user-id"] as string;

  if (!userId) {
    const authHeader = req.headers["authorization"] as string;
    if (authHeader && authHeader.startsWith("Bearer ")) {
      userId = authHeader.substring(7);
    }
  }

  if (userId) {
    req.userId = userId;
    req.user = {
      id: userId,
      email: "user@example.com",
    };
  }

  next();
}

/**
 * Check if user owns the resource
 */
export function authorize(resourceUserIdField: string = "userId") {
  return (req: Request, res: Response, next: NextFunction) => {
    const userId = req.userId;
    const resourceUserId = (req as any)[resourceUserIdField];

    if (!userId || userId !== resourceUserId) {
      throw new UnauthorizedError(
        "You are not authorized to access this resource"
      );
    }

    next();
  };
}
