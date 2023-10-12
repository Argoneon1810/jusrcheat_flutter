import 'package:flutter/material.dart';

class Logger {
  static log(String message, [List<String>? messages]) {
    StringBuffer buffer = StringBuffer();
    buffer.write(message);
    if (messages != null) {
      int len = messages.length;
      for (int i = 0; i < len; ++i) {
        buffer.write(' ');
        buffer.write(messages[i]);
      }
    }
    debugPrint(buffer.toString());
  }
}