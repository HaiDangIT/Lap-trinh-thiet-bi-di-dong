import dotenv from "dotenv";
dotenv.config();
export const config = {
    // Server
    port: parseInt(process.env.PORT || "3000", 10),
    nodeEnv: process.env.NODE_ENV || "development",
    // Database
    databaseUrl: process.env.DATABASE_URL || "",
    // JWT
    jwtSecret: process.env.JWT_SECRET || "fallback-secret-key",
    jwtExpiresIn: process.env.JWT_EXPIRES_IN || "7d",
    // Timezone
    defaultTimezone: process.env.DEFAULT_TIMEZONE || "UTC",
    // CORS
    corsOrigin: process.env.CORS_ORIGIN || "http://localhost:5173",
    // Pagination
    defaultPageSize: 20,
    maxPageSize: 100,
};
export default config;
//# sourceMappingURL=env.config.js.map