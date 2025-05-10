import 'package:sleep_tracking/data/database/connection_to_database.dart';
import 'package:sleep_tracking/models/sleep_recording.dart';

class RecommendationService {
  // Генерация рекомендаций на основе средней продолжительности сна и его качества
  Future<List<String>> generateRecommendations(int userId) async {
    try {
      final response = await SupabaseConnection.client
          .from('SleepRecording')
          .select()
          .eq('UserId', userId)
          .order('Date', ascending: false);

      if (response.isEmpty) {
        return ['Добавьте записи сна, чтобы получить рекомендации.'];
      }

      final sleepRecords =
          response.map((record) => SleepRecording.fromMap(record)).toList();

      final avgDuration =
          sleepRecords.map((e) => e.sleepDuration).reduce((a, b) => a + b) /
          sleepRecords.length;

      final qualityScores =
          sleepRecords.map((e) => _qualityToScore(e.sleepQuality)).toList();
      final avgQuality =
          qualityScores.reduce((a, b) => a + b) / qualityScores.length;

      return _getExpandedRecommendations(avgQuality, avgDuration);
    } catch (e) {
      print('Ошибка при генерации рекомендаций: $e');
      return ['Произошла ошибка при получении рекомендаций. Попробуйте позже.'];
    }
  }

  // Перевод текстовой оценки качества сна в числовую шкалу
  int _qualityToScore(String quality) {
    switch (quality.toLowerCase()) {
      case 'отличное':
        return 5;
      case 'хорошее':
        return 4;
      case 'нормальное':
        return 3;
      case 'плохое':
        return 2;
      case 'ужасное':
        return 1;
      default:
        return 0;
    }
  }

  // Получение подходящего списка рекомендаций по оценкам
  List<String> _getExpandedRecommendations(
    double avgQuality,
    double avgDuration,
  ) {
    if (avgQuality >= 4.5 && avgDuration >= 8) {
      return _recommendations['Excellent']!;
    } else if (avgQuality >= 4.0 && avgDuration >= 7) {
      return _recommendations['Good']!;
    } else if (avgQuality >= 3.0 && avgDuration >= 5) {
      return _recommendations['Average']!;
    } else if (avgQuality >= 2.0 || avgDuration >= 4) {
      return _recommendations['Poor']!;
    } else {
      return _recommendations['Terrible']!;
    }
  }

  // Карта всех возможных рекомендаций по категориям
  final Map<String, List<String>> _recommendations = {
    "Excellent": [
      "Вы отлично отдыхаете и восстанавливаетесь. Продолжайте соблюдать текущий режим дня и привычки. Для поддержания высокого уровня сна:",
      "Уделяйте время утренней зарядке или легкой физической активности.",
      "Используйте дневной свет для стабилизации биоритмов.",
      "Придерживайтесь своего режима даже в выходные.",
      "Ничего себе... Ну ты и засоня, как так получется спать? Ты чо Частер Спорта Международного Класса по сну что ли? Капец... НУ ТАК ДЕРЖАТЬ",
    ],
    "Good": [
      "Ваш сон нормальный, но есть возможность сделать его еще лучше:",
      "Добавьте расслабляющий чай с ромашкой или мелиссой перед сном.",
      "Избегайте слишком активного обсуждения или просмотров эмоциональных программ перед сном.",
      "Проверьте комфортность подушки и матраса — возможно, их замена улучшит качество сна.",
    ],
    "Average": [
      "Ваш сон нуждается в улучшении, но ситуация пока не критичная. Рекомендации:",
      "Установите чёткий график сна: ложитесь и просыпайтесь в одно и то же время.",
      "Добавьте вечерние прогулки на свежем воздухе.",
      "Постарайтесь исключить источники раздражения перед сном, такие как телевизор или громкие звуки.",
      "Попробуйте практиковать глубокое дыхание или йогу для расслабления.",
    ],
    "Poor": [
      "Ваш сон серьезно нарушен, и необходимо принять меры:",
      "Уменьшите время пребывания в постели в период бодрствования, чтобы стимулировать более глубокий сон.",
      "Ограничьте дневной сон до 15–20 минут, если чувствуете усталость.",
      "Постепенно уменьшайте уровень света за час до сна, создавая полумрак в комнате.",
      "Проконсультируйтесь с врачом, если нарушение сна продолжается больше недели.",
    ],
    "Terrible": [
      "Ситуация требует срочного внимания, чтобы избежать серьезных последствий:",
      "Начните вести дневник сна, чтобы фиксировать режимы и раздражители.",
      "Избегайте длительного нахождения в постели без сна — займитесь чем-то расслабляющим, а затем снова попытайтесь заснуть.",
      "Рассмотрите помощь специалиста для диагностики потенциальных проблем.",
      "Если тревога мешает засыпанию, попробуйте успокаивающие практики, например, медитацию или технику прогрессивной мышечной релаксации.",
      "Попробуйте натуральные добавки (например, мелатонин или магний), но только после консультации с врачом.",
    ],
  };
}
