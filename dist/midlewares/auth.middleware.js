import { UnauthorizedError } from "../utils/errors.js";
/**
 * Mock authentication middleware
 * In production, verify JWT token here
 */
export async function authenticate(req, res, next) {
    try {
        // Mock: Get user ID from header (in production, decode from JWT)
        // Support both x-user-id and Authorization: Bearer <userId>
        let userId = req.headers["x-user-id"];
        if (!userId) {
            const authHeader = req.headers["authorization"];
            if (authHeader && authHeader.startsWith("Bearer ")) {
                userId = authHeader.substring(7);
            }
        }
        if (!userId) {
            throw new UnauthorizedError("Authentication required. Please provide userId in 'Authorization: Bearer <userId>' header");
        }
        // Get user from database to get real email
        const { default: userRepository } = await import("../repositories/user.repository.js");
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
    }
    catch (error) {
        next(error);
    }
}
/**
 * Optional authentication - doesn't fail if no auth provided
 */
export function optionalAuth(req, res, next) {
    let userId = req.headers["x-user-id"];
    if (!userId) {
        const authHeader = req.headers["authorization"];
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
export function authorize(resourceUserIdField = "userId") {
    return (req, res, next) => {
        const userId = req.userId;
        const resourceUserId = req[resourceUserIdField];
        if (!userId || userId !== resourceUserId) {
            throw new UnauthorizedError("You are not authorized to access this resource");
        }
        next();
    };
}
//# sourceMappingURL=auth.middleware.js.map