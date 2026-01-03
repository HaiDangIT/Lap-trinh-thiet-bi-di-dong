import express, {} from "express";
import swaggerUi from "swagger-ui-express";
import swaggerSpec from "./config/swagger.config.js";
import apiRoutes from "./routes/index.js";
import { errorHandler, notFoundHandler, } from "./midlewares/error.middleware.js";
import { requestLogger, cors, rateLimit, bodyLimit, } from "./midlewares/common.middleware.js";
/**
 * Create and configure Express application
 */
export function createApp() {
    const app = express();
    // Global middlewares
    app.use(cors);
    app.use(requestLogger);
    app.use(rateLimit(100, 60000)); // 100 requests per minute
    app.use(bodyLimit);
    app.use(express.json());
    app.use(express.urlencoded({ extended: true }));
    // Swagger documentation
    app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
        customCss: ".swagger-ui .topbar { display: none }",
        customSiteTitle: "Calendar API Documentation",
    }));
    // Swagger JSON endpoint
    app.get("/api-docs.json", (req, res) => {
        res.setHeader("Content-Type", "application/json");
        res.send(swaggerSpec);
    });
    // API routes
    app.use("/api", apiRoutes);
    // Root endpoint
    app.get("/", (req, res) => {
        res.json({
            success: true,
            message: "Calendar API Server",
            version: "1.0.0",
            documentation: "/api-docs",
            endpoints: {
                health: "/api/health",
                users: "/api/users",
                calendars: "/api/calendars",
                events: "/api/events",
            },
        });
    });
    // Error handlers (must be last)
    app.use(notFoundHandler);
    app.use(errorHandler);
    return app;
}
export default createApp;
//# sourceMappingURL=app.js.map