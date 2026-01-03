export class AppError extends Error {
    statusCode;
    message;
    isOperational;
    constructor(statusCode, message, isOperational = true) {
        super(message);
        this.statusCode = statusCode;
        this.message = message;
        this.isOperational = isOperational;
        Object.setPrototypeOf(this, AppError.prototype);
        Error.captureStackTrace(this, this.constructor);
    }
}
export class ValidationError extends AppError {
    constructor(message) {
        super(400, message);
    }
}
export class NotFoundError extends AppError {
    constructor(message = "Resource not found") {
        super(404, message);
    }
}
export class UnauthorizedError extends AppError {
    constructor(message = "Unauthorized") {
        super(401, message);
    }
}
export class BadRequestError extends AppError {
    constructor(message = "Bad Request") {
        super(400, message);
    }
}
export class ForbiddenError extends AppError {
    constructor(message = "Forbidden") {
        super(403, message);
    }
}
export class ConflictError extends AppError {
    constructor(message = "Resource conflict") {
        super(409, message);
    }
}
//# sourceMappingURL=errors.js.map