import { type User, Prisma } from "@prisma/client";
export declare class UserRepository {
    /**
     * Tạo user mới
     */
    create(data: Prisma.UserCreateInput): Promise<User>;
    /**
     * Tìm user theo ID
     */
    findById(id: string): Promise<User | null>;
    /**
     * Tìm user theo email
     */
    findByEmail(email: string): Promise<User | null>;
    /**
     * Lấy tất cả users (có phân trang)
     */
    findAll(skip?: number, take?: number, where?: any): Promise<User[]>;
    /**
     * Đếm tổng số users
     */
    count(where?: any): Promise<number>;
    /**
     * Cập nhật user
     */
    update(id: string, data: Prisma.UserUpdateInput): Promise<User>;
    /**
     * Xóa user
     */
    delete(id: string): Promise<User>;
    /**
     * Kiểm tra email đã tồn tại chưa
     */
    emailExists(email: string, excludeId?: string): Promise<boolean>;
    /**
     * Search users by email or name
     */
    searchUsers(query: string, limit?: number): Promise<User[]>;
    /**
     * Get user statistics
     */
    getUserStatistics(userId: string): Promise<{
        calendarsCount: number;
        eventsCreated: number;
        eventsAttending: number;
    }>;
    /**
     * Bulk delete users
     */
    bulkDelete(userIds: string[]): Promise<number>;
}
declare const _default: UserRepository;
export default _default;
//# sourceMappingURL=user.repository.d.ts.map