import 'dart:async';
import 'package:charcode/charcode.dart';
import 'package:readline/readline.dart';
import 'package:test/test.dart';

main() {
  test('plain string', () async {
    var ctrl = new StreamController<List<int>>()
      ..add([$f, $o, $o])
      ..close();
    expect(await ctrl.stream.transform(new LineReader(print)).first, 'foo');
  });

  test('previous', () async {
    var ctrl = new StreamController<List<int>>();
    ctrl.add([$f, $o, $o]); // 'foo'
    ctrl.add([$esc, $A, $lf]); // Up, ENTER
    ctrl.close();

    var list = await ctrl.stream.transform<String>(new LineReader(print, trim: true)).toList();
    expect(list, ['foo', 'foo']);
  });
}
