import speakeasy from "speakeasy";
import QRCode from "qrcode";
import { randomBytes, createHash } from "crypto";

/**
 * Generate 2FA secret and QR code
 */
export async function generateTwoFactorSecret(
  userEmail: string
): Promise<{ secret: string; qrCodeUrl: string }> {
  // Generate secret
  const secret = speakeasy.generateSecret({
    name: `Calendar App (${userEmail})`,
    issuer: "Calendar Management System",
    length: 32,
  });

  if (!secret.otpauth_url) {
    throw new Error("Failed to generate OTP auth URL");
  }

  // Generate QR code as data URL
  const qrCodeUrl = await QRCode.toDataURL(secret.otpauth_url);

  return {
    secret: secret.base32,
    qrCodeUrl,
  };
}

/**
 * Verify TOTP token
 */
export function verifyTwoFactorToken(token: string, secret: string): boolean {
  return speakeasy.totp.verify({
    secret: secret,
    encoding: "base32",
    token: token,
    window: 2, // Allow 2 time steps before/after for clock drift
  });
}

/**
 * Generate backup codes
 */
export function generateBackupCodes(count: number = 10): string[] {
  const codes: string[] = [];
  for (let i = 0; i < count; i++) {
    const code = randomBytes(4).toString("hex").toUpperCase();
    codes.push(code);
  }
  return codes;
}

/**
 * Hash backup code for storage
 */
export function hashBackupCode(code: string): string {
  return createHash("sha256").update(code).digest("hex");
}

/**
 * Verify backup code
 */
export function verifyBackupCode(
  inputCode: string,
  hashedCodes: string[]
): boolean {
  const hashedInput = hashBackupCode(inputCode);
  return hashedCodes.includes(hashedInput);
}
