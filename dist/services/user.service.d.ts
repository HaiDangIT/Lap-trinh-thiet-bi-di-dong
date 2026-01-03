import { type User } from "@prisma/client";
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
export declare class UserService {
    /**
     * Đăng ký user mới
     */
    register(dto: CreateUserDto): Promise<User>;
    /**
     * Login
     */
    login(dto: LoginDto): Promise<{
        user: User;
        requires2FA: boolean;
    }>;
    /**
     * Lấy user theo ID
     */
    getUserById(id: string): Promise<User>;
    /**
     * Cập nhật user
     */
    updateUser(id: string, dto: UpdateUserDto): Promise<User>;
    /**
     * Xóa user
     */
    deleteUser(id: string): Promise<void>;
    /**
     * Lấy danh sách users (phân trang)
     */
    getUsers(page?: number, pageSize?: number, search?: string): Promise<{
        users: {
            email: string;
            id: string;
            passwordHash: string;
            fullName: string | null;
            timezone: string;
            createdAt: Date;
            updatedAt: Date;
        }[];
        total: number;
        page: number;
        pageSize: number;
        totalPages: number;
    }>;
    /**
     * Change password
     */
    changePassword(userId: string, currentPassword: string, newPassword: string): Promise<void>;
    /**
     * Verify 2FA during login
     */
    verifyLoginWith2FA(userId: string, token: string): Promise<{
        user: User;
        token: string;
    }>;
    /**
     * Get user statistics
     */
    getUserStats(userId: string): Promise<{
        calendarsCount: number;
        eventsCreated: number;
        eventsAttending: number;
    }>;
    /**
     * Search users
     */
    searchUsers(query: string, limit?: number): Promise<User[]>;
    /**
     * Bulk delete users
     */
    bulkDeleteUsers(userIds: string[]): Promise<number>;
}
declare const _default: UserService;
export default _default;
//# sourceMappingURL=user.service.d.ts.map