import 'package:carpik_kaldirimlar/models/app_user.dart';
import 'package:carpik_kaldirimlar/services/auth_service.dart';
import 'package:carpik_kaldirimlar/services/post_service.dart';
import 'package:carpik_kaldirimlar/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PublicUserView extends StatefulWidget {
  final String userId;

  const PublicUserView({super.key, required this.userId});

  @override
  State<PublicUserView> createState() => _PublicUserViewState();
}

class _PublicUserViewState extends State<PublicUserView> {
  AppUser? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final authService = context.read<AuthService>();
    final user = await authService.getUser(widget.userId);
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final postService = context.watch<PostService>();
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Kullanıcı bulunamadı')),
      );
    }

    // Filter posts for this user
    // Note: In a real app with many users, we'd want a query for this.
    // For now, filtering client side is consistent with current architecture.
    final userPosts = postService.posts.where((p) => p.authorId == widget.userId).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_user!.name),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                   // Profile Header
                   CircleAvatar(
                    radius: 48,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      _user!.name[0].toUpperCase(),
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _user!.name,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_user!.bio != null && _user!.bio!.isNotEmpty)
                     Container(
                       margin: const EdgeInsets.only(top: 16),
                       padding: const EdgeInsets.all(16),
                       decoration: BoxDecoration(
                         color: theme.colorScheme.surfaceContainer,
                         borderRadius: BorderRadius.circular(12),
                       ),
                       child: MarkdownBody(
                         data: _user!.bio!,
                         styleSheet: MarkdownStyleSheet(
                           p: theme.textTheme.bodyMedium,
                         ),
                       ),
                     ),

                  const SizedBox(height: 48),
                  const Divider(),
                  const SizedBox(height: 32),
                  
                  // Posts Section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Yazılar (${userPosts.length})',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  if (userPosts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('Henüz hiç yazı paylaşmamış.'),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: userPosts.length,
                      itemBuilder: (context, index) {
                        return PostCard(
                          post: userPosts[index],
                          onTap: () => context.go('/post/${userPosts[index].id}'),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
