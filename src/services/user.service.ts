import { type User } from "@prisma/client";
import userRepository from "../repositories/user.repository.js";
import { hashPassword, comparePassword } from "../utils/crypto.util.js";
import {
  ValidationError,
  NotFoundError,
  UnauthorizedError,
} from "../utils/errors.js";

export interface CreateUserDto {
  email: string;
  password: string;
  fullName?: string;
  timezone?: string;
}

export interface UpdateUserDto {
  fullName?: string;
  timezone?: string;
  password?: string;
}

export interface LoginDto {
  email: string;
  password: string;
}

export class UserService {
  /**
   * Đăng ký user mới
   */
  async register(dto: CreateUserDto): Promise<User> {
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
  async login(dto: LoginDto): Promise<{ user: User; requires2FA: boolean }> {
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
  async getUserById(id: string): Promise<User> {
    const user = await userRepository.findById(id);
    if (!user) {
      throw new NotFoundError("User not found");
    }
    return user;
  }

  /**
   * Cập nhật user
   */
  async updateUser(id: string, dto: UpdateUserDto): Promise<User> {
    const user = await userRepository.findById(id);
    if (!user) {
      throw new NotFoundError("User not found");
    }

    const updateData: any = {};

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
  async deleteUser(id: string): Promise<void> {
    const user = await userRepository.findById(id);
    if (!user) {
      throw new NotFoundError("User not found");
    }

    await userRepository.delete(id);
  }

  /**
   * Lấy danh sách users (phân trang)
   */
  async getUsers(page: number = 1, pageSize: number = 20, search?: string) {
    const skip = (page - 1) * pageSize;

    const where = search
      ? {
          OR: [
            { email: { contains: search, mode: "insensitive" as const } },
            { fullName: { contains: search, mode: "insensitive" as const } },
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
  async changePassword(
    userId: string,
    currentPassword: string,
    newPassword: string
  ): Promise<void> {
    const user = await userRepository.findById(userId);
    if (!user) {
      throw new NotFoundError("User not found");
    }

    const isValid = comparePassword(currentPassword, user.passwordHash);
    if (!isValid) {
      throw new UnauthorizedError("Current password is incorrect");
    }

    if (newPassword.length < 6) {
      throw new ValidationError(
        "New password must be at least 6 characters long"
      );
    }

    const newPasswordHash = hashPassword(newPassword);
    await userRepository.update(userId, { passwordHash: newPasswordHash });
  }

  /**
   * Verify 2FA during login
   */
  async verifyLoginWith2FA(
    userId: string,
    token: string
  ): Promise<{ user: User; token: string }> {
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
  async getUserStats(userId: string) {
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
  async searchUsers(query: string, limit: number = 10): Promise<User[]> {
    return userRepository.searchUsers(query, limit);
  }

  /**
   * Bulk delete users
   */
  async bulkDeleteUsers(userIds: string[]): Promise<number> {
    return userRepository.bulkDelete(userIds);
  }
}

export default new UserService();
