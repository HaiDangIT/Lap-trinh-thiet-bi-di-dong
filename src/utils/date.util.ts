/**
 * Date utilities
 */

/**
 * Kiểm tra date có hợp lệ không
 */
export function isValidDate(date: any): boolean {
  return date instanceof Date && !isNaN(date.getTime());
}

/**
 * Parse ISO string to Date
 */
export function parseISODate(dateString: string): Date | null {
  try {
    const date = new Date(dateString);
    return isValidDate(date) ? date : null;
  } catch {
    return null;
  }
}

/**
 * Kiểm tra startTime < endTime
 */
export function isValidTimeRange(startTime: Date, endTime: Date): boolean {
  return startTime < endTime;
}

/**
 * Kiểm tra 2 khoảng thời gian có overlap không
 */
export function isTimeOverlap(
  start1: Date,
  end1: Date,
  start2: Date,
  end2: Date
): boolean {
  return start1 < end2 && start2 < end1;
}

/**
 * Get start of day
 */
export function startOfDay(date: Date): Date {
  const d = new Date(date);
  d.setHours(0, 0, 0, 0);
  return d;
}

/**
 * Get end of day
 */
export function endOfDay(date: Date): Date {
  const d = new Date(date);
  d.setHours(23, 59, 59, 999);
  return d;
}

/**
 * Add days to date
 */
export function addDays(date: Date, days: number): Date {
  const result = new Date(date);
  result.setDate(result.getDate() + days);
  return result;
}

/**
 * Get start of week (Monday)
 */
export function startOfWeek(date: Date): Date {
  const d = new Date(date);
  const day = d.getDay();
  const diff = d.getDate() - day + (day === 0 ? -6 : 1); // adjust when day is Sunday
  d.setDate(diff);
  return startOfDay(d);
}

/**
 * Get end of week (Sunday)
 */
export function endOfWeek(date: Date): Date {
  const start = startOfWeek(date);
  return endOfDay(addDays(start, 6));
}

/**
 * Get start of month
 */
export function startOfMonth(date: Date): Date {
  const d = new Date(date);
  d.setDate(1);
  return startOfDay(d);
}

/**
 * Get end of month
 */
export function endOfMonth(date: Date): Date {
  const d = new Date(date);
  d.setMonth(d.getMonth() + 1);
  d.setDate(0);
  return endOfDay(d);
}

/**
 * Format duration in minutes to human readable
 */
export function formatDuration(minutes: number): string {
  if (minutes < 60) {
    return `${minutes}m`;
  }
  const hours = Math.floor(minutes / 60);
  const mins = minutes % 60;
  return mins > 0 ? `${hours}h ${mins}m` : `${hours}h`;
}
