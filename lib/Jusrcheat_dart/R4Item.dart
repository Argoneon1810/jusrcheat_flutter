import 'dart:typed_data';

//interface use only
abstract class R4Item {
  String getName();
  String getDesc();
  Uint8List serialize();
}