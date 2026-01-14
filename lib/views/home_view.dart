import 'package:carpik_kaldirimlar/models/post.dart';
import 'package:carpik_kaldirimlar/services/post_service.dart';
import 'package:carpik_kaldirimlar/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
            child: Builder(
              builder: (context) {
                final featuredParams = context.select<PostService, List<Post>>((s) => s.featuredPosts);
                if (featuredParams.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
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
                          onPressed: () => context.go('/create-post'),
                          icon: const Icon(Icons.edit),
                          label: const LabelText('Yazmaya Başla'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                final featured = featuredParams.first;
                return InkWell(
                  onTap: () => context.push('/post/${featured.id}'),
                  child: Container(
                    width: double.infinity,
                    height: 400,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      image: featured.imageUrl != null 
                        ? DecorationImage(
                            image: NetworkImage(featured.imageUrl!), 
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.5), BlendMode.darken),
                          ) 
                        : null,
                    ),
                    child: Container(
                       padding: const EdgeInsets.all(32),
                       alignment: Alignment.bottomLeft,
                       decoration: const BoxDecoration(
                         gradient: LinearGradient(
                           begin: Alignment.topCenter, 
                           end: Alignment.bottomCenter,
                           colors: [Colors.transparent, Colors.black87],
                         )
                       ),
                       child: Column(
                         mainAxisSize: MainAxisSize.min,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Container(
                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                             decoration: BoxDecoration(
                               color: theme.colorScheme.primary,
                               borderRadius: BorderRadius.circular(4),
                             ),
                             child: Text(
                               'GÜNÜN YAZISI',
                               style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onPrimary),
                             ),
                           ),
                           const SizedBox(height: 16),
                           Text(
                             featured.title,
                             style: theme.textTheme.displaySmall?.copyWith(
                               color: Colors.white, 
                               fontWeight: FontWeight.bold
                             ),
                           ),
                           const SizedBox(height: 8),
                           Text(
                             featured.excerpt ?? '',
                             style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
                             maxLines: 2,
                             overflow: TextOverflow.ellipsis,
                           ),
                           const SizedBox(height: 24),
                           FilledButton.icon(
                             onPressed: () => context.push('/post/${featured.id}'), 
                             icon: const Icon(Icons.read_more), 
                             label: const Text('Devamını Oku')
                           ),
                         ],
                       ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Featured Section Header
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Son Yazılar',
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
