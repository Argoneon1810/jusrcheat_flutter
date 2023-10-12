import 'dart:typed_data';

import 'EndianUtils.dart';

class R4GamePointer {
  late String gameId;
  late int gameIdNum;
  late int pointer;

  R4GamePointer.createNew(this.gameId, this.gameIdNum, this.pointer);
  R4GamePointer.readExisting(Uint8List bytes) {
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < 4; ++i) {
      buffer.write(String.fromCharCode(bytes[i]));
    }
    gameId = buffer.toString();
    gameIdNum = EndianUtils.little2int(bytes.sublist(0x04, 0x08));
    pointer = EndianUtils.little2int(bytes.sublist(0x08, 0x0c));
  }

  Uint8List serialize() {
    Uint8List bytes = Uint8List(0x10);
    for(int i = 0; i < 4; ++i) {
      bytes[i] = gameId.codeUnitAt(i);
    }
    Uint8List tempId = EndianUtils.int2little(gameIdNum);
    for(int i = 0; i < 4; ++i) {
      bytes[i+0x04] = tempId[i];
    }
    Uint8List tempPointer = EndianUtils.int2little(pointer);
    for(int i = 0; i < 4; ++i) {
      bytes[i+0x08] = tempPointer[i];
    }
    for(int i = 0; i < 4; ++i) {
      bytes[i+0x0c] = 0;
    }
    return bytes;
  }
}