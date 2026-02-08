import 'package:floor/floor.dart';

@Entity(tableName: 'notes')
class Note {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  String title;
  String description;
  int completed;
  final String createdAt;

  // Location fields
  double? latitude;
  double? lonitude;
  String? address;

  Note({
    this.id,
    required this.title,
    required this.description,
    this.completed = 0,
    required this.createdAt,
    this.latitude,
    this.lonitude,
    this.address,
  });

  // Note copyWith({
  //   int? id,
  //   String? title,
  //   String? description,
  //   bool? completed,
  //   String? createdAt,
  //   double? latitude,
  //   double? longitude,
  //   String? address,
  // }) {
  //   return Note(
  //     id: id ?? this.id,
  //     title: title ?? this.title,
  //     description: description ?? this.description,
  //     completed: completed  this.completed,
  //     createdAt: createdAt ?? this.createdAt,
  //     latitude: latitude ?? this.latitude,
  //     longitude: longitude ?? this.longitude,
  //     address: address ?? this.address,
  //   );
  // }

  bool get hasLocation => latitude != null && lonitude != null;
}
