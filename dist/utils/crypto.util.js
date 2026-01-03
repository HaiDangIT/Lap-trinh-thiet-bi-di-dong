import crypto from "crypto";
/**
 * Hash password using SHA-256
 * In production, use bcrypt or argon2
 */
export function hashPassword(password) {
    return crypto.createHash("sha256").update(password).digest("hex");
}
/**
 * Compare password with hash
 */
export function comparePassword(password, hash) {
    const passwordHash = hashPassword(password);
    return passwordHash === hash;
}
/**
 * Generate random token
 */
export function generateToken(length = 32) {
    return crypto.randomBytes(length).toString("hex");
}
/**
 * Validate email format
 */
export function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}
/**
 * Sanitize string (remove special characters)
 */
export function sanitizeString(str) {
    return str.replace(/[<>]/g, "");
}
/**
 * Generate UUID v4
 */
export function generateUUID() {
    return crypto.randomUUID();
}
//# sourceMappingURL=crypto.util.js.map