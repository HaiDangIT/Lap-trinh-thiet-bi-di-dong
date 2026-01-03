declare class TwoFactorService {
    /**
     * Setup 2FA for user - Generate secret and QR code
     */
    setupTwoFactor(userId: string, email: string): Promise<{
        secret: string;
        qrCodeUrl: string;
        backupCodes: string[];
    }>;
    /**
     * Enable 2FA - Verify token before enabling
     */
    enableTwoFactor(userId: string, token: string): Promise<void>;
    /**
     * Disable 2FA - Verify token before disabling
     */
    disableTwoFactor(userId: string, token: string): Promise<void>;
    /**
     * Verify 2FA token during login
     */
    verifyTwoFactor(userId: string, token: string): Promise<{
        valid: boolean;
        usedBackupCode?: boolean;
    }>;
    /**
     * Check if user has 2FA enabled
     */
    isTwoFactorEnabled(userId: string): Promise<boolean>;
    /**
     * Get 2FA status
     */
    getTwoFactorStatus(userId: string): Promise<{
        isEnabled: boolean;
        hasBackupCodes: boolean;
        backupCodesCount?: number;
    }>;
    /**
     * Regenerate backup codes
     */
    regenerateBackupCodes(userId: string, token: string): Promise<string[]>;
}
declare const _default: TwoFactorService;
export default _default;
//# sourceMappingURL=twoFactor.service.d.ts.map