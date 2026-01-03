import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../config/app_config.dart';
import 'api_client.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  List<User> _allUsers = [];
  final ApiClient _apiClient = ApiClient();
  bool _useLocalStorage = true; // Toggle between API and local storage

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isManager => _currentUser?.isManager ?? false;
  bool get isAdminRole => _currentUser?.isAdminRole ?? false;

  AuthService() {
    _loadUsers();
    _loadCurrentUser();
    _createDefaultAdmin();
  }

  /// Set whether to use local storage or API
  void setUseLocalStorage(bool value) {
    _useLocalStorage = value;
    notifyListeners();
  }

  // Load all users from SharedPreferences
  Future<void> _loadUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users');

      if (usersJson != null) {
        final List<dynamic> usersList = json.decode(usersJson);
        _allUsers = usersList.map((u) => User.fromMap(u)).toList();
      }
    } catch (e) {
      debugPrint('Error loading users: $e');
    }
  }

  // Save all users to SharedPreferences
  Future<void> _saveUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = json.encode(_allUsers.map((u) => u.toMap()).toList());
      await prefs.setString('users', usersJson);
    } catch (e) {
      debugPrint('Error saving users: $e');
    }
  }

  // Load current user from SharedPreferences
  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getString('currentUserId');

      if (currentUserId != null) {
        _currentUser = _allUsers.firstWhere(
          (u) => u.id == currentUserId,
          orElse: () => _allUsers.first,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading current user: $e');
    }
  }

  // Create default admin account
  Future<void> _createDefaultAdmin() async {
    // Create Admin if not exists
    if (!_allUsers.any((u) => u.email == ApiConfig.adminEmail)) {
      final admin = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: ApiConfig.adminEmail,
        password: ApiConfig.adminPassword,
        fullName: 'Administrator',
        isAdmin: true,
        role: UserRole.admin,
      );
      _allUsers.add(admin);
    }

    // Create Manager if not exists
    if (!_allUsers.any((u) => u.email == ApiConfig.managerEmail)) {
      final manager = User(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        email: ApiConfig.managerEmail,
        password: ApiConfig.managerPassword,
        fullName: 'Manager',
        isAdmin: false,
        role: UserRole.manager,
      );
      _allUsers.add(manager);
    }

    // Create User if not exists
    if (!_allUsers.any((u) => u.email == ApiConfig.userEmail)) {
      final user = User(
        id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
        email: ApiConfig.userEmail,
        password: ApiConfig.userPassword,
        fullName: 'Regular User',
        isAdmin: false,
        role: UserRole.user,
      );
      _allUsers.add(user);
    }

    await _saveUsers();
    notifyListeners();
  }

  /// Set current user from API response
  /// Use this after successful API login to save user data
  Future<void> setCurrentUserFromApi(Map<String, dynamic> userData) async {
    try {
      // Parse role from backend response or detect from email
      UserRole role = UserRole.user;
      String email = userData['email'] ?? '';
      String? roleStr = userData['role'];

      if (roleStr != null) {
        // If role is provided by backend
        switch (roleStr.toLowerCase()) {
          case 'admin':
            role = UserRole.admin;
            break;
          case 'manager':
            role = UserRole.manager;
            break;
          default:
            role = UserRole.user;
        }
      } else {
        // Detect role from email (temporary solution until backend returns role)
        if (email.toLowerCase() == ApiConfig.adminEmail.toLowerCase()) {
          role = UserRole.admin;
        } else if (email.toLowerCase() ==
            ApiConfig.managerEmail.toLowerCase()) {
          role = UserRole.manager;
        } else {
          role = UserRole.user;
        }
      }

      // Create user from API data
      _currentUser = User(
        id: userData['id'],
        email: email,
        fullName: userData['fullName'] ?? userData['full_name'] ?? 'User',
        password: '', // Don't store password
        isAdmin: role == UserRole.admin,
        role: role,
      );

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUserId', _currentUser!.id);

      // Set auth token (use userId as token for now)
      _apiClient.setAuthToken(_currentUser!.id);
      await prefs.setString('authToken', _currentUser!.id);

      debugPrint(
        '✅ User logged in: ${_currentUser!.email} (${_currentUser!.role})',
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting current user from API: $e');
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    try {
      if (_useLocalStorage) {
        // Local storage login (current implementation)
        final user = _allUsers.firstWhere(
          (u) =>
              u.email.toLowerCase() == email.toLowerCase() &&
              u.password == password,
          orElse: () => User(id: '', email: '', password: '', fullName: ''),
        );

        if (user.id.isNotEmpty) {
          _currentUser = user;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('currentUserId', user.id);
          _apiClient.setAuthToken(user.id);
          notifyListeners();
          return true;
        }
        return false;
      } else {
        // API login
        final response = await _apiClient.login(
          email: email,
          password: password,
        );

        if (response['success'] == true) {
          final data = response['data'];

          // Check if 2FA is required
          if (data['requires2FA'] == true) {
            // Store userId for 2FA verification
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('pending2FAUserId', data['userId']);
            return false; // Need 2FA verification
          }

          // Create user from API response
          _currentUser = User(
            id: data['id'],
            email: data['email'],
            fullName: data['fullName'],
            password: '', // Don't store password
            isAdmin: data['isAdmin'] ?? false,
            role: data['isAdmin'] ? UserRole.admin : UserRole.user,
          );

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('currentUserId', _currentUser!.id);

          // Set auth token
          final token = data['token'] ?? _currentUser!.id;
          _apiClient.setAuthToken(token);
          await prefs.setString('authToken', token);

          notifyListeners();
          return true;
        }
        return false;
      }
    } catch (e) {
      debugPrint('Error logging in: $e');
      return false;
    }
  }

  // Verify 2FA after login
  Future<bool> verify2FA(String userId, String token) async {
    try {
      final response = await _apiClient.verify2FA(userId: userId, token: token);

      if (response['success'] == true) {
        final data = response['data'];

        // Create user from API response
        _currentUser = User(
          id: data['id'],
          email: data['email'],
          fullName: data['fullName'],
          password: '',
          isAdmin: data['isAdmin'] ?? false,
          role: data['isAdmin'] ? UserRole.admin : UserRole.user,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentUserId', _currentUser!.id);
        await prefs.remove('pending2FAUserId');

        // Set auth token
        final authToken = data['token'] ?? _currentUser!.id;
        _apiClient.setAuthToken(authToken);
        await prefs.setString('authToken', authToken);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error verifying 2FA: $e');
      return false;
    }
  }

  // Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.user,
  }) async {
    try {
      if (_useLocalStorage) {
        // Local storage registration (current implementation)
        // Check if email already exists
        if (_allUsers.any(
          (u) => u.email.toLowerCase() == email.toLowerCase(),
        )) {
          return false;
        }

        final newUser = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          email: email,
          password: password,
          fullName: fullName,
          isAdmin: role == UserRole.admin,
          role: role,
        );

        _allUsers.add(newUser);
        await _saveUsers();
        return true;
      } else {
        // API registration
        final response = await _apiClient.register(
          email: email,
          password: password,
          fullName: fullName,
        );

        if (response['success'] == true) {
          return true;
        }
        return false;
      }
    } catch (e) {
      debugPrint('Error registering user: $e');
      return false;
    }
  }

  // Load users from API
  Future<void> loadUsersFromAPI() async {
    try {
      final response = await _apiClient.getUsers();

      if (response['success'] == true) {
        final List<dynamic> usersData = response['data'];
        _allUsers = usersData
            .map(
              (data) => User(
                id: data['id'],
                email: data['email'],
                fullName: data['fullName'],
                password: '',
                isAdmin: data['isAdmin'] ?? false,
                role: data['isAdmin'] ? UserRole.admin : UserRole.user,
              ),
            )
            .toList();

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading users from API: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
    _apiClient.setAuthToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUserId');
    await prefs.remove('authToken');
    await prefs.remove('pending2FAUserId');
    notifyListeners();
  }

  // Get all users (admin/manager only)
  List<User> getAllUsers() {
    if (isAdmin || isManager) {
      return List.from(_allUsers);
    }
    return [];
  }

  // Delete user (admin only)
  Future<bool> deleteUser(String userId) async {
    if (!isAdmin) return false;

    try {
      _allUsers.removeWhere((u) => u.id == userId);
      await _saveUsers();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting user: $e');
      return false;
    }
  }

  // Update user (admin only)
  Future<bool> updateUser(User user) async {
    if (!isAdmin) return false;

    try {
      final index = _allUsers.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _allUsers[index] = user;
        await _saveUsers();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating user: $e');
      return false;
    }
  }
}
