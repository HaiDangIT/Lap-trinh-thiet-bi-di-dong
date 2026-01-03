import { createApp } from "./app.js";
import config from "./config/env.config.js";
import prisma from "./config/database.config.js";
/**
 * Start the server
 */
async function startServer() {
    try {
        // Test database connection
        await prisma.$connect();
        console.log("✅ Database connected successfully");
        // Create Express app
        const app = createApp();
        // Start listening
        const server = app.listen(config.port, () => {
            console.log("🚀 Server started successfully");
            console.log(`📍 Environment: ${config.nodeEnv}`);
            console.log(`🌐 Server running on: http://localhost:${config.port}`);
            console.log(`📊 API Documentation: http://localhost:${config.port}/api`);
            console.log(`💚 Health Check: http://localhost:${config.port}/api/health`);
        });
        // Graceful shutdown
        const gracefulShutdown = async (signal) => {
            console.log(`\n${signal} received, shutting down gracefully...`);
            server.close(async () => {
                console.log("🔌 HTTP server closed");
                // Disconnect from database
                await prisma.$disconnect();
                console.log("🔌 Database disconnected");
                console.log("👋 Server shutdown complete");
                process.exit(0);
            });
            // Force shutdown after 10 seconds
            setTimeout(() => {
                console.error("⚠️  Forced shutdown due to timeout");
                process.exit(1);
            }, 10000);
        };
        // Handle shutdown signals
        process.on("SIGTERM", () => gracefulShutdown("SIGTERM"));
        process.on("SIGINT", () => gracefulShutdown("SIGINT"));
        // Handle uncaught errors
        process.on("uncaughtException", (error) => {
            console.error("❌ Uncaught Exception:", error);
            gracefulShutdown("UNCAUGHT_EXCEPTION");
        });
        process.on("unhandledRejection", (reason, promise) => {
            console.error("❌ Unhandled Rejection at:", promise, "reason:", reason);
            gracefulShutdown("UNHANDLED_REJECTION");
        });
    }
    catch (error) {
        console.error("❌ Failed to start server:", error);
        process.exit(1);
    }
}
// Start the server
startServer();
//# sourceMappingURL=server.js.map