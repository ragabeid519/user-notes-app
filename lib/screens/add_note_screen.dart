import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import '../models/note.dart';
import 'home_screen.dart';

class AddNoteScreen extends StatelessWidget {
  const AddNoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final isLocationEnabled = false.obs;

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Note')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// TITLE
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),

            /// DESCRIPTION
            TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.note),
              ),
            ),
            const SizedBox(height: 16),

            /// LOCATION
            Obx(
              () => SwitchListTile(
                title: const Text('Attach current location'),
                subtitle: const Text('Save your current place with the note'),
                value: isLocationEnabled.value,
                onChanged: (value) {
                  isLocationEnabled.value = value;
                },
                secondary: const Icon(Icons.location_on),
              ),
            ),

            const Spacer(),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save Note'),
                onPressed: () async {
                  if (titleController.text.trim().isEmpty) {
                    Get.snackbar(
                      'Validation Error',
                      'Title cannot be empty',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }

                  final note = Note(
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    createdAt: DateFormat(
                      'yyyy-MM-dd HH:mm',
                    ).format(DateTime.now()),
                  );

                  final id = await database.noteDao.insertNote(note);

                  Get.offAll(
                    () => const HomeScreen(),
                    arguments: [isLocationEnabled.value, id],
                    transition: Transition.rightToLeftWithFade,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
