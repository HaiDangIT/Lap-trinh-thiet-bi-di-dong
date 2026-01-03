import type { Request, Response, NextFunction } from "express";
import { ValidationError } from "../utils/errors.js";

/**
 * Validate calendar creation
 */
export function validateCreateCalendar(
  req: Request,
  res: Response,
  next: NextFunction
) {
  const { name, colorCode, isPrimary } = req.body;

  if (!name || typeof name !== "string") {
    throw new ValidationError("Calendar name is required");
  }

  if (name.trim().length === 0) {
    throw new ValidationError("Calendar name cannot be empty");
  }

  if (colorCode !== undefined) {
    if (typeof colorCode !== "string") {
      throw new ValidationError("Color code must be a string");
    }
    // Validate hex color format
    if (!/^#[0-9A-F]{6}$/i.test(colorCode)) {
      throw new ValidationError(
        "Color code must be in hex format (e.g., #039BE5)"
      );
    }
  }

  if (isPrimary !== undefined && typeof isPrimary !== "boolean") {
    throw new ValidationError("isPrimary must be a boolean");
  }

  next();
}

/**
 * Validate calendar update
 */
export function validateUpdateCalendar(
  req: Request,
  res: Response,
  next: NextFunction
) {
  const { name, colorCode, isPrimary } = req.body;

  if (name !== undefined) {
    if (typeof name !== "string") {
      throw new ValidationError("Calendar name must be a string");
    }
    if (name.trim().length === 0) {
      throw new ValidationError("Calendar name cannot be empty");
    }
  }

  if (colorCode !== undefined) {
    if (typeof colorCode !== "string") {
      throw new ValidationError("Color code must be a string");
    }
    if (!/^#[0-9A-F]{6}$/i.test(colorCode)) {
      throw new ValidationError(
        "Color code must be in hex format (e.g., #039BE5)"
      );
    }
  }

  if (isPrimary !== undefined && typeof isPrimary !== "boolean") {
    throw new ValidationError("isPrimary must be a boolean");
  }

  next();
}
