import 'package:carpik_kaldirimlar/models/comment.dart';
import 'package:carpik_kaldirimlar/services/post_service.dart';
import 'package:carpik_kaldirimlar/services/auth_service.dart';
import 'package:carpik_kaldirimlar/widgets/comment_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UserCommentsList extends StatelessWidget {
  final String userId;
  const UserCommentsList({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    if (userId.isEmpty) return const SizedBox();

    return StreamBuilder<List<Comment>>(
      stream: context.read<PostService>().getUserComments(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final error = snapshot.error.toString();
          if (error.contains('failed-precondition') || error.contains('requires an index')) {
             return const Center(child: Padding(
               padding: EdgeInsets.all(16.0),
               child: Text('Lütfen Firestore Index oluşturun: Link için debug konsola bakın.', textAlign: TextAlign.center),
             ));
          }
          return Center(child: Text('Hata: $error'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final comments = snapshot.data ?? [];

        if (comments.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('Henüz hiç yorum yapılmamış.'),
          ));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: comments.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            return CommentCard(
              comment: comments[index],
              onTap: () {
                if(comments[index].postId.isNotEmpty) {
                  context.go('/post/${comments[index].postId}');
                }
              },
              onDelete: (context.read<AuthService>().currentUserId == comments[index].authorId) ? () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Yorumu Sil'),
                    content: const Text('Bu yorumu silmek istiyor musunuz?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('İptal'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await context.read<PostService>().deleteComment(
                            comments[index].postId, 
                            comments[index].id
                          );
                          if (context.mounted) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(content: Text('Yorum silindi')),
                             );
                          }
                        },
                        child: const Text('Sil', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              } : null,
            );
          },
        );
      },
    );
  }
}

class SliverTabDelegate extends SliverPersistentHeaderDelegate {
  SliverTabDelegate(this._tabBar, {required this.color});

  final TabBar _tabBar;
  final Color color;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: color,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(SliverTabDelegate oldDelegate) {
    return false;
  }
}
