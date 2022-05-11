import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notessqflite/db/dbmethods.dart';
import 'package:notessqflite/models/notemodel.dart';
import 'package:notessqflite/widgets/note_card_widget.dart';

import 'edit_note_page.dart';
import 'note_detail_page.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  _NotesPageState createState() => _NotesPageState();
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

    notes = await NotesDatabase.instance.readAllNotes();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      centerTitle: true,
      backgroundColor: Colors.green.shade200,
      title:   const Text(
        'Notes',
        style: TextStyle(fontSize: 24),
      ),
      actions:  [ InkWell(
        onTap: (){
          NotesDatabase.instance.deleteAll().then((value) => refreshNotes());
         
        },
        child: Container(
          margin: const EdgeInsets.only(top: 8,bottom: 8,right: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
           // color: Color.fromARGB(182, 17, 218, 44),
           border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(5)
          ),
          child: const Text("Delete All",style: TextStyle(color: Color.fromARGB(255, 255, 20, 4),fontWeight: FontWeight.bold),),)
        ),],
    ),
    body: Center(
      child: isLoading
          ? const CircularProgressIndicator()
          : notes.isEmpty
          ? const Text(
        'No Notes',
        style: TextStyle(color: Colors.white, fontSize: 24),
      )
          : buildNotes(),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.black,
      child: const Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddEditNotePage()),
        );

        refreshNotes();
      },
    ),
  );

  Widget buildNotes() => StaggeredGridView.countBuilder(
    padding: const EdgeInsets.all(8),
    itemCount: notes.length,
    staggeredTileBuilder: (index) => const StaggeredTile.fit(2),
    crossAxisCount: 4,
    mainAxisSpacing: 4,
    crossAxisSpacing: 4,
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
  );
}