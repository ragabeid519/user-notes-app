import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../models/note.dart';
import 'note_dao.dart';

part 'database.g.dart'; // Generated file

@Database(version: 1, entities: [Note])
abstract class AppDatabase extends FloorDatabase {
  NoteDao get noteDao;
}
