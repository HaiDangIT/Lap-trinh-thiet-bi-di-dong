/**
 * Generate 2FA secret and QR code
 */
export declare function generateTwoFactorSecret(userEmail: string): Promise<{
    secret: string;
    qrCodeUrl: string;
}>;
/**
 * Verify TOTP token
 */
export declare function verifyTwoFactorToken(token: string, secret: string): boolean;
/**
 * Generate backup codes
 */
export declare function generateBackupCodes(count?: number): string[];
/**
 * Hash backup code for storage
 */
export declare function hashBackupCode(code: string): string;
/**
 * Verify backup code
 */
export declare function verifyBackupCode(inputCode: string, hashedCodes: string[]): boolean;
//# sourceMappingURL=twoFactor.util.d.ts.map