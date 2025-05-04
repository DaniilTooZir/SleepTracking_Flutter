import 'package:sleep_tracking/data/database/connection_to_database.dart';
import 'package:sleep_tracking/models/sleep_recording.dart';

class RecommendationService {
  Future<List<String>> generateRecommendations(int userId) async {
    final response = await SupabaseConnection.client
        .from('SleepRecording')
        .select()
        .eq('UserId', userId)
        .order('Date', ascending: false);

    if (response.isEmpty) {
      return ['Добавьте записи сна, чтобы получить рекомендации.'];
    }

    final sleepRecords = response
        .map((record) => SleepRecording.fromMap(record))
        .toList();

    final avgDuration = sleepRecords
        .map((e) => e.sleepDuration)
        .reduce((a, b) => a + b) / sleepRecords.length;

    final qualityScores = sleepRecords.map((e) =>
        _qualityToScore(e.sleepQuality)).toList();
    final avgQuality = qualityScores.reduce((a, b) => a + b) /
        qualityScores.length;

    final List<String> recommendations = [];

    if (avgDuration < 7) {
      recommendations.add(
          'Ваш средний сон меньше 7 часов. Постарайтесь ложиться раньше.');
    }

    if (avgQuality < 3) {
      recommendations.add(
          'Качество сна невысокое. Возможно, стоит попробовать расслабление перед сном.');
    }

    if (sleepRecords.length < 5) {
      recommendations.add(
          'Добавьте больше записей сна для более точной аналитики.');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Ваш сон в норме! Продолжайте в том же духе 😊');
    }

    return recommendations;
  }

  int _qualityToScore(String quality) {
    switch (quality.toLowerCase()) {
      case 'плохой':
        return 1;
      case 'средний':
        return 3;
      case 'хороший':
        return 5;
      default:
        return 3;
    }
  }
}