import {} from "@prisma/client";
import userRepository from "../repositories/user.repository.js";
import { hashPassword, comparePassword } from "../utils/crypto.util.js";
import { ValidationError, NotFoundError, UnauthorizedError, } from "../utils/errors.js";
export class UserService {
    /**
     * Đăng ký user mới
     */
    async register(dto) {
        // Validate email
        const existingUser = await userRepository.findByEmail(dto.email);
        if (existingUser) {
            throw new ValidationError("Email already exists");
        }
        // Hash password
        const passwordHash = hashPassword(dto.password);
        // Tạo user
        const user = await userRepository.create({
            email: dto.email,
            passwordHash,
            fullName: dto.fullName || null,
            timezone: dto.timezone || "UTC",
        });
        return user;
    }
    /**
     * Login
     */
    async login(dto) {
        const user = await userRepository.findByEmail(dto.email);
        if (!user) {
            throw new UnauthorizedError("Invalid credentials");
        }
        const isValid = comparePassword(dto.password, user.passwordHash);
        if (!isValid) {
            throw new UnauthorizedError("Invalid credentials");
        }
        // Check if 2FA is enabled
        const twoFactorService = (await import("./twoFactor.service.js")).default;
        const requires2FA = await twoFactorService.isTwoFactorEnabled(user.id);
        return {
            user,
            requires2FA,
        };
    }
    /**
     * Lấy user theo ID
     */
    async getUserById(id) {
        const user = await userRepository.findById(id);
        if (!user) {
            throw new NotFoundError("User not found");
        }
        return user;
    }
    /**
     * Cập nhật user
     */
    async updateUser(id, dto) {
        const user = await userRepository.findById(id);
        if (!user) {
            throw new NotFoundError("User not found");
        }
        const updateData = {};
        if (dto.fullName !== undefined) {
            updateData.fullName = dto.fullName;
        }
        if (dto.timezone !== undefined) {
            updateData.timezone = dto.timezone;
        }
        if (dto.password) {
            updateData.passwordHash = hashPassword(dto.password);
        }
        return userRepository.update(id, updateData);
    }
    /**
     * Xóa user
     */
    async deleteUser(id) {
        const user = await userRepository.findById(id);
        if (!user) {
            throw new NotFoundError("User not found");
        }
        await userRepository.delete(id);
    }
    /**
     * Lấy danh sách users (phân trang)
     */
    async getUsers(page = 1, pageSize = 20, search) {
        const skip = (page - 1) * pageSize;
        const where = search
            ? {
                OR: [
                    { email: { contains: search, mode: "insensitive" } },
                    { fullName: { contains: search, mode: "insensitive" } },
                ],
            }
            : {};
        const [users, total] = await Promise.all([
            userRepository.findAll(skip, pageSize, where),
            userRepository.count(where),
        ]);
        return {
            users,
            total,
            page,
            pageSize,
            totalPages: Math.ceil(total / pageSize),
        };
    }
    /**
     * Change password
     */
    async changePassword(userId, currentPassword, newPassword) {
        const user = await userRepository.findById(userId);
        if (!user) {
            throw new NotFoundError("User not found");
        }
        const isValid = comparePassword(currentPassword, user.passwordHash);
        if (!isValid) {
            throw new UnauthorizedError("Current password is incorrect");
        }
        if (newPassword.length < 6) {
            throw new ValidationError("New password must be at least 6 characters long");
        }
        const newPasswordHash = hashPassword(newPassword);
        await userRepository.update(userId, { passwordHash: newPasswordHash });
    }
    /**
     * Verify 2FA during login
     */
    async verifyLoginWith2FA(userId, token) {
        const user = await userRepository.findById(userId);
        if (!user) {
            throw new NotFoundError("User not found");
        }
        const twoFactorService = (await import("./twoFactor.service.js")).default;
        const result = await twoFactorService.verifyTwoFactor(userId, token);
        if (!result.valid) {
            throw new UnauthorizedError("Invalid 2FA token");
        }
        return {
            user,
            token: userId, // In production, generate JWT token here
        };
    }
    /**
     * Get user statistics
     */
    async getUserStats(userId) {
        const user = await userRepository.findById(userId);
        if (!user) {
            throw new NotFoundError("User not found");
        }
        const stats = await userRepository.getUserStatistics(userId);
        return stats;
    }
    /**
     * Search users
     */
    async searchUsers(query, limit = 10) {
        return userRepository.searchUsers(query, limit);
    }
    /**
     * Bulk delete users
     */
    async bulkDeleteUsers(userIds) {
        return userRepository.bulkDelete(userIds);
    }
}
export default new UserService();
//# sourceMappingURL=user.service.js.map