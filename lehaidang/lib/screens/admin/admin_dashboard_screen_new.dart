import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/event_service.dart';
import '../../models/event_model.dart';
import '../../models/user_model.dart';
import 'add_edit_user_screen.dart';
import 'admin_settings_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to show/hide FAB
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Tổng Quan'),
            Tab(icon: Icon(Icons.people), text: 'Người Dùng'),
            Tab(icon: Icon(Icons.event), text: 'Sự Kiện'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminSettingsScreen()),
              );
            },
            tooltip: 'Cài đặt',
          ),
          PopupMenuButton<void>(
            icon: const Icon(Icons.account_circle),
            itemBuilder: (context) => <PopupMenuEntry<void>>[
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.admin_panel_settings),
                  title: Text(authService.currentUser?.fullName ?? 'Admin'),
                  subtitle: Text(authService.currentUser?.email ?? ''),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                onTap: () async {
                  await authService.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/');
                  }
                },
                child: const ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Đăng Xuất', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_OverviewTab(), _UsersTab(), _EventsTab()],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEditUserScreen()),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Thêm'),
              backgroundColor: Colors.deepPurple,
            )
          : null,
    );
  }
}

// Overview Tab
class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final eventService = Provider.of<EventService>(context);

    final allUsers = authService.getAllUsers();
    final adminCount = allUsers.where((u) => u.role == UserRole.admin).length;
    final managerCount = allUsers
        .where((u) => u.role == UserRole.manager)
        .length;
    final userCount = allUsers.where((u) => u.role == UserRole.user).length;
    final allEvents = eventService.getAllEvents();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thống kê hệ thống',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Tổng người dùng',
                  value: allUsers.length.toString(),
                  icon: Icons.people,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Tổng sự kiện',
                  value: allEvents.length.toString(),
                  icon: Icons.event,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Role breakdown
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Admin',
                  value: adminCount.toString(),
                  icon: Icons.admin_panel_settings,
                  color: Colors.purple,
                  isSmall: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Manager',
                  value: managerCount.toString(),
                  icon: Icons.supervisor_account,
                  color: Colors.orange,
                  isSmall: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'User',
                  value: userCount.toString(),
                  icon: Icons.person,
                  color: Colors.teal,
                  isSmall: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Recent activities
          Text(
            'Hoạt động gần đây',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRecentActivities(allUsers, allEvents),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(List<User> users, List<Event> events) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person_add, color: Colors.blue),
            title: const Text('Người dùng mới nhất'),
            subtitle: users.isNotEmpty
                ? Text(
                    '${users.last.fullName} - ${users.last.role.displayName}',
                  )
                : const Text('Chưa có người dùng'),
            trailing: users.isNotEmpty
                ? Text(
                    DateFormat('dd/MM/yyyy').format(
                      DateTime.fromMillisecondsSinceEpoch(
                        int.parse(users.last.id),
                      ),
                    ),
                  )
                : null,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.event, color: Colors.green),
            title: const Text('Sự kiện sắp tới'),
            subtitle: events.isNotEmpty
                ? Text(events.first.title)
                : const Text('Chưa có sự kiện'),
            trailing: events.isNotEmpty
                ? Text(DateFormat('dd/MM').format(events.first.startTime))
                : null,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isSmall;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isSmall ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: isSmall ? 24 : 32),
                if (!isSmall)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: isSmall ? 8 : 12),
            Text(
              title,
              style: TextStyle(
                fontSize: isSmall ? 12 : 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isSmall) ...[
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Users Tab với phân loại theo role
class _UsersTab extends StatefulWidget {
  const _UsersTab();

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  UserRole? _filterRole;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        var users = authService.getAllUsers();

        // Apply role filter
        if (_filterRole != null) {
          users = users.where((u) => u.role == _filterRole).toList();
        }

        return Column(
          children: [
            // Filter chips
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey[100],
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('Tất cả'),
                      selected: _filterRole == null,
                      onSelected: (_) => setState(() => _filterRole = null),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Admin'),
                      selected: _filterRole == UserRole.admin,
                      onSelected: (_) =>
                          setState(() => _filterRole = UserRole.admin),
                      avatar: const Icon(Icons.admin_panel_settings, size: 18),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Manager'),
                      selected: _filterRole == UserRole.manager,
                      onSelected: (_) =>
                          setState(() => _filterRole = UserRole.manager),
                      avatar: const Icon(Icons.supervisor_account, size: 18),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('User'),
                      selected: _filterRole == UserRole.user,
                      onSelected: (_) =>
                          setState(() => _filterRole = UserRole.user),
                      avatar: const Icon(Icons.person, size: 18),
                    ),
                  ],
                ),
              ),
            ),
            // User list
            Expanded(
              child: users.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không có người dùng',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: users.length,
                      padding: const EdgeInsets.all(8),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return _UserCard(user: user);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _UserCard extends StatelessWidget {
  final User user;

  const _UserCard({required this.user});

  Color _getRoleColor() {
    switch (user.role) {
      case UserRole.admin:
        return Colors.purple;
      case UserRole.manager:
        return Colors.orange;
      case UserRole.user:
        return Colors.blue;
    }
  }

  IconData _getRoleIcon() {
    switch (user.role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.manager:
        return Icons.supervisor_account;
      case UserRole.user:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor().withValues(alpha: 0.1),
          child: Icon(_getRoleIcon(), color: _getRoleColor()),
        ),
        title: Text(
          user.fullName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getRoleColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.role.displayName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getRoleColor(),
                    ),
                  ),
                ),
                if (user.twoFactorEnabled)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.security, size: 12, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          '2FA',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Chỉnh sửa'),
                ],
              ),
            ),
            if (!user.isAdminRole)
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Xóa', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
          ],
          onSelected: (value) async {
            if (value == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditUserScreen(userToEdit: user),
                ),
              );
            } else if (value == 'delete') {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Xác nhận xóa'),
                  content: Text('Bạn có chắc muốn xóa ${user.fullName}?'),
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

              if (confirmed == true && context.mounted) {
                final authService = Provider.of<AuthService>(
                  context,
                  listen: false,
                );
                await authService.deleteUser(user.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xóa người dùng')),
                  );
                }
              }
            }
          },
        ),
      ),
    );
  }
}

// Events Tab
class _EventsTab extends StatelessWidget {
  const _EventsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<EventService>(
      builder: (context, eventService, child) {
        final events = eventService.getAllEvents();

        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'Chưa có sự kiện nào',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: events.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final event = events[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: event.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                title: Text(
                  event.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(event.startTime),
                    ),
                    if (event.location?.isNotEmpty == true)
                      Text(
                        event.location!,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility, size: 20),
                              SizedBox(width: 8),
                              Text('Xem'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Xóa', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) async {
                        if (value == 'delete') {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Xác nhận xóa'),
                              content: Text(
                                'Bạn có chắc muốn xóa "${event.title}"?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
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

                          if (confirmed == true && context.mounted) {
                            eventService.deleteEvent(event.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã xóa sự kiện')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
