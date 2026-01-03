import { Router } from "express";
import userRoutes from "./user.routes.js";
import calendarRoutes from "./calendar.routes.js";
import eventRoutes from "./event.routes.js";
import twoFactorRoutes from "./twoFactor.routes.js";
import smartAssistantRoutes from "./smart-assistant.routes.js";
/**
 * @swagger
 * tags:
 *   - name: Users
 *     description: User management and authentication
 *   - name: Calendars
 *     description: Calendar management
 *   - name: Events
 *     description: Event management and scheduling
 *   - name: 2FA
 *     description: Two-Factor Authentication
 *   - name: Smart Assistant
 *     description: AI-powered smart features and suggestions
 *   - name: Health
 *     description: Health check endpoints
 */
const router = Router();
/**
 * @swagger
 * /api/health:
 *   get:
 *     summary: Health check endpoint
 *     tags: [Health]
 *     security: []
 *     responses:
 *       200:
 *         description: API is healthy
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: ok
 *                 timestamp:
 *                   type: string
 *                   format: date-time
 *                 uptime:
 *                   type: number
 *                 environment:
 *                   type: string
 */
router.get("/health", (req, res) => {
    res.json({
        status: "ok",
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        environment: process.env.NODE_ENV || "development",
    });
});
/**
 * @swagger
 * /api:
 *   get:
 *     summary: API information
 *     tags: [Health]
 *     security: []
 *     responses:
 *       200:
 *         description: API information
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 name:
 *                   type: string
 *                 version:
 *                   type: string
 *                 description:
 *                   type: string
 *                 endpoints:
 *                   type: object
 */
router.get("/", (req, res) => {
    res.json({
        name: "Calendar Management API",
        version: "1.0.0",
        description: "API for managing calendars, events, and schedules with RBAC",
        endpoints: {
            health: "/api/health",
            docs: "/api-docs",
            users: "/api/users",
            calendars: "/api/calendars",
            events: "/api/events",
            "2fa": "/api/2fa",
            smart: "/api/smart",
        },
    });
});
// Mount routes
router.use("/users", userRoutes);
router.use("/calendars", calendarRoutes);
router.use("/events", eventRoutes);
router.use("/2fa", twoFactorRoutes);
router.use("/smart", smartAssistantRoutes);
export default router;
//# sourceMappingURL=index.js.map