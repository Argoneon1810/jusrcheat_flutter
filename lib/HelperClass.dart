class HelperClass {
  static copyList({
    required List<int> readFrom,
    required List<int> writeTo,
    required int readStartingIndex,
    required int writeStartingIndex,
    required int length
  }) {
    for (int i = 0; i < length; ++i) {
      if (writeStartingIndex + i >= writeTo.length) break;
      if (readStartingIndex + i >= readFrom.length) break;
      writeTo[writeStartingIndex + i] = readFrom[readStartingIndex + i];
    }
  }

  static String matchDigits(String original, int length) {
    int toAdd = length - original.length;
    StringBuffer buffer = StringBuffer();
    if(toAdd > 0) {
      for(int _ = 0; _ < toAdd; ++_) {
        buffer.write("0");
      }
      buffer.write(original);
    } else {
      buffer.write(original);
    }
    return buffer.toString();
  }
}