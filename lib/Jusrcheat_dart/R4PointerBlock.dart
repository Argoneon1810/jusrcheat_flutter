import 'dart:typed_data';

import 'package:jusrcheat_flutter/ByteBuffer.dart';

import 'R4GamePointer.dart';
import 'R4Game.dart';

class R4PointerBlock {
  late List<R4GamePointer> _gamePointers;
  int numGames() => _gamePointers.length;
  R4GamePointer getGamePointer(int i) => _gamePointers[i];

  // Never edit the existing PointerBlock. Always create a new one
  R4PointerBlock.parseByteBuffer(Uint8List bytes, int offset) {
    ByteBuffer bb = ByteBuffer(data: bytes);
    bb.skip(offset);

    _gamePointers = List.empty(growable: true);

    int start = offset;
    Uint8List temp = Uint8List(0x10);
    while(true) {
      bb.read(temp);
      if(temp[0] == 0) break;
      _gamePointers.add(R4GamePointer.readExisting(temp));
    }
  }
  R4PointerBlock.rebuildFromGameList(List<R4Game> games) {
    _gamePointers = List<R4GamePointer>.empty(growable: true);
    int offset = 0x110 + games.length * 0x10;
    for(int i = 0; i < games.length; ++i) {
      R4Game game = games[i];
      _gamePointers.add(R4GamePointer.createNew(game.gameId, game.gameIdNum, offset));
      offset += game.serialize().length;
    }
  }

  Uint8List serialize() {
    List<int> b = List.empty(growable: true);
    for(int i = 0; i < _gamePointers.length; ++i) {
      b.addAll(_gamePointers[i].serialize());
    }
    // Write the separator block
    for(int i = 0; i<0x10; ++i) {
      b.add(0);
    }
    return Uint8List.fromList(b);
  }
}