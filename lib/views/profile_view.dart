import 'package:carpik_kaldirimlar/services/auth_service.dart';
import 'package:carpik_kaldirimlar/services/post_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final authService = context.read<AuthService>();
    _nameController.text = authService.currentUserName ?? '';
    _bioController.text = authService.currentBio ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isNotEmpty) {
      await context.read<AuthService>().updateProfile(
        _nameController.text,
        bio: _bioController.text,
      );
      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil güncellendi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = context.watch<AuthService>();
    final postService = context.watch<PostService>();
    
    // Filter posts to show only those belonging to the current user
    final userPosts = postService.posts.where((p) => p.author == authService.currentUserName).toList();

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                CircleAvatar(
                  radius: 64,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    (authService.currentUserName ?? 'K')[0].toUpperCase(),
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_isEditing)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Ad Soyad',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filled(
                              onPressed: _saveProfile,
                              icon: const Icon(Icons.check),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filledTonal(
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  _nameController.text = authService.currentUserName ?? '';
                                  _bioController.text = authService.currentBio ?? '';
                                });
                              },
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _bioController,
                          decoration: const InputDecoration(
                            labelText: 'Biyografi (Markdown destekli)',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 5,
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            authService.currentUserName ?? 'Kullanıcı',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = true;
                                _bioController.text = authService.currentBio ?? '';
                              });
                            },
                            icon: const Icon(Icons.edit, size: 20),
                            tooltip: 'Profili Düzenle',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        authService.currentUserEmail ?? '',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                       const SizedBox(height: 24),
                       if (authService.currentBio != null && authService.currentBio!.isNotEmpty)
                         Container(
                           padding: const EdgeInsets.all(16),
                           decoration: BoxDecoration(
                             color: theme.colorScheme.surfaceContainer,
                             borderRadius: BorderRadius.circular(12),
                           ),
                           child: MarkdownBody(
                             data: authService.currentBio!,
                             styleSheet: MarkdownStyleSheet(
                               p: theme.textTheme.bodyMedium,
                             ),
                           ),
                         ),
                    ],
                  ),
                
                const SizedBox(height: 48),

                // Stats in Profile
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                   _ProfileStat(
                     label: 'Yazılar',
                     value: userPosts.length.toString(),
                   ),
                   const SizedBox(width: 48),
                   const _ProfileStat(
                     label: 'Katılım',
                     value: 'Ocak 2024',
                   ),
                  ],
                ),
                
                 const SizedBox(height: 48),
                 SizedBox(
                   width: double.infinity,
                   child: OutlinedButton.icon(
                     onPressed: () {
                         context.read<AuthService>().logout();
                         context.go('/');
                     },
                     icon: const Icon(Icons.logout),
                     label: const Text('Çıkış Yap'),
                   ),
                 ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  
  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
