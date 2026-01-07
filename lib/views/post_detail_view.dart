import 'package:carpik_kaldirimlar/models/comment.dart';
import 'package:carpik_kaldirimlar/models/post.dart';
import 'package:carpik_kaldirimlar/services/auth_service.dart';
import 'package:carpik_kaldirimlar/services/post_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';


class PostDetailView extends StatefulWidget {
  final String postId;

  const PostDetailView({super.key, required this.postId});

  @override
  State<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSendingComment = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostService>().incrementViewCount(widget.postId);
    });
  }
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleLike(String userId) async {
    await context.read<PostService>().toggleLike(widget.postId, userId);
  }

  void _addComment(String authorName, String authorId) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSendingComment = true);
    await context.read<PostService>().addComment(widget.postId, text, authorName, authorId);
    if (mounted) {
      _commentController.clear();
      setState(() => _isSendingComment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final postService = context.watch<PostService>();
    final authService = context.watch<AuthService>();
    final isLoggedIn = authService.isLoggedIn;
    final currentUserId = authService.currentUserId;

    final post = postService.getPost(widget.postId) ?? Post(
      id: '0',
      title: 'Bulunamadı',
      author: '-',
      authorId: '',
      date: DateTime.now(),
      excerpt: 'Yazı bulunamadı veya silinmiş olabilir.',
    );

    final isLiked = currentUserId != null && post.likes.contains(currentUserId);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (currentUserId == post.authorId)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.go('/dashboard/edit/${post.id}'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(post.author.isNotEmpty ? post.author[0] : '?'),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                             if (post.authorId.isNotEmpty) {
                               context.push('/user/${post.authorId}');
                             }
                          },
                          child: Text(
                            post.author,
                            style: theme.textTheme.titleMedium?.copyWith(
                              decoration: post.authorId.isNotEmpty ? TextDecoration.underline : null,
                              decorationColor: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              DateFormat('d MMMM y').format(post.date),
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(width: 8),
                            const Text('•'),
                            const SizedBox(width: 8),
                            Icon(Icons.remove_red_eye_outlined, size: 14, color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text('${post.viewCount}', style: theme.textTheme.bodySmall),
                            const SizedBox(width: 12),
                            Icon(isLiked ? Icons.favorite : Icons.favorite_border, 
                                 size: 14, 
                                 color: isLiked ? Colors.red : theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text('${post.likeCount}', style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (isLoggedIn)
                      FilledButton.icon(
                        onPressed: () => _toggleLike(currentUserId!),
                        icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                        label: Text(isLiked ? 'Beğendin' : 'Beğen'),
                        style: FilledButton.styleFrom(
                          backgroundColor: isLiked ? Colors.red.withOpacity(0.1) : null,
                          foregroundColor: isLiked ? Colors.red : null,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                // ... Image and Content
                if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 300,
                      width: double.infinity,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Image.network(
                        post.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                           const Center(child: Icon(Icons.image_not_supported, size: 48)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                // Markdown Rendering
                  MarkdownBody(
                    data: post.content ?? '',
                    softLineBreak: true,
                    styleSheet: MarkdownStyleSheet(
                      p: theme.textTheme.bodyLarge?.copyWith(height: 1.8, fontSize: 18),
                      h1: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, height: 2),
                      h2: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, height: 1.8),
                      h3: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, height: 1.6),
                      blockquote: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                      blockquoteDecoration: BoxDecoration(
                        border: Border(left: BorderSide(color: theme.colorScheme.primary, width: 4)),
                        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      ),
                    ),
                    onTapLink: (text, href, title) async {
                    if (href != null) {
                      final uri = Uri.tryParse(href);
                      if (uri != null && (uri.isScheme('http') || uri.isScheme('https'))) {
                        await launchUrl(uri);
                      }
                    }
                  },
                ),
                const SizedBox(height: 60),
                const Divider(),
                const SizedBox(height: 32),
                
                // Comments Section
                Text(
                  'Yorumlar',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                if (isLoggedIn) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       CircleAvatar(
                        radius: 18,
                         child: Text(authService.currentUserName?[0].toUpperCase() ?? '?'),
                       ),
                       const SizedBox(width: 12),
                       Expanded(
                         child: TextField(
                           controller: _commentController,
                           decoration: const InputDecoration(
                             hintText: 'Bir yorum yaz...',
                             border: OutlineInputBorder(),
                           ),
                           minLines: 1,
                           maxLines: 3,
                         ),
                       ),
                       const SizedBox(width: 8),
                       IconButton.filled(
                         onPressed: _isSendingComment 
                            ? null 
                            : () => _addComment(authService.currentUserName ?? 'Anonim', authService.currentUserId!),
                         icon: _isSendingComment 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                            : const Icon(Icons.send),
                       ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ] else 
                   Padding(
                     padding: const EdgeInsets.only(bottom: 24),
                     child: TextButton(
                       onPressed: () => context.go('/login'),
                       child: const Text('Yorum yapmak için giriş yapın'),
                     ),
                   ),

                StreamBuilder<List<Comment>>(
                  stream: postService.getCommentsStream(widget.postId),
                  builder: (context, snapshot) {
                     if (snapshot.hasError) return const Text('Yorumlar yüklenemedi');
                     if (snapshot.connectionState == ConnectionState.waiting) {
                       return const Center(child: CircularProgressIndicator());
                     }
                     
                     final comments = snapshot.data ?? [];
                     if (comments.isEmpty) {
                       return const Text('Henüz yorum yok. İlk yorumu sen yap!', style: TextStyle(color: Colors.grey));
                     }
                     
                     return ListView.separated(
                       shrinkWrap: true,
                       physics: const NeverScrollableScrollPhysics(),
                       itemCount: comments.length,
                       separatorBuilder: (context, index) => const SizedBox(height: 16),
                       itemBuilder: (context, index) {
                         final comment = comments[index];
                         return Row(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             CircleAvatar(
                               radius: 16,
                               child: Text(comment.authorName.isNotEmpty ? comment.authorName[0] : '?'),
                             ),
                             const SizedBox(width: 12),
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Row(
                                     children: [
                                       Text(comment.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                       const SizedBox(width: 8),
                                       Text(
                                         DateFormat('d MMM HH:mm').format(comment.date),
                                          style: theme.textTheme.bodySmall,
                                       ),
                                     ],
                                   ),
                                   const SizedBox(height: 4),
                                   Text(comment.text),
                                 ],
                               ),
                             ),
                             if (currentUserId != null && (currentUserId == comment.authorId || currentUserId == post.authorId))
                               IconButton(
                                 icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                                 onPressed: () {
                                   showDialog(
                                     context: context,
                                     builder: (context) => AlertDialog(
                                       title: const Text('Yorumu Sil'),
                                       content: const Text('Bu yorumu silmek istediğinize emin misiniz?'),
                                       actions: [
                                         TextButton(
                                           onPressed: () => Navigator.pop(context),
                                           child: const Text('İptal'),
                                         ),
                                         TextButton(
                                           onPressed: () {
                                             context.read<PostService>().deleteComment(widget.postId, comment.id);
                                             Navigator.pop(context);
                                           },
                                           child: const Text('Sil', style: TextStyle(color: Colors.red)),
                                         ),
                                       ],
                                     ),
                                   );
                                 },
                               ),
                           ],
                         );
                       },
                     );
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
