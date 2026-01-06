import 'package:carpik_kaldirimlar/models/post.dart';
import 'package:carpik_kaldirimlar/services/auth_service.dart';
import 'package:carpik_kaldirimlar/services/post_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CreatePostView extends StatefulWidget {
  final String? postId;
  const CreatePostView({super.key, this.postId});

  @override
  State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _excerptController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.postId != null) {
      _isEditing = true;
      _loadPost();
    }
  }

  void _loadPost() {
    final post = context.read<PostService>().getPost(widget.postId!);
    if (post != null) {
      _titleController.text = post.title;
      _excerptController.text = post.excerpt ?? '';
      _contentController.text = post.content ?? '';
      _imageUrlController.text = post.imageUrl ?? '';
    }
  }

  void _publishOrUpdate() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authService = context.read<AuthService>();
      final postService = context.read<PostService>();

      try {
        if (_isEditing) {
           // Retrieve original post to keep original author/date if needed, 
           // or just overwrite basic fields. Ideally we keep original data.
           // For simplicity, we recreate the object but keep ID.
           // Real app might want to fetch original first.
           final originalPost = postService.getPost(widget.postId!);
           
           final updatedPost = Post(
            id: widget.postId!,
            title: _titleController.text,
            author: originalPost?.author ?? (authService.currentUserName ?? 'Anonim'),
            authorId: originalPost?.authorId ?? (authService.currentUserId ?? ''), // Keep original author ID
            date: originalPost?.date ?? DateTime.now(),
            excerpt: _excerptController.text.isEmpty ? null : _excerptController.text,
            content: _contentController.text,
            imageUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text : null,
          );
          
          await postService.updatePost(updatedPost);

          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Yazı güncellendi!')),
            );
            context.go('/post/${widget.postId}');
          }

        } else {
          final newPost = Post(
            id: const Uuid().v4(),
            title: _titleController.text,
            author: authService.currentUserName ?? 'Anonim',
            authorId: authService.currentUserId ?? '', // Save current user ID
            date: DateTime.now(),
            excerpt: _excerptController.text.isEmpty ? null : _excerptController.text,
            content: _contentController.text,
            imageUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text : null,
          );

          await postService.addPost(newPost);
          
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Yazı yayınlandı!')),
            );
            context.go('/dashboard');
          }
        }
      } catch (e) {
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Hata: $e')),
            );
         }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _excerptController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Yazıyı Düzenle' : 'Yeni Yazı Oluştur'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    style: theme.textTheme.headlineMedium,
                    decoration: const InputDecoration(
                      hintText: 'Başlık',
                      border: InputBorder.none,
                    ),
                    validator: (v) => v?.isNotEmpty == true ? null : 'Başlık gerekli',
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _excerptController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Özet (Opsiyonel)',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    // No validator needed for optional
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _contentController,
                    maxLines: 15,
                    decoration: const InputDecoration(
                      labelText: 'İçerik',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Kapak Görseli URL (Opsiyonel)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: _isLoading ? null : _publishOrUpdate,
                        icon: Icon(_isEditing ? Icons.save : Icons.send),
                        label: Text(_isEditing ? 'Güncelle' : 'Yayınla'),
                      ),
                    ],
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
