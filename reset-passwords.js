import prisma from "./dist/config/database.config.js";
import { hashPassword } from "./dist/utils/crypto.util.js";

async function resetPasswords() {
  try {
    console.log('🔐 Resetting passwords to "password123" for all users...\n');

    const newPassword = "password123";
    const newHash = hashPassword(newPassword);

    const result = await prisma.user.updateMany({
      data: {
        passwordHash: newHash,
      },
    });

    console.log(`✅ Updated ${result.count} user(s)`);
    console.log(`\n🎉 All users now have password: "${newPassword}"\n`);

    // Show all users
    const users = await prisma.user.findMany({
      select: { email: true },
    });

    console.log("📋 Users:");
    users.forEach((u) => console.log(`   - ${u.email}`));
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    await prisma.$disconnect();
  }
}

resetPasswords();
