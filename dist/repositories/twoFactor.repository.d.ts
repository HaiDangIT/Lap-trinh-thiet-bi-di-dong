import type { TwoFactor } from "@prisma/client";
export declare function create(data: {
    userId: string;
    secret: string;
    backupCodes: string[];
}): Promise<TwoFactor>;
export declare function findByUserId(userId: string): Promise<TwoFactor | null>;
export declare function updateStatus(userId: string, isEnabled: boolean): Promise<TwoFactor>;
export declare function update(userId: string, data: Partial<{
    secret: string;
    backupCodes: string[];
    isEnabled: boolean;
}>): Promise<TwoFactor>;
export declare function updateBackupCodes(userId: string, backupCodes: string[]): Promise<TwoFactor>;
export declare function remove(userId: string): Promise<void>;
//# sourceMappingURL=twoFactor.repository.d.ts.map