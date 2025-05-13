// Модель записи сна пользователя
class SleepRecording{
  final int? id;
  final int userId;
  final DateTime date;
  final Duration sleepStart;
  final Duration sleepEnd;
  final double sleepDuration;
  final String sleepQuality;

  SleepRecording({
    this.id,
    required this.userId,
    required this.date,
    required this.sleepStart,
    required this.sleepEnd,
    required this.sleepDuration,
    required this.sleepQuality
});
  // Преобразование записи из карты Supabase в объект
  factory SleepRecording.fromMap(Map<String, dynamic> map) {
    return SleepRecording(
      id: map['Id'] != null ? map['Id'] as int : null,
      userId: map['UserId'],
      date: DateTime.parse(map['Date']),
      sleepStart: _parseInterval(map['SleepStart']?.toString() ?? ''),
      sleepEnd: _parseInterval(map['SleepEnd']?.toString() ?? ''),
      sleepDuration: (map['SleepDuration'] as num).toDouble(),
      sleepQuality: map['SleepQuality'],
    );
  }
  // Преобразование строки формата Supabase в объект Duration
  static Duration _parseInterval(String interval) {
    final dayRegex = RegExp(r'(\d+)\s+days?\s+(\d+):(\d+):(\d+)');
    final timeOnlyRegex = RegExp(r'(\d+):(\d+):(\d+)');

    if (dayRegex.hasMatch(interval)) {
      final match = dayRegex.firstMatch(interval)!;
      final days = int.parse(match.group(1)!);
      final hours = int.parse(match.group(2)!);
      final minutes = int.parse(match.group(3)!);
      final seconds = int.parse(match.group(4)!);
      return Duration(days: days, hours: hours, minutes: minutes, seconds: seconds);
    } else if (timeOnlyRegex.hasMatch(interval)) {
      final match = timeOnlyRegex.firstMatch(interval)!;
      final hours = int.parse(match.group(1)!);
      final minutes = int.parse(match.group(2)!);
      final seconds = int.parse(match.group(3)!);
      return Duration(hours: hours, minutes: minutes, seconds: seconds);
    }
    return Duration.zero;
  }
  // Преобразование записи в карту для отправки в Supabase
  Map<String, dynamic> toMap({bool includeId = false}) {
    final map = <String, dynamic> {
      'UserId': userId,
      'Date': date.toIso8601String(),
      'SleepStart': 'PT${sleepStart.inHours}H${sleepStart.inMinutes % 60}M${sleepStart.inSeconds % 60}S',
      'SleepEnd': 'PT${sleepEnd.inHours}H${sleepEnd.inMinutes % 60}M${sleepEnd.inSeconds % 60}S',
      'SleepDuration': sleepDuration,
      'SleepQuality': sleepQuality,
    };
    if(includeId && id != null){
      map['Id'] = id;
    }
    return map;
  }
}