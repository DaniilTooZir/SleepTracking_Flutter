import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sleep_tracking/data/services/sleep_tracking_service.dart';
import 'package:sleep_tracking/models/sleep_recording.dart';
import 'package:sleep_tracking/providers/user_provider.dart';

class SleepTrackingScreen extends StatefulWidget {
  const SleepTrackingScreen({super.key});

  @override
  _SleepTrackingScreenState createState() => _SleepTrackingScreenState();
}

class _SleepTrackingScreenState extends State<SleepTrackingScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _selectedQuality;

  final List<String> _qualityOptions = [
    'Ужасное',
    'Плохое',
    'Нормальное',
    'Хорошее',
    'Отличное',
  ];
  final SleepTrackingService _sleepTrackingService = SleepTrackingService();
  List<SleepRecording> _sleepRecords = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSleepRecords());
  }

  Future<void> _loadSleepRecords() async {
    final userId = context.read<UserProvider>().userId;
    if (userId != null) {
      try {
        final records = await _sleepTrackingService.getSleepRecords(userId);
        setState(() {
          _sleepRecords = records;
        });
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка загрузки записей: $e')));
      }
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2026),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        if (isStart) {
          _startTime = time;
        } else {
          _endTime = time;
        }
      });
    }
  }

  Duration _calculateDuration(TimeOfDay start, TimeOfDay end) {
    final startDuration = Duration(hours: start.hour, minutes: start.minute);
    final endDuration = Duration(hours: end.hour, minutes: end.minute);
    return endDuration >= startDuration
        ? endDuration - startDuration
        : const Duration(hours: 24) - startDuration + endDuration;
  }

  Future<void> _addSleepRecord() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = context.read<UserProvider>().userId;
    if (userId == null) {
      _showSnackBar('Ошибка: не найден пользователь');
      return;
    }

    try {
      final record = await _sleepTrackingService.addSleepRecord(
        userId: userId,
        date: _selectedDate!,
        sleepStart: Duration(
          hours: _startTime!.hour,
          minutes: _startTime!.minute,
        ),
        sleepEnd: Duration(hours: _endTime!.hour, minutes: _endTime!.minute),
        sleepQuality: _selectedQuality!,
      );

      _showSnackBar('Запись добавлена');
      _formKey.currentState!.reset();
      setState(() {
        _selectedDate = null;
        _startTime = null;
        _endTime = null;
        _selectedQuality = null;
      });
      _loadSleepRecords();
    } catch (e) {
      _showSnackBar('Ошибка: $e');
    }
  }

  Future<void> _deleteSleepRecord(int id) async {
    try {
      await _sleepTrackingService.deleteSleepRecord(id);
      _showSnackBar('Запись удалена');
      _loadSleepRecords();
    } catch (e) {
      _showSnackBar('Ошибка: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildTimeRow(String label, TimeOfDay? time, VoidCallback onTap) {
    return Row(
      children: [
        Expanded(
          child: Text(
            time == null
                ? '$label не выбрано'
                : '$label: ${time.format(context)}',
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(onPressed: onTap, child: Text(label)),
      ],
    );
  }

  Widget _buildDateRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            _selectedDate == null
                ? 'Дата сна не выбрана'
                : 'Дата сна: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(onPressed: _pickDate, child: const Text('Выбрать дату')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Отслеживание сна')),
      body: LayoutBuilder(
        builder:
            (context, constraints) => Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildDateRow(),
                            const SizedBox(height: 10),
                            _buildTimeRow(
                              'Начало сна',
                              _startTime,
                              () => _pickTime(isStart: true),
                            ),
                            const SizedBox(height: 10),
                            _buildTimeRow(
                              'Конец сна',
                              _endTime,
                              () => _pickTime(isStart: false),
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Качество сна',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedQuality,
                              items:
                                  _qualityOptions
                                      .map(
                                        (q) => DropdownMenuItem(
                                          value: q,
                                          child: Text(q),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  (val) =>
                                      setState(() => _selectedQuality = val),
                              validator:
                                  (val) =>
                                      val == null
                                          ? 'Выберите качество сна'
                                          : null,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _addSleepRecord,
                                icon: const Icon(Icons.add),
                                label: const Text('Добавить запись'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Divider(),
                      const SizedBox(height: 10),
                      _sleepRecords.isEmpty
                          ? const Center(
                            child: Text(
                              'Нет записей о сне',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                          : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _sleepRecords.length,
                            itemBuilder: (context, index) {
                              final record = _sleepRecords[index];
                              return ListTile(
                                title: Text(
                                  'Дата: ${record.date.toLocal().toString().split(' ')[0]}',
                                ),
                                subtitle: Text(
                                  'Начало: ${record.sleepStart}, Конец: ${record.sleepEnd}, Качество: ${record.sleepQuality}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    if (record.id != null) {
                                      _deleteSleepRecord(record.id!);
                                    } else {
                                      _showSnackBar(
                                        'Ошибка: ID записи не найден',
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
