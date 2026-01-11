import 'package:carpik_kaldirimlar/models/comment.dart';
import 'package:carpik_kaldirimlar/services/auth_service.dart';
import 'package:carpik_kaldirimlar/services/report_service.dart';
import 'package:carpik_kaldirimlar/models/report.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CommentCard({
    super.key,
    required this.comment,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = context.watch<AuthService>();
    final isLoggedIn = authService.isLoggedIn;
    final currentUserId = authService.currentUserId;
    final isAuthor = currentUserId == comment.authorId;
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: theme.colorScheme.secondary,
                  child: Text(
                    comment.authorName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  comment.authorName,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('d MMM y').format(comment.date),
                   style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (onDelete != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: theme.colorScheme.error,
                    onPressed: onDelete,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    tooltip: 'Sil',
                  ),
                  ),

                if (!isAuthor && isLoggedIn)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: IconButton(
                       icon: const Icon(Icons.report_gmailerrorred, size: 20, color: Colors.grey),
                       tooltip: 'Yorumu Raporla',
                       padding: EdgeInsets.zero,
                       constraints: const BoxConstraints(),
                       onPressed: () => _showReportDialog(context, comment.id, comment.authorId),
                    ),
                  ),
              ],
            ),
             const SizedBox(height: 8),
             Text(
               comment.text,
               style: theme.textTheme.bodyMedium,
             ),
             const SizedBox(height: 12),
             if (comment.postId.isNotEmpty)
               Align(
                 alignment: Alignment.centerLeft,
                 child: TextButton.icon(
                   onPressed: onTap,
                   icon: const Icon(Icons.arrow_outward, size: 16),
                   label: const Text('Yazıya Git'),
                   style: TextButton.styleFrom(
                     padding: EdgeInsets.zero,
                     minimumSize: const Size(0, 32),
                     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                   ),
                 ),
               ),
          ],
        ),
      ),
    );
  }


  void _showReportDialog(BuildContext context, String reportedItemId, String reportedAuthorId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yorumu Raporla'),
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
                type: 'comment',
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
}
