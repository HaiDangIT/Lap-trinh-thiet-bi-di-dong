/**
 * Timezone Utilities
 * Xử lý chuyển đổi múi giờ cho Calendar App
 */
export interface TimezoneInfo {
    timezone: string;
    offset: string;
    abbr: string;
}
/**
 * Danh sách các múi giờ phổ biến
 */
export declare const COMMON_TIMEZONES: TimezoneInfo[];
/**
 * Chuyển đổi thời gian local sang UTC
 * @param date - Thời gian local
 * @param timezone - Múi giờ (mặc định UTC)
 * @returns Date object ở UTC
 */
export declare function toUTC(date: Date, timezone?: string): Date;
/**
 * Chuyển đổi thời gian UTC sang múi giờ cụ thể
 * @param date - Thời gian UTC
 * @param timezone - Múi giờ đích
 * @returns Date object ở múi giờ đích
 */
export declare function fromUTC(date: Date, timezone: string): Date;
/**
 * Format thời gian theo múi giờ
 */
export declare function formatDateInTimezone(date: Date, timezone: string, format?: "full" | "date" | "time"): string;
/**
 * Kiểm tra timezone có hợp lệ không
 */
export declare function isValidTimezone(timezone: string): boolean;
/**
 * Lấy offset của timezone (theo phút)
 */
export declare function getTimezoneOffset(timezone: string): number;
//# sourceMappingURL=timezone.util.d.ts.map