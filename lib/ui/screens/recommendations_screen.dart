import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sleep_tracking/providers/user_provider.dart';
import 'package:sleep_tracking/data/services/recommendation_service.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  _RecommendationsScreenState createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  List<String> _recommendations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;

    if (userId != null) {
      final service = RecommendationService();
      final recs = await service.generateRecommendations(userId);
      setState(() {
        _recommendations = recs;
        _isLoading = false;
      });
    } else {
      setState(() {
        _recommendations = ['Ошибка: пользователь не найден.'];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Рекомендации по сну')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _recommendations.isEmpty
              ? const Center(child: Text('Нет доступных рекомендаций.'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _recommendations.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _recommendations[index],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
