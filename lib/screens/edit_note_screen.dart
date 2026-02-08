import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notes_app/main.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/screens/home_screen.dart';

class EditNoteScreen extends StatelessWidget {
  EditNoteScreen({super.key});

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  final isLocationEnabled = false.obs;

  @override
  Widget build(BuildContext context) {
    final Note note = Get.arguments;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Note')),
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

            /// LOCATION SWITCH
            Obx(
              () => SwitchListTile(
                title: const Text('Update current location'),
                subtitle: const Text(
                  'Attach your current location to this note',
                ),
                value: isLocationEnabled.value,
                onChanged: (value) {
                  isLocationEnabled.value = value;
                },
                secondary: const Icon(Icons.location_on),
              ),
            ),

            const Spacer(),

            /// ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Save Changes'),
                    onPressed: () async {
                      if (titleController.text.trim().isEmpty) {
                        Get.snackbar(
                          'Validation Error',
                          'Title cannot be empty',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }

                      note.title = titleController.text.trim();
                      note.description = descriptionController.text.trim();

                      await database.noteDao.updateNote(note);

                      Get.offAll(
                        () => HomeScreen(),
                        arguments: [isLocationEnabled.value, note.id],
                        transition: Transition.rightToLeftWithFade,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
