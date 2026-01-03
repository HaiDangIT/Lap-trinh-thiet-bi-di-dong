import { AppError } from "../utils/errors.js";
import { errorResponse } from "../utils/response.util.js";
/**
 * Global error handler middleware
 */
export function errorHandler(err, req, res, next) {
    console.error("Error:", err);
    // Handle AppError (our custom errors)
    if (err instanceof AppError) {
        return res
            .status(err.statusCode)
            .json(errorResponse(err.message, err.statusCode));
    }
    // Handle Prisma errors
    if (err.name === "PrismaClientKnownRequestError") {
        const prismaError = err;
        if (prismaError.code === "P2002") {
            return res
                .status(409)
                .json(errorResponse("A record with this value already exists", 409));
        }
        if (prismaError.code === "P2025") {
            return res.status(404).json(errorResponse("Record not found", 404));
        }
    }
    // Handle validation errors from Prisma
    if (err.name === "PrismaClientValidationError") {
        return res.status(400).json(errorResponse("Invalid data provided", 400));
    }
    // Handle unknown errors
    const statusCode = 500;
    const message = process.env.NODE_ENV === "production"
        ? "Internal server error"
        : err.message || "Something went wrong";
    return res.status(statusCode).json(errorResponse(message, statusCode, {
        ...(process.env.NODE_ENV === "development" && { stack: err.stack }),
    }));
}
/**
 * Not found handler
 */
export function notFoundHandler(req, res) {
    res
        .status(404)
        .json(errorResponse(`Route ${req.originalUrl} not found`, 404));
}
/**
 * Async handler wrapper to catch errors in async route handlers
 */
export function asyncHandler(fn) {
    return (req, res, next) => {
        Promise.resolve(fn(req, res, next)).catch(next);
    };
}
//# sourceMappingURL=error.middleware.js.map