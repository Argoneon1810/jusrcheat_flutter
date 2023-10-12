import 'dart:typed_data';

import 'package:crc32_checksum/crc32_checksum.dart';
import 'package:jusrcheat_flutter/ByteBuffer.dart';
import 'package:jusrcheat_flutter/HelperClass.dart';

import 'R4ProgressCallback.dart';
import 'R4Header.dart';
import 'R4Game.dart';
import 'R4PointerBlock.dart';

class R4Cheat {
  // All numbers are little endian
  // Strings must be aligned to 0x03, 0x07, 0x0B, or 0x0F
  // Strings are null terminated
  /* Structure
	 * 0x00: R4 CheatCode
	 * 0x0C: 00 01 00 00 -> Offset of where the cheats start? (0x0100)
	 * 0x10-0x4B: Cheat database title + \0
	 * 0x4C-0x4D: XX XX -> Encoding. GBK = D5 53, BIG5 = F5 53, SJIS = 75 53 UTF8 = 55 73
	 * 0x4E-0x4F: 41 59
	 * 0x50: "Cheat Enable"
	 * Game Pointer
	 * 0x00-0x03: Game ID
	 * 0x04-0x07: That version number?
	 * 0x08-0x0B: Offset in file
	 * 0x0C-0x0F: ????
	 *
	 * 16 byte Separator block of 00s
	 *
	 * Game
	 * 0x0000-0x????: Title, zero terminated, padded to blocks of 4 bytes
	 * Title is in blocks of 4*n-1. If the title is a multiple of 4, four extra zeros are added.
	 *
	 * (reset after title)
	 * 0x00-0x01: Number of items
	 * 0x03-0x04: Flags. Master code enable. 0xF0 is enable, 0x00 is disable
	 * 0x05-0x24: Master code, 4 byte chunks
	 *
	 *
	 *
	 * 0x25-0x26: Number of 4 byte chunks associated with item if it's a code, number of codes if it's a folder
	 * 0x27-0x28: Flags. 0x0010 = Folder 0x0001 = Code Enable for Codes, "One Hot" for folders
	 * 0x29-0x??: Title+Description
	 *
	 * (reset after desc)
	 * For codes:
	 * 0x00-0x03: Number of 4 byte cheat code chunks
	 * 0x04-0x??: The codes
	 * For Folders:
	 * Codes.
	 *
	 */

  static List<R4Game> getGames(R4Header header, Uint8List data) {
    R4PointerBlock block = R4PointerBlock.parseByteBuffer(data, header.getCodeOffset());
    List<R4Game> games = List.empty(growable: true);
    int numGames = block.numGames();
    for(int i = 0; i < numGames; ++i) {
      games.add(R4Game.readExisting(data, block.getGamePointer(i)));
    }
    return games;
  }
  static List<R4Game> getGamesWithCallback(R4Header header, Uint8List data, R4ProgressCallback callback) {
    R4PointerBlock block = R4PointerBlock.parseByteBuffer(data, header.getCodeOffset());
    List<R4Game> games = List.empty(growable: true);
    int numGames = block.numGames();
    for(int i = 0; i < numGames; ++i) {
      games.add(R4Game.readExisting(data, block.getGamePointer(i)));
      callback.setProgress(i, numGames);
    }
    return games;
  }

  static Uint8List serialize(R4Header header, List<R4Game> games) {
    R4PointerBlock newBlock = R4PointerBlock.rebuildFromGameList(games);
    BytesBuilder bb = BytesBuilder();
    bb.add(header.serialize());
    bb.add(newBlock.serialize());
    for(int i = 0; i < games.length; i++) {
      bb.add(games[i].serialize());
    }
    return bb.toBytes();
  }
  static Uint8List serializeWithCallback(R4Header header, List<R4Game> games, R4ProgressCallback callback) {
    R4PointerBlock newBlock = R4PointerBlock.rebuildFromGameList(games);
    BytesBuilder bb = BytesBuilder();
    bb.add(header.serialize());
    bb.add(newBlock.serialize());
    for(int i = 0; i < games.length; i++) {
      bb.add(games[i].serialize());
      callback.setProgress(i, games.length);
    }
    return bb.toBytes();
  }

  static List<String> getIds(Uint8List data) {
    Uint8List header = Uint8List(0x200);
    ByteBuffer buffer = ByteBuffer(data: data);
    buffer.read(header);
    String s = String.fromCharCodes(header, 0x0c, 0x0c+4);
    int check = ~Crc32.calculate(header);
    return [s, HelperClass.matchDigits(check.toRadixString(16), 8)];
  }
  static int validateGame(String title, String id1, String master) {
    if(title == "") {
      return 1;
    } else if(id1 == "") {
      return 2;
    } else if(master == "") {
      return 3;
    }

    master = master.replaceAll("[\n]+"," ");
    master = master.replaceAll("[ ]+"," ");
    List<String> tmp = master.split(" ");
    if(tmp.length != 8) {
      return 4;
    }
    RegExp exp = RegExp(r"([0-9a-fA-F]{8})");
    for(String sub in tmp) {
      if(!exp.hasMatch(sub)) {
        return 5;
      }
    }
    return 0;
  }
  static int validateCode(String title, String code) {
    if(title == "") {
      return 1;
    }
    code = code.replaceAll("[\n]+"," ");
    code = code.replaceAll("[ ]+"," ");
    if(code == "") {
      return 0;
    }

    List<String> tmp = code.split(" ");
    RegExp exp = RegExp(r"([0-9a-fA-F]{8})");
    for(String sub in tmp) {
      if(!exp.hasMatch(sub)) {
        return 2;
      }
    }
    return 0;
  }
}