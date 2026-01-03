import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../services/auth_service.dart';
import '../../services/event_service.dart';
import '../../models/event_model.dart';

class AddEventScreen extends StatefulWidget {
  final DateTime selectedDate;
  final Event? eventToEdit;

  const AddEventScreen({
    super.key,
    required this.selectedDate,
    this.eventToEdit,
  });

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  Color _selectedColor = Colors.blue;
  bool _hasReminder = false;
  int _reminderMinutes = 15;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.eventToEdit != null) {
      // Edit mode
      final event = widget.eventToEdit!;
      _titleController.text = event.title;
      _descriptionController.text = event.description;
      _locationController.text = event.location ?? '';
      _startDate = event.startTime;
      _startTime = TimeOfDay.fromDateTime(event.startTime);
      _endDate = event.endTime;
      _endTime = TimeOfDay.fromDateTime(event.endTime);
      _selectedColor = event.color;
      _hasReminder = event.hasReminder;
      _reminderMinutes = event.reminderMinutesBefore;
    } else {
      // Add mode
      _startDate = widget.selectedDate;
      _startTime = const TimeOfDay(hour: 9, minute: 0);
      _endDate = widget.selectedDate;
      _endTime = const TimeOfDay(hour: 10, minute: 0);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  Future<void> _selectColor() async {
    Color pickerColor = _selectedColor;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn màu sự kiện'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) {
              pickerColor = color;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _selectedColor = pickerColor);
              Navigator.pop(context);
            },
            child: const Text('Chọn'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    final startDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thời gian kết thúc phải sau thời gian bắt đầu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final eventService = Provider.of<EventService>(context, listen: false);

    final event = Event(
      id:
          widget.eventToEdit?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      userId: authService.currentUser!.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      startTime: startDateTime,
      endTime: endDateTime,
      color: _selectedColor,
      hasReminder: _hasReminder,
      reminderMinutesBefore: _reminderMinutes,
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
    );

    bool success;
    if (widget.eventToEdit != null) {
      success = await eventService.updateEvent(event);
    } else {
      success = await eventService.addEvent(event);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.eventToEdit != null
                ? 'Cập nhật sự kiện thành công'
                : 'Thêm sự kiện thành công',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.eventToEdit != null ? 'Chỉnh Sửa Sự Kiện' : 'Thêm Sự Kiện',
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Tiêu đề *',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tiêu đề';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Mô tả',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Location
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Địa điểm',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Start Date & Time
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectStartDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Ngày bắt đầu',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(dateFormat.format(_startDate)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _selectStartTime,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Giờ bắt đầu',
                        prefixIcon: const Icon(Icons.access_time),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(_startTime.format(context)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // End Date & Time
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectEndDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Ngày kết thúc',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(dateFormat.format(_endDate)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _selectEndTime,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Giờ kết thúc',
                        prefixIcon: const Icon(Icons.access_time),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(_endTime.format(context)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Color Picker
            InkWell(
              onTap: _selectColor,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Màu sắc',
                  prefixIcon: const Icon(Icons.palette),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('Chọn màu'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Reminder
            Card(
              child: SwitchListTile(
                title: const Text('Nhắc nhở'),
                subtitle: _hasReminder
                    ? Text('Nhắc trước $_reminderMinutes phút')
                    : const Text('Không có nhắc nhở'),
                value: _hasReminder,
                onChanged: (value) {
                  setState(() => _hasReminder = value);
                },
                secondary: const Icon(Icons.notifications),
              ),
            ),

            if (_hasReminder) ...[
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nhắc trước: $_reminderMinutes phút',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Slider(
                        value: _reminderMinutes.toDouble(),
                        min: 5,
                        max: 60,
                        divisions: 11,
                        label: '$_reminderMinutes phút',
                        onChanged: (value) {
                          setState(() => _reminderMinutes = value.toInt());
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        widget.eventToEdit != null
                            ? 'Cập Nhật'
                            : 'Thêm Sự Kiện',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
