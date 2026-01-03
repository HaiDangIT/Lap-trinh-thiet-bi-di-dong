import prisma from "./dist/config/database.config.js";

async function reset2FA() {
  try {
    console.log("🔄 Resetting 2FA for all users...\n");

    // Delete all 2FA records
    const result = await prisma.twoFactor.deleteMany({});

    console.log(`✅ Deleted ${result.count} 2FA record(s)`);
    console.log("\n✨ 2FA reset complete!");
    console.log("\n📝 Next steps:");
    console.log("1. Start server: npm start");
    console.log("2. Call POST /api/2fa/setup to get NEW QR code");
    console.log("3. Delete old entry in Google Authenticator");
    console.log("4. Scan NEW QR code");
    console.log("5. Call POST /api/2fa/enable with token from app");
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    await prisma.$disconnect();
  }
}

reset2FA();
