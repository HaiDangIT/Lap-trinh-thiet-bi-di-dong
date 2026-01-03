/**
 * Response utilities
 */
export interface SuccessResponse<T = any> {
    success: true;
    data: T;
    message?: string;
}
export interface ErrorResponse {
    success: false;
    error: {
        message: string;
        statusCode: number;
        details?: any;
    };
}
export interface PaginatedResponse<T = any> {
    success: true;
    data: T[];
    pagination: {
        page: number;
        pageSize: number;
        totalItems: number;
        totalPages: number;
        hasNext: boolean;
        hasPrev: boolean;
    };
}
export declare function successResponse<T>(data: T, message?: string): SuccessResponse<T>;
export declare function errorResponse(message: string, statusCode?: number, details?: any): ErrorResponse;
export declare function paginatedResponse<T>(data: T[], page: number, pageSize: number, totalItems: number): PaginatedResponse<T>;
//# sourceMappingURL=response.util.d.ts.map