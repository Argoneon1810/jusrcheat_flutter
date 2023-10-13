import 'dart:convert';
import 'dart:typed_data';
import 'package:jusrcheat_flutter/HelperClass.dart';
import 'package:jusrcheat_flutter/Logger.dart';

class EndianUtils {
  static int little2int(Uint8List b) {
    if (b.length != 4) {
      Logger.log("Error: Bad Int Length");
    }
    return ( ((b[3]<<24)&0xFF000000) | ((b[2] << 16)&0xFF0000) | ((b[1] << 8)&0xFF00) | (b[0]&0xFF));
  }
  static Uint8List int2little(int i) => Uint8List.fromList([i&0xFF, (i>>8)&0xFF, (i>>16)&0xFF, (i>>24)&0xFF]);

  static int little2short(Uint8List b) {
    if(b.length != 2) {
      Logger.log("Error: Bad Short Length");
    }
    return ((b[1] << 8) & 0xFF00) | (b[0] & 0xFF);
  }
  static Uint8List short2little(int s) => Uint8List.fromList([s&0xFF, (s>>8)&0xFF]);

  // Note: &3 = %4
  static int alignto4(int pos) => (4 - (pos & 3)) & 3;
  static int alignstr(int len) => (4 - (len & 3)) + len;
  static Uint8List str2byte_1(String s, bool padding) {
    Uint8List b;

    if(padding) {
      b = Uint8List(alignstr(s.length));
    } else {
      b = Uint8List(s.length + 1);
    }

    HelperClass.copyList(
        readFrom: utf8.encode(s),
        writeTo: b,
        readStartingIndex: 0,
        writeStartingIndex: 0,
        length: b.length
    );
    return b;
  }
  static Uint8List str2byte_2(String s1, String s2, bool padding) {
    Uint8List b;

    if(padding) {
      b = Uint8List(alignstr(s1.length + 1 + s2.length));
    } else {
      b = Uint8List(s1.length + 1 + s2.length + 1);
    }

    for(int i = 0; i<b.length; i++) {
      if(i < s1.length) {
        b[i] = s1.codeUnitAt(i);
      } else if(i == s1.length) {
        b[i] = 0;
      } else if((i - (s1.length + 1)) < s2.length) {
        b[i] = s2.codeUnitAt(i - (s1.length + 1));
      } else {
        b[i] = 0;
      }
    }
    return b;
  }
}