import { Router } from "express";
import userRoutes from "./user.routes.js";
import calendarRoutes from "./calendar.routes.js";
import eventRoutes from "./event.routes.js";
const router = Router();
// API routes
router.use("/users", userRoutes);
router.use("/calendars", calendarRoutes);
router.use("/events", eventRoutes);
// Health check
router.get("/health", (req, res) => {
    res.json({
        success: true,
        message: "Calendar API is running",
        timestamp: new Date().toISOString(),
    });
});
export default router;
//# sourceMappingURL=index.js.map