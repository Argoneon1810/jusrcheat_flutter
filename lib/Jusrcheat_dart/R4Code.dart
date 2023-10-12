import 'dart:typed_data';

import 'package:jusrcheat_flutter/HelperClass.dart';
import 'package:jusrcheat_flutter/Logger.dart';
import 'package:jusrcheat_flutter/ByteBuffer.dart';

import 'EndianUtils.dart';
import 'R4Item.dart';

class R4Code implements R4Item{
  late int _numChunks;
  late int _numCodeChunks;

  late bool codeEnabled;
  late List<int> _codes;

  late String _codeName;
  @override
  String getName() => _codeName;
  set codeName(String codeName) { _codeName = codeName; }

  late String _codeDesc;
  @override
  String getDesc() => _codeDesc;
  set codeDesc(String codeDesc) { _codeDesc = codeDesc; }

  R4Code.createNew(this._codeName, this._codeDesc) {
    _codes = List<int>.empty(growable: true);
  }
  R4Code.readExisting(int numChunks, int flags, ByteBuffer bb) {
    _numChunks = numChunks & 0xFFFF;
    codeEnabled = (flags & 0x0100) == 0x0100;
    _codes = List<int>.empty(growable: true);

    StringBuffer sb = StringBuffer();
    int tempCharCode;
    while((tempCharCode = bb.readByte()) != 0) {
      sb.write(String.fromCharCode(tempCharCode));
    }
    _codeName = sb.toString();
    sb.clear();

    while((tempCharCode = bb.readByte()) != 0) {
      sb.write(String.fromCharCode(tempCharCode));
    }
    _codeDesc = sb.toString();
    sb.clear();

    bb.skip(EndianUtils.alignto4(_codeName.length + _codeDesc.length + 2));

    Uint8List tempArr = Uint8List(4);
    bb.read(tempArr);
    _numCodeChunks = EndianUtils.little2int(tempArr);

    for(int i = 0; i < _numCodeChunks; ++i) {
      bb.read(tempArr);
      _codes.add(EndianUtils.little2int(tempArr));
    }
  }

  List<int> getCodes() => _codes;
  String getCodeStr() {
    if(_codes.isEmpty) {
      return "";
    }
    StringBuffer sb = StringBuffer();
    for(int i = 0; i < _codes.length; i += 2) {
      if(i != 0) {
        sb.write("\n");
      }
      sb.write(("${HelperClass.matchDigits(_codes[i].toRadixString(16), 8)} ${HelperClass.matchDigits(_codes[i+1].toRadixString(16), 8)}"));
    }
    return sb.toString();
  }
  void addCode(int toAdd) => _codes.add(toAdd);
  bool tryAddAll(String s) {
    s = s.replaceAll("[\n]+"," ");
    s = s.replaceAll("[ ]+"," ");
    for(String ss in s.split(" ")) {
      if(ss.length != 8) {
        return false;
      }
      try {
        _codes.add(int.parse(ss, radix: 16));
      } on FormatException catch(e, stacktrace) {
        Logger.log(e.message, ['\n', stacktrace.toString()]);
        return false;
      }
    }
    return true;
  }
  void addAll(List<int> a) => _codes.addAll(a);
  void removeAll() => _codes.clear();

  @override
  Uint8List serialize() {
    List<int> b = List.empty(growable: true);

    // Total chunks
    b.add(0); // Set this later
    b.add(0); // This too
    b.add(0);
    b.add(codeEnabled ? 1 : 0);

    int chunks = 0;
    Uint8List codeText = EndianUtils.str2byte_2(_codeName, _codeDesc, true);
    chunks += codeText.length ~/ 4;
    for(int bb in codeText) {
      b.add(bb);
    }
    chunks += 1;

    // Code chunks
    // Technically can be 32 bit, but the total chunk count is 16 bit.
    int codeChunks = _codes.length;
    Uint8List tmp = EndianUtils.int2little(codeChunks);
    b.add(tmp[0]);
    b.add(tmp[1]);
    b.add(tmp[2]);
    b.add(tmp[3]);
    chunks += codeChunks;
    for(int fragment in _codes) {
      tmp = EndianUtils.int2little(fragment);
      b.add(tmp[0]);
      b.add(tmp[1]);
      b.add(tmp[2]);
      b.add(tmp[3]);
    }
    tmp = EndianUtils.short2little(chunks);
    b[0] = tmp[0];
    b[1] = tmp[1];

    return Uint8List.fromList(b);
  }

}