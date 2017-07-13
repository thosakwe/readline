import 'dart:async';
import 'dart:convert';
import 'package:charcode/charcode.dart';

const LineReader readline = const LineReader(print);

typedef Printer(String msg);

/// Better support for reading text out of data streams, including support for console escape characters.
class LineReader implements StreamTransformer<List<int>, String> {
  /// The [Encoding] used to transform byte arrays into Strings. default: `UTF8`
  final Encoding encoding;

  /// If this is `true` (`false` by default), then new input lines will overwrite one at the current index.
  ///
  /// If not, then they will be inserted into the history and shift subsequent entries over.
  final bool overwriteHistory;

  /// If this is `true` (`false` by default), then empty lines will be skipped, and not seen in the output stream.
  final bool trim;

  final Printer printer;

  const LineReader(this.printer,
      {this.encoding: UTF8, this.overwriteHistory: false, this.trim: false});

  @override
  Stream<String> bind(Stream<List<int>> stream) {
    final ctrl = new StreamController<String>();
    bool isEscape = false;
    int historyIndex = 0;
    final List<String> history = [];
    final List<int> buf = [];

    void flush() {
      var str = encoding.decode(buf);
      bool add = true;

      if (trim == true) {
        str = str.trim();
        add = str.isNotEmpty;
      }

      if (add) {
        // Increment history
        if (overwriteHistory == true)
          history[historyIndex] = str;
        else {
          history.insert(historyIndex, str);
          historyIndex++;
        }
        ctrl.add(str);
        buf.clear();
      }
    }

    stream.expand<int>((x) => x).listen((ch) {
      if (isEscape) {
        switch (ch) {
          case $A:
            if (historyIndex > 0) historyIndex--;
            if (historyIndex < history.length)
              buf.addAll(history[historyIndex].codeUnits);
            printer('\r' + new String.fromCharCodes(buf));
            break;
        }

        isEscape = false;
      } else if (ch == $esc) {
        flush();
        isEscape = true;
      } else if (ch == $lf) {
        // Trim any trailing CR/LF in the buffer
        while (buf.isNotEmpty && (buf.last == $cr || buf.last == $lf))
          buf.removeLast();
        flush();
      } else {
        isEscape = false;
        buf.add(ch);
      }
    }, onDone: () {
      flush();
      ctrl.close();
    }, onError: ctrl.addError);

    return ctrl.stream;
  }
}
