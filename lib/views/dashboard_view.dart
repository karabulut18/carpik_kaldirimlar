import 'package:carpik_kaldirimlar/services/auth_service.dart';
import 'package:carpik_kaldirimlar/services/post_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = context.watch<AuthService>();
    final postService = context.watch<PostService>();
    // Filter posts to show only those belonging to the current user
    final posts = postService.posts.where((p) => p.author == authService.currentUserName).toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hoşgeldin, ${authService.currentUserName ?? 'Yazar'}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Stats Row
                Row(
                  children: [
                    _StatCard(
                      label: 'Toplam Görüntülenme',
                      value: '154,320',
                      icon: Icons.bar_chart,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 24),
                    _StatCard(
                      label: 'Toplam Yazı',
                      value: posts.length.toString(),
                      icon: Icons.layers,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 24),
                    _StatCard(
                      label: 'Yorumlar',
                      value: '1,250',
                      icon: Icons.comment,
                      color: Colors.green,
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),
                Text(
                  'Son Yazılar',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: posts.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        title: Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(post.excerpt ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {}, // Edit placeholder
                              icon: const Icon(Icons.edit_outlined),
                              tooltip: 'Düzenle',
                            ),
                            IconButton(
                              onPressed: () {
                                context.read<PostService>().deletePost(post.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Yazı silindi')),
                                );
                              },
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              tooltip: 'Sil',
                            ),
                          ],
                        ),
                        onTap: () => context.push('/post/${post.id}'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/dashboard/create'),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Yazı'),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodyMedium),
                  const Spacer(),
                  Icon(icon, color: color, size: 20),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
