import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../services/auth_api_service.dart';
import '../../services/event_api_service.dart';
import '../../services/calendar_api_service.dart';

/// Example: Cách sử dụng API Services
/// File này chỉ để demo, không sử dụng trong production
class ApiExampleScreen extends StatefulWidget {
  const ApiExampleScreen({super.key});

  @override
  State<ApiExampleScreen> createState() => _ApiExampleScreenState();
}

class _ApiExampleScreenState extends State<ApiExampleScreen> {
  final _authApi = AuthApiService();
  final _eventApi = EventApiService();
  final _calendarApi = CalendarApiService();

  String _output = 'Nhấn vào button để test API';
  bool _loading = false;
  String? _userId;
  String? _calendarId;

  void _setOutput(String message) {
    setState(() {
      _output = message;
      _loading = false;
    });
  }

  void _setLoading() {
    setState(() {
      _loading = true;
      _output = 'Đang xử lý...';
    });
  }

  /// Test Login API
  Future<void> _testLogin() async {
    _setLoading();
    try {
      final response = await _authApi.login(
        email: ApiConfig.adminEmail,
        password: ApiConfig.adminPassword,
      );
      // response = {id, email, fullName, timezone}
      _userId = response['id'];
      _setOutput('✅ Login thành công!\n\nUser ID: $_userId\n\nUser: $response');
    } catch (e) {
      _setOutput('❌ Login thất bại:\n\n$e');
    }
  }

  /// Test Register API
  Future<void> _testRegister() async {
    _setLoading();
    try {
      final response = await _authApi.register(
        email: 'test${DateTime.now().millisecondsSinceEpoch}@test.com',
        password: 'test123',
        fullName: 'Test User',
      );
      _setOutput('✅ Register thành công!\n\n$response');
    } catch (e) {
      _setOutput('❌ Register thất bại:\n\n$e');
    }
  }

  /// Test Get All Users (Admin)
  Future<void> _testGetUsers() async {
    if (_userId == null) {
      _setOutput('⚠️ Vui lòng login với admin account trước!');
      return;
    }

    _setLoading();
    try {
      final users = await _authApi.getAllUsers(_userId!);
      _setOutput('✅ Lấy users thành công!\n\nTổng số: ${users.length} users');
    } catch (e) {
      _setOutput('❌ Lấy users thất bại:\n\n$e');
    }
  }

  /// Test Create Calendar
  Future<void> _testCreateCalendar() async {
    if (_userId == null) {
      _setOutput('⚠️ Vui lòng login trước!');
      return;
    }

    _setLoading();
    try {
      final response = await _calendarApi.createCalendar(_userId!, {
        'name': 'Test Calendar ${DateTime.now().millisecondsSinceEpoch}',
        'description': 'Calendar for testing',
        'timezone': 'Asia/Ho_Chi_Minh',
      });
      _calendarId = response['_id'];
      _setOutput(
        '✅ Tạo calendar thành công!\n\nCalendar ID: $_calendarId\n\nData: $response',
      );
    } catch (e) {
      _setOutput('❌ Tạo calendar thất bại:\n\n$e');
    }
  }

  /// Test Search Events
  Future<void> _testSearchEvents() async {
    if (_userId == null) {
      _setOutput('⚠️ Vui lòng login trước!');
      return;
    }

    _setLoading();
    try {
      final events = await _eventApi.searchEvents(
        userId: _userId!,
        query: 'meeting',
      );
      _setOutput('✅ Tìm kiếm thành công!\n\nKết quả: ${events.length} events');
    } catch (e) {
      _setOutput('❌ Tìm kiếm thất bại:\n\n$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test - Backend Integration'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Environment Info
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🔧 Cấu hình Backend',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Environment: ${ApiConfig.environment}'),
                    Text('Base URL: ${ApiConfig.baseUrl}'),
                    if (_userId != null) Text('User ID: $_userId'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Auth Tests
            const Text(
              '🔐 Authentication',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _loading ? null : _testLogin,
              icon: const Icon(Icons.login),
              label: Text('Test Login (${ApiConfig.adminEmail})'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _loading ? null : _testRegister,
              icon: const Icon(Icons.person_add),
              label: const Text('Test Register'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _loading ? null : _testGetUsers,
              icon: const Icon(Icons.people),
              label: const Text('Get All Users'),
            ),
            const SizedBox(height: 16),

            // Calendar Tests
            const Text(
              '📅 Calendars',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _loading ? null : _testCreateCalendar,
              icon: const Icon(Icons.calendar_today),
              label: const Text('Create Calendar'),
            ),
            const SizedBox(height: 16),

            // Event Tests
            const Text(
              '📆 Events',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _loading ? null : _testSearchEvents,
              icon: const Icon(Icons.search),
              label: const Text('Search Events'),
            ),
            const SizedBox(height: 16),

            // Output
            const Text(
              '📄 Kết quả',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              constraints: const BoxConstraints(minHeight: 200),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Text(
                      _output,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
            ),
            const SizedBox(height: 16),

            // Info Card
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Lưu ý quan trọng',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Backend API đang chạy tại: http://localhost:3000\n'
                      '• Tài khoản test: admin@example.com / admin123\n'
                      '• Authentication dùng User ID làm Bearer token\n'
                      '• Xem chi tiết API trong API_ENDPOINTS.md\n'
                      '• Đảm bảo backend đang chạy trước khi test',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
