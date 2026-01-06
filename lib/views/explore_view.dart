import 'package:carpik_kaldirimlar/models/post.dart';
import 'package:carpik_kaldirimlar/services/post_service.dart';
import 'package:carpik_kaldirimlar/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allPosts = context.watch<PostService>().posts;
    
    // Filter posts
    final posts = _searchQuery.isEmpty 
        ? allPosts 
        : allPosts.where((post) {
            final query = _searchQuery.toLowerCase();
            return post.title.toLowerCase().contains(query) || 
                   post.author.toLowerCase().contains(query);
          }).toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keşfet',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Yeni hikayeler, denemeler ve şiirler.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Ara...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainer,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 32),

                if (posts.isEmpty)
                   Center(
                     child: Padding(
                       padding: const EdgeInsets.all(32.0),
                       child: Text('Sonuç bulunamadı.', style: theme.textTheme.bodyLarge),
                     ),
                   )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return PostCard(
                        post: post,
                        onTap: () => context.push('/post/${post.id}'),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
