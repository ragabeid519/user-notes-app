import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:notes_app/main.dart';
import 'package:notes_app/screens/edit_note_screen.dart';
import 'package:shake/shake.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/note.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final notes = <Note>[].obs;
  final searchController = TextEditingController();

  Position? position;
  @override
  void initState() {
    super.initState();
    loadNotes();
    _initShakeDetector();

    _handleIncomingLocation();
  }

  // ================= LOCATION =================

  void _handleIncomingLocation() {
    if (Get.arguments != null) {
      final bool isChecked = Get.arguments[0];
      final int noteId = Get.arguments[1];
      if (isChecked) {
        updateNoteLocation(noteId);
      }
    }
  }

  Future<Position?> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      await Get.defaultDialog(
        title: 'Location disabled',
        content: const Text('Please enable location services'),
      );
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> updateNoteLocation(int id) async {
    final note = await database.noteDao.getNoteById(id);
    position = await getCurrentLocation();

    if (note == null || position == null) return;

    final placemarks = await placemarkFromCoordinates(
      position!.latitude,
      position!.longitude,
    );

    if (placemarks.isNotEmpty) {
      final address =
          '${placemarks[0].country}, ${placemarks[0].administrativeArea}';

      await database.noteDao.updateLocation(
        note.id!,
        position!.latitude,
        position!.longitude,
        address,
      );

      loadNotes();
    }
  }

  Future<void> loadNotes() async {
    notes.value = await database.noteDao.getAllNote();
  }

  void _initShakeDetector() {
    ShakeDetector.autoStart(
      onPhoneShake: (_) async {
        final shouldDelete = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Delete all notes?'),
            content: const Text('This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );

        if (shouldDelete ?? false) {
          // alart dialog to delete all notes with undo action
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Delete all notes?'),
                content: const Text('This action cannot be undone.'),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () async {
                      await database.noteDao.deleteAllNotes();
                      loadNotes();
                      Get.back();
                    },
                    child: const Text('Delete'),
                  ),
                ],
              );
            },
          );
        }
      },
    );
  }

  Future<void> searchNotes(String query) async {
    if (query.isEmpty) {
      loadNotes();
    } else {
      notes.value = await database.noteDao.searchNotes('%$query%');
    }
  }

  Future<void> toggleCompleted(Note note, bool value) async {
    note.completed = value ? 1 : 0;
    await database.noteDao.updateNote(note);
    loadNotes();
  }

  Future<void> openLocation(Note note) async {
    final uri = Uri.parse(
      "geo:0,0?q=${note.latitude},${note.lonitude}(${note.title})",
    );
    launchUrl(uri);
  }

  Future<void> undoDelete(Note note) async {
    await database.noteDao.insertNote(note).then((value) => loadNotes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          Obx(
            () => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${notes.where((n) => n.completed == 1).length}/${notes.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/add_note'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SearchBar(
              controller: searchController,
              hintText: 'Search notes...',
              leading: const Icon(Icons.search),
              onChanged: searchNotes,
            ),
          ),
          Expanded(
            child: Obx(
              () => ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: notes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final note = notes[index];
                  final isDone = note.completed == 1;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  note.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    decoration: isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                              Checkbox(
                                value: isDone,
                                onChanged: (v) => toggleCompleted(note, v!),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            note.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 16),
                              const SizedBox(width: 4),
                              Text(note.createdAt),
                              const Spacer(),
                              if (note.latitude != null)
                                IconButton(
                                  icon: const Icon(Icons.location_on),
                                  onPressed: () => openLocation(note),
                                ),
                            ],
                          ),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Chip(
                                    label: Text(
                                      isDone ? 'Completed' : 'Pending',
                                    ),
                                    backgroundColor: isDone
                                        ? Colors.green.shade100
                                        : Colors.orange.shade100,
                                  ),
                                  Text(
                                    note.address ?? '',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    Get.to(EditNoteScreen(), arguments: note),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () => Clipboard.setData(
                                  ClipboardData(text: note.description),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await database.noteDao.deleteNote(note);

                                  // show snackbar to undo delete action
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Note deleted'),
                                      duration: const Duration(seconds: 2),
                                      action: SnackBarAction(
                                        label: 'Undo',
                                        onPressed: () {
                                          undoDelete(note);
                                        },
                                      ),
                                    ),
                                  );

                                  loadNotes();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
