/**
 * RRULE (Recurrence Rule) Utilities
 * Xử lý logic lặp lại sự kiện theo chuẩn iCalendar RFC 5545
 */
export type Frequency = "DAILY" | "WEEKLY" | "MONTHLY" | "YEARLY";
export type Weekday = "MO" | "TU" | "WE" | "TH" | "FR" | "SA" | "SU";
export interface RecurrenceOptions {
    frequency: Frequency;
    interval?: number;
    byDay?: Weekday[];
    byMonthDay?: number[];
    byMonth?: number[];
    untilDate?: Date;
    count?: number;
}
/**
 * Tạo RRULE string từ options
 */
export declare function buildRRuleString(options: RecurrenceOptions): string;
/**
 * Parse RRULE string thành options
 */
export declare function parseRRuleString(rrule: string): RecurrenceOptions | null;
/**
 * Tính toán các occurrence trong khoảng thời gian
 */
export declare function calculateOccurrences(startDate: Date, endDate: Date, rangeStart: Date, rangeEnd: Date, recurrenceRule: RecurrenceOptions, maxOccurrences?: number): Date[];
/**
 * Helper: Kiểm tra một ngày có phải là occurrence của sự kiện lặp
 */
export declare function isOccurrenceDate(date: Date, startDate: Date, recurrenceRule: RecurrenceOptions): boolean;
//# sourceMappingURL=rrule.util.d.ts.map