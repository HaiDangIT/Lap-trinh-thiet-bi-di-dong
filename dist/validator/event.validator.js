import { ValidationError } from "../utils/errors.js";
import { isValidDate, parseISODate } from "../utils/date.util.js";
import { isValidEmail } from "../utils/crypto.util.js";
/**
 * Validate event creation
 */
export function validateCreateEvent(req, res, next) {
    const { calendarId, title, startTime, endTime, isAllDay, isRecurring, recurrenceRule, attendees, reminders, } = req.body;
    // Required fields
    if (!calendarId || typeof calendarId !== "string") {
        throw new ValidationError("Calendar ID is required");
    }
    if (!title || typeof title !== "string") {
        throw new ValidationError("Event title is required");
    }
    if (title.trim().length === 0) {
        throw new ValidationError("Event title cannot be empty");
    }
    if (!startTime || typeof startTime !== "string") {
        throw new ValidationError("Start time is required");
    }
    if (!endTime || typeof endTime !== "string") {
        throw new ValidationError("End time is required");
    }
    // Parse and validate dates
    const start = parseISODate(startTime);
    const end = parseISODate(endTime);
    if (!start || !isValidDate(start)) {
        throw new ValidationError("Invalid start time format");
    }
    if (!end || !isValidDate(end)) {
        throw new ValidationError("Invalid end time format");
    }
    if (start >= end) {
        throw new ValidationError("Start time must be before end time");
    }
    // Store parsed dates in request for later use
    req.body.startTime = start;
    req.body.endTime = end;
    // Optional fields validation
    if (isAllDay !== undefined && typeof isAllDay !== "boolean") {
        throw new ValidationError("isAllDay must be a boolean");
    }
    if (isRecurring !== undefined && typeof isRecurring !== "boolean") {
        throw new ValidationError("isRecurring must be a boolean");
    }
    // Validate recurrence rule if recurring
    if (isRecurring && recurrenceRule) {
        validateRecurrenceRule(recurrenceRule);
    }
    // Validate attendees
    if (attendees !== undefined) {
        if (!Array.isArray(attendees)) {
            throw new ValidationError("Attendees must be an array");
        }
        attendees.forEach((attendee, index) => {
            if (!attendee.email || typeof attendee.email !== "string") {
                throw new ValidationError(`Attendee ${index + 1}: Email is required`);
            }
            if (!isValidEmail(attendee.email)) {
                throw new ValidationError(`Attendee ${index + 1}: Invalid email format`);
            }
        });
    }
    // Validate reminders
    if (reminders !== undefined) {
        if (!Array.isArray(reminders)) {
            throw new ValidationError("Reminders must be an array");
        }
        reminders.forEach((reminder, index) => {
            if (reminder.minutesBefore === undefined ||
                typeof reminder.minutesBefore !== "number") {
                throw new ValidationError(`Reminder ${index + 1}: minutesBefore is required`);
            }
            if (reminder.minutesBefore < 0) {
                throw new ValidationError(`Reminder ${index + 1}: minutesBefore must be positive`);
            }
        });
    }
    next();
}
/**
 * Validate recurrence rule
 */
function validateRecurrenceRule(rule) {
    const validFrequencies = ["DAILY", "WEEKLY", "MONTHLY", "YEARLY"];
    if (!rule.frequency || !validFrequencies.includes(rule.frequency)) {
        throw new ValidationError(`Frequency must be one of: ${validFrequencies.join(", ")}`);
    }
    if (rule.interval !== undefined) {
        if (typeof rule.interval !== "number" || rule.interval < 1) {
            throw new ValidationError("Interval must be a positive number");
        }
    }
    if (rule.byDay !== undefined) {
        if (!Array.isArray(rule.byDay)) {
            throw new ValidationError("byDay must be an array");
        }
        const validDays = ["MO", "TU", "WE", "TH", "FR", "SA", "SU"];
        rule.byDay.forEach((day) => {
            if (!validDays.includes(day)) {
                throw new ValidationError(`Invalid day: ${day}. Must be one of: ${validDays.join(", ")}`);
            }
        });
    }
    if (rule.untilDate !== undefined) {
        const until = parseISODate(rule.untilDate);
        if (!until || !isValidDate(until)) {
            throw new ValidationError("Invalid untilDate format");
        }
        rule.untilDate = until;
    }
    if (rule.count !== undefined) {
        if (typeof rule.count !== "number" || rule.count < 1) {
            throw new ValidationError("Count must be a positive number");
        }
    }
}
/**
 * Validate event update
 */
export function validateUpdateEvent(req, res, next) {
    const { title, startTime, endTime, isAllDay } = req.body;
    if (title !== undefined) {
        if (typeof title !== "string") {
            throw new ValidationError("Title must be a string");
        }
        if (title.trim().length === 0) {
            throw new ValidationError("Title cannot be empty");
        }
    }
    if (startTime !== undefined) {
        const start = parseISODate(startTime);
        if (!start || !isValidDate(start)) {
            throw new ValidationError("Invalid start time format");
        }
        req.body.startTime = start;
    }
    if (endTime !== undefined) {
        const end = parseISODate(endTime);
        if (!end || !isValidDate(end)) {
            throw new ValidationError("Invalid end time format");
        }
        req.body.endTime = end;
    }
    if (isAllDay !== undefined && typeof isAllDay !== "boolean") {
        throw new ValidationError("isAllDay must be a boolean");
    }
    next();
}
/**
 * Validate get events in range
 */
export function validateGetEventsInRange(req, res, next) {
    const { startTime, endTime } = req.query;
    if (!startTime || typeof startTime !== "string") {
        throw new ValidationError("Start time is required");
    }
    if (!endTime || typeof endTime !== "string") {
        throw new ValidationError("End time is required");
    }
    const start = parseISODate(startTime);
    const end = parseISODate(endTime);
    if (!start || !isValidDate(start)) {
        throw new ValidationError("Invalid start time format");
    }
    if (!end || !isValidDate(end)) {
        throw new ValidationError("Invalid end time format");
    }
    if (start >= end) {
        throw new ValidationError("Start time must be before end time");
    }
    // Store parsed dates
    req.query.startTime = start.toISOString();
    req.query.endTime = end.toISOString();
    next();
}
//# sourceMappingURL=event.validator.js.map