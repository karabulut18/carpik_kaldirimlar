import 'package:carpik_kaldirimlar/models/post.dart';
import 'package:carpik_kaldirimlar/services/auth_service.dart';
import 'package:carpik_kaldirimlar/models/report.dart';

import 'package:carpik_kaldirimlar/services/post_service.dart';
import 'package:carpik_kaldirimlar/services/report_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AdminPanelView extends StatelessWidget {
  const AdminPanelView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Yönetim Paneli'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Yazılar', icon: Icon(Icons.article)),
              Tab(text: 'Kullanıcılar', icon: Icon(Icons.people)),
              Tab(text: 'Raporlar', icon: Icon(Icons.report)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PostsTab(),
            _UsersTab(),
            _ReportsTab(),
          ],
        ),
      ),
    );
  }
}

class _PostsTab extends StatelessWidget {
  const _PostsTab();

  @override
  Widget build(BuildContext context) {
    final postService = context.watch<PostService>();
    final posts = postService.posts;

    if (posts.isEmpty) {
      return const Center(child: Text('Henüz yazı yok.'));
    }

    return ListView.separated(
      itemCount: posts.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final post = posts[index];
        return ListTile(
          title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('${post.author} • ${DateFormat('d MMM y').format(post.date)}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(context, post),
          ),
          onTap: () => context.go('/post/${post.id}'),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yazıyı Sil'),
        content: Text('"${post.title}" başlıklı yazıyı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<PostService>().deletePost(post.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Yazı silindi.')),
              );
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(child: Text('Kullanıcı bulunamadı.'));
        }

        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final uid = docs[index].id;
            final email = data['email'] ?? 'No Email';
            final name = data['name'] ?? 'No Name';
            final role = data['role'] ?? 'user';
            
            final currentUser = context.read<AuthService>().currentUserId;
            final isSelf = uid == currentUser;

            return ListTile(
              leading: CircleAvatar(child: Text(name[0].toUpperCase())),
              title: Text('$name ($role)'),
              subtitle: Text(email),
              onTap: () => context.push('/user/$uid'),
              trailing: isSelf 
                ? const Tooltip(message: 'Kendinizi silemezsiniz', child: IconButton(icon: Icon(Icons.block, color: Colors.grey), onPressed: null))
                : IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: () => _confirmDeleteUser(context, uid, name),
                ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteUser(BuildContext context, String uid, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kullanıcıyı Sil'),
        content: Text('"$name" adlı kullanıcıyı silmek istediğinizden emin misiniz? Bu işlem kullanıcının veritabanı kaydını siler.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(uid).delete();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kullanıcı silindi.')),
                );
              }
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}

class _ReportsTab extends StatelessWidget {
  const _ReportsTab();
  
  @override
  Widget build(BuildContext context) {
    final reportService = context.watch<ReportService>();
    
    return StreamBuilder<List<Report>>(
      stream: reportService.getReports(),
      builder: (context, snapshot) {
         if (snapshot.hasError) return Center(child: Text('Hata: ${snapshot.error}'));
         if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
         
         final reports = snapshot.data ?? [];
         if (reports.isEmpty) return const Center(child: Text('Henüz rapor yok.'));
         
         return ListView.builder(
           itemCount: reports.length,
           itemBuilder: (context, index) {
             final report = reports[index];
             return ExpansionTile(
               title: Text('${report.type.toUpperCase()} Raporu'),
               subtitle: Text('Sebep: ${report.reason}\nTarih: ${DateFormat('d MMM HH:mm').format(report.date)}'),
               trailing: IconButton(
                 icon: const Icon(Icons.check, color: Colors.green),
                 onPressed: () => _resolveReport(context, report.id),
                 tooltip: 'Raporu Kapat (Sil)',
               ),
               children: [
                  ListTile(
                    title: const Text('Raporlayan ID'),
                    subtitle: SelectableText(report.reporterId),
                  ),
                  ListTile(
                    title: const Text('Raporlanan İçerik ID'),
                    subtitle: SelectableText(report.reportedItemId),
                    trailing: IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () {
                         if (report.type == 'post') {
                            context.push('/post/${report.reportedItemId}');
                         }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FilledButton.icon(
                          onPressed: () => _deleteContent(context, report),
                          icon: const Icon(Icons.delete_forever),
                          label: const Text('İçeriği Sil'),
                          style: FilledButton.styleFrom(backgroundColor: Colors.red),
                        ),
                      ],
                    ),
                  ),
               ],
             );
           },
         );
      },
    );
  }

  void _resolveReport(BuildContext context, String reportId) {
     context.read<ReportService>().deleteReport(reportId);
  }
  
  void _deleteContent(BuildContext context, Report report) async {
     final confirm = await showDialog<bool>(
       context: context,
       builder: (context) => AlertDialog(
         title: const Text('İçeriği Sil'),
         content: const Text('Raporlanan içeriği silmek istediğinize emin misiniz?'),
         actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sil')),
         ],
       ),
     );
     
     if (confirm == true) {
        if (!context.mounted) return;
        if (report.type == 'post') {
           await context.read<PostService>().deletePost(report.reportedItemId);
        } else if (report.type == 'comment') {
           await context.read<PostService>().deleteComment('', report.reportedItemId);
        }
        if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('İçerik silindi.')));
           _resolveReport(context, report.id);
        }
     }
  }
}
