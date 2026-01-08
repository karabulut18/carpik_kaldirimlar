import 'package:carpik_kaldirimlar/models/comment.dart';
import 'package:carpik_kaldirimlar/services/post_service.dart';
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
          return Center(child: Text('Hata: ${snapshot.error}'));
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
