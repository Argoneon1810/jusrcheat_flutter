import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';

import 'Logger.dart';

import 'Jusrcheat_dart/R4Cheat.dart';
import 'Jusrcheat_dart/R4Game.dart';
import 'Jusrcheat_dart/R4Header.dart';

class TreeViewPage extends StatefulWidget {
  const TreeViewPage({Key? key, required this.title, required this.header, required this.games}) : super(key: key);

  final String title;
  final R4Header header;
  final List<R4Game> games;

  @override
  State<TreeViewPage> createState() => _TreeViewPageState();
}

class _TreeViewPageState extends State<TreeViewPage> {
  String filename = "";
  Color defaultColor = Colors.grey[400]!;

  final String mimeType = "text/plain";
  String _suggestedName = "usrcheat.dat";

  void mySaveAs() async {
    var dir = await getSaveLocation(suggestedName: _suggestedName);
    if(dir != null) {
      var file = XFile.fromData(
          R4Cheat.serialize(widget.header, widget.games),
          mimeType: mimeType,
          name: _suggestedName
      );
      file.saveTo(dir.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: mySaveAs,
              child: const Text('Save As'),
            ),
          ],
        ),
      ),
    );
  }
}