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
export function buildRRuleString(options: RecurrenceOptions): string {
  const parts: string[] = [`FREQ=${options.frequency}`];

  if (options.interval && options.interval > 1) {
    parts.push(`INTERVAL=${options.interval}`);
  }

  if (options.byDay && options.byDay.length > 0) {
    parts.push(`BYDAY=${options.byDay.join(",")}`);
  }

  if (options.byMonthDay && options.byMonthDay.length > 0) {
    parts.push(`BYMONTHDAY=${options.byMonthDay.join(",")}`);
  }

  if (options.byMonth && options.byMonth.length > 0) {
    parts.push(`BYMONTH=${options.byMonth.join(",")}`);
  }

  if (options.untilDate) {
    const until =
      options.untilDate.toISOString().replace(/[-:]/g, "").split(".")[0] + "Z";
    parts.push(`UNTIL=${until}`);
  }

  if (options.count) {
    parts.push(`COUNT=${options.count}`);
  }

  return `RRULE:${parts.join(";")}`;
}

/**
 * Parse RRULE string thành options
 */
export function parseRRuleString(rrule: string): RecurrenceOptions | null {
  try {
    const ruleStr = rrule.replace("RRULE:", "");
    const parts = ruleStr.split(";");
    const options: Partial<RecurrenceOptions> = {};

    for (const part of parts) {
      const [key, value] = part.split("=");

      if (!value) continue;

      switch (key) {
        case "FREQ":
          options.frequency = value as Frequency;
          break;
        case "INTERVAL":
          options.interval = parseInt(value, 10);
          break;
        case "BYDAY":
          options.byDay = value.split(",") as Weekday[];
          break;
        case "BYMONTHDAY":
          options.byMonthDay = value.split(",").map((v) => parseInt(v, 10));
          break;
        case "BYMONTH":
          options.byMonth = value.split(",").map((v) => parseInt(v, 10));
          break;
        case "UNTIL":
          // Parse format: 20260101T000000Z
          const year = parseInt(value.substring(0, 4), 10);
          const month = parseInt(value.substring(4, 6), 10) - 1;
          const day = parseInt(value.substring(6, 8), 10);
          options.untilDate = new Date(Date.UTC(year, month, day));
          break;
        case "COUNT":
          options.count = parseInt(value, 10);
          break;
      }
    }

    return options.frequency ? (options as RecurrenceOptions) : null;
  } catch {
    return null;
  }
}

/**
 * Tính toán các occurrence trong khoảng thời gian
 */
export function calculateOccurrences(
  startDate: Date,
  endDate: Date,
  rangeStart: Date,
  rangeEnd: Date,
  recurrenceRule: RecurrenceOptions,
  maxOccurrences: number = 100
): Date[] {
  const occurrences: Date[] = [];
  let currentDate = new Date(startDate);
  let count = 0;

  // Nếu có count limit
  const countLimit = recurrenceRule.count || maxOccurrences;

  // Nếu có until date
  const untilLimit = recurrenceRule.untilDate || rangeEnd;

  while (
    currentDate <= untilLimit &&
    count < countLimit &&
    occurrences.length < maxOccurrences
  ) {
    // Kiểm tra xem currentDate có nằm trong range không
    if (currentDate >= rangeStart && currentDate <= rangeEnd) {
      // Kiểm tra các điều kiện byDay, byMonthDay, byMonth
      if (matchesRecurrenceRule(currentDate, recurrenceRule)) {
        occurrences.push(new Date(currentDate));
        count++;
      }
    }

    // Tăng currentDate theo frequency và interval
    currentDate = getNextOccurrence(currentDate, recurrenceRule);

    // Safety check để tránh infinite loop
    if (occurrences.length >= maxOccurrences) break;
  }

  return occurrences;
}

/**
 * Kiểm tra một ngày có khớp với recurrence rule không
 */
function matchesRecurrenceRule(date: Date, rule: RecurrenceOptions): boolean {
  // Kiểm tra byDay (thứ trong tuần)
  if (rule.byDay && rule.byDay.length > 0) {
    const dayOfWeek = date.getDay(); // 0 = Sunday
    const dayMap: Record<number, Weekday> = {
      0: "SU",
      1: "MO",
      2: "TU",
      3: "WE",
      4: "TH",
      5: "FR",
      6: "SA",
    };
    if (!rule.byDay.includes(dayMap[dayOfWeek]!)) {
      return false;
    }
  }

  // Kiểm tra byMonthDay (ngày trong tháng)
  if (rule.byMonthDay && rule.byMonthDay.length > 0) {
    const dayOfMonth = date.getDate();
    if (!rule.byMonthDay.includes(dayOfMonth)) {
      return false;
    }
  }

  // Kiểm tra byMonth (tháng trong năm)
  if (rule.byMonth && rule.byMonth.length > 0) {
    const month = date.getMonth() + 1; // 0-indexed to 1-indexed
    if (!rule.byMonth.includes(month)) {
      return false;
    }
  }

  return true;
}

/**
 * Lấy occurrence tiếp theo
 */
function getNextOccurrence(date: Date, rule: RecurrenceOptions): Date {
  const next = new Date(date);
  const interval = rule.interval || 1;

  switch (rule.frequency) {
    case "DAILY":
      next.setDate(next.getDate() + interval);
      break;
    case "WEEKLY":
      next.setDate(next.getDate() + 7 * interval);
      break;
    case "MONTHLY":
      next.setMonth(next.getMonth() + interval);
      break;
    case "YEARLY":
      next.setFullYear(next.getFullYear() + interval);
      break;
  }

  return next;
}

/**
 * Helper: Kiểm tra một ngày có phải là occurrence của sự kiện lặp
 */
export function isOccurrenceDate(
  date: Date,
  startDate: Date,
  recurrenceRule: RecurrenceOptions
): boolean {
  // Đơn giản hóa: tạo list occurrences và check
  const occurrences = calculateOccurrences(
    startDate,
    new Date(startDate.getTime() + 3600000), // +1 hour
    new Date(date.getFullYear(), date.getMonth(), date.getDate()),
    new Date(date.getFullYear(), date.getMonth(), date.getDate(), 23, 59, 59),
    recurrenceRule,
    10
  );

  return occurrences.some(
    (occ) =>
      occ.getFullYear() === date.getFullYear() &&
      occ.getMonth() === date.getMonth() &&
      occ.getDate() === date.getDate()
  );
}
