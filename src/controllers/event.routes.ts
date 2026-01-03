import { Router } from "express";
import * as eventController from "../controllers/event.controller.js";
import { authenticate } from "../midlewares/auth.middleware.js";
import {
  validateCreateEvent,
  validateUpdateEvent,
  validateGetEventsInRange,
} from "../validator/event.validator.js";

const router = Router();

// All routes require authentication
router.use(authenticate);

// Special routes (must come before /:id)
router.get("/search", eventController.searchEvents);
router.get("/upcoming", eventController.getUpcomingEvents);
router.get(
  "/range",
  validateGetEventsInRange,
  eventController.getEventsInRange
);

// CRUD routes
router.post("/", validateCreateEvent, eventController.createEvent);
router.get("/:id", eventController.getEventById);
router.put("/:id", validateUpdateEvent, eventController.updateEvent);
router.put("/:id/occurrence", eventController.updateRecurringOccurrence);
router.delete("/:id", eventController.deleteEvent);

export default router;
