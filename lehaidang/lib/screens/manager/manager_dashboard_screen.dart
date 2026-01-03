import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/event_service.dart';
import '../../models/event_model.dart';
import '../../models/user_model.dart';
import '../login_screen.dart';
import '../user/add_event_screen.dart';
import '../user/event_detail_screen.dart';

/// Manager Dashboard Screen
/// Manager có 9 permissions:
/// - user:read, calendar:read/write, event:read/write/delete
/// - recurring-event:read/write, system:manage-users
class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load users khi khởi động
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadUsers() async {
    // Load users from API if not using local storage
    // Otherwise, data will be automatically loaded from SharedPreferences
    if (mounted) {
      setState(() {});
    }
  }

  void _logout() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.logout();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final eventService = Provider.of<EventService>(context);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.dashboard, color: Colors.deepOrange, size: 24),
            ),
            const SizedBox(width: 12),
            const Flexible(
              child: Text(
                'Manager Dashboard',
                style: TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          // User info
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.deepOrange.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.deepOrange,
                  child: Text(
                    authService.currentUser?.fullName
                            .substring(0, 1)
                            .toUpperCase() ??
                        'M',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  authService.currentUser?.fullName ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Logout
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.deepOrange),
            tooltip: 'Đăng xuất',
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Column(
            children: [
              // Statistics Cards
              if (isDesktop)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      _buildStatCard(
                        'Tổng Events',
                        eventService.allEvents.length,
                        Icons.event,
                        Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        'Users',
                        authService.getAllUsers().length,
                        Icons.people,
                        Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        'Hôm nay',
                        eventService.getTodayEventsCount(),
                        Icons.today,
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
              // Tabs
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.deepOrange,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.deepOrange,
                  indicatorWeight: 2,
                  labelStyle: const TextStyle(fontSize: 11),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.dashboard_outlined, size: 18),
                      text: 'Tổng quan',
                    ),
                    Tab(icon: Icon(Icons.event, size: 18), text: 'Events'),
                    Tab(icon: Icon(Icons.people, size: 18), text: 'Users'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_OverviewTab(), _EventsTab(), _UsersTab()],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddEventScreen(selectedDate: DateTime.now()),
                  ),
                );
              },
              backgroundColor: Colors.deepOrange,
              icon: const Icon(Icons.add),
              label: const Text('Tạo Event'),
            )
          : null,
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Overview Tab - Dashboard summary
class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    final eventService = Provider.of<EventService>(context);
    final authService = Provider.of<AuthService>(context);
    final events = eventService.allEvents;
    final users = authService.getAllUsers();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics Grid
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: MediaQuery.of(context).size.width > 800
                ? 2.5
                : 2.2,
            children: [
              _buildOverviewCard(
                'Tổng Events',
                events.length.toString(),
                Icons.event,
                Colors.blue,
              ),
              _buildOverviewCard(
                'Users',
                users.length.toString(),
                Icons.people,
                Colors.green,
              ),
              _buildOverviewCard(
                'Events Hôm nay',
                eventService.getTodayEventsCount().toString(),
                Icons.today,
                Colors.orange,
              ),
              _buildOverviewCard(
                'Events Tuần này',
                eventService.getThisWeekEventsCount().toString(),
                Icons.date_range,
                Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Recent Events
          _buildSectionHeader('Events Gần Đây', Icons.schedule),
          const SizedBox(height: 6),
          _buildRecentEvents(events.take(5).toList()),

          const SizedBox(height: 12),

          // User List Preview
          _buildSectionHeader('Danh Sách Users', Icons.people_outline),
          const SizedBox(height: 6),
          _buildUsersList(users.take(5).toList()),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              title,
              style: TextStyle(fontSize: 9, color: Colors.grey[600]),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.deepOrange),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildRecentEvents(List<Event> events) {
    if (events.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.event_busy, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Text(
                'Chưa có events nào',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: events.map((event) => _buildEventItem(event)).toList(),
    );
  }

  Widget _buildEventItem(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: event.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(event.startTime),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(List<User> users) {
    if (users.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.people_outline, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Text(
                'Chưa có users nào',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(children: users.map((user) => _buildUserItem(user)).toList());
  }

  Widget _buildUserItem(User user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: user.isAdmin ? Colors.red : Colors.blue,
            child: Icon(
              user.isAdmin ? Icons.admin_panel_settings : Icons.person,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  user.email,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: user.isAdmin ? Colors.red.shade50 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              user.isAdmin ? 'ADMIN' : 'USER',
              style: TextStyle(
                fontSize: 10,
                color: user.isAdmin ? Colors.red : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Events Tab - Manager có quyền CRUD events
class _EventsTab extends StatelessWidget {
  const _EventsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<EventService>(
      builder: (context, eventService, child) {
        final events = eventService.allEvents;

        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Chưa có sự kiện nào',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nhấn nút "+" để tạo sự kiện mới',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            return _EventCard(event: events[index]);
          },
        );
      },
    );
  }
}

/// Event Card with Manager actions
class _EventCard extends StatelessWidget {
  final Event event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final eventService = Provider.of<EventService>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.grey.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title & Actions
              Row(
                children: [
                  // Color indicator
                  Container(
                    width: 5,
                    height: 50,
                    decoration: BoxDecoration(
                      color: event.color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (event.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            event.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Actions
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEventScreen(
                              selectedDate: event.startTime,
                              eventToEdit: event,
                            ),
                          ),
                        );
                      } else if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text('Xác nhận'),
                            content: const Text(
                              'Bạn có chắc muốn xóa sự kiện này?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Hủy'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Xóa'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          eventService.deleteEvent(event.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã xóa sự kiện'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      } else if (value == 'hide') {
                        eventService.toggleEventVisibility(event.id);
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 12),
                            Text('Sửa'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Xóa', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'hide',
                        child: Row(
                          children: [
                            Icon(
                              event.isHidden
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(event.isHidden ? 'Hiện' : 'Ẩn'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Date & Time
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 18, color: Colors.deepOrange),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd/MM/yyyy - HH:mm').format(event.startTime),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (event.isHidden) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Đã ẩn',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Users Tab - Manager chỉ có quyền xem users (user:read)
class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final users = authService.getAllUsers();

        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Chưa có người dùng nào',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Danh sách người dùng trống',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _UserCard(user: user);
          },
        );
      },
    );
  }
}

/// User Card - Read-only for Manager with beautiful design
class _UserCard extends StatelessWidget {
  final User user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.grey.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: user.isAdmin
                ? [Colors.red.shade50, Colors.white]
                : user.isManager
                ? [Colors.orange.shade50, Colors.white]
                : [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Hero(
            tag: 'user_${user.id}',
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: user.isAdmin
                      ? [Colors.red.shade400, Colors.red.shade700]
                      : user.isManager
                      ? [Colors.orange.shade400, Colors.orange.shade700]
                      : [Colors.blue.shade400, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color:
                        (user.isAdmin
                                ? Colors.red
                                : user.isManager
                                ? Colors.orange
                                : Colors.blue)
                            .withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                user.isAdmin
                    ? Icons.admin_panel_settings
                    : user.isManager
                    ? Icons.business_center
                    : Icons.person,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          title: Text(
            user.fullName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.email, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      user.email,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: user.isAdmin
                            ? [Colors.red.shade400, Colors.red.shade600]
                            : user.isManager
                            ? [Colors.orange.shade400, Colors.orange.shade600]
                            : [Colors.blue.shade400, Colors.blue.shade600],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (user.isAdmin
                                      ? Colors.red
                                      : user.isManager
                                      ? Colors.orange
                                      : Colors.blue)
                                  .withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      user.isAdmin
                          ? 'ADMIN'
                          : user.isManager
                          ? 'MANAGER'
                          : 'USER',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user,
                          size: 12,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.visibility, color: Colors.grey, size: 20),
          ),
        ),
      ),
    );
  }
}
