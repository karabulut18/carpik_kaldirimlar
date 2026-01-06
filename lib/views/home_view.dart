import 'package:carpik_kaldirimlar/models/post.dart';
import 'package:carpik_kaldirimlar/services/post_service.dart';
import 'package:carpik_kaldirimlar/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              ),
              child: Column(
                children: [
                  Text(
                    'Çarpık Kaldırımlar',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Her hikaye bir adımla başlar. Sizinki burada.',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit),
                    label: const LabelText('Yazmaya Başla'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Featured Section Header
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Öne Çıkan Yazılar',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Post List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final posts = context.read<PostService>().posts;
                  // Use take(3) effectively by checking index or just showing first 3
                  if (index >= posts.length) return const SizedBox.shrink(); 
                  final post = posts[index];
                  
                  return PostCard(
                    post: post,
                    onTap: () => context.push('/post/${post.id}'),
                  );
                },
                childCount: context.watch<PostService>().posts.length.clamp(0, 3), // Show max 3 on home
              ),
            ),
          ),
          
          // Footer Spacer
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}
  
  class LabelText extends StatelessWidget {
    final String text;
    const LabelText(this.text, {super.key});
  
    @override
    Widget build(BuildContext context) {
      return Text(text);
    }
  }
