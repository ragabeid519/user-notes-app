import 'package:floor/floor.dart';
import 'package:notes_app/models/note.dart';

@dao
abstract class NoteDao {
  // get all notes using limit and offset

  @Query(
    'SELECT * FROM notes ORDER BY createdAt DESC LIMIT :limit OFFSET :offset',
  )
  Future<List<Note>> getNotes(int limit, int offset);

  @Query('SELECT * FROM notes ORDER BY createdAt DESC')
  Future<List<Note>> getAllNote();

  @Query('SELECT * FROM notes WHERE id = :id')
  Future<Note?> getNoteById(int id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertNote(Note note);

  @update
  Future<void> updateNote(Note note);

  // search notes by title or description
  @Query(
    'SELECT * FROM notes WHERE title LIKE :query OR description LIKE :query',
  )
  Future<List<Note>> searchNotes(String query);

  @delete
  Future<void> deleteNote(Note note);

  @Query('DELETE FROM notes WHERE id = :id')
  Future<void> deleteNoteById(int id);

  @Query('DELETE FROM notes')
  Future<void> deleteAllNotes();

  // update lat and long and address
  @Query(
    'UPDATE notes SET latitude = :latitude, lonitude = :lonitude, address = :address WHERE id = :id',
  )
  Future<void> updateLocation(
    int id,
    double latitude,
    double lonitude,
    String address,
  );
}
