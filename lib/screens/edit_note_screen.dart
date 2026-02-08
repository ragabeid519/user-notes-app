import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:notes_app/main.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/screens/home_screen.dart';

class EditNoteScreen extends StatelessWidget {
  EditNoteScreen({super.key});

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  Note? note;

  final isCheked = false.obs;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    note = Get.arguments;
    titleController.text = note!.title;
    descriptionController.text = note!.description;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Note')),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              TextField(
                maxLines: 5,
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              // make checkbox to get the current location
              Obx(
                () => CheckboxListTile(
                  // add icon like location
                  secondary: const Icon(Icons.location_on),

                  title: const Text('Get Current Location'),
                  value: isCheked.value,
                  onChanged: (value) async {
                    isCheked.value = value!;
                    if (isCheked.value) {
                      isCheked.value = value;
                    }
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  // save the note to the database
                  note!.title = titleController.text;
                  note!.description = descriptionController.text;
                  await database.noteDao.updateNote(note!);

                  Get.offAll(
                    () => HomeScreen(),
                    // arguments: {'note': note, 'isChacked': isCheked.value},
                    arguments: [isCheked.value, note!.id],
                  );
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
