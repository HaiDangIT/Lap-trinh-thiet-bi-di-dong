import type { Request, Response, NextFunction } from "express";
/**
 * Setup 2FA - Generate QR code and backup codes
 */
export declare function setup2FA(req: Request, res: Response, next: NextFunction): Promise<Response<any, Record<string, any>> | undefined>;
/**
 * Enable 2FA after verification
 */
export declare function enable2FA(req: Request, res: Response, next: NextFunction): Promise<Response<any, Record<string, any>> | undefined>;
/**
 * Disable 2FA
 */
export declare function disable2FA(req: Request, res: Response, next: NextFunction): Promise<Response<any, Record<string, any>> | undefined>;
/**
 * Verify 2FA token (during login)
 */
export declare function verify2FA(req: Request, res: Response, next: NextFunction): Promise<Response<any, Record<string, any>> | undefined>;
/**
 * Get 2FA status
 */
export declare function get2FAStatus(req: Request, res: Response, next: NextFunction): Promise<Response<any, Record<string, any>> | undefined>;
/**
 * Regenerate backup codes
 */
export declare function regenerateBackupCodes(req: Request, res: Response, next: NextFunction): Promise<Response<any, Record<string, any>> | undefined>;
//# sourceMappingURL=twoFactor.controller.d.ts.map