import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
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
  var notes = <Note>[].obs;
  RxBool isCompleted = false.obs;
  final searchController = TextEditingController();

  Future<void> loasdNotes() async {
    notes.value = await database.noteDao.getAllNote();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loasdNotes();
  }

  ////      location proccess
  ///
  //////////////////////////////////////////////////////////////////////////
  //////////////////////LOCATION///////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////

  Position? position;

  Future<Position?> getCurrentLocation() async {
    // check if location are turned on
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // location services are not enabled
      // show dialog to enable location
      await Get.defaultDialog(
        title: 'Location services are disabled',
        content: const Text(
          'Enable location services to get your current location',
        ),
      );
      await Geolocator.openLocationSettings();
      return null;
    }
    // check if location services are enabled
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // location services are denied
        // show dialog to enable location
        await Get.defaultDialog(
          title: 'Location services are disabled',
          content: const Text(
            'Enable location services to get your current location',
          ),
        );
        return null;
      }
    }
    // check if location services denied
    if (permission == LocationPermission.deniedForever) {
      // location services are denied forever
      // show dialog to enable location
      await Get.defaultDialog(
        title: 'Location services are disabled',
        content: const Text(
          'Enable location services to get your current location',
        ),
      );
      return null;
    }
    // get the current location
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    print('Current location: ${position.latitude}, ${position.longitude}');

    return position;
  }

  Future<void> getLocation() async {
    position = await getCurrentLocation();
  }

  searchNotes(String query) async {
    notes.value = await database.noteDao.searchNotes('%$query%');
  }

  Future<void> updateNoteLocation(int id, bool isChacked) async {
    Note? note = await database.noteDao.getNoteById(id);
    print('chacked: $isChacked 1===============');
    if (isChacked) {
      // update lat and long of the note
      print('chacked: $isChacked 2===============');
      await getLocation();
      if (position != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position!.latitude,
          position!.longitude,
        );
        if (placemarks.isNotEmpty) {
          note!.latitude = position!.latitude;
          note.lonitude = position!.longitude;
          note.address =
              '${placemarks[0].country}, ${placemarks[0].administrativeArea}';
          await database.noteDao.updateLocation(
            note.id!,
            note.latitude!,
            note.lonitude!,
            note.address!,
          );
          print('chacked: $isChacked 3===============');

          loasdNotes();
        }
      }
      // show error message if location is not found
      else {
        await Get.defaultDialog(
          title: 'Location services are disabled',
          content: const Text(
            'Enable location services to get your current location',
          ),
        );
      }
      print('chacked: $isChacked 4===============');
    }
    // loasdNotes();
  }

  @override
  Widget build(BuildContext context) {
    getLocation();
    if (Get.arguments != null) {
      updateNoteLocation(Get.arguments[1], Get.arguments[0] as bool);
    }

    ShakeDetector detector = ShakeDetector.autoStart(
      onPhoneShake: (ShakeEvent event) async {
        // ask user if they want to delete all notes
        final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete all notes?'),
            content: const Text('Are you sure you want to delete all notes?'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text('Delete'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        );
        if (shouldDelete ?? false) {
          // delete all notes
          await database.noteDao.deleteAllNotes();
          loasdNotes();
        }
        print('Shake direction: ${event.direction}');
        print('Shake force: ${event.force}');
        print('Shake timestamp: ${event.timestamp}');
      },
    );
    detector.startListening();

    return SafeArea(
      child: Scaffold(
        // make rounded app bar with calculate completed notes
        appBar: AppBar(
          title: const Text('Home Screen'),
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          actions: [
            Obx(
              () => Text(
                "Completed: ${notes.where((element) => element.completed == 1).length} / ${notes.length}         ",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
        ),
        // appBar: AppBar(title: const Text('Home Screen')),
        // make floating button to add new note
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.toNamed('/add_note');
          },
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            // search in notes
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Search in notes',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) async {
                  // searchNotes(value);
                  // search in notes by title and description
                  await searchNotes(value);
                },
              ),
            ),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    isCompleted.value = note.completed == 1 ? true : false;
                    return Card(
                      color: isCompleted.value ? Colors.green : Colors.red,
                      child: ListTile(
                        dense: true,
                        isThreeLine: true,
                        // minLeadingWidth: 333,
                        minTileHeight: 1090,

                        title: Text(
                          note.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        subtitle: Column(
                          children: [
                            TextField(
                              maxLines: 1,
                              readOnly: true,
                              controller: TextEditingController(
                                text: note.description,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,

                              children: [
                                Checkbox(
                                  value: note.completed == 1 ? true : false,
                                  onChanged: (value) async {
                                    // update the note in the database
                                    note.completed = value! ? 1 : 0;
                                    await database.noteDao.updateNote(note);
                                    loasdNotes();
                                  },
                                ),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,

                                      children: [
                                        // show the address of the note if exists
                                        note.latitude != null &&
                                                note.lonitude != null
                                            ? IconButton(
                                                onPressed: () {
                                                  // go to location saved in the note on the map
                                                  final uri = Uri.parse(
                                                    "geo:0,0?q=${note.latitude},${note.lonitude}(${note.title})",
                                                  );
                                                  launchUrl(uri);
                                                },
                                                icon: const Icon(
                                                  Icons.location_on,
                                                ),
                                              )
                                            : SizedBox.shrink(),
                                        note.address != null
                                            ? Text(note.address!)
                                            : Text(''),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      spacing: 8,
                                      children: [
                                        // show icon for created at of the note
                                        Icon(Icons.access_time),
                                        Text(note.createdAt),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () async {
                                Get.to(EditNoteScreen(), arguments: note);
                              },
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () async {
                                // snack bar with undo action to undo delete action
                                Get.snackbar(
                                  'Delete Note',
                                  'Are you sure you want to delete this note ?',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 3),
                                  animationDuration: const Duration(seconds: 1),
                                  icon: IconButton(
                                    // undo delete action
                                    icon: Icon(Icons.undo, color: Colors.white),
                                    onPressed: () async {
                                      await database.noteDao
                                          .insertNote(note)
                                          .then((value) => loasdNotes());
                                    },
                                  ),
                                );
                                //
                                await database.noteDao
                                    .deleteNote(note)
                                    .then((value) => loasdNotes());
                              },
                              icon: const Icon(Icons.delete),
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
      ),
    );
  }
}
