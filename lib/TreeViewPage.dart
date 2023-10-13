import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:saf/saf.dart';

import 'dart:typed_data';
import 'dart:io' as io;
//import 'dart:html' as html;

import 'Logger.dart';
import 'HelperClass.dart';

import 'Jusrcheat_dart/R4Cheat.dart';
import 'Jusrcheat_dart/R4Game.dart';
import 'Jusrcheat_dart/R4Header.dart';
import 'Jusrcheat_dart/R4ProgressCallback.dart';

class TreeViewPage extends StatefulWidget {
  const TreeViewPage({Key? key, required this.title, required this.header, required this.games}) : super(key: key);

  final String title;
  final R4Header header;
  final List<R4Game> games;

  @override
  State<TreeViewPage> createState() => _TreeViewPageState();
}

class _TreeViewPageState extends State<TreeViewPage> implements R4ProgressCallback {
  String filename = "";
  Color defaultColor = Colors.grey[400]!;

  late String _suggestedName = "usrcheat.dat";

  @override
  void setProgress(int num, int max) {
    // TODO: implement setProgress
  }

  void mySaveAs() async {
    Uint8List serialized = R4Cheat.serializeWithCallback(widget.header, widget.games, this);
    if(kIsWeb) {
      Logger.log("Unsupported. Debug Only");
      /*
      html.AnchorElement anchor = html.AnchorElement(
          href: html.Url.createObjectUrl(html.Blob(serialized)),
      );
      anchor.download = _suggestedName;
      anchor.text = "Download ${anchor.download}";
      anchor.click();
      **/
    } else if (io.Platform.isAndroid) {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if(selectedDirectory == null) {
        Logger.log("User cancelled to select a directory.");
        return;
      }
      Saf saf = Saf("~/Downloads");
      bool? isGranted = await saf.getDirectoryPermission(isDynamic: false);
      if (isGranted == null || !isGranted) {
        Logger.log("shared storage access permission not granted.");
        return;
      }
      List<String>? paths = await saf.getFilesPath();
      if(paths != null) {
        bool okay = false;
        int i = 1;
        while (!okay) {
          for (var path in paths) {
            if(path == _suggestedName) {
              if(i == 1) {
                _suggestedName = "$_suggestedName ($i)";
              } else {
                _suggestedName = _suggestedName.substring(0, _suggestedName.length-1-HelperClass.countDigits(i));
              }
              break;
            }
          }
        }
      }
      await Saf.releasePersistedPermissions();
    } else {

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