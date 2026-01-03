/**
 * Date utilities
 */
/**
 * Kiểm tra date có hợp lệ không
 */
export declare function isValidDate(date: any): boolean;
/**
 * Parse ISO string to Date
 */
export declare function parseISODate(dateString: string): Date | null;
/**
 * Kiểm tra startTime < endTime
 */
export declare function isValidTimeRange(startTime: Date, endTime: Date): boolean;
/**
 * Kiểm tra 2 khoảng thời gian có overlap không
 */
export declare function isTimeOverlap(start1: Date, end1: Date, start2: Date, end2: Date): boolean;
/**
 * Get start of day
 */
export declare function startOfDay(date: Date): Date;
/**
 * Get end of day
 */
export declare function endOfDay(date: Date): Date;
/**
 * Add days to date
 */
export declare function addDays(date: Date, days: number): Date;
/**
 * Get start of week (Monday)
 */
export declare function startOfWeek(date: Date): Date;
/**
 * Get end of week (Sunday)
 */
export declare function endOfWeek(date: Date): Date;
/**
 * Get start of month
 */
export declare function startOfMonth(date: Date): Date;
/**
 * Get end of month
 */
export declare function endOfMonth(date: Date): Date;
/**
 * Format duration in minutes to human readable
 */
export declare function formatDuration(minutes: number): string;
//# sourceMappingURL=date.util.d.ts.map