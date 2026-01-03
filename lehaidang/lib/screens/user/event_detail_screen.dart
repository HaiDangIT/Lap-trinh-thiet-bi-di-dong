import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/event_service.dart';
import '../../models/event_model.dart';
import 'add_event_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    final eventService = Provider.of<EventService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Sự Kiện'),
        backgroundColor: event.color,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEventScreen(
                    selectedDate: event.startTime,
                    eventToEdit: event,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Xác nhận xóa'),
                  content: const Text('Bạn có chắc muốn xóa sự kiện này?'),
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

              if (confirm == true && context.mounted) {
                await eventService.deleteEvent(event.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xóa sự kiện'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with color
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: event.color,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (event.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      event.description,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Date & Time
                  _DetailCard(
                    icon: Icons.calendar_today,
                    iconColor: Colors.blue,
                    title: 'Thời gian',
                    children: [
                      _DetailRow(
                        label: 'Ngày',
                        value: dateFormat.format(event.startTime),
                      ),
                      const Divider(),
                      _DetailRow(
                        label: 'Bắt đầu',
                        value: timeFormat.format(event.startTime),
                      ),
                      const Divider(),
                      _DetailRow(
                        label: 'Kết thúc',
                        value: timeFormat.format(event.endTime),
                      ),
                      const Divider(),
                      _DetailRow(
                        label: 'Thời lượng',
                        value: _getDuration(event.startTime, event.endTime),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Location
                  if (event.location != null)
                    _DetailCard(
                      icon: Icons.location_on,
                      iconColor: Colors.red,
                      title: 'Địa điểm',
                      children: [
                        Text(
                          event.location!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),

                  if (event.location != null) const SizedBox(height: 16),

                  // Reminder
                  _DetailCard(
                    icon: Icons.notifications,
                    iconColor: Colors.orange,
                    title: 'Nhắc nhở',
                    children: [
                      Row(
                        children: [
                          Icon(
                            event.hasReminder
                                ? Icons.notifications_active
                                : Icons.notifications_off,
                            color: event.hasReminder
                                ? Colors.orange
                                : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            event.hasReminder
                                ? 'Nhắc trước ${event.reminderMinutesBefore} phút'
                                : 'Không có nhắc nhở',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Participants (if any)
                  if (event.participants.isNotEmpty)
                    _DetailCard(
                      icon: Icons.people,
                      iconColor: Colors.purple,
                      title: 'Người tham gia',
                      children: [
                        ...event.participants.map(
                          (participant) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 16,
                                  child: Icon(Icons.person, size: 16),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  participant,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // Metadata
                  _DetailCard(
                    icon: Icons.info,
                    iconColor: Colors.grey,
                    title: 'Thông tin',
                    children: [
                      _DetailRow(
                        label: 'Tạo lúc',
                        value: dateFormat.format(event.createdAt),
                      ),
                      const Divider(),
                      _DetailRow(label: 'ID', value: event.id),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '$hours giờ ${minutes > 0 ? '$minutes phút' : ''}';
    } else {
      return '$minutes phút';
    }
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Widget> children;

  const _DetailCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
