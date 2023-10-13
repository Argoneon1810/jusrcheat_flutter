import 'dart:convert';
import 'dart:typed_data';

import 'package:jusrcheat_flutter/Logger.dart';
import 'package:jusrcheat_flutter/ByteBuffer.dart';

import 'EndianUtils.dart';
import 'R4Code.dart';
import 'R4Item.dart';

class R4Folder implements R4Item {
  late String _foldName;
  late String _foldDesc;
  late bool oneHot;

  bool _isMisc = false;
  bool get isMisc => _isMisc;

  late List<R4Code> _codes;

  late int _numCodes;
  int get numCodes => _numCodes;

  @override
  String getName() => _foldName;
  set foldName(String foldName) { _foldName = foldName; }

  @override
  String getDesc() => _foldDesc;
  set foldDesc(String foldDesc) { _foldDesc = foldDesc; }

  R4Folder.createNew(String foldName, String foldDesc, {bool isMisc = false}) {
    _foldName = foldName;
    _foldDesc = foldDesc;
    _isMisc = isMisc;
    _codes = List<R4Code>.empty(growable: true);
  }
  R4Folder.readExisting(int numCodes, int flags, ByteBuffer bb) {
    _numCodes = numCodes & 0xFFFF;
    _codes = List<R4Code>.empty(growable: true);
    // On some games, certain folders appear to have 0x0001 as a flag
    // Unknown what this is
    oneHot = (flags&0x0100)==0x0100;

    Utf8Decoder decoder = const Utf8Decoder(allowMalformed: true);
    List<int> encodedText = List.empty(growable: true);
    int tempCharCode, readByteCount = 0;
    while((tempCharCode = bb.readByte()) != 0) {
      encodedText.add(tempCharCode);
      readByteCount++;
    }
    _foldName = decoder.convert(encodedText);

    encodedText.clear();
    while((tempCharCode = bb.readByte()) != 0) {
      encodedText.add(tempCharCode);
      readByteCount++;
    }
    _foldDesc = decoder.convert(encodedText);

    bb.skip(EndianUtils.alignto4(readByteCount + 2));

    Uint8List tempArr = Uint8List(2);
    for(int i = 0; i<this.numCodes; i++) {
      bb.read(tempArr);
      int numberThings = EndianUtils.little2short(tempArr);

      bb.read(tempArr);
      int cflags = EndianUtils.little2short(tempArr);

      if((cflags & 0x1000) == 0x1000) {
        // Folder
        Logger.log("Error: Folder in folder");
      } else {
        // Code
        R4Code tmpCode = R4Code.readExisting(numberThings, cflags, bb);
        _codes.add(tmpCode);
      }
    }
  }

  List<R4Code> getCodes() => _codes;
  void appendCode(R4Code code) => _codes.add(code);
  void insertCodeAt(R4Code code, int index) => _codes.insert(index, code);
  void replaceCodeAt(R4Code code, int index) => _codes[index] = code;
  void removeCodeAt(int index) => _codes.removeAt(index);
  void removeAll() => _codes.clear();

  @override
  Uint8List serialize() {
    List<int> b = List.empty(growable: true);
    Uint8List tmp = EndianUtils.short2little(_numCodes);
    // Total chunks
    b.add(tmp[0]); // Set this later
    b.add(tmp[1]); // This too
    b.add(0);
    b.add(0x10 | (oneHot ? 1 : 0));

    Uint8List foldText = EndianUtils.str2byte_2(_foldName, _foldDesc, true);
    for(int bb in foldText) {
      b.add(bb);
    }
    for(R4Code code in _codes) {
      b.addAll(code.serialize());
    }
    return Uint8List.fromList(b);
  }
}