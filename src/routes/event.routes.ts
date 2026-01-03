import { Router } from "express";
import * as eventController from "../controllers/event.controller.js";
import { authenticate } from "../midlewares/auth.middleware.js";
import { authorize } from "../midlewares/authorization.middleware.js";
import { Permissions } from "../config/permissions.config.js";
import {
  validateCreateEvent,
  validateUpdateEvent,
  validateGetEventsInRange,
} from "../validator/event.validator.js";

const router = Router();

// All routes require authentication
router.use(authenticate);

/**
 * @swagger
 * /api/events/range:
 *   get:
 *     summary: Get events in date range
 *     tags: [Events]
 *     parameters:
 *       - in: query
 *         name: startTime
 *         required: true
 *         schema:
 *           type: string
 *           format: date-time
 *       - in: query
 *         name: endTime
 *         required: true
 *         schema:
 *           type: string
 *           format: date-time
 *       - in: query
 *         name: calendarId
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: List of events
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Event'
 */
router.get(
  "/range",
  validateGetEventsInRange,
  authorize(Permissions.EVENT_READ),
  eventController.getEventsInRange
);

/**
 * @swagger
 * /api/events/search:
 *   get:
 *     summary: Search events
 *     tags: [Events]
 *     parameters:
 *       - in: query
 *         name: q
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Search results
 */
router.get(
  "/search",
  authorize(Permissions.EVENT_READ),
  eventController.searchEvents
);

/**
 * @swagger
 * /api/events/upcoming:
 *   get:
 *     summary: Get upcoming events
 *     tags: [Events]
 *     responses:
 *       200:
 *         description: Upcoming events
 */
router.get(
  "/upcoming",
  authorize(Permissions.EVENT_READ),
  eventController.getUpcomingEvents
);

/**
 * @swagger
 * /api/events:
 *   post:
 *     summary: Create a new event
 *     tags: [Events]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - title
 *               - startTime
 *               - endTime
 *               - calendarId
 *             properties:
 *               title:
 *                 type: string
 *               description:
 *                 type: string
 *               location:
 *                 type: string
 *               startTime:
 *                 type: string
 *                 format: date-time
 *               endTime:
 *                 type: string
 *                 format: date-time
 *               isAllDay:
 *                 type: boolean
 *               isRecurring:
 *                 type: boolean
 *               calendarId:
 *                 type: string
 *                 format: uuid
 *               recurrence:
 *                 type: object
 *                 properties:
 *                   frequency:
 *                     type: string
 *                     enum: [DAILY, WEEKLY, MONTHLY, YEARLY]
 *                   interval:
 *                     type: integer
 *                   byDay:
 *                     type: string
 *                   count:
 *                     type: integer
 *               attendees:
 *                 type: array
 *                 items:
 *                   type: object
 *                   properties:
 *                     email:
 *                       type: string
 *                     name:
 *                       type: string
 *               reminders:
 *                 type: array
 *                 items:
 *                   type: object
 *                   properties:
 *                     minutesBefore:
 *                       type: integer
 *                     method:
 *                       type: string
 *     responses:
 *       201:
 *         description: Event created
 *       400:
 *         $ref: '#/components/responses/ValidationError'
 */
router.post(
  "/",
  validateCreateEvent,
  authorize(Permissions.EVENT_WRITE),
  eventController.createEvent
);

/**
 * @swagger
 * /api/events/{id}:
 *   get:
 *     summary: Get event by ID
 *     tags: [Events]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: Event details
 *       404:
 *         $ref: '#/components/responses/NotFoundError'
 */
router.get(
  "/:id",
  authorize(Permissions.EVENT_READ),
  eventController.getEventById
);

/**
 * @swagger
 * /api/events/{id}:
 *   put:
 *     summary: Update event
 *     tags: [Events]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *               description:
 *                 type: string
 *               startTime:
 *                 type: string
 *                 format: date-time
 *               endTime:
 *                 type: string
 *                 format: date-time
 *     responses:
 *       200:
 *         description: Event updated
 */
router.put(
  "/:id",
  validateUpdateEvent,
  authorize(Permissions.EVENT_WRITE),
  eventController.updateEvent
);

/**
 * @swagger
 * /api/events/{id}/occurrence:
 *   put:
 *     summary: Update a single occurrence of recurring event
 *     tags: [Events]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - originalStartTime
 *             properties:
 *               originalStartTime:
 *                 type: string
 *                 format: date-time
 *               newStartTime:
 *                 type: string
 *                 format: date-time
 *               newEndTime:
 *                 type: string
 *                 format: date-time
 *               updatedTitle:
 *                 type: string
 *               isCancelled:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Occurrence updated
 */
router.put(
  "/:id/occurrence",
  authorize(Permissions.EVENT_WRITE),
  eventController.updateRecurringOccurrence
);

/**
 * @swagger
 * /api/events/{id}:
 *   delete:
 *     summary: Delete event
 *     tags: [Events]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Event deleted
 *       403:
 *         $ref: '#/components/responses/ForbiddenError'
 */
router.delete(
  "/:id",
  authorize(Permissions.EVENT_DELETE),
  eventController.deleteEvent
);

export default router;
