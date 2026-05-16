import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_flutter/providers/gamification_provider.dart';
import 'package:expense_tracker_flutter/models/badge.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Achievements'),
      ),
      body: Consumer<GamificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = provider.stats;
          final unlockedIds = provider.unlockedBadges.map((b) => b.badgeId).toSet();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Stats Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(icon: '⭐', label: 'Points', value: '${stats.points}'),
                      _StatItem(icon: '🔥', label: 'Streak', value: '${stats.currentStreak}'),
                      _StatItem(icon: '🏆', label: 'Best Streak', value: '${stats.bestStreak}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Badges Grid
              Text(
                'Badges',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: availableBadges.length,
                itemBuilder: (context, index) {
                  final badgeDef = availableBadges[index];
                  final isUnlocked = unlockedIds.contains(badgeDef.id);
                  
                  return Opacity(
                    opacity: isUnlocked ? 1.0 : 0.4,
                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(badgeDef.iconPath, style: const TextStyle(fontSize: 32)),
                          const SizedBox(height: 8),
                          Text(
                            badgeDef.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          if (!isUnlocked)
                            const Icon(Icons.lock, size: 16, color: Colors.grey)
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
