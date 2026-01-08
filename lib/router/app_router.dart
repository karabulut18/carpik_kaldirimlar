import 'package:carpik_kaldirimlar/services/auth_service.dart';
import 'package:carpik_kaldirimlar/views/admin_panel_view.dart';
import 'package:carpik_kaldirimlar/views/create_post_view.dart';

import 'package:carpik_kaldirimlar/views/explore_view.dart';
import 'package:carpik_kaldirimlar/views/home_view.dart';
import 'package:carpik_kaldirimlar/views/login_view.dart';
import 'package:carpik_kaldirimlar/views/post_detail_view.dart';
import 'package:carpik_kaldirimlar/views/profile_view.dart';
import 'package:carpik_kaldirimlar/views/public_user_view.dart';
import 'package:carpik_kaldirimlar/views/register_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';



class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {



      
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          final authService = context.watch<AuthService>();
          
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Çarpık Kaldırımlar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              centerTitle: false,
              elevation: 0,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              actions: [
                _NavButton(
                  label: 'Ana Sayfa',
                  isActive: state.uri.path == '/',
                  onPressed: () => context.go('/'),
                ),
                _NavButton(
                  label: 'Keşfet',
                  isActive: state.uri.path == '/explore',
                  onPressed: () => context.go('/explore'),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: authService.isLoggedIn 
                    ? _UserMenu(userName: authService.currentUserName ?? 'Kullanıcı')
                    : FilledButton.tonalIcon(
                        onPressed: () => context.go('/login'),
                        icon: const Icon(Icons.person_outline, size: 18),
                        label: const Text('Giriş Yap'),
                      ),
                ),
              ],
            ),
            body: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeView(),
          ),
          GoRoute(
            path: '/explore',
            builder: (context, state) => const ExploreView(),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => const LoginView(),
          ),
          GoRoute(
            path: '/register',
            builder: (context, state) => const RegisterView(),
          ),

          GoRoute(
            path: '/create-post',
            builder: (context, state) => const CreatePostView(),
          ),
          GoRoute(
            path: '/edit-post/:postId',
            builder: (context, state) {
              final postId = state.pathParameters['postId'];
              return CreatePostView(postId: postId);
            },
          ),
          GoRoute(
            path: '/post/:postId',
            builder: (context, state) {
              final postId = state.pathParameters['postId']!;
              return PostDetailView(postId: postId);
            },
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) {
              if (!context.read<AuthService>().isLoggedIn) {
                return const LoginView();
              }
              return const ProfileView();
            },
          ),
          GoRoute(
            path: '/admin',
            redirect: (context, state) {
               final auth = context.read<AuthService>();
               if (!auth.isLoggedIn || !auth.isAdmin) {
                 return '/';
               }
               return null;
            },
            builder: (context, state) => const AdminPanelView(),
          ),
          GoRoute(
            path: '/user/:userId',
            builder: (context, state) {
              final userId = state.pathParameters['userId']!;
              return PublicUserView(userId: userId);
            },
          ),
        ],
      ),
    ],
  );
}

class _NavButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _NavButton({
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _UserMenu extends StatelessWidget {
  final String userName;
  const _UserMenu({required this.userName});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'logout') {
          context.read<AuthService>().logout();
          context.go('/');
        } else if (value == 'admin') {
          context.go('/admin');
        } else if (value == 'create') {
          context.go('/create-post');
        } else if (value == 'profile') {
          context.go('/profile');
        }
      },
      child: Chip(
        avatar: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            userName[0].toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        label: Text(userName),
      ),
      itemBuilder: (context) {
        final isAdmin = context.read<AuthService>().isAdmin;
        return [
        if (isAdmin) ...[
          const PopupMenuItem(
            value: 'admin',
            child: Row(
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.orange),
                SizedBox(width: 8),
                Text('Yönetim Paneli'),
              ],
            ),
          ),

        ],
        const PopupMenuItem(
          value: 'create',
          child: Row(
            children: [
              Icon(Icons.edit_note),
              SizedBox(width: 8),
              Text('Yeni Yazı'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person),
              SizedBox(width: 8),
              Text('Profilim'),
            ],
          ),
        ),
         const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ];
      },
    );
  }
}
