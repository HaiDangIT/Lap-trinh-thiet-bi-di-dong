# 📱 HƯỚNG DẪN TÍCH HỢP 2FA CHO MOBILE APP

## 📋 **MỤC LỤC**

- [I. API Endpoints](#i-api-endpoints-cần-dùng)
- [II. Flow Tích Hợp](#ii-flow-tích-hợp-trong-mobile-app)
- [III. Code Mẫu](#iii-code-mẫu-cho-mobile)
- [IV. UI/UX Gợi Ý](#iv-uiux-gợi-ý)
- [V. Lưu Ý Quan Trọng](#v-lưu-ý-quan-trọng)
- [VI. Packages Cần Dùng](#vi-packages-cần-dùng)
- [VII. Error Codes](#vii-api-error-codes)

---

## **I. API ENDPOINTS CẦN DÙNG**

### Base URL

```
Development: http://localhost:3000/api
Production: https://your-domain.com/api
```

---

### **1. ĐĂNG NHẬP (Login)**

**Endpoint:** `POST /api/users/login`

**Headers:**

```
Content-Type: application/json
```

**Request Body:**

```json
{
  "email": "admin@example.com",
  "password": "admin123"
}
```

**Response khi KHÔNG có 2FA (200):**

```json
{
  "success": true,
  "data": {
    "id": "6c55590c-29fd-4cb6-8f02-0b9e1e9e9eb0",
    "email": "admin@example.com",
    "fullName": "Admin User",
    "timezone": "Asia/Ho_Chi_Minh"
  },
  "message": "Login successful"
}
```

**Response khi CÓ 2FA (200):**

```json
{
  "success": true,
  "data": {
    "userId": "6c55590c-29fd-4cb6-8f02-0b9e1e9e9eb0",
    "email": "admin@example.com",
    "requires2FA": true,
    "message": "Please provide 2FA token to complete login"
  },
  "message": "2FA required"
}
```

---

### **2. XÁC THỰC 2FA (Verify 2FA Token)**

**Endpoint:** `POST /api/2fa/verify`

**Headers:**

```
Content-Type: application/json
```

**Request Body:**

```json
{
  "userId": "6c55590c-29fd-4cb6-8f02-0b9e1e9e9eb0",
  "token": "123456"
}
```

_Note: `token` có thể là 6 số từ Google Authenticator hoặc backup code_

**Response Success (200):**

```json
{
  "success": true,
  "data": {
    "userId": "6c55590c-29fd-4cb6-8f02-0b9e1e9e9eb0",
    "verified": true,
    "usedBackupCode": false
  },
  "message": "2FA verified successfully"
}
```

**Response Error (401):**

```json
{
  "success": false,
  "message": "Invalid 2FA token"
}
```

---

### **3. SETUP 2FA (Bật 2FA lần đầu)**

**Endpoint:** `POST /api/2fa/setup`

**Headers:**

```
Authorization: Bearer 6c55590c-29fd-4cb6-8f02-0b9e1e9e9eb0
Content-Type: application/json
```

**Request Body:** _(Không cần)_

**Response (200):**

```json
{
  "success": true,
  "data": {
    "secret": "JBSWY3DPEHPK3PXP",
    "qrCodeUrl": "data:image/png;base64,iVBORw0KGgo...",
    "backupCodes": [
      "A1B2C3D4",
      "E5F6G7H8",
      "I9J0K1L2",
      "M3N4O5P6",
      "Q7R8S9T0",
      "U1V2W3X4",
      "Y5Z6A7B8",
      "C9D0E1F2",
      "G3H4I5J6",
      "K7L8M9N0"
    ]
  },
  "message": "2FA setup initiated. Please scan the QR code and verify with a token to enable."
}
```

**⚠️ Quan trọng:**

- `qrCodeUrl`: Data URL của QR code, hiển thị trong Image component
- `backupCodes`: Danh sách 10 mã dự phòng, **CHỈ HIỂN THỊ 1 LẦN**, user phải lưu lại
- `secret`: Base32 secret key (nếu user muốn nhập thủ công thay vì scan QR)

---

### **4. ENABLE 2FA (Kích hoạt sau khi setup)**

**Endpoint:** `POST /api/2fa/enable`

**Headers:**

```
Authorization: Bearer 6c55590c-29fd-4cb6-8f02-0b9e1e9e9eb0
Content-Type: application/json
```

**Request Body:**

```json
{
  "token": "123456"
}
```

_Note: Token 6 số từ Google Authenticator_

**Response Success (200):**

```json
{
  "success": true,
  "data": null,
  "message": "2FA enabled successfully"
}
```

**Response Error (400):**

```json
{
  "success": false,
  "message": "Invalid 2FA token"
}
```

---

### **5. KIỂM TRA TRẠNG THÁI 2FA**

**Endpoint:** `GET /api/2fa/status`

**Headers:**

```
Authorization: Bearer 6c55590c-29fd-4cb6-8f02-0b9e1e9e9eb0
```

**Response (200):**

```json
{
  "success": true,
  "data": {
    "isEnabled": true,
    "hasBackupCodes": true,
    "backupCodesCount": 8
  },
  "message": "2FA status retrieved"
}
```

---

### **6. TẮT 2FA**

**Endpoint:** `POST /api/2fa/disable`

**Headers:**

```
Authorization: Bearer 6c55590c-29fd-4cb6-8f02-0b9e1e9e9eb0
Content-Type: application/json
```

**Request Body:**

```json
{
  "token": "123456"
}
```

_Note: Token hoặc backup code_

**Response (200):**

```json
{
  "success": true,
  "data": null,
  "message": "2FA disabled successfully"
}
```

---

### **7. ĐĂNG KÝ (Register)**

**Endpoint:** `POST /api/users/register`

**Headers:**

```
Content-Type: application/json
```

**Request Body:**

```json
{
  "email": "newuser@example.com",
  "password": "password123",
  "fullName": "New User",
  "timezone": "Asia/Ho_Chi_Minh"
}
```

**Response (201):**

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "newuser@example.com",
    "fullName": "New User",
    "timezone": "Asia/Ho_Chi_Minh"
  },
  "message": "User registered successfully"
}
```

---

## **II. FLOW TÍCH HỢP TRONG MOBILE APP**

### **FLOW 1: Login không có 2FA**

```
1. User nhập email/password
2. App gọi POST /api/users/login
3. Kiểm tra response.data.requires2FA
4. Nếu FALSE → Lưu userId vào secure storage, chuyển màn hình chính
```

### **FLOW 2: Login có 2FA**

```
1. User nhập email/password
2. App gọi POST /api/users/login
3. Kiểm tra response.data.requires2FA
4. Nếu TRUE:
   - Lưu userId tạm thời (trong state)
   - Hiện màn hình nhập OTP
5. User nhập 6 số từ Google Authenticator
6. App gọi POST /api/2fa/verify với userId và token
7. Nếu verify thành công:
   - Lưu userId vào secure storage
   - Chuyển màn hình chính
8. Nếu verify thất bại:
   - Hiện error message
   - Cho phép thử lại
   - Hiện option "Use backup code"
```

### **FLOW 3: Setup 2FA lần đầu**

```
1. User đã login, vào Settings → Security → Enable 2FA
2. App gọi POST /api/2fa/setup (có Authorization header)
3. Nhận về:
   - qrCodeUrl: Hiển thị QR Code
   - backupCodes: Hiển thị danh sách backup codes
4. Màn hình Setup 2FA:
   Step 1: Hiển thị QR Code
   - "Scan this QR code with Google Authenticator"
   - Hiển thị QR code image

   Step 2: Hiển thị Backup Codes
   - Warning: "⚠️ Save these codes in a safe place!"
   - List 10 backup codes
   - Button "Copy All"
   - Checkbox "I've saved my codes"

   Step 3: Verify
   - "Enter code from Google Authenticator to confirm"
   - OTP input (6 digits)
   - Button "Enable 2FA"

5. User scan QR bằng Google Authenticator
6. User nhập 6 số từ app để verify
7. App gọi POST /api/2fa/enable với token
8. Nếu thành công:
   - Hiện success message
   - Update UI status (2FA enabled)
   - Quay về Settings screen
```

### **FLOW 4: Dùng Backup Code**

```
1. User login và nhận requires2FA: true
2. Trên màn hình OTP, có link "Use backup code"
3. User click → Hiện input khác
4. User nhập 1 trong 10 backup codes đã lưu
5. App gọi POST /api/2fa/verify với backup code
6. Nếu thành công:
   - Login thành công
   - Thông báo: "Backup code used. X codes remaining"
   - Gợi ý: "Consider setting up 2FA again"
```

---

## **III. CODE MẪU CHO MOBILE**

### **A. React Native / Expo**

#### **1. Setup Dependencies**

```bash
npm install @react-native-async-storage/async-storage
npm install react-native-qrcode-svg
npm install react-native-otp-inputs
npm install axios
```

#### **2. API Service (api.js)**

```javascript
import axios from "axios";
import AsyncStorage from "@react-native-async-storage/async-storage";

const API_BASE_URL = "http://localhost:3000/api";

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
});

// Interceptor để thêm token
api.interceptors.request.use(async (config) => {
  const userId = await AsyncStorage.getItem("userId");
  if (userId) {
    config.headers.Authorization = `Bearer ${userId}`;
  }
  return config;
});

export const authAPI = {
  // Login
  login: async (email, password) => {
    const response = await api.post("/users/login", { email, password });
    return response.data;
  },

  // Register
  register: async (email, password, fullName) => {
    const response = await api.post("/users/register", {
      email,
      password,
      fullName,
      timezone: "Asia/Ho_Chi_Minh",
    });
    return response.data;
  },
};

export const twoFactorAPI = {
  // Setup 2FA
  setup: async () => {
    const response = await api.post("/2fa/setup");
    return response.data;
  },

  // Enable 2FA
  enable: async (token) => {
    const response = await api.post("/2fa/enable", { token });
    return response.data;
  },

  // Verify 2FA
  verify: async (userId, token) => {
    const response = await axios.post(`${API_BASE_URL}/2fa/verify`, {
      userId,
      token,
    });
    return response.data;
  },

  // Get Status
  getStatus: async () => {
    const response = await api.get("/2fa/status");
    return response.data;
  },

  // Disable 2FA
  disable: async (token) => {
    const response = await api.post("/2fa/disable", { token });
    return response.data;
  },
};
```

#### **3. Login Screen (LoginScreen.js)**

```javascript
import React, { useState } from "react";
import { View, TextInput, Button, Alert } from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { authAPI } from "./api";

export default function LoginScreen({ navigation }) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  const handleLogin = async () => {
    if (!email || !password) {
      Alert.alert("Error", "Please enter email and password");
      return;
    }

    setLoading(true);
    try {
      const result = await authAPI.login(email, password);

      if (result.data.requires2FA) {
        // Có 2FA → Chuyển sang màn hình OTP
        navigation.navigate("OTPScreen", {
          userId: result.data.userId,
          email: result.data.email,
        });
      } else {
        // Không có 2FA → Login thành công
        await AsyncStorage.setItem("userId", result.data.id);
        await AsyncStorage.setItem("email", result.data.email);
        navigation.replace("Home");
      }
    } catch (error) {
      Alert.alert(
        "Login Failed",
        error.response?.data?.message || "Invalid credentials"
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={{ padding: 20 }}>
      <TextInput
        placeholder="Email"
        value={email}
        onChangeText={setEmail}
        autoCapitalize="none"
        keyboardType="email-address"
        style={{ borderWidth: 1, padding: 10, marginBottom: 10 }}
      />
      <TextInput
        placeholder="Password"
        value={password}
        onChangeText={setPassword}
        secureTextEntry
        style={{ borderWidth: 1, padding: 10, marginBottom: 10 }}
      />
      <Button
        title={loading ? "Loading..." : "Login"}
        onPress={handleLogin}
        disabled={loading}
      />
    </View>
  );
}
```

#### **4. OTP Screen (OTPScreen.js)**

```javascript
import React, { useState } from "react";
import {
  View,
  Text,
  TextInput,
  Button,
  Alert,
  TouchableOpacity,
} from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { twoFactorAPI } from "./api";

export default function OTPScreen({ route, navigation }) {
  const { userId, email } = route.params;
  const [token, setToken] = useState("");
  const [loading, setLoading] = useState(false);
  const [showBackupCode, setShowBackupCode] = useState(false);

  const handleVerify = async () => {
    if (!token || token.length !== 6) {
      Alert.alert("Error", "Please enter 6-digit code");
      return;
    }

    setLoading(true);
    try {
      const result = await twoFactorAPI.verify(userId, token);

      if (result.success) {
        // Verify thành công
        await AsyncStorage.setItem("userId", userId);
        await AsyncStorage.setItem("email", email);

        if (result.data.usedBackupCode) {
          Alert.alert(
            "Backup Code Used",
            "You have used a backup code. Consider setting up 2FA again.",
            [{ text: "OK", onPress: () => navigation.replace("Home") }]
          );
        } else {
          navigation.replace("Home");
        }
      }
    } catch (error) {
      Alert.alert(
        "Verification Failed",
        error.response?.data?.message || "Invalid token"
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={{ padding: 20 }}>
      <Text style={{ fontSize: 20, marginBottom: 10 }}>Enter 2FA Code</Text>
      <Text style={{ marginBottom: 20 }}>
        Enter the 6-digit code from your Google Authenticator app
      </Text>

      <TextInput
        placeholder={showBackupCode ? "Backup Code" : "123456"}
        value={token}
        onChangeText={setToken}
        keyboardType={showBackupCode ? "default" : "number-pad"}
        maxLength={showBackupCode ? 8 : 6}
        style={{
          borderWidth: 1,
          padding: 15,
          fontSize: 24,
          textAlign: "center",
          marginBottom: 20,
        }}
      />

      <Button
        title={loading ? "Verifying..." : "Verify"}
        onPress={handleVerify}
        disabled={loading}
      />

      <TouchableOpacity
        onPress={() => setShowBackupCode(!showBackupCode)}
        style={{ marginTop: 20, alignItems: "center" }}
      >
        <Text style={{ color: "blue" }}>
          {showBackupCode ? "Use authenticator code" : "Use backup code"}
        </Text>
      </TouchableOpacity>
    </View>
  );
}
```

#### **5. Setup 2FA Screen (Setup2FAScreen.js)**

```javascript
import React, { useState, useEffect } from "react";
import {
  View,
  Text,
  Image,
  Button,
  Alert,
  ScrollView,
  TouchableOpacity,
  Clipboard,
} from "react-native";
import { twoFactorAPI } from "./api";

export default function Setup2FAScreen({ navigation }) {
  const [qrCodeUrl, setQrCodeUrl] = useState("");
  const [backupCodes, setBackupCodes] = useState([]);
  const [token, setToken] = useState("");
  const [step, setStep] = useState(1); // 1: QR, 2: Backup Codes, 3: Verify
  const [savedCodes, setSavedCodes] = useState(false);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setupTwoFactor();
  }, []);

  const setupTwoFactor = async () => {
    try {
      const result = await twoFactorAPI.setup();
      setQrCodeUrl(result.data.qrCodeUrl);
      setBackupCodes(result.data.backupCodes);
    } catch (error) {
      Alert.alert(
        "Error",
        error.response?.data?.message || "Failed to setup 2FA"
      );
    }
  };

  const copyBackupCodes = () => {
    Clipboard.setString(backupCodes.join("\n"));
    Alert.alert("Copied", "Backup codes copied to clipboard");
  };

  const handleEnable = async () => {
    if (!token || token.length !== 6) {
      Alert.alert("Error", "Please enter 6-digit code");
      return;
    }

    setLoading(true);
    try {
      await twoFactorAPI.enable(token);
      Alert.alert("Success", "2FA enabled successfully", [
        { text: "OK", onPress: () => navigation.goBack() },
      ]);
    } catch (error) {
      Alert.alert("Error", error.response?.data?.message || "Invalid token");
    } finally {
      setLoading(false);
    }
  };

  return (
    <ScrollView style={{ padding: 20 }}>
      {step === 1 && (
        <View>
          <Text style={{ fontSize: 20, fontWeight: "bold", marginBottom: 10 }}>
            Step 1: Scan QR Code
          </Text>
          <Text style={{ marginBottom: 20 }}>
            Scan this QR code with Google Authenticator app
          </Text>
          {qrCodeUrl && (
            <Image
              source={{ uri: qrCodeUrl }}
              style={{
                width: 300,
                height: 300,
                alignSelf: "center",
                marginBottom: 20,
              }}
            />
          )}
          <Button title="Next" onPress={() => setStep(2)} />
        </View>
      )}

      {step === 2 && (
        <View>
          <Text style={{ fontSize: 20, fontWeight: "bold", marginBottom: 10 }}>
            Step 2: Save Backup Codes
          </Text>
          <Text style={{ color: "red", marginBottom: 20 }}>
            ⚠️ Save these codes in a safe place! They can be used if you lose
            your phone.
          </Text>
          <View
            style={{
              backgroundColor: "#f5f5f5",
              padding: 15,
              marginBottom: 20,
            }}
          >
            {backupCodes.map((code, index) => (
              <Text key={index} style={{ fontSize: 16, marginBottom: 5 }}>
                {code}
              </Text>
            ))}
          </View>
          <Button title="Copy All Codes" onPress={copyBackupCodes} />
          <TouchableOpacity
            onPress={() => setSavedCodes(!savedCodes)}
            style={{ flexDirection: "row", marginTop: 20, marginBottom: 20 }}
          >
            <Text>{savedCodes ? "✅" : "☐"}</Text>
            <Text style={{ marginLeft: 10 }}>I've saved my backup codes</Text>
          </TouchableOpacity>
          <Button
            title="Next"
            onPress={() => setStep(3)}
            disabled={!savedCodes}
          />
        </View>
      )}

      {step === 3 && (
        <View>
          <Text style={{ fontSize: 20, fontWeight: "bold", marginBottom: 10 }}>
            Step 3: Verify Setup
          </Text>
          <Text style={{ marginBottom: 20 }}>
            Enter the 6-digit code from Google Authenticator to confirm
          </Text>
          <TextInput
            placeholder="123456"
            value={token}
            onChangeText={setToken}
            keyboardType="number-pad"
            maxLength={6}
            style={{
              borderWidth: 1,
              padding: 15,
              fontSize: 24,
              textAlign: "center",
              marginBottom: 20,
            }}
          />
          <Button
            title={loading ? "Enabling..." : "Enable 2FA"}
            onPress={handleEnable}
            disabled={loading}
          />
        </View>
      )}
    </ScrollView>
  );
}
```

---

### **B. Flutter / Dart**

#### **1. Setup Dependencies (pubspec.yaml)**

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  shared_preferences: ^2.2.0
  qr_flutter: ^4.1.0
  pinput: ^3.0.0
```

#### **2. API Service (api_service.dart)**

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // Verify 2FA
  static Future<Map<String, dynamic>> verify2FA(String userId, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/2fa/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'token': token}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // Setup 2FA
  static Future<Map<String, dynamic>> setup2FA() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    final response = await http.post(
      Uri.parse('$baseUrl/2fa/setup'),
      headers: {
        'Authorization': 'Bearer $userId',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // Enable 2FA
  static Future<Map<String, dynamic>> enable2FA(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    final response = await http.post(
      Uri.parse('$baseUrl/2fa/enable'),
      headers: {
        'Authorization': 'Bearer $userId',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({'token': token}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }
}
```

#### **3. Login Screen (login_screen.dart)**

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please enter email and password');
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await ApiService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (result['data']['requires2FA'] == true) {
        // Có 2FA → Chuyển sang màn hình OTP
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPScreen(
              userId: result['data']['userId'],
              email: result['data']['email'],
            ),
          ),
        );
      } else {
        // Không có 2FA → Login thành công
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', result['data']['id']);
        await prefs.setString('email', result['data']['email']);
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _handleLogin,
              child: Text(_loading ? 'Loading...' : 'Login'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## **IV. UI/UX GỢI Ý**

### **1. Màn hình Login**

```
┌─────────────────────────────┐
│         Login               │
├─────────────────────────────┤
│                             │
│  Email                      │
│  [___________________]      │
│                             │
│  Password                   │
│  [___________________]      │
│                             │
│  [     Login     ]          │
│                             │
│  Don't have account?        │
│  Sign up                    │
└─────────────────────────────┘
```

### **2. Màn hình OTP (Nhập 2FA)**

```
┌─────────────────────────────┐
│    Enter 2FA Code           │
├─────────────────────────────┤
│                             │
│  Enter the 6-digit code     │
│  from your authenticator    │
│                             │
│  [1] [2] [3] [4] [5] [6]    │
│                             │
│  [      Verify      ]       │
│                             │
│  ⏱️ Code expires in 25s      │
│                             │
│  Lost your phone?           │
│  Use backup code            │
└─────────────────────────────┘
```

### **3. Màn hình Setup 2FA - Step 1: QR Code**

```
┌─────────────────────────────┐
│   Setup Two-Factor Auth     │
│         Step 1 of 3         │
├─────────────────────────────┤
│                             │
│  Scan QR Code               │
│                             │
│  ┌─────────────────┐        │
│  │                 │        │
│  │   [QR CODE]     │        │
│  │                 │        │
│  └─────────────────┘        │
│                             │
│  Scan this with Google      │
│  Authenticator app          │
│                             │
│  Can't scan? Enter key:     │
│  JBSWY3DPEHPK3PXP          │
│                             │
│  [       Next       ]       │
└─────────────────────────────┘
```

### **4. Màn hình Setup 2FA - Step 2: Backup Codes**

```
┌─────────────────────────────┐
│   Setup Two-Factor Auth     │
│         Step 2 of 3         │
├─────────────────────────────┤
│                             │
│  ⚠️ Save Backup Codes       │
│                             │
│  Keep these codes safe!     │
│  Each can be used once.     │
│                             │
│  ┌─────────────────────┐   │
│  │ A1B2C3D4            │   │
│  │ E5F6G7H8            │   │
│  │ I9J0K1L2            │   │
│  │ M3N4O5P6            │   │
│  │ Q7R8S9T0            │   │
│  │ U1V2W3X4            │   │
│  │ Y5Z6A7B8            │   │
│  │ C9D0E1F2            │   │
│  │ G3H4I5J6            │   │
│  │ K7L8M9N0            │   │
│  └─────────────────────┘   │
│                             │
│  [    Copy All    ]         │
│                             │
│  ☑ I've saved my codes      │
│                             │
│  [       Next       ]       │
└─────────────────────────────┘
```

### **5. Màn hình Setup 2FA - Step 3: Verify**

```
┌─────────────────────────────┐
│   Setup Two-Factor Auth     │
│         Step 3 of 3         │
├─────────────────────────────┤
│                             │
│  Verify Setup               │
│                             │
│  Enter code from Google     │
│  Authenticator to confirm   │
│                             │
│  [1] [2] [3] [4] [5] [6]    │
│                             │
│  [   Enable 2FA   ]         │
│                             │
└─────────────────────────────┘
```

---

## **V. LƯU Ý QUAN TRỌNG**

### **1. Security Best Practices**

#### **Secure Storage**

```javascript
// ❌ KHÔNG làm thế này:
AsyncStorage.setItem("password", password); // Plain text

// ✅ Làm thế này:
import * as SecureStore from "expo-secure-store"; // Expo
// hoặc
import { SecureStore } from "react-native-keychain"; // React Native

await SecureStore.setItemAsync("userId", userId);
```

#### **HTTPS Only**

```javascript
// ❌ Development
const API_URL = "http://localhost:3000";

// ✅ Production
const API_URL = "https://api.yourdomain.com";
```

#### **Clear Sensitive Data**

```javascript
// Sau khi login thành công
setPassword(""); // Clear password từ state
setToken(""); // Clear OTP token
```

### **2. User Experience**

#### **Auto-Submit OTP**

```javascript
// Khi user nhập đủ 6 số, tự động verify
const [otp, setOtp] = useState("");

useEffect(() => {
  if (otp.length === 6) {
    handleVerify(); // Auto-submit
  }
}, [otp]);
```

#### **Countdown Timer**

```javascript
// Hiện countdown cho TOTP (30 giây)
const [countdown, setCountdown] = useState(30);

useEffect(() => {
  const timer = setInterval(() => {
    setCountdown((prev) => (prev > 0 ? prev - 1 : 30));
  }, 1000);
  return () => clearInterval(timer);
}, []);

// Display: "Code expires in {countdown}s"
```

#### **Loading States**

```javascript
// Hiện loading khi gọi API
const [loading, setLoading] = useState(false);

<Button
  title={loading ? "Verifying..." : "Verify"}
  onPress={handleVerify}
  disabled={loading} // Disable button khi loading
/>;
```

### **3. Error Handling**

```javascript
// Handle network errors
try {
  const result = await api.login(email, password);
} catch (error) {
  if (error.code === "NETWORK_ERROR") {
    Alert.alert("Network Error", "Please check your internet connection");
  } else if (error.response?.status === 401) {
    Alert.alert("Invalid Credentials", "Email or password is incorrect");
  } else if (error.response?.status === 429) {
    Alert.alert("Too Many Attempts", "Please try again later");
  } else {
    Alert.alert("Error", error.message || "Something went wrong");
  }
}
```

### **4. Testing**

#### **Test Accounts**

```
ADMIN:
- Email: admin@example.com
- Password: admin123

MANAGER:
- Email: manager@example.com
- Password: manager123

USER:
- Email: user@example.com
- Password: user123
```

#### **Test 2FA**

```
1. Login với test account
2. Setup 2FA
3. Scan QR với Google Authenticator
4. Lưu backup codes
5. Enable 2FA
6. Logout
7. Login lại → Nhập OTP → Thành công
```

---

## **VI. PACKAGES CẦN DÙNG**

### **React Native / Expo**

```bash
# Core
npm install axios
npm install @react-native-async-storage/async-storage

# UI Components
npm install react-native-qrcode-svg
npm install react-native-otp-inputs
npm install react-native-svg

# Navigation (nếu chưa có)
npm install @react-navigation/native
npm install @react-navigation/stack

# Secure Storage (Expo)
npx expo install expo-secure-store

# Secure Storage (React Native)
npm install react-native-keychain
```

### **Flutter**

```yaml
dependencies:
  flutter:
    sdk: flutter

  # HTTP Client
  http: ^1.1.0

  # Local Storage
  shared_preferences: ^2.2.0

  # QR Code
  qr_flutter: ^4.1.0

  # OTP Input
  pinput: ^3.0.0

  # Clipboard
  flutter_clipboard: ^2.0.0
```

---

## **VII. API ERROR CODES**

```
200 - OK (Success)
201 - Created (Register success)
400 - Bad Request (Invalid input, Invalid token)
401 - Unauthorized (Invalid credentials, Authentication required)
403 - Forbidden (No permission)
404 - Not Found (User not found, Resource not found)
409 - Conflict (Email already exists)
429 - Too Many Requests (Rate limited)
500 - Internal Server Error
```

### **Error Response Format**

```json
{
  "success": false,
  "message": "Invalid 2FA token",
  "statusCode": 401
}
```

---

## **VIII. TESTING CHECKLIST**

### **Login Flow**

- [ ] Login thành công khi không có 2FA
- [ ] Login hiện OTP screen khi có 2FA
- [ ] OTP verify thành công với token đúng
- [ ] OTP verify thất bại với token sai
- [ ] Backup code hoạt động đúng
- [ ] Error messages hiện đúng

### **Setup 2FA**

- [ ] QR code hiển thị đúng
- [ ] Backup codes hiển thị đủ 10 codes
- [ ] Copy backup codes hoạt động
- [ ] Enable 2FA thành công sau verify token
- [ ] Enable 2FA thất bại với token sai

### **Security**

- [ ] UserId được lưu trong secure storage
- [ ] Password không lưu trong plain text
- [ ] Token được clear sau khi dùng
- [ ] API gọi qua HTTPS (production)
- [ ] Authorization header được gửi đúng

---

## **IX. SUPPORT & CONTACT**

**API Documentation:** http://localhost:3000/api-docs
**Backend Server:** http://localhost:3000
**Test Environment:** Development

**Issues:**

- Kiểm tra server đang chạy: `npm start`
- Kiểm tra network connection
- Xem console logs để debug
- Test với Swagger UI trước khi tích hợp mobile

---

## **X. NEXT STEPS**

1. ✅ Copy code mẫu vào project
2. ✅ Cài đặt dependencies
3. ✅ Update API_BASE_URL
4. ✅ Test login flow
5. ✅ Test 2FA setup
6. ✅ Test với Google Authenticator
7. ✅ Handle errors
8. ✅ Polish UI/UX
9. ✅ Testing trên real devices
10. ✅ Deploy to production

---

**Document Version:** 1.0  
**Last Updated:** 2026-01-03  
**Author:** Backend Team  
**Status:** Ready for Integration
