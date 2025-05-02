
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
  factory SleepRecording.fromMap(Map<String, dynamic> map) {
    return SleepRecording(
      id: map['Id'] != null ? map['Id'] as int : null,
      userId: map['UserId'],
      date: DateTime.parse(map['Date']),
      sleepStart: _parseInterval(map['SleepStart']),
      sleepEnd: _parseInterval(map['SleepEnd']),
      sleepDuration: map['SleepDuration'],
      sleepQuality: map['SleepQuality'],
    );
  }

  static Duration _parseInterval(String interval) {
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(interval);
    if (match == null) return Duration.zero;
    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;

    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

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