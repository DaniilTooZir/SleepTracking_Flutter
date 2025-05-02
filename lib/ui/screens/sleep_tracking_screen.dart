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

  // Список записей о сне
  List<SleepRecording> _sleepRecords = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSleepRecords();
    });
  }

  Future<void> _loadSleepRecords() async {
    final userId = context
        .read<UserProvider>()
        .userId;
    if (userId == null) {
      try {
        final records = await _sleepTrackingService.getSleepRecords(userId!);
        setState(() {
          _sleepRecords = records;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки записей: $e')),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final TimeOfDay? time = await showTimePicker(
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

  Future<void> _addSleepRecord() async {
    if (_formKey.currentState!.validate()) {
      final userId = context.read<UserProvider>().userId;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка: не найден пользователь')),
        );
        return;
      }
      try {
        final sleepStart = Duration(
            hours: _startTime!.hour, minutes: _startTime!.minute);
        final sleepEnd = Duration(
            hours: _endTime!.hour, minutes: _endTime!.minute);

        final sleepRecord = await _sleepTrackingService.addSleepRecord(
          userId: userId,
          date: _selectedDate!,
          sleepStart: sleepStart,
          sleepEnd: sleepEnd,
          sleepQuality: _selectedQuality!,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Запись добавлена')),
        );

        // Обновляем список записей о сне
        _loadSleepRecords();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Отслеживание сна')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
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
                          // Дата
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedDate == null
                                      ? 'Дата сна не выбрана'
                                      : 'Дата сна: ${_selectedDate!
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0]}',
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _pickDate,
                                child: const Text('Выбрать дату'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Время начала
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _startTime == null
                                      ? 'Время начала не выбрано'
                                      : 'Начало сна: ${_startTime!.format(
                                      context)}',
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _pickTime(isStart: true),
                                child: const Text('Начало сна'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Время конца
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _endTime == null
                                      ? 'Время конца не выбрано'
                                      : 'Конец сна: ${_endTime!.format(
                                      context)}',
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _pickTime(isStart: false),
                                child: const Text('Конец сна'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Качество сна
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Качество сна',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedQuality,
                            items: _qualityOptions
                                .map(
                                  (quality) =>
                                  DropdownMenuItem(
                                    value: quality,
                                    child: Text(quality),
                                  ),
                            )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedQuality = value),
                            validator: (value) =>
                            value == null ? 'Выберите качество сна' : null,
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
                    SizedBox(
                      height: 200,
                      child: _sleepRecords.isEmpty
                          ? const Center(
                        child: Text(
                          'Нет записей о сне',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                          : ListView.builder(
                        itemCount: _sleepRecords.length,
                        itemBuilder: (context, index) {
                          final record = _sleepRecords[index];
                          return ListTile(
                            title: Text(
                                'Дата: ${record.date.toLocal().toString().split(
                                    ' ')[0]}'),
                            subtitle: Text(
                                'Начало: ${record.sleepStart}, Конец: ${record
                                    .sleepEnd}, Качество: ${record
                                    .sleepQuality}'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                try {
                                  if (record.id != null) {
                                    _deleteSleepRecord(record.id!);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text(
                                          'Ошибка: ID записи не найден')),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Ошибка: $e')),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteSleepRecord(int id) async {
    try {
      await _sleepTrackingService.deleteSleepRecord(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Запись удалена')),
      );
      _loadSleepRecords();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }
}
