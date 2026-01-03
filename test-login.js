import crypto from "crypto";

function hashPassword(password) {
  return crypto.createHash("sha256").update(password).digest("hex");
}

function comparePassword(password, hash) {
  const passwordHash = hashPassword(password);
  console.log("Input password:", password);
  console.log("Hashed input:  ", passwordHash);
  console.log("Stored hash:   ", hash);
  console.log("Match:", passwordHash === hash);
  return passwordHash === hash;
}

// Test với password "password123"
const testPassword = "password123";
const expectedHash = hashPassword(testPassword);

console.log("🔐 Testing password hashing\n");
console.log("Password:", testPassword);
console.log("Expected hash:", expectedHash);
console.log("\n✅ Test comparePassword:");
comparePassword(testPassword, expectedHash);

console.log("\n❌ Test wrong password:");
comparePassword("wrongpassword", expectedHash);
