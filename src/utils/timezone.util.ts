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
export const COMMON_TIMEZONES: TimezoneInfo[] = [
  { timezone: "UTC", offset: "+00:00", abbr: "UTC" },
  { timezone: "Asia/Ho_Chi_Minh", offset: "+07:00", abbr: "ICT" },
  { timezone: "America/New_York", offset: "-05:00", abbr: "EST" },
  { timezone: "America/Los_Angeles", offset: "-08:00", abbr: "PST" },
  { timezone: "Europe/London", offset: "+00:00", abbr: "GMT" },
  { timezone: "Europe/Paris", offset: "+01:00", abbr: "CET" },
  { timezone: "Asia/Tokyo", offset: "+09:00", abbr: "JST" },
  { timezone: "Asia/Shanghai", offset: "+08:00", abbr: "CST" },
  { timezone: "Australia/Sydney", offset: "+11:00", abbr: "AEDT" },
];

/**
 * Chuyển đổi thời gian local sang UTC
 * @param date - Thời gian local
 * @param timezone - Múi giờ (mặc định UTC)
 * @returns Date object ở UTC
 */
export function toUTC(date: Date, timezone: string = "UTC"): Date {
  // Trong production, nên dùng thư viện như date-fns-tz hoặc luxon
  // Đây là implementation đơn giản
  return new Date(date.toISOString());
}

/**
 * Chuyển đổi thời gian UTC sang múi giờ cụ thể
 * @param date - Thời gian UTC
 * @param timezone - Múi giờ đích
 * @returns Date object ở múi giờ đích
 */
export function fromUTC(date: Date, timezone: string): Date {
  // Trong production, nên dùng thư viện như date-fns-tz hoặc luxon
  return new Date(date.toLocaleString("en-US", { timeZone: timezone }));
}

/**
 * Format thời gian theo múi giờ
 */
export function formatDateInTimezone(
  date: Date,
  timezone: string,
  format: "full" | "date" | "time" = "full"
): string {
  const options: Intl.DateTimeFormatOptions = {
    timeZone: timezone,
  };

  if (format === "full" || format === "date") {
    options.year = "numeric";
    options.month = "2-digit";
    options.day = "2-digit";
  }

  if (format === "full" || format === "time") {
    options.hour = "2-digit";
    options.minute = "2-digit";
    options.second = "2-digit";
  }

  return new Intl.DateTimeFormat("en-US", options).format(date);
}

/**
 * Kiểm tra timezone có hợp lệ không
 */
export function isValidTimezone(timezone: string): boolean {
  try {
    Intl.DateTimeFormat(undefined, { timeZone: timezone });
    return true;
  } catch {
    return false;
  }
}

/**
 * Lấy offset của timezone (theo phút)
 */
export function getTimezoneOffset(timezone: string): number {
  const now = new Date();
  const tzDate = new Date(now.toLocaleString("en-US", { timeZone: timezone }));
  const utcDate = new Date(now.toLocaleString("en-US", { timeZone: "UTC" }));
  return (tzDate.getTime() - utcDate.getTime()) / (1000 * 60);
}
