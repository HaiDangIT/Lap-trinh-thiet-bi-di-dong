import { Router } from "express";
import * as calendarController from "../controllers/calendar.controller.js";
import { authenticate } from "../midlewares/auth.middleware.js";
import {
  validateCreateCalendar,
  validateUpdateCalendar,
} from "../validator/calendar.validator.js";

const router = Router();

// All routes require authentication
router.use(authenticate);

router.post("/", validateCreateCalendar, calendarController.createCalendar);
router.get("/", calendarController.getUserCalendars);
router.get("/:id", calendarController.getCalendarById);
router.put("/:id", validateUpdateCalendar, calendarController.updateCalendar);
router.delete("/:id", calendarController.deleteCalendar);
router.post("/:id/primary", calendarController.setPrimaryCalendar);

export default router;
