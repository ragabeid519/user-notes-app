import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:notes_app/screens/splash_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'screens/add_note_screen.dart';
import 'screens/home_screen.dart';
import 'database/database.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  await initDatabase();

  runApp(MyApp());
}

/// initialize database
Future<void> initDatabase() async {
  await copyDatabase();
  final dir = await getApplicationDocumentsDirectory();
  final path = join(dir.path, "user_notes.db");
  print("Database path: $path");
  database = await $FloorAppDatabase.databaseBuilder(path).build();
  // use the database as needed
}

late final AppDatabase database;

/// function to copy database from assets to device storage
Future<void> copyDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final path = join(dir.path, "user_notes.db");
  print("Database path: $path");
  // check if the database exists
  if (File(path).existsSync()) {
    print("Database already exists");
    return;
  }
  // copy from assets
  final data = await rootBundle.load('assets/database/user_notes.db');
  final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  await File(path).writeAsBytes(bytes);
  print("Database copied");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'app_name',
      debugShowCheckedModeBanner: false,
      routes: {'/add_note': (context) => AddNoteScreen()},
      // Home
      home: const SplashView(),
    );
  }
}
