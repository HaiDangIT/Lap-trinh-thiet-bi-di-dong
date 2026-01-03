#!/usr/bin/env node

/**
 * Quick API Test Script
 * Run: node test-api.js
 */

const BASE_URL = "http://localhost:3000";

// Colors for terminal output
const colors = {
  reset: "\x1b[0m",
  green: "\x1b[32m",
  red: "\x1b[31m",
  yellow: "\x1b[33m",
  blue: "\x1b[34m",
  cyan: "\x1b[36m",
};

function log(message, color = "reset") {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

async function testEndpoint(method, path, body = null, headers = {}) {
  const url = `${BASE_URL}${path}`;
  const options = {
    method,
    headers: {
      "Content-Type": "application/json",
      ...headers,
    },
  };

  if (body) {
    options.body = JSON.stringify(body);
  }

  try {
    log(`\n→ ${method} ${path}`, "cyan");
    if (body) {
      log(`  Body: ${JSON.stringify(body, null, 2)}`, "yellow");
    }

    const response = await fetch(url, options);
    const data = await response.json();

    if (response.ok) {
      log(`✓ ${response.status} - Success`, "green");
      log(`  Response: ${JSON.stringify(data, null, 2)}`, "blue");
      return { success: true, data, status: response.status };
    } else {
      log(`✗ ${response.status} - Error`, "red");
      log(`  Response: ${JSON.stringify(data, null, 2)}`, "red");
      return { success: false, data, status: response.status };
    }
  } catch (error) {
    log(`✗ Request failed: ${error.message}`, "red");
    return { success: false, error: error.message };
  }
}

async function runTests() {
  log("\n╔════════════════════════════════════════╗", "cyan");
  log("║   API Test Suite - Calendar App       ║", "cyan");
  log("╚════════════════════════════════════════╝", "cyan");

  let testUserId = null;
  let testUserEmail = null;

  // Test 1: Health Check
  log("\n\n[TEST 1] Health Check", "yellow");
  log("═".repeat(50), "yellow");
  await testEndpoint("GET", "/api/health");

  // Test 2: API Info
  log("\n\n[TEST 2] API Information", "yellow");
  log("═".repeat(50), "yellow");
  await testEndpoint("GET", "/api");

  // Test 3: Register User
  log("\n\n[TEST 3] Register New User", "yellow");
  log("═".repeat(50), "yellow");
  const timestamp = Date.now();
  const testEmail = `test${timestamp}@example.com`;
  const registerResult = await testEndpoint("POST", "/api/users/register", {
    email: testEmail,
    password: "test123456",
    fullName: "Test User",
    timezone: "Asia/Ho_Chi_Minh",
  });

  if (registerResult.success) {
    testUserId = registerResult.data.data.id;
    testUserEmail = registerResult.data.data.email;
    log(`\n✓ Created user ID: ${testUserId}`, "green");
  }

  // Test 4: Login
  log("\n\n[TEST 4] User Login", "yellow");
  log("═".repeat(50), "yellow");
  const loginResult = await testEndpoint("POST", "/api/users/login", {
    email: testEmail,
    password: "test123456",
  });

  // Test 5: Get User Profile
  if (testUserId) {
    log("\n\n[TEST 5] Get User Profile", "yellow");
    log("═".repeat(50), "yellow");
    await testEndpoint("GET", "/api/users/me", null, {
      Authorization: `Bearer ${testUserId}`,
    });
  }

  // Test 6: Setup 2FA
  if (testUserId) {
    log("\n\n[TEST 6] Setup 2FA", "yellow");
    log("═".repeat(50), "yellow");
    const setupResult = await testEndpoint("POST", "/api/2fa/setup", null, {
      Authorization: `Bearer ${testUserId}`,
    });

    if (setupResult.success) {
      log("\n✓ 2FA Setup successful!", "green");
      log("  Secret: " + setupResult.data.data.secret, "cyan");
      log(
        "  Backup codes: " + setupResult.data.data.backupCodes.length,
        "cyan"
      );
      log("\n  ⚠️  QR Code generated (base64 data available)", "yellow");
    }
  }

  // Test 7: Get 2FA Status
  if (testUserId) {
    log("\n\n[TEST 7] Get 2FA Status", "yellow");
    log("═".repeat(50), "yellow");
    await testEndpoint("GET", "/api/2fa/status", null, {
      Authorization: `Bearer ${testUserId}`,
    });
  }

  // Test 8: Search Users
  if (testUserId) {
    log("\n\n[TEST 8] Search Users", "yellow");
    log("═".repeat(50), "yellow");
    await testEndpoint("GET", "/api/users/search?q=test&limit=5", null, {
      Authorization: `Bearer ${testUserId}`,
    });
  }

  // Test 9: Get User Stats
  if (testUserId) {
    log("\n\n[TEST 9] Get User Statistics", "yellow");
    log("═".repeat(50), "yellow");
    await testEndpoint("GET", `/api/users/${testUserId}/stats`, null, {
      Authorization: `Bearer ${testUserId}`,
    });
  }

  // Test 10: Update User
  if (testUserId) {
    log("\n\n[TEST 10] Update User", "yellow");
    log("═".repeat(50), "yellow");
    await testEndpoint(
      "PUT",
      `/api/users/${testUserId}`,
      {
        fullName: "Updated Test User",
        timezone: "Asia/Tokyo",
      },
      {
        Authorization: `Bearer ${testUserId}`,
      }
    );
  }

  // Test 11: Change Password
  if (testUserId) {
    log("\n\n[TEST 11] Change Password", "yellow");
    log("═".repeat(50), "yellow");
    await testEndpoint(
      "POST",
      "/api/users/change-password",
      {
        currentPassword: "test123456",
        newPassword: "newpass789",
      },
      {
        Authorization: `Bearer ${testUserId}`,
      }
    );
  }

  // Summary
  log("\n\n╔════════════════════════════════════════╗", "cyan");
  log("║         Test Suite Complete!           ║", "cyan");
  log("╚════════════════════════════════════════╝", "cyan");
  log("\n✓ All API endpoints tested", "green");
  log(`✓ Test user created: ${testUserEmail}`, "green");
  log(`✓ User ID: ${testUserId}`, "green");
  log("\n📝 Note: Some tests may fail if server is not running", "yellow");
  log("   Start server with: npm run dev\n", "yellow");
}

// Check if server is running
async function checkServer() {
  try {
    const response = await fetch(`${BASE_URL}/api/health`);
    return response.ok;
  } catch (error) {
    return false;
  }
}

// Main
(async () => {
  log("\n🚀 Starting API Test Suite...", "cyan");

  const serverRunning = await checkServer();
  if (!serverRunning) {
    log("\n✗ Error: Server is not running!", "red");
    log("  Please start the server first: npm run dev", "yellow");
    log("  Then run this test again.\n", "yellow");
    process.exit(1);
  }

  await runTests();
})();
