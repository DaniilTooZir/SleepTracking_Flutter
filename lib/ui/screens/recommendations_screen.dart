import 'package:flutter/material.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  _RecommendationsScreenState createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final List<String> _recommendations = [
    'Старайтесь ложиться спать и просыпаться в одно и то же время.',
    'Избегайте экранов за час до сна.',
    'Не употребляйте кофеин вечером.',
  ];

  void _refreshRecommendations() {
    setState(() {
      // Здесь позже будет логика обновления рекомендаций
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Рекомендации')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  children: [
                    ListView.separated(
                      itemCount: _recommendations.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.check_circle_outline),
                          title: Text(
                            _recommendations[index],
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      },
                      separatorBuilder:
                          (context, index) => const Divider(thickness: 1),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _refreshRecommendations,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Обновить рекомендации'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
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
}
