import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
// package for placemark
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import '../models/note.dart';
import 'home_screen.dart';

class AddNoteScreen extends StatelessWidget {
  AddNoteScreen({super.key});

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  //////////////////////////////////////////////////////////////////////////
  //////////////////////LOCATION///////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////

  final isCheked = false.obs;
  // Position? position;

  // Future<Position?> getCurrentLocation() async {
  //   // check if location are turned on
  //   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     // location services are not enabled
  //     // show dialog to enable location
  //     await Get.defaultDialog(
  //       title: 'Location services are disabled',
  //       content: const Text(
  //         'Enable location services to get your current location',
  //       ),
  //     );
  //     await Geolocator.openLocationSettings();
  //     return null;
  //   }
  //   // check if location services are enabled
  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       // location services are denied
  //       // show dialog to enable location
  //       await Get.defaultDialog(
  //         title: 'Location services are disabled',
  //         content: const Text(
  //           'Enable location services to get your current location',
  //         ),
  //       );
  //       return null;
  //     }
  //   }
  //   // check if location services denied
  //   if (permission == LocationPermission.deniedForever) {
  //     // location services are denied forever
  //     // show dialog to enable location
  //     await Get.defaultDialog(
  //       title: 'Location services are disabled',
  //       content: const Text(
  //         'Enable location services to get your current location',
  //       ),
  //     );
  //     return null;
  //   }
  //   // get the current location
  //   final position = await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.high,
  //   );
  //   print('Current location: ${position.latitude}, ${position.longitude}');

  //   return position;
  // }

  // Future<void> getLocation() async {
  //   position = await getCurrentLocation();
  // }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // getLocation();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Add Note')),
        // make a form to add a note to the database
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
                  // check if the checkbox is checked or not
                  secondary: const Icon(Icons.location_on),
                  enabled: true,
                  title: const Text('Get current location'),
                  value: isCheked.value,
                  onChanged: (value) async {
                    isCheked.value = value!;
                    print(' isCheked: $isCheked ============================');
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  // save the note to the database
                  final note = Note(
                    title: titleController.text,
                    description: descriptionController.text,
                    createdAt: DateFormat(
                      'yyyy-MM-dd HH:mm',
                    ).format(DateTime.now()),
                  );
                  int id = await database.noteDao.insertNote(note);
                  print('Note saved with id: $id=============');

                  // Get.to(HomeScreen());
                  // go back to home screen after saving the note and refresh the list of notes
                  Get.offAll(
                    () => HomeScreen(),
                    // arguments: {'note': note, 'isChecked': isCheked.value},
                    arguments: [isCheked.value, id],
                    transition: Transition.rightToLeftWithFade,
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
