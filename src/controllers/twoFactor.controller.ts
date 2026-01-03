import type { Request, Response, NextFunction } from "express";
import twoFactorService from "../services/twoFactor.service.js";
import { successResponse } from "../utils/response.util.js";

/**
 * Setup 2FA - Generate QR code and backup codes
 */
export async function setup2FA(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const userId = req.user!.id;
    const userEmail = req.user!.email;

    const result = await twoFactorService.setupTwoFactor(userId, userEmail);

    return res
      .status(200)
      .json(
        successResponse(
          result,
          "2FA setup initiated. Please scan the QR code and verify with a token to enable."
        )
      );
  } catch (error) {
    next(error);
  }
}

/**
 * Enable 2FA after verification
 */
export async function enable2FA(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const userId = req.user!.id;
    const { token } = req.body;

    await twoFactorService.enableTwoFactor(userId, token);

    return res
      .status(200)
      .json(successResponse(null, "2FA enabled successfully"));
  } catch (error) {
    next(error);
  }
}

/**
 * Disable 2FA
 */
export async function disable2FA(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const userId = req.user!.id;
    const { token } = req.body;

    await twoFactorService.disableTwoFactor(userId, token);

    return res
      .status(200)
      .json(successResponse(null, "2FA disabled successfully"));
  } catch (error) {
    next(error);
  }
}

/**
 * Verify 2FA token (during login)
 */
export async function verify2FA(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const { userId, token } = req.body;

    const result = await twoFactorService.verifyTwoFactor(userId, token);

    if (!result.valid) {
      return res.status(401).json({
        success: false,
        message: "Invalid 2FA token",
      });
    }

    return res.status(200).json(
      successResponse(
        {
          userId,
          verified: true,
          usedBackupCode: result.usedBackupCode,
        },
        "2FA verified successfully"
      )
    );
  } catch (error) {
    next(error);
  }
}

/**
 * Get 2FA status
 */
export async function get2FAStatus(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const userId = req.user!.id;

    const status = await twoFactorService.getTwoFactorStatus(userId);

    return res
      .status(200)
      .json(successResponse(status, "2FA status retrieved"));
  } catch (error) {
    next(error);
  }
}

/**
 * Regenerate backup codes
 */
export async function regenerateBackupCodes(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const userId = req.user!.id;
    const { token } = req.body;

    const backupCodes = await twoFactorService.regenerateBackupCodes(
      userId,
      token
    );

    return res
      .status(200)
      .json(
        successResponse(
          { backupCodes },
          "Backup codes regenerated successfully. Save these codes in a safe place!"
        )
      );
  } catch (error) {
    next(error);
  }
}
