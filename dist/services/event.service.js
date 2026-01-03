import { Prisma } from "@prisma/client";
import eventRepository from "../repositories/event.repository.js";
import calendarRepository from "../repositories/calendar.repository.js";
import recurrenceRuleRepository from "../repositories/recurrence-rule.repository.js";
import eventExceptionRepository from "../repositories/event-exception.repository.js";
import attendeeRepository from "../repositories/attendee.repository.js";
import reminderRepository from "../repositories/reminder.repository.js";
import { ValidationError, NotFoundError, ForbiddenError, ConflictError, } from "../utils/errors.js";
import { isValidTimeRange, isTimeOverlap } from "../utils/date.util.js";
import { buildRRuleString, calculateOccurrences, } from "../utils/rrule.util.js";
export class EventService {
    /**
     * Tạo event mới
     */
    async createEvent(userId, dto) {
        // Validate calendar
        const calendar = await calendarRepository.findById(dto.calendarId);
        if (!calendar) {
            throw new NotFoundError("Calendar not found");
        }
        if (calendar.userId !== userId) {
            throw new ForbiddenError("You do not have access to this calendar");
        }
        // Validate time range
        if (!isValidTimeRange(dto.startTime, dto.endTime)) {
            throw new ValidationError("Start time must be before end time");
        }
        // Check conflicts if requested
        if (dto.checkConflicts) {
            const conflicts = await eventRepository.findConflicts(dto.calendarId, dto.startTime, dto.endTime);
            if (conflicts.length > 0) {
                throw new ConflictError(`Event conflicts with ${conflicts.length} existing event(s)`);
            }
        }
        // Prepare event data
        const eventData = {
            calendar: {
                connect: { id: dto.calendarId },
            },
            creator: {
                connect: { id: userId },
            },
            title: dto.title,
            description: dto.description,
            location: dto.location,
            startTime: dto.startTime,
            endTime: dto.endTime,
            isAllDay: dto.isAllDay || false,
            isRecurring: dto.isRecurring || false,
        };
        // Add recurrence rule if recurring
        if (dto.isRecurring && dto.recurrenceRule) {
            const rruleString = buildRRuleString(dto.recurrenceRule);
            eventData.recurrenceRule = {
                create: {
                    frequency: dto.recurrenceRule.frequency,
                    interval: dto.recurrenceRule.interval || 1,
                    byDay: dto.recurrenceRule.byDay?.join(","),
                    byMonthDay: dto.recurrenceRule.byMonthDay?.join(","),
                    byMonth: dto.recurrenceRule.byMonth?.join(","),
                    untilDate: dto.recurrenceRule.untilDate,
                    count: dto.recurrenceRule.count,
                    rruleString,
                },
            };
        }
        // Add attendees
        if (dto.attendees && dto.attendees.length > 0) {
            eventData.attendees = {
                create: dto.attendees.map((att) => ({
                    email: att.email,
                    displayName: att.displayName,
                    isOrganizer: att.isOrganizer || false,
                    status: "PENDING",
                })),
            };
        }
        // Add reminders
        if (dto.reminders && dto.reminders.length > 0) {
            eventData.reminders = {
                create: dto.reminders.map((rem) => ({
                    minutesBefore: rem.minutesBefore,
                    method: rem.method || "PUSH",
                })),
            };
        }
        // Create event
        const event = await eventRepository.create(eventData);
        return event;
    }
    /**
     * Lấy event theo ID
     */
    async getEventById(id, userId) {
        const event = await eventRepository.findById(id);
        if (!event) {
            throw new NotFoundError("Event not found");
        }
        // Kiểm tra quyền truy cập
        if (event.calendar.userId !== userId) {
            throw new ForbiddenError("You do not have access to this event");
        }
        return event;
    }
    /**
     * Lấy events trong khoảng thời gian
     */
    async getEventsInRange(userId, startTime, endTime, calendarId) {
        const filters = {
            startTime,
            endTime,
        };
        // Nếu có calendarId, kiểm tra quyền
        if (calendarId) {
            const calendar = await calendarRepository.findById(calendarId);
            if (!calendar || calendar.userId !== userId) {
                throw new ForbiddenError("You do not have access to this calendar");
            }
            filters.calendarId = calendarId;
        }
        else {
            // Lấy tất cả calendars của user
            const calendars = await calendarRepository.findByUserId(userId);
            const calendarIds = calendars.map((c) => c.id);
            if (calendarIds.length === 0) {
                return [];
            }
            // Filter by user's calendars
            filters.creatorId = userId;
        }
        const events = await eventRepository.findInRange(startTime, endTime, filters);
        // Expand recurring events
        const expandedEvents = [];
        for (const event of events) {
            if (event.isRecurring && event.recurrenceRule) {
                // Calculate occurrences
                const occurrences = calculateOccurrences(event.startTime, event.endTime, startTime, endTime, {
                    frequency: event.recurrenceRule.frequency,
                    interval: event.recurrenceRule.interval,
                    byDay: event.recurrenceRule.byDay?.split(","),
                    byMonthDay: event.recurrenceRule.byMonthDay
                        ?.split(",")
                        .map(Number),
                    byMonth: event.recurrenceRule.byMonth
                        ?.split(",")
                        .map(Number),
                    untilDate: event.recurrenceRule.untilDate || undefined,
                    count: event.recurrenceRule.count || undefined,
                });
                // Check exceptions
                const exceptions = event.exceptions || [];
                for (const occurrenceDate of occurrences) {
                    // Check if this occurrence has an exception
                    const exception = exceptions.find((ex) => ex.originalStartTime.getTime() === occurrenceDate.getTime());
                    if (exception?.isCancelled) {
                        // Skip cancelled occurrences
                        continue;
                    }
                    // Create virtual event for this occurrence
                    const virtualEvent = {
                        ...event,
                        startTime: exception?.newStartTime || occurrenceDate,
                        endTime: exception?.newEndTime ||
                            new Date(occurrenceDate.getTime() +
                                (event.endTime.getTime() - event.startTime.getTime())),
                        title: exception?.updatedTitle || event.title,
                        location: exception?.updatedLocation || event.location,
                    };
                    expandedEvents.push(virtualEvent);
                }
            }
            else {
                expandedEvents.push(event);
            }
        }
        return expandedEvents;
    }
    /**
     * Cập nhật event
     */
    async updateEvent(id, userId, dto) {
        const event = await eventRepository.findById(id);
        if (!event) {
            throw new NotFoundError("Event not found");
        }
        // Kiểm tra quyền
        if (event.calendar.userId !== userId) {
            throw new ForbiddenError("You do not have access to this event");
        }
        // Validate time range if both are provided
        if (dto.startTime && dto.endTime) {
            if (!isValidTimeRange(dto.startTime, dto.endTime)) {
                throw new ValidationError("Start time must be before end time");
            }
        }
        const updateData = {};
        if (dto.title !== undefined)
            updateData.title = dto.title;
        if (dto.description !== undefined)
            updateData.description = dto.description;
        if (dto.location !== undefined)
            updateData.location = dto.location;
        if (dto.startTime !== undefined)
            updateData.startTime = dto.startTime;
        if (dto.endTime !== undefined)
            updateData.endTime = dto.endTime;
        if (dto.isAllDay !== undefined)
            updateData.isAllDay = dto.isAllDay;
        return eventRepository.update(id, updateData);
    }
    /**
     * Update một occurrence của recurring event
     */
    async updateRecurringOccurrence(eventId, userId, dto) {
        const event = await eventRepository.findById(eventId);
        if (!event) {
            throw new NotFoundError("Event not found");
        }
        if (event.calendar.userId !== userId) {
            throw new ForbiddenError("You do not have access to this event");
        }
        if (!event.isRecurring) {
            throw new ValidationError("Event is not recurring");
        }
        // Tạo hoặc update exception
        const existingException = await eventExceptionRepository.findByEventAndDate(eventId, dto.originalStartTime);
        if (existingException) {
            await eventExceptionRepository.update(existingException.id, {
                newStartTime: dto.newStartTime || null,
                newEndTime: dto.newEndTime || null,
                updatedTitle: dto.updatedTitle || null,
                updatedLocation: dto.updatedLocation || null,
                isCancelled: dto.isCancelled || false,
            });
        }
        else {
            await eventExceptionRepository.create({
                event: {
                    connect: { id: eventId },
                },
                originalStartTime: dto.originalStartTime,
                newStartTime: dto.newStartTime || null,
                newEndTime: dto.newEndTime || null,
                updatedTitle: dto.updatedTitle || null,
                updatedLocation: dto.updatedLocation || null,
                isCancelled: dto.isCancelled || false,
            });
        }
    }
    /**
     * Xóa event
     */
    async deleteEvent(id, userId) {
        const event = await eventRepository.findById(id);
        if (!event) {
            throw new NotFoundError("Event not found");
        }
        if (event.calendar.userId !== userId) {
            throw new ForbiddenError("You do not have access to this event");
        }
        await eventRepository.delete(id);
    }
    /**
     * Tìm kiếm events
     */
    async searchEvents(userId, query, page = 1, pageSize = 20) {
        const skip = (page - 1) * pageSize;
        const events = await eventRepository.search(userId, query, skip, pageSize);
        return {
            events,
            page,
            pageSize,
        };
    }
    /**
     * Lấy upcoming events
     */
    async getUpcomingEvents(userId, limit = 10) {
        return eventRepository.findUpcomingByUserId(userId, limit);
    }
}
export default new EventService();
//# sourceMappingURL=event.service.js.map