import 'dart:io';
import 'package:readline/readline.dart';

const String PROMPT = 'Enter text to have it echoed: ';

main() async {
  stdout.write(PROMPT);

  stdin.transform(new LineReader(stdout.write, trim: true)).listen((msg) {
    print('You typed: $msg');
    stdout.write(PROMPT);
  });
}
