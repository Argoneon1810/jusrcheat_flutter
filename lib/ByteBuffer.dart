import 'dart:typed_data';

class ByteBuffer {
  late Uint8List _data;
  int _index = 0;

  ByteBuffer({required Uint8List data}) {_data = data;}

  void skip(int length) {
    _index += length;
  }

  int readByte() => _data[_index++];
  void read(List<int> toGetResult) {
    for(int i = 0; i < toGetResult.length; ++i) {
      toGetResult[i] = _data[i+_index];
    }
    _index += toGetResult.length;
  }
}