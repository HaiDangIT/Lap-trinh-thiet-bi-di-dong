import { Router } from "express";
import * as calendarController from "../controllers/calendar.controller.js";
import { authenticate } from "../midlewares/auth.middleware.js";
import { authorize } from "../midlewares/authorization.middleware.js";
import { Permissions } from "../config/permissions.config.js";
import {
  validateCreateCalendar,
  validateUpdateCalendar,
} from "../validator/calendar.validator.js";

const router = Router();

// All routes require authentication
router.use(authenticate);

/**
 * @swagger
 * /api/calendars:
 *   post:
 *     summary: Create a new calendar
 *     tags: [Calendars]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *             properties:
 *               name:
 *                 type: string
 *               colorCode:
 *                 type: string
 *                 default: '#039BE5'
 *               isPrimary:
 *                 type: boolean
 *                 default: false
 *     responses:
 *       201:
 *         description: Calendar created
 *       400:
 *         $ref: '#/components/responses/ValidationError'
 */
router.post(
  "/",
  validateCreateCalendar,
  authorize(Permissions.CALENDAR_WRITE),
  calendarController.createCalendar
);

/**
 * @swagger
 * /api/calendars:
 *   get:
 *     summary: Get all calendars of current user
 *     tags: [Calendars]
 *     responses:
 *       200:
 *         description: List of calendars
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
 *                     $ref: '#/components/schemas/Calendar'
 */
router.get(
  "/",
  authorize(Permissions.CALENDAR_READ),
  calendarController.getUserCalendars
);

/**
 * @swagger
 * /api/calendars/{id}:
 *   get:
 *     summary: Get calendar by ID
 *     tags: [Calendars]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: Calendar details
 *       404:
 *         $ref: '#/components/responses/NotFoundError'
 */
router.get(
  "/:id",
  authorize(Permissions.CALENDAR_READ),
  calendarController.getCalendarById
);

/**
 * @swagger
 * /api/calendars/{id}:
 *   put:
 *     summary: Update calendar
 *     tags: [Calendars]
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
 *               name:
 *                 type: string
 *               colorCode:
 *                 type: string
 *     responses:
 *       200:
 *         description: Calendar updated
 */
router.put(
  "/:id",
  validateUpdateCalendar,
  authorize(Permissions.CALENDAR_WRITE),
  calendarController.updateCalendar
);

/**
 * @swagger
 * /api/calendars/{id}:
 *   delete:
 *     summary: Delete calendar
 *     tags: [Calendars]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Calendar deleted
 *       403:
 *         $ref: '#/components/responses/ForbiddenError'
 */
router.delete(
  "/:id",
  authorize(Permissions.CALENDAR_DELETE),
  calendarController.deleteCalendar
);

/**
 * @swagger
 * /api/calendars/{id}/primary:
 *   post:
 *     summary: Set calendar as primary
 *     tags: [Calendars]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Calendar set as primary
 */
router.post(
  "/:id/primary",
  authorize(Permissions.CALENDAR_WRITE),
  calendarController.setPrimaryCalendar
);

export default router;
