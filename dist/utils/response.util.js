/**
 * Response utilities
 */
export function successResponse(data, message) {
    return {
        success: true,
        data,
        ...(message && { message }),
    };
}
export function errorResponse(message, statusCode = 500, details) {
    return {
        success: false,
        error: {
            message,
            statusCode,
            ...(details && { details }),
        },
    };
}
export function paginatedResponse(data, page, pageSize, totalItems) {
    const totalPages = Math.ceil(totalItems / pageSize);
    return {
        success: true,
        data,
        pagination: {
            page,
            pageSize,
            totalItems,
            totalPages,
            hasNext: page < totalPages,
            hasPrev: page > 1,
        },
    };
}
//# sourceMappingURL=response.util.js.map