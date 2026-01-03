import type { Request, Response, NextFunction } from "express";
import { ValidationError } from "../utils/errors.js";
import { isValidEmail } from "../utils/crypto.util.js";

/**
 * Validate user registration
 */
export function validateUserRegistration(
  req: Request,
  res: Response,
  next: NextFunction
) {
  const { email, password, fullName, timezone } = req.body;

  if (!email || typeof email !== "string") {
    throw new ValidationError("Email is required");
  }

  if (!isValidEmail(email)) {
    throw new ValidationError("Invalid email format");
  }

  if (!password || typeof password !== "string") {
    throw new ValidationError("Password is required");
  }

  if (password.length < 6) {
    throw new ValidationError("Password must be at least 6 characters");
  }

  if (fullName !== undefined && typeof fullName !== "string") {
    throw new ValidationError("Full name must be a string");
  }

  if (timezone !== undefined && typeof timezone !== "string") {
    throw new ValidationError("Timezone must be a string");
  }

  next();
}

/**
 * Validate user login
 */
export function validateUserLogin(
  req: Request,
  res: Response,
  next: NextFunction
) {
  const { email, password } = req.body;

  if (!email || typeof email !== "string") {
    throw new ValidationError("Email is required");
  }

  if (!password || typeof password !== "string") {
    throw new ValidationError("Password is required");
  }

  next();
}

/**
 * Validate user update
 */
export function validateUserUpdate(
  req: Request,
  res: Response,
  next: NextFunction
) {
  const { fullName, timezone, password } = req.body;

  if (fullName !== undefined && typeof fullName !== "string") {
    throw new ValidationError("Full name must be a string");
  }

  if (timezone !== undefined && typeof timezone !== "string") {
    throw new ValidationError("Timezone must be a string");
  }

  if (password !== undefined) {
    if (typeof password !== "string") {
      throw new ValidationError("Password must be a string");
    }
    if (password.length < 6) {
      throw new ValidationError("Password must be at least 6 characters");
    }
  }

  next();
}
