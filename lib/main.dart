import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'Jusrcheat_dart/R4Cheat.dart';
import 'Jusrcheat_dart/R4Game.dart';
import 'Jusrcheat_dart/R4Header.dart';
import 'Jusrcheat_dart/R4ProgressCallback.dart';

import 'Logger.dart';
import 'TreeViewPage.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jusrcheat_Flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Jusrcheat_Flutter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> implements R4ProgressCallback {
  String filename = "";
  Color defaultColor = Colors.grey[400]!;

  int current = 0;
  int max = 1;
  
  R4Header? header;
  List<R4Game>? games;
  bool isMidPrep = false;
  bool isReady = false;

  @override
  void setProgress(int current, int max) {
    setState(() {
      this.current = current;
      this.max = max;
    });
  }
  
  void goToTreeView() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) {
              return TreeViewPage(title: "Inspector", header: header!, games: games!);
            },
        )
    ).then((value) {
      isReady = false;
      isMidPrep = false;
      header = null;
      games = null;
    });
  }

  Future<void> myOpenFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) {
      Logger.log("User cancelled reading file");
      return;
    }

    Uint8List? bytes = result.files.single.bytes;
    if (bytes == null) {
      Logger.log("something went wrong");
      return;
    }

    isMidPrep = true;

    header = R4Header.readExisting(bytes);
    if(header == null) {
      Logger.log("something went wrong");
      return;
    }
    R4Header headerUnwrapped = header!;

    if(!headerUnwrapped.isHeaderValid()) {
      setState(() {
        filename = "Invalid Header";
      });
      return;
    }

    games = R4Cheat.getGamesWithCallback(headerUnwrapped, bytes, this);
    current = max;
    isReady = true;
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
            !isMidPrep
              ? Container(
                height: 200,
                width: 400,
                decoration: BoxDecoration(
                  border: Border.all(width: 5, color: defaultColor,),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => myOpenFile(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Find and Upload", style: TextStyle(fontWeight: FontWeight.bold, color: defaultColor, fontSize: 20,),),
                          Icon(Icons.upload_rounded, color: defaultColor,),
                        ],
                      ),
                    ),
                    Text("(*.dat)", style: TextStyle(color: defaultColor,),),
                    const SizedBox(height: 10,),
                    Text(filename, style: TextStyle(color: defaultColor,),),
                  ],
                ),
              )
              : Text("progress: ${(current / max) * 100}%"),
            if(isReady)
              ElevatedButton(onPressed: goToTreeView, child: const Text("Proceed")),
          ],
        ),
      ),
    );
  }
}