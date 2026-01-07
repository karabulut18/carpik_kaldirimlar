import 'package:carpik_kaldirimlar/models/post.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (post.authorId.isNotEmpty && 
                          GoRouter.of(context).routerDelegate.currentConfiguration.uri.path != '/user/${post.authorId}') {
                        context.push('/user/${post.authorId}');
                      }
                    },
                    child: Text(
                      post.author,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('d MMMM y').format(post.date),
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Icon(Icons.remove_red_eye_outlined, size: 16, color: theme.colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    '${post.viewCount}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.favorite_border, size: 16, color: theme.colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    '${post.likeCount}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                post.excerpt ?? '',
                style: theme.textTheme.bodyLarge,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: onTap,
                child: const Text('Devamını oku →'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
