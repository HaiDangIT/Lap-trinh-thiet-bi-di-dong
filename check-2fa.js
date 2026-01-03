import prisma from "./dist/config/database.config.js";
import speakeasy from "speakeasy";

async function check2FASetup() {
  try {
    console.log("🔐 Checking 2FA setup in database...\n");

    const twoFactorRecords = await prisma.twoFactor.findMany({
      include: {
        user: {
          select: {
            email: true,
            fullName: true,
          },
        },
      },
    });

    if (twoFactorRecords.length === 0) {
      console.log("❌ No 2FA records found in database!");
      return;
    }

    console.log(`✅ Found ${twoFactorRecords.length} 2FA record(s):\n`);

    for (const record of twoFactorRecords) {
      console.log(`User: ${record.user.email}`);
      console.log(`  - Full Name: ${record.user.fullName}`);
      console.log(`  - Is Enabled: ${record.isEnabled}`);
      console.log(
        `  - Secret: ${
          record.secret ? record.secret.substring(0, 10) + "..." : "NULL"
        }`
      );
      console.log(`  - Secret Length: ${record.secret?.length || 0}`);
      console.log(`  - Backup Codes Count: ${record.backupCodes?.length || 0}`);

      // Generate current token from secret for testing
      if (record.secret) {
        try {
          const currentToken = speakeasy.totp({
            secret: record.secret,
            encoding: "base32",
          });
          console.log(`  - Current Token (for testing): ${currentToken}`);
          console.log(`  - Use this token in your app to test!`);
        } catch (error) {
          console.log(`  - ❌ Error generating token: ${error.message}`);
        }
      }
      console.log("");
    }
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    await prisma.$disconnect();
  }
}

check2FASetup();
