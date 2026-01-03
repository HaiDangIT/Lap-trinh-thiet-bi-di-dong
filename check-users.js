import prisma from "./dist/config/database.config.js";
import { hashPassword } from "./dist/utils/crypto.util.js";

async function checkUsers() {
  try {
    console.log("📋 Checking users in database...\n");

    const users = await prisma.user.findMany({
      select: {
        id: true,
        email: true,
        passwordHash: true,
        fullName: true,
        createdAt: true,
      },
      orderBy: {
        createdAt: "desc",
      },
    });

    if (users.length === 0) {
      console.log("❌ No users found in database!");
      console.log("💡 Please register a user first.\n");
    } else {
      console.log(`✅ Found ${users.length} user(s):\n`);

      users.forEach((user, index) => {
        console.log(`${index + 1}. Email: ${user.email}`);
        console.log(`   Full Name: ${user.fullName || "N/A"}`);
        console.log(`   Created: ${user.createdAt}`);
        console.log(
          `   Password Hash: ${user.passwordHash.substring(0, 30)}...`
        );
        console.log("");
      });

      // Test password hashing
      console.log("🔐 Testing password hashing:");
      const testPassword = "password123";
      const testHash = hashPassword(testPassword);
      console.log(`Password: "${testPassword}"`);
      console.log(`Hash: ${testHash}`);
      console.log("");

      // Check if any user has this password
      const matchingUser = users.find((u) => u.passwordHash === testHash);
      if (matchingUser) {
        console.log(
          `✅ User "${matchingUser.email}" has password: "${testPassword}"`
        );
      } else {
        console.log(`❌ No user has password: "${testPassword}"`);
        console.log(
          "💡 Try registering with this password or check your password."
        );
      }
    }
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    await prisma.$disconnect();
  }
}

checkUsers();
