import 'dart:typed_data';

import 'package:jusrcheat_flutter/HelperClass.dart';
import 'package:jusrcheat_flutter/Logger.dart';

import 'EndianUtils.dart';

enum Encoding {
  GBK(arr: [0xD5, 0x53, 0x41, 0x59]),
  BIG5(arr: [0xF5, 0x53, 0x41, 0x59]),
  SJIS(arr: [0x75, 0x53, 0x41, 0x59]),
  UTF8(arr: [0x55, 0x73, 0x41, 0x59]);

  static int types = 4;
  final List<int> arr;

  const Encoding({ required this.arr });
}

class R4Header {
  // Constants
  static const int HEADER_SIZE = 0x100;
  static const String MAGIC = "R4 CheatCode";
  static const int START_OFFSET = 0x00000100;

  late Uint8List _data;


  R4Header.createNew(String title, Encoding encoding, bool isActive) {
    _data = Uint8List(HEADER_SIZE);
    for(int i = 0; i < MAGIC.length; ++i) {
      _data[i] = MAGIC.codeUnitAt(i);
    }
    resetCodeOffset();
    setDatabaseName(title);
    setEncoding(encoding);
    setCheatEnabled(isActive);
  }
  R4Header.readExisting(Uint8List bytes) {
    _data = Uint8List(HEADER_SIZE);
    HelperClass.copyList(
        readFrom: bytes,
        writeTo: _data,
        readStartingIndex: 0,
        writeStartingIndex: 0,
        length: HEADER_SIZE
    );
  }

  bool isHeaderValid() {
    for(int i = 0; i < MAGIC.length; ++i) {
      if(_data[i] != MAGIC.codeUnitAt(i)) {
        return false;
      }
    }
    return true;
  }

  String getDatabaseName() {
    StringBuffer sb = StringBuffer();
    for(int i = 0x10; i < 0x4B; ++i) {
      if(_data[i] == 0) break;
      sb.write(String.fromCharCode(_data[i]));
    }
    return sb.toString();
  }
  void setDatabaseName(String databaseName) {
    if(databaseName.length > 59) {
      //later change this into somewhat like popup
      Logger.log("Database name will be truncated!");
    }

    for(int i = 0; i < 59; ++i) {
      _data[i + 0x10] = i < databaseName.length ? databaseName.codeUnitAt(i) : 0;
    }
  }

  int getEncoding() {
    int encoding = _data[0x4C]; // Not the full encoding, but the encoding can be determined with the first byte
    int i = 0;
    for(Encoding elem in Encoding.values) {
      if (elem.arr[0] == encoding) return i;
      i++;
    }
    return -1;
  }
  void setEncoding(Encoding encoding) {
    for(int i = 0; i < 4; ++i) {
      _data[i + 0x4C] = encoding.arr[i];
    }
  }

  bool getCheatEnable() => ((_data[0x50] & 0x01) == 1);
  void setCheatEnabled(bool isActive) => _data[0x50] = isActive ? 1 : 0;

  int getCodeOffset() => EndianUtils.little2int(_data.sublist(MAGIC.length, MAGIC.length + 4));
  void setCodeOffset(int offset) {
    Uint8List b = EndianUtils.int2little(offset);
    HelperClass.copyList(
        readFrom: b,
        writeTo: _data,
        readStartingIndex: 0,
        writeStartingIndex: 0x0C,
        length: 4
    );
  }
  void resetCodeOffset() {
    Uint8List b = EndianUtils.int2little(START_OFFSET);
    HelperClass.copyList(
        readFrom: b,
        writeTo: _data,
        readStartingIndex: 0,
        writeStartingIndex: 0x0C,
        length: 4
    );
  }

  Uint8List serialize() => _data;
}