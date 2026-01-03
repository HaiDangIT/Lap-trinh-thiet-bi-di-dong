/**
 * Hash password using SHA-256
 * In production, use bcrypt or argon2
 */
export declare function hashPassword(password: string): string;
/**
 * Compare password with hash
 */
export declare function comparePassword(password: string, hash: string): boolean;
/**
 * Generate random token
 */
export declare function generateToken(length?: number): string;
/**
 * Validate email format
 */
export declare function isValidEmail(email: string): boolean;
/**
 * Sanitize string (remove special characters)
 */
export declare function sanitizeString(str: string): string;
/**
 * Generate UUID v4
 */
export declare function generateUUID(): string;
//# sourceMappingURL=crypto.util.d.ts.map