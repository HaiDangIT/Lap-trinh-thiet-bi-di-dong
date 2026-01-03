import prisma from "../config/database.config.js";
import { ForbiddenError } from "../utils/errors.js";
/**
 * Middleware kiểm tra quyền truy cập
 */
export const authorize = (...requiredPermissions) => {
    return async (req, res, next) => {
        try {
            const userId = req.headers.authorization?.replace("Bearer ", "");
            if (!userId) {
                throw new ForbiddenError("User not authenticated");
            }
            // Lấy tất cả permissions của user thông qua roles
            const userRoles = await prisma.userRole.findMany({
                where: { userId },
                include: {
                    role: {
                        include: {
                            roleClaims: true,
                        },
                    },
                },
            });
            // Tập hợp tất cả permissions từ các roles
            const userPermissions = new Set();
            userRoles.forEach((userRole) => {
                userRole.role.roleClaims.forEach((claim) => {
                    if (claim.claimType === "permission") {
                        userPermissions.add(claim.claimValue);
                    }
                });
            });
            // Kiểm tra xem user có đủ quyền không
            const hasPermission = requiredPermissions.every((permission) => userPermissions.has(permission));
            if (!hasPermission) {
                throw new ForbiddenError(`Missing required permissions: ${requiredPermissions.join(", ")}`);
            }
            next();
        }
        catch (error) {
            next(error);
        }
    };
};
/**
 * Middleware kiểm tra role
 */
export const requireRole = (...requiredRoles) => {
    return async (req, res, next) => {
        try {
            const userId = req.headers.authorization?.replace("Bearer ", "");
            if (!userId) {
                throw new ForbiddenError("User not authenticated");
            }
            // Lấy tất cả roles của user
            const userRoles = await prisma.userRole.findMany({
                where: { userId },
                include: {
                    role: true,
                },
            });
            const userRoleNames = userRoles.map((ur) => ur.role.name);
            // Kiểm tra xem user có role yêu cầu không
            const hasRole = requiredRoles.some((role) => userRoleNames.includes(role));
            if (!hasRole) {
                throw new ForbiddenError(`Missing required roles: ${requiredRoles.join(", ")}`);
            }
            next();
        }
        catch (error) {
            next(error);
        }
    };
};
/**
 * Helper để lấy permissions của user
 */
export const getUserPermissions = async (userId) => {
    const userRoles = await prisma.userRole.findMany({
        where: { userId },
        include: {
            role: {
                include: {
                    roleClaims: true,
                },
            },
        },
    });
    const permissions = new Set();
    userRoles.forEach((userRole) => {
        userRole.role.roleClaims.forEach((claim) => {
            if (claim.claimType === "permission") {
                permissions.add(claim.claimValue);
            }
        });
    });
    return permissions;
};
/**
 * Helper để kiểm tra user có role không
 */
export const hasRole = async (userId, roleName) => {
    const userRole = await prisma.userRole.findFirst({
        where: {
            userId,
            role: {
                name: roleName,
            },
        },
    });
    return !!userRole;
};
//# sourceMappingURL=authorization.middleware.js.map