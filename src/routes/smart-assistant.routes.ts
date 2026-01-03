import { Router } from "express";
import * as smartController from "../controllers/smart-assistant.controller.js";
import { authenticate } from "../midlewares/auth.middleware.js";

const router = Router();

/**
 * @swagger
 * /api/smart/analyze-event:
 *   post:
 *     summary: Analyze event and get AI suggestions
 *     tags: [Smart Assistant]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - title
 *             properties:
 *               title:
 *                 type: string
 *                 example: "Team Meeting"
 *               description:
 *                 type: string
 *                 example: "Discuss Q1 project updates"
 *               startTime:
 *                 type: string
 *                 format: date-time
 *                 example: "2026-01-10T10:00:00Z"
 *               location:
 *                 type: string
 *                 example: "Conference Room A"
 *     responses:
 *       200:
 *         description: Event analyzed with smart suggestions
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     category:
 *                       type: object
 *                       properties:
 *                         category:
 *                           type: string
 *                         icon:
 *                           type: string
 *                         color:
 *                           type: string
 *                         confidence:
 *                           type: number
 *                     suggestions:
 *                       type: array
 *                       items:
 *                         type: object
 *                     duration:
 *                       type: object
 */
router.post("/analyze-event", authenticate, smartController.analyzeEvent);

/**
 * @swagger
 * /api/smart/check-conflicts:
 *   post:
 *     summary: Check for scheduling conflicts
 *     tags: [Smart Assistant]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - calendarId
 *               - startTime
 *               - endTime
 *             properties:
 *               calendarId:
 *                 type: string
 *                 format: uuid
 *               startTime:
 *                 type: string
 *                 format: date-time
 *               endTime:
 *                 type: string
 *                 format: date-time
 *               excludeEventId:
 *                 type: string
 *                 format: uuid
 *     responses:
 *       200:
 *         description: Conflict check result
 */
router.post("/check-conflicts", authenticate, smartController.checkConflicts);

/**
 * @swagger
 * /api/smart/find-free-slots:
 *   post:
 *     summary: Find free time slots for scheduling
 *     tags: [Smart Assistant]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - calendarId
 *               - date
 *               - duration
 *             properties:
 *               calendarId:
 *                 type: string
 *                 format: uuid
 *               date:
 *                 type: string
 *                 format: date
 *                 example: "2026-01-10"
 *               duration:
 *                 type: number
 *                 description: Duration in minutes
 *                 example: 60
 *               workingHoursStart:
 *                 type: number
 *                 default: 9
 *                 example: 9
 *               workingHoursEnd:
 *                 type: number
 *                 default: 18
 *                 example: 18
 *     responses:
 *       200:
 *         description: List of free time slots
 */
router.post("/find-free-slots", authenticate, smartController.findFreeSlots);

/**
 * @swagger
 * /api/smart/suggest-time:
 *   post:
 *     summary: Suggest best time for an event
 *     tags: [Smart Assistant]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - calendarId
 *               - preferredDate
 *               - duration
 *             properties:
 *               calendarId:
 *                 type: string
 *               preferredDate:
 *                 type: string
 *                 format: date
 *               duration:
 *                 type: number
 *               preferences:
 *                 type: object
 *                 properties:
 *                   preferMorning:
 *                     type: boolean
 *                   preferAfternoon:
 *                     type: boolean
 *                   avoidLunchTime:
 *                     type: boolean
 *     responses:
 *       200:
 *         description: Best time suggestion
 */
router.post("/suggest-time", authenticate, smartController.suggestBestTime);

/**
 * @swagger
 * /api/smart/user-stats:
 *   get:
 *     summary: Get time analytics and insights
 *     tags: [Smart Assistant]
 *     parameters:
 *       - in: query
 *         name: startDate
 *         schema:
 *           type: string
 *           format: date
 *       - in: query
 *         name: endDate
 *         schema:
 *           type: string
 *           format: date
 *     responses:
 *       200:
 *         description: User statistics and insights
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     totalEvents:
 *                       type: number
 *                     totalHours:
 *                       type: number
 *                     categoryBreakdown:
 *                       type: object
 *                     busiestDay:
 *                       type: string
 *                     averageEventDuration:
 *                       type: number
 *                     insights:
 *                       type: array
 *                       items:
 *                         type: string
 */
router.get("/user-stats", authenticate, smartController.getUserStats);

/**
 * @swagger
 * /api/smart/auto-categorize:
 *   post:
 *     summary: Auto-categorize user's events using AI
 *     tags: [Smart Assistant]
 *     responses:
 *       200:
 *         description: Categorization result
 */
router.post(
  "/auto-categorize",
  authenticate,
  smartController.autoCategorizeEvents
);

export default router;
