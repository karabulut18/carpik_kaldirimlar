import 'package:carpik_kaldirimlar/models/comment.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
}
