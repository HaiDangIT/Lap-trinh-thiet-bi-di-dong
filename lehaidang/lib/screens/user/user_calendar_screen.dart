import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/event_service.dart';
import '../../models/event_model.dart';
import 'add_event_screen.dart';
import 'event_detail_screen.dart';
import 'user_settings_screen.dart';

/// User Calendar Screen - Google Calendar style
class UserCalendarScreen extends StatefulWidget {
  const UserCalendarScreen({super.key});

  @override
  State<UserCalendarScreen> createState() => _UserCalendarScreenState();
}

class _UserCalendarScreenState extends State<UserCalendarScreen>
    with SingleTickerProviderStateMixin {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(
    DateTime day,
    EventService eventService,
    String userId,
  ) {
    return eventService.getEventsForDate(day, userId);
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final eventService = Provider.of<EventService>(context);
    final userId = authService.currentUser?.id ?? '';
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            if (!isDesktop)
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            Icon(Icons.calendar_today, size: 24, color: Colors.blue),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Lịch',
                style: TextStyle(color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: EventSearchDelegate(eventService, userId),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserSettingsScreen()),
              );
            },
          ),
          PopupMenuButton<void>(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: Text(
                authService.currentUser?.fullName
                        .substring(0, 1)
                        .toUpperCase() ??
                    'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            itemBuilder: (context) => <PopupMenuEntry<void>>[
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(authService.currentUser?.fullName ?? ''),
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
                  title: Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: isDesktop ? null : _buildSideDrawer(context, userId),
      body: isDesktop
          ? Row(
              children: [
                // Sidebar bên trái (như Google Calendar)
                Container(
                  width: 256,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: _buildSideDrawer(context, userId),
                ),
                // Nội dung chính
                Expanded(child: _buildMainContent(eventService, userId)),
              ],
            )
          : _buildMainContent(eventService, userId),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddEventScreen(selectedDate: _selectedDay),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tạo sự kiện'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Sidebar với mini calendar
  Widget _buildSideDrawer(BuildContext context, String userId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Nút "Tạo" (giống Google Calendar)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddEventScreen(selectedDate: _selectedDay),
                  ),
                );
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Tạo', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 2,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Mini Calendar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: false,
                titleTextStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                leftChevronIcon: const Icon(Icons.chevron_left, size: 18),
                rightChevronIcon: const Icon(Icons.chevron_right, size: 18),
              ),
              daysOfWeekHeight: 28,
              rowHeight: 28,
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                weekendStyle: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              calendarStyle: CalendarStyle(
                cellMargin: const EdgeInsets.all(2),
                todayDecoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
                defaultTextStyle: const TextStyle(fontSize: 10),
                weekendTextStyle: const TextStyle(fontSize: 10),
                outsideDaysVisible: false,
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
            ),
          ),

          const SizedBox(height: 16),

          // Danh sách lịch (giống Google Calendar)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Lịch của tôi',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Các lịch (có thể mở rộng sau)
          _buildCalendarItem('0664_Lê Hải Đăng', Colors.blue, true),
          _buildCalendarItem('Học-Code', Colors.amber, true),
          _buildCalendarItem('Sinh nhật', Colors.green, true),
          _buildCalendarItem('Tasks', Colors.blue, true),
        ],
      ),
    );
  }

  Widget _buildCalendarItem(String name, Color color, bool isVisible) {
    return ListTile(
      dense: true,
      leading: Checkbox(
        value: isVisible,
        onChanged: (value) {
          // TODO: Toggle calendar visibility
        },
        activeColor: color,
        shape: const CircleBorder(),
      ),
      title: Text(name, style: const TextStyle(fontSize: 14)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  // Nội dung chính
  Widget _buildMainContent(EventService eventService, String userId) {
    return Column(
      children: [
        // Thanh điều hướng ngày tháng
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedDay = DateTime.now();
                    _focusedDay = DateTime.now();
                  });
                },
                icon: const Icon(Icons.today, size: 14),
                label: const Text('Hôm nay', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DateFormat('MMMM yyyy').format(_focusedDay),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(
                      _focusedDay.year,
                      _focusedDay.month - 1,
                    );
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(
                      _focusedDay.year,
                      _focusedDay.month + 1,
                    );
                  });
                },
              ),
            ],
          ),
        ),
        // Expanded calendar view - wrap in Flexible để tránh overflow
        Flexible(
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: (day) => _getEventsForDay(day, eventService, userId),
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerVisible: false,
            daysOfWeekHeight: 30,
            rowHeight: 38,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              todayDecoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              defaultTextStyle: const TextStyle(fontSize: 12),
              weekendTextStyle: const TextStyle(fontSize: 12),
              markerDecoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
              markerSize: 5,
              cellMargin: const EdgeInsets.all(2),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              weekendStyle: TextStyle(
                color: Colors.red[400],
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
          ),
        ),
        const SizedBox(height: 8),
        // Tab bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Colors.blue,
            indicatorWeight: 2,
            labelPadding: const EdgeInsets.symmetric(horizontal: 2),
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.event, size: 14),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        'Ngày ${DateFormat('d').format(_selectedDay)}',
                        style: const TextStyle(fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.upcoming, size: 14),
                    const SizedBox(width: 2),
                    const Flexible(
                      child: Text(
                        'Sắp tới',
                        style: TextStyle(fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.list, size: 14),
                    const SizedBox(width: 2),
                    const Flexible(
                      child: Text(
                        'Tất cả',
                        style: TextStyle(fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _DayEventsView(selectedDay: _selectedDay, userId: userId),
              _UpcomingEventsView(userId: userId),
              _AllEventsView(userId: userId),
            ],
          ),
        ),
      ],
    );
  }
}

// Day Events View
class _DayEventsView extends StatelessWidget {
  final DateTime selectedDay;
  final String userId;

  const _DayEventsView({required this.selectedDay, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventService>(
      builder: (context, eventService, child) {
        final events = eventService.getEventsForDate(selectedDay, userId);

        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_available, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Không có sự kiện',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('EEEE, d MMMM').format(selectedDay),
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

// Upcoming Events View
class _UpcomingEventsView extends StatelessWidget {
  final String userId;

  const _UpcomingEventsView({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventService>(
      builder: (context, eventService, child) {
        final events = eventService.getUpcomingEvents(userId);

        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_note, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Không có sự kiện sắp tới',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
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

// All Events View
class _AllEventsView extends StatelessWidget {
  final String userId;

  const _AllEventsView({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventService>(
      builder: (context, eventService, child) {
        final events = eventService.getUserEvents(userId);

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

// Event Card - Google Calendar style
class _EventCard extends StatelessWidget {
  final Event event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = event.color;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Color indicator
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              // Event details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Time
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('EEE, d MMM yyyy').format(event.startTime),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    // Location
                    if (event.location?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              event.location!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // More options
              IconButton(
                icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                onPressed: () {
                  _showEventOptions(context, event);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEventOptions(BuildContext context, Event event) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Chỉnh sửa'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEventScreen(
                    selectedDate: event.startTime,
                    eventToEdit: event,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Xóa', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Xác nhận xóa'),
                  content: Text('Bạn có chắc muốn xóa "${event.title}"?'),
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
                final eventService = Provider.of<EventService>(
                  context,
                  listen: false,
                );
                eventService.deleteEvent(event.id);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Đã xóa sự kiện')));
              }
            },
          ),
        ],
      ),
    );
  }
}

// Search Delegate
class EventSearchDelegate extends SearchDelegate {
  final EventService eventService;
  final String userId;

  EventSearchDelegate(this.eventService, this.userId);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = eventService.searchEvents(query, userId);

    return _buildResultsList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = eventService.searchEvents(query, userId);

    return _buildResultsList(suggestions);
  }

  Widget _buildResultsList(List<Event> events) {
    if (events.isEmpty) {
      return const Center(child: Text('Không tìm thấy sự kiện nào'));
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        return _EventCard(event: events[index]);
      },
    );
  }
}
