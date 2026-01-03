import type { Request, Response, NextFunction } from "express";

/**
 * Request logging middleware
 */
export function requestLogger(req: Request, res: Response, next: NextFunction) {
  const start = Date.now();

  // Log request
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);

  // Log response when finished
  res.on("finish", () => {
    const duration = Date.now() - start;
    console.log(
      `[${new Date().toISOString()}] ${req.method} ${req.path} - ${
        res.statusCode
      } (${duration}ms)`
    );
  });

  next();
}

/**
 * CORS middleware (simple implementation)
 */
export function cors(req: Request, res: Response, next: NextFunction) {
  const allowedOrigins = process.env.CORS_ORIGIN?.split(",") || [
    "http://localhost:5173",
  ];
  const origin = req.headers.origin;

  if (origin && allowedOrigins.includes(origin)) {
    res.setHeader("Access-Control-Allow-Origin", origin);
  }

  res.setHeader(
    "Access-Control-Allow-Methods",
    "GET, POST, PUT, PATCH, DELETE, OPTIONS"
  );
  res.setHeader(
    "Access-Control-Allow-Headers",
    "Content-Type, Authorization, X-User-Id"
  );
  res.setHeader("Access-Control-Allow-Credentials", "true");

  // Handle preflight
  if (req.method === "OPTIONS") {
    return res.status(204).end();
  }

  next();
}

/**
 * Rate limiting (simple implementation)
 */
const requestCounts = new Map<string, { count: number; resetTime: number }>();

export function rateLimit(
  maxRequests: number = 100,
  windowMs: number = 60000 // 1 minute
) {
  return (req: Request, res: Response, next: NextFunction) => {
    const ip = req.ip || req.socket.remoteAddress || "unknown";
    const now = Date.now();

    let record = requestCounts.get(ip);

    // Reset if window expired
    if (!record || now > record.resetTime) {
      record = {
        count: 0,
        resetTime: now + windowMs,
      };
      requestCounts.set(ip, record);
    }

    record.count++;

    if (record.count > maxRequests) {
      return res.status(429).json({
        success: false,
        error: {
          message: "Too many requests",
          statusCode: 429,
        },
      });
    }

    next();
  };
}

/**
 * Body parser size limit
 */
export function bodyLimit(req: Request, res: Response, next: NextFunction) {
  const contentLength = req.headers["content-length"];
  const maxSize = 10 * 1024 * 1024; // 10MB

  if (contentLength && parseInt(contentLength) > maxSize) {
    return res.status(413).json({
      success: false,
      error: {
        message: "Request body too large",
        statusCode: 413,
      },
    });
  }

  next();
}
