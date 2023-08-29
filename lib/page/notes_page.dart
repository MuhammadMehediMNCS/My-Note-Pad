import 'package:flutter/material.dart';
import 'package:staggered_grid_view_flutter/staggered_grid_view_flutter.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import '../db/notes_database.dart';
import '../model/note.dart';
import '../widget/note_card_widget.dart';
import 'edit_note_page.dart';
import 'note_detail_page.dart';


class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late List<Note> notes;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshNotes();
  }

  @override
  void dispose() {
    NotesDatabase.instance.close();

    super.dispose();
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);

    this.notes = await NotesDatabase.instance.readAllNotes();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Notes',
        style: TextStyle(fontSize: 24.0),
      ),
      actions: const [Icon(Icons.search), SizedBox(width: 12)],
    ),
    body: Center(
      child: isLoading
      ? const CircularProgressIndicator()
      : notes.isEmpty
        ? const Text(
          'No Notes',
          style: TextStyle(color: Colors.white, fontSize: 30.0),
        )
        : buildNotes(),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.black,
      child: const Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddEditNotePage())
        );

        refreshNotes();
      }
    ),
  );

  Widget buildNotes() => StaggeredGridView.countBuilder(
    padding: const EdgeInsets.all(8.0),
    itemCount: notes.length,
    crossAxisSpacing: 4,
    crossAxisCount: 4,
    mainAxisSpacing: 4,
    itemBuilder: (context, index) {
      final note = notes[index];

      return GestureDetector(
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => NoteDetailPage(noteId: note.id!),
          ));
          refreshNotes();
        },
        child: NoteCardWidget(note: note, index: index),
      );
    },
    staggeredTileBuilder: (index) => const StaggeredTile.fit(3)
  );
}