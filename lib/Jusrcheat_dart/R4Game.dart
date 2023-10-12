import 'dart:convert';
import 'dart:typed_data';

import 'package:jusrcheat_flutter/ByteBuffer.dart';
import 'package:jusrcheat_flutter/HelperClass.dart';

import 'EndianUtils.dart';
import 'R4GamePointer.dart';
import 'R4Item.dart';
import 'R4Folder.dart';
import 'R4Code.dart';

class R4Game {
  late bool gameEnabled;
  late final List<int> masterCode = List<int>.filled(8, 0);
  late String gameTitle;

  late String gameId;
  late int gameIdNum;

  late List<R4Item> _items;
  late int _numItems;

  // Create a new game
  R4Game.createNew(this.gameId, this.gameIdNum, int numItems) {
    _numItems = numItems;
    _items = List.empty(growable: true);
  }
  // Read an existing game
  R4Game.readExisting(Uint8List data, R4GamePointer gamePointer) {
    gameId = gamePointer.gameId;
    gameIdNum = gamePointer.gameIdNum;
    _items = List<R4Item>.empty(growable: true);

    ByteBuffer bb = ByteBuffer(data: data);
    bb.skip(gamePointer.pointer);

    StringBuffer sb = StringBuffer();
    int tempCharCode;
    while((tempCharCode = bb.readByte()) != 0) {
      sb.write(String.fromCharCode(tempCharCode));
    }
    gameTitle = sb.toString();
    sb.clear();

    // Align to nearest multiple of 4
    bb.skip(EndianUtils.alignto4(gameTitle.length + 1));

    // Get number of codes/folders
    Uint8List tempArr = Uint8List(2);
    bb.read(tempArr);
    _numItems = EndianUtils.little2short(tempArr) & 0xFFFF;

    // Get flags
    bb.read(tempArr);
    gameEnabled = (tempArr[1] & 0xF0) == 0xF0;

    tempArr = Uint8List(4);
    for(int i = 0; i < masterCode.length; ++i) {
      bb.read(tempArr);
      masterCode[i] = EndianUtils.little2int(tempArr);
    }

    tempArr = Uint8List(2);
    int i = 0;
    while(i < _numItems) {
      bb.read(tempArr);
      int numberThings = EndianUtils.little2short(tempArr);

      bb.read(tempArr);
      int flags = EndianUtils.little2short(tempArr);

      if((flags & 0x1000) == 0x1000) {
        // Folder
        ++i;
        R4Folder tmpFold = R4Folder.readExisting(numberThings, flags, bb);
        i += (numberThings & 0xFFFF);
        _items.add(tmpFold);
      } else {
        // Code
        i++;
        R4Code tmpCode = R4Code.readExisting(numberThings, flags, bb);
        _items.add(tmpCode);
      }
    }
  }

  String getMasterCodeStr(){
    StringBuffer sb = StringBuffer();
    for(int i = 0; i < masterCode.length; i += 2) {
      if(i != 0) {
        sb.write("\n");
      }
      sb.write(("${HelperClass.matchDigits(masterCode[i].toRadixString(16), 8)} ${HelperClass.matchDigits(masterCode[i+1].toRadixString(16), 8)}"));
    }
    return sb.toString();
  }
  void setMasterCodeStr(String masterCodeInString) {
    masterCodeInString = masterCodeInString.replaceAll("[\n]+", " ");
    masterCodeInString = masterCodeInString.replaceAll("[ ]+", " ");
    List<String> elems = masterCodeInString.split(" ");
    for(int i = 0; i < elems.length; ++i) {
      masterCode[i] = int.parse(elems[i], radix: 16);
    }
  }

  List<R4Item> getItems() => _items;
  void appendItem(R4Item item) => _items.add(item);
  void insertItemAt(R4Item item, int index) => _items.insert(index, item);
  void replaceItem(R4Item item, int index) => _items[index] = item;
  void removeItemAt(int index) => _items.removeAt(index);
  void removeAll() => _items.clear();

  Uint8List serialize() {
    _numItems = 0;
    for(R4Item item in _items) {
      if(item is R4Folder) {
        _numItems += item.numCodes;
      }
      _numItems++;
    }

    List<int> b = List.empty(growable: true);

    // Write the Game title
    Uint8List tmp = EndianUtils.str2byte_1(gameTitle, true);
    for(int bb in tmp) {
      b.add(bb);
    }

    tmp = EndianUtils.short2little(_numItems);
    b.add(tmp[0]);
    b.add(tmp[1]);
    b.add(0);
    b.add(gameEnabled ? 0xF0 : 0x00);
    for(int mast in masterCode) {
      tmp = EndianUtils.int2little(mast);
      b.add(tmp[0]);
      b.add(tmp[1]);
      b.add(tmp[2]);
      b.add(tmp[3]);
    }
    for(R4Item item in _items) {
      b.addAll(item.serialize());
    }
    return Uint8List.fromList(b);
  }
}