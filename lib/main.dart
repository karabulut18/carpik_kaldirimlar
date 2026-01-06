import 'package:carpik_kaldirimlar/firebase_options.dart';
import 'package:carpik_kaldirimlar/router/app_router.dart';
import 'package:carpik_kaldirimlar/services/auth_service.dart';
import 'package:carpik_kaldirimlar/services/post_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => PostService()),
      ],
      child: const CarpikKaldirimlarApp(),
    ),
  );
}

class CarpikKaldirimlarApp extends StatelessWidget {
  const CarpikKaldirimlarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Çarpık Kaldırımlar',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.light,
        ),
        // textTheme: GoogleFonts.robotoSerifTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
        // textTheme: GoogleFonts.robotoSerifTextTheme(
        //   ThemeData(brightness: Brightness.dark).textTheme,
        // ),
      ),
      themeMode: ThemeMode.system,
    );
  }
}
