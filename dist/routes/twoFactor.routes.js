import { Router } from "express";
import * as twoFactorController from "../controllers/twoFactor.controller.js";
import { authenticate } from "../midlewares/auth.middleware.js";
const router = Router();
/**
 * @swagger
 * /api/2fa/setup:
 *   post:
 *     summary: Setup 2FA - Generate QR code and backup codes
 *     tags: [2FA]
 *     responses:
 *       200:
 *         description: 2FA setup initiated
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     secret:
 *                       type: string
 *                       description: Base32 encoded secret (for manual entry)
 *                     qrCodeUrl:
 *                       type: string
 *                       description: QR code data URL for Google Authenticator
 *                     backupCodes:
 *                       type: array
 *                       items:
 *                         type: string
 *                       description: One-time backup codes (save these!)
 *       400:
 *         description: 2FA already enabled
 */
router.post("/setup", authenticate, twoFactorController.setup2FA);
/**
 * @swagger
 * /api/2fa/enable:
 *   post:
 *     summary: Enable 2FA after verifying token
 *     tags: [2FA]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - token
 *             properties:
 *               token:
 *                 type: string
 *                 description: 6-digit TOTP token from authenticator app
 *                 example: "123456"
 *     responses:
 *       200:
 *         description: 2FA enabled successfully
 *       400:
 *         description: Invalid token or 2FA not setup
 */
router.post("/enable", authenticate, twoFactorController.enable2FA);
/**
 * @swagger
 * /api/2fa/disable:
 *   post:
 *     summary: Disable 2FA
 *     tags: [2FA]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - token
 *             properties:
 *               token:
 *                 type: string
 *                 description: 6-digit TOTP token or backup code
 *     responses:
 *       200:
 *         description: 2FA disabled successfully
 *       400:
 *         description: Invalid token
 */
router.post("/disable", authenticate, twoFactorController.disable2FA);
/**
 * @swagger
 * /api/2fa/verify:
 *   post:
 *     summary: Verify 2FA token (used during login)
 *     tags: [2FA]
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - userId
 *               - token
 *             properties:
 *               userId:
 *                 type: string
 *                 format: uuid
 *               token:
 *                 type: string
 *                 description: 6-digit TOTP token or backup code
 *     responses:
 *       200:
 *         description: 2FA verified successfully
 *       401:
 *         description: Invalid token
 */
router.post("/verify", twoFactorController.verify2FA);
/**
 * @swagger
 * /api/2fa/status:
 *   get:
 *     summary: Get 2FA status for current user
 *     tags: [2FA]
 *     responses:
 *       200:
 *         description: 2FA status
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     isEnabled:
 *                       type: boolean
 *                     hasBackupCodes:
 *                       type: boolean
 *                     backupCodesCount:
 *                       type: number
 */
router.get("/status", authenticate, twoFactorController.get2FAStatus);
/**
 * @swagger
 * /api/2fa/regenerate-backup-codes:
 *   post:
 *     summary: Regenerate backup codes
 *     tags: [2FA]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - token
 *             properties:
 *               token:
 *                 type: string
 *                 description: 6-digit TOTP token for verification
 *     responses:
 *       200:
 *         description: Backup codes regenerated
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     backupCodes:
 *                       type: array
 *                       items:
 *                         type: string
 *       400:
 *         description: Invalid token or 2FA not enabled
 */
router.post("/regenerate-backup-codes", authenticate, twoFactorController.regenerateBackupCodes);
export default router;
//# sourceMappingURL=twoFactor.routes.js.map