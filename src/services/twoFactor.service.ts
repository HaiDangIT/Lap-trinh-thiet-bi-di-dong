import * as twoFactorRepository from "../repositories/twoFactor.repository.js";
import {
  generateTwoFactorSecret,
  verifyTwoFactorToken,
  generateBackupCodes,
  hashBackupCode,
  verifyBackupCode,
} from "../utils/twoFactor.util.js";
import { NotFoundError, BadRequestError } from "../utils/errors.js";

class TwoFactorService {
  /**
   * Setup 2FA for user - Generate secret and QR code
   */
  async setupTwoFactor(
    userId: string,
    email: string
  ): Promise<{ secret: string; qrCodeUrl: string; backupCodes: string[] }> {
    // Check if 2FA already exists
    const existing = await twoFactorRepository.findByUserId(userId);
    if (existing && existing.isEnabled) {
      throw new BadRequestError("2FA is already enabled for this account");
    }

    // Generate secret and QR code
    const { secret, qrCodeUrl } = await generateTwoFactorSecret(email);

    // Generate backup codes
    const backupCodes = generateBackupCodes(10);
    const hashedBackupCodes = backupCodes.map((code) => hashBackupCode(code));

    // Save to database (not enabled yet)
    if (existing) {
      // Update existing record with new secret and backup codes
      await twoFactorRepository.update(userId, {
        secret,
        backupCodes: hashedBackupCodes,
      });
    } else {
      await twoFactorRepository.create({
        userId,
        secret,
        backupCodes: hashedBackupCodes,
      });
    }

    return {
      secret,
      qrCodeUrl,
      backupCodes, // Return unhashed codes to user (one-time display)
    };
  }

  /**
   * Enable 2FA - Verify token before enabling
   */
  async enableTwoFactor(userId: string, token: string): Promise<void> {
    const twoFactor = await twoFactorRepository.findByUserId(userId);
    if (!twoFactor) {
      throw new NotFoundError("2FA not setup. Please setup 2FA first.");
    }

    if (twoFactor.isEnabled) {
      throw new BadRequestError("2FA is already enabled");
    }

    // Verify token
    const isValid = verifyTwoFactorToken(token, twoFactor.secret);
    if (!isValid) {
      throw new BadRequestError("Invalid 2FA token");
    }

    // Enable 2FA
    await twoFactorRepository.updateStatus(userId, true);
  }

  /**
   * Disable 2FA - Verify token before disabling
   */
  async disableTwoFactor(userId: string, token: string): Promise<void> {
    const twoFactor = await twoFactorRepository.findByUserId(userId);
    if (!twoFactor) {
      throw new NotFoundError("2FA not found");
    }

    if (!twoFactor.isEnabled) {
      throw new BadRequestError("2FA is not enabled");
    }

    // Verify token or backup code
    const isValidToken = verifyTwoFactorToken(token, twoFactor.secret);
    const isValidBackup = verifyBackupCode(token, twoFactor.backupCodes);

    if (!isValidToken && !isValidBackup) {
      throw new BadRequestError("Invalid 2FA token or backup code");
    }

    // Disable and remove 2FA
    await twoFactorRepository.remove(userId);
  }

  /**
   * Verify 2FA token during login
   */
  async verifyTwoFactor(
    userId: string,
    token: string
  ): Promise<{ valid: boolean; usedBackupCode?: boolean }> {
    const twoFactor = await twoFactorRepository.findByUserId(userId);
    if (!twoFactor || !twoFactor.isEnabled) {
      throw new NotFoundError("2FA not enabled for this account");
    }

    // Try TOTP token first
    const isValidToken = verifyTwoFactorToken(token, twoFactor.secret);
    if (isValidToken) {
      return { valid: true };
    }

    // Try backup code
    const isValidBackup = verifyBackupCode(token, twoFactor.backupCodes);
    if (isValidBackup) {
      // Remove used backup code
      const updatedCodes = twoFactor.backupCodes.filter(
        (code) => code !== hashBackupCode(token)
      );
      await twoFactorRepository.updateBackupCodes(userId, updatedCodes);

      return { valid: true, usedBackupCode: true };
    }

    return { valid: false };
  }

  /**
   * Check if user has 2FA enabled
   */
  async isTwoFactorEnabled(userId: string): Promise<boolean> {
    const twoFactor = await twoFactorRepository.findByUserId(userId);
    return twoFactor?.isEnabled ?? false;
  }

  /**
   * Get 2FA status
   */
  async getTwoFactorStatus(userId: string): Promise<{
    isEnabled: boolean;
    hasBackupCodes: boolean;
    backupCodesCount?: number;
  }> {
    const twoFactor = await twoFactorRepository.findByUserId(userId);

    if (!twoFactor) {
      return {
        isEnabled: false,
        hasBackupCodes: false,
      };
    }

    return {
      isEnabled: twoFactor.isEnabled,
      hasBackupCodes: twoFactor.backupCodes.length > 0,
      backupCodesCount: twoFactor.backupCodes.length,
    };
  }

  /**
   * Regenerate backup codes
   */
  async regenerateBackupCodes(
    userId: string,
    token: string
  ): Promise<string[]> {
    const twoFactor = await twoFactorRepository.findByUserId(userId);

    if (!twoFactor || !twoFactor.isEnabled) {
      throw new NotFoundError("2FA is not enabled for this account");
    }

    // Verify token to ensure user has access
    const isValid = verifyTwoFactorToken(token, twoFactor.secret);
    if (!isValid) {
      throw new BadRequestError("Invalid 2FA token");
    }

    // Generate new backup codes
    const backupCodes = generateBackupCodes(10);
    const hashedBackupCodes = backupCodes.map((code) => hashBackupCode(code));

    // Update in database
    await twoFactorRepository.updateBackupCodes(userId, hashedBackupCodes);

    return backupCodes;
  }
}

export default new TwoFactorService();
