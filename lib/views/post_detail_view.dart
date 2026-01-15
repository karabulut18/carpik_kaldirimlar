import 'package:flutter/services.dart';
import 'package:carpik_kaldirimlar/widgets/link_preview_card.dart';
import 'package:carpik_kaldirimlar/models/comment.dart';
import 'package:carpik_kaldirimlar/models/post.dart';
import 'package:carpik_kaldirimlar/services/auth_service.dart';
import 'package:carpik_kaldirimlar/services/post_service.dart';
import 'package:carpik_kaldirimlar/services/report_service.dart';
import 'package:carpik_kaldirimlar/models/report.dart';
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
  Comment? _replyingTo; // Track who we are replying to

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = context.read<AuthService>();
      final postService = context.read<PostService>();
      final post = postService.getPost(widget.postId);
      
      // Only increment if the viewer is NOT the author
      if (post != null && authService.currentUserId != post.authorId) {
        postService.incrementViewCount(widget.postId);
      }
    });
  }
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String? _extractFirstLink(String? content) {
    if (content == null) return null;
    final urlRegExp = RegExp(
        r'https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&//=]*)');
    final match = urlRegExp.firstMatch(content);
    return match?.group(0);
  }

  void _toggleLike(String userId) async {
    await context.read<PostService>().toggleLike(widget.postId, userId);
  }

  void _showReportDialog({required String reportedItemId, required String reportedAuthorId, required String type}) {
    if (!context.read<AuthService>().isLoggedIn) {
      context.go('/login');
      return;
    }
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${type == 'post' ? 'Yazıyı' : 'Yorumu'} Raporla'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Lütfen raporlama nedeninizi belirtin:'),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Neden?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) return;

              final authService = context.read<AuthService>();
              final report = Report(
                id: '',
                reporterId: authService.currentUserId!,
                reportedItemId: reportedItemId,
                reportedAuthorId: reportedAuthorId,
                type: type,
                reason: reason,
                date: DateTime.now(),
              );
              
              Navigator.pop(context); // Close dialog
              
              try {
                await context.read<ReportService>().createReport(report);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Raporunuz iletildi. Teşekkürler.')),
                  );
                }
              } catch (e) {
                 if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata oluştu: $e')),
                  );
                }
              }
            },
            child: const Text('Raporla'),
          ),
        ],
      ),
    );
  }

  void _addComment(String authorName, String authorId) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSendingComment = true);
    
    String? replyToId;
    String? replyToUserName;
    int depth = 0;
    String finalText = text;

    if (_replyingTo != null) {
      if (_replyingTo!.depth == 0) {
        // Replying to root -> Merge to Depth 1
        replyToId = _replyingTo!.id;
        replyToUserName = _replyingTo!.authorName; // Or username if available
        depth = 1;
      } else {
        // Replying to a reply -> Flatten to Depth 1, add tag
        replyToId = _replyingTo!.replyToId; // Same parent
        replyToUserName = _replyingTo!.authorName;
        depth = 1;
        // The tag @username should already be in the text if the user didn't delete it
        // If we want to force it or if the user modified it, we can handle it, 
        // but typically we let the user edit the pre-filled text.
      }
    }

    await context.read<PostService>().addComment(
      widget.postId, 
      finalText, 
      authorName, 
      authorId,
      replyToId: replyToId,
      replyToUserName: replyToUserName,
      depth: depth,
    );
    
    if (mounted) {
      _commentController.clear();
      setState(() {
         _isSendingComment = false;
         _replyingTo = null; // Reset reply state
      });
    }
  }
  
  void _initiateReply(Comment comment) {
    setState(() {
      _replyingTo = comment;
    });
    // Pre-fill username if replying to a sub-reply (flattening strategy)
    if (comment.depth > 0) {
      // Find author handle logic could be here, but for now we rely on authorName or we need to fetch user.
      // Since AppUser has username but Comment only has authorName/AuthorId, we might not have the username handy.
      // Optimistic approach: Use authorName or fetch.
      // For speed, let's assume authorName is the display name. Ideally we need the @handle.
      _commentController.text = "@${comment.authorName.replaceAll(' ', '')} ";
    } else {
      _commentController.clear();
    }
    
    // Focus the text field
    // Ideally we'd use a FocusNode but TextField autofocus works or specific node
  }

  void _cancelReply() {
    setState(() {
      _replyingTo = null;
      _commentController.clear();
    });
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
              onPressed: () => context.go('/edit-post/${post.id}'),
            )
          else if (isLoggedIn)
             IconButton(
               icon: const Icon(Icons.report_gmailerrorred),
               tooltip: 'Yazıyı Raporla',
               onPressed: () => _showReportDialog(reportedItemId: post.id, reportedAuthorId: post.authorId, type: 'post'),
             ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Paylaş',
            onPressed: () {
              final url = 'https://carpik-kaldirimlar.web.app/post/${post.id}';
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bağlantı kopyalandı!')),
              );
            },
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                post.category,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
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
                          backgroundColor: isLiked ? Colors.red.withValues(alpha: 0.1) : null,
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
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
                const SizedBox(height: 32),
                if (_extractFirstLink(post.content) != null) ...[
                  LinkPreviewCard(url: _extractFirstLink(post.content)!),
                  const SizedBox(height: 32),
                ],
                if (post.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: post.tags.map((tag) => Chip(
                      label: Text('#$tag'),
                      labelStyle: TextStyle(color: theme.colorScheme.onSecondaryContainer),
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      side: BorderSide.none,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    )).toList(),
                  ),
                ],
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
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       if (_replyingTo != null)
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                           color: Theme.of(context).colorScheme.surfaceContainerHighest,
                           child: Row(
                             children: [
                               Icon(Icons.reply, size: 16, color: Theme.of(context).colorScheme.primary),
                               const SizedBox(width: 8),
                               Expanded(child: Text("Yanıtlanıyor: ${_replyingTo!.authorName}", style: Theme.of(context).textTheme.bodySmall)),
                               IconButton(
                                 icon: const Icon(Icons.close, size: 16), 
                                 onPressed: _cancelReply,
                                 padding: EdgeInsets.zero,
                                 constraints: const BoxConstraints(),
                               )
                             ],
                           ),
                         ),
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
                               maxLength: 1000,
                               decoration: InputDecoration(
                                 hintText: _replyingTo != null ? 'Yanıtınızı yazın...' : 'Bir yorum yaz...',
                                 border: const OutlineInputBorder(),
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
                     if (snapshot.hasError) {
                        final error = snapshot.error.toString();
                        if (error.contains('failed-precondition') || error.contains('requires an index')) {
                           return const Padding(
                             padding: EdgeInsets.all(16.0),
                             child: Text('Lütfen Firestore Index oluşturun: Link için debug konsola bakın.', textAlign: TextAlign.center),
                           );
                        }
                        return Text('Yorumlar yüklenemedi: $error');
                     }
                     if (snapshot.connectionState == ConnectionState.waiting) {
                       return const Center(child: CircularProgressIndicator());
                     }
                     
                     final comments = snapshot.data ?? [];
                     if (comments.isEmpty) {
                       return const Text('Henüz yorum yok. İlk yorumu sen yap!', style: TextStyle(color: Colors.grey));
                     }
                                           // Build Tree
                       // 1. Separate roots and replies
                       final roots = comments.where((c) => c.depth == 0).toList();
                       final replies = comments.where((c) => c.depth > 0).toList();
                       
                       // 2. Map replies to their parents
                       final replyMap = <String, List<Comment>>{};
                       for (var r in replies) {
                         if (r.replyToId != null) {
                           replyMap.putIfAbsent(r.replyToId!, () => []).add(r);
                         }
                       }
                       
                       return ListView.separated(
                         shrinkWrap: true,
                         physics: const NeverScrollableScrollPhysics(),
                         itemCount: roots.length,
                         separatorBuilder: (context, index) => const SizedBox(height: 24),
                         itemBuilder: (context, index) {
                           final root = roots[index];
                           final rootReplies = replyMap[root.id] ?? [];
                           // Sort replies by date (oldest first usually for chat flow, or newest?)
                           // Let's do Oldest first so it reads like a conversation
                           rootReplies.sort((a, b) => a.date.compareTo(b.date));
                           
                           return Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               _buildCommentItem(root, currentUserId, authService.isAdmin),
                               if (rootReplies.isNotEmpty)
                                 Padding(
                                   padding: const EdgeInsets.only(left: 32, top: 12),
                                   child: ListView.separated(
                                     shrinkWrap: true,
                                     physics: const NeverScrollableScrollPhysics(),
                                     itemCount: rootReplies.length,
                                     separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                                     itemBuilder: (ctx, i) => _buildCommentItem(rootReplies[i], currentUserId, authService.isAdmin),
                                   ),
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
  Widget _buildCommentItem(Comment comment, String? currentUserId, bool isAdmin) {
    final isLiked = currentUserId != null && comment.likes.contains(currentUserId);
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: theme.colorScheme.surfaceContainer,
          child: Text(comment.authorName.isNotEmpty ? comment.authorName[0].toUpperCase() : '?', style: const TextStyle(fontSize: 12)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(comment.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(width: 8),
                   Text(
                     DateFormat('d MMM HH:mm').format(comment.date),
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                   ),
                ],
              ),
              const SizedBox(height: 4),
              // Highlight regex logic or simple text
              Text(
                comment.text, 
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.3),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  // Like Button
                  InkWell(
                    onTap: currentUserId == null ? null : () {
                      context.read<PostService>().toggleCommentLike(comment.id, currentUserId);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          Icon(isLiked ? Icons.favorite : Icons.favorite_border, 
                               size: 14, 
                               color: isLiked ? Colors.red : Colors.grey),
                          if (comment.likes.isNotEmpty) ...[
                             const SizedBox(width: 4),
                             Text('${comment.likes.length}', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                          ]
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Reply Button
                  if (currentUserId != null)
                    InkWell(
                      onTap: () => _initiateReply(comment),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text("Yanıtla", style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    
                  const Spacer(),
                  // Report/Delete
                  if (currentUserId != null)
                   PopupMenuButton<String>(
                     icon: const Icon(Icons.more_horiz, size: 16),
                     onSelected: (v) {
                       if (v == 'delete') {
                         context.read<PostService>().deleteComment(widget.postId, comment.id);
                       } else if (v == 'report') {
                         _showReportDialog(reportedItemId: comment.id, reportedAuthorId: comment.authorId, type: 'comment');
                       }
                     },
                     itemBuilder: (context) {
                       final isOwner = currentUserId == comment.authorId;
                       return [
                         if (isOwner || isAdmin)
                           const PopupMenuItem(value: 'delete', child: Text('Sil', style: TextStyle(color: Colors.red))),
                         if (!isOwner)
                           const PopupMenuItem(value: 'report', child: Text('Raporla')),
                       ];
                     },
                   )
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
