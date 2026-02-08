import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'database/database.dart';
import 'screens/add_note_screen.dart';
import 'screens/splash_screen.dart';

late final AppDatabase database;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  await _initDatabase();

  runApp(const MyApp());
}

/// ======================
/// DATABASE INITIALIZATION
/// ======================
Future<void> _initDatabase() async {
  await _copyDatabaseIfNeeded();
  final dir = await getApplicationDocumentsDirectory();
  final path = join(dir.path, "user_notes.db");

  database = await $FloorAppDatabase.databaseBuilder(path).build();
}

/// Copy database from assets (first run only)
Future<void> _copyDatabaseIfNeeded() async {
  final dir = await getApplicationDocumentsDirectory();
  final path = join(dir.path, "user_notes.db");

  if (File(path).existsSync()) return;

  final data = await rootBundle.load('assets/database/user_notes.db');
  final bytes = data.buffer.asUint8List();
  await File(path).writeAsBytes(bytes);
}

/// ======================
/// APP ROOT
/// ======================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'User Notes',
      debugShowCheckedModeBanner: false,

      /// 🌗 Ready for Dark Mode later
      themeMode: ThemeMode.system,

      /// 🎨 Light Theme
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey.shade100,

        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),

        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      /// 🌑 Dark Theme (اختياري – جاهز)
      darkTheme: ThemeData.dark(useMaterial3: true),

      /// 🧭 Routes
      getPages: [
        GetPage(
          name: '/add_note',
          page: () => AddNoteScreen(),
          transition: Transition.rightToLeft,
        ),
      ],

      /// 🚀 Entry Point
      home: const SplashView(),
    );
  }
}
