import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sleep_tracking/data/services/sleep_tracking_service.dart';
import 'package:sleep_tracking/models/sleep_recording.dart';
import 'package:sleep_tracking/providers/user_provider.dart';

// Экран для отслеживания сна
class SleepTrackingScreen extends StatefulWidget {
  const SleepTrackingScreen({super.key});

  @override
  _SleepTrackingScreenState createState() => _SleepTrackingScreenState();
}

class _SleepTrackingScreenState extends State<SleepTrackingScreen> {
  // Ключ формы для валидации полей
  final _formKey = GlobalKey<FormState>();
  // Переменные для хранения выбранной даты, времени начала и окончания сна, а также качества сна
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
  // Сервис для работы с данными о сне
  final SleepTrackingService _sleepTrackingService = SleepTrackingService();
  List<SleepRecording> _sleepRecords = [];
  // Инициализация данных после построения виджета
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSleepRecords());
  }

  // Загрузка записей о сне из базы данных
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

  // Открытие диалога для выбора даты
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  // Открытие диалога для выбора времени
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

  // Вычисление продолжительности сна
  Duration _calculateDuration(TimeOfDay start, TimeOfDay end) {
    final startDuration = Duration(hours: start.hour, minutes: start.minute);
    final endDuration = Duration(hours: end.hour, minutes: end.minute);
    return endDuration >= startDuration
        ? endDuration - startDuration
        : const Duration(hours: 24) - startDuration + endDuration;
  }

  // Добавление новой записи о сне
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

  // Удаление записи о сне
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

  // Форматирование продолжительности в строку для отображения
  String _formatDurationToTime(Duration duration) {
    final hours = duration.inHours.remainder(24).toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
  // Построение строки с выбором времени для начала и конца сна
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
  // Построение строки с выбором даты
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
  // Форматирование времени из дробных часов в "чч:мм"
  String formatDoubleHoursToHM(double hours) {
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
  // Метод для создания UI
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
                                  'Начало: ${_formatDurationToTime(record.sleepStart)}, '
                                  'Конец: ${_formatDurationToTime(record.sleepEnd)}, '
                                  'Длительность: ${formatDoubleHoursToHM(record.sleepDuration)} ч, '
                                  'Качество: ${record.sleepQuality}',
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
