import 'package:chalkdart/chalk.dart';
import 'package:cli_table/src/utils.dart';
import 'package:test/test.dart';

String zebra(String string) {
  var res = '';
  for (var i = 0; i < string.length; i++) {
    final letter = string[i];
    res += i % 2 == 0 ? letter : chalk.inverse(letter);
  }
  return res;
}

Map<String, dynamic> defaultOptions() {
  return {
    'chars': {
      'top': '─',
      'top-mid': '┬',
      'top-left': '┌',
      'top-right': '┐',
      'bottom': '─',
      'bottom-mid': '┴',
      'bottom-left': '└',
      'bottom-right': '┘',
      'left': '│',
      'left-mid': '├',
      'mid': '─',
      'mid-mid': '┼',
      'right': '│',
      'right-mid': '┤',
      'middle': '│',
    },
    'truncate': '…',
    'colWidths': [],
    'rowHeights': [],
    'colAligns': [],
    'rowAligns': [],
    'style': {
      'padding-left': 1,
      'padding-right': 1,
      'head': ['red'],
      'border': ['grey'],
      'compact': false,
    },
    'head': [],
  };
}

void main() {
  group('utils', () {
    group('strlen', () {
      test('length of "hello" is 5', () {
        expect(strlen('hello'), 5);
      });

      test('length of "hi" is 2', () {
        expect(strlen('hi'), 2);
      });

      test('length of "hello" in red is 5', () {
        expect(strlen(chalk.red('hello')), 5);
      });

      test('length of "hello" in zebra is 5', () {
        expect(strlen(zebra('hello')), 5);
      });

      test('length of "hello\\nhi\\nheynow" is 6', () {
        expect(strlen('hello\nhi\nheynow'), 6);
      });

      test('length of "中文字符" is 8', () {
        expect(strlen('中文字符'), 8);
      });

      test('length of "日本語の文字" is 12', () {
        expect(strlen('日本語の文字'), 12);
      });

      test('length of "한글" is 4', () {
        expect(strlen('한글'), 4);
      });
    });

    group('repeat', () {
      test('"-" x 3', () {
        expect(repeat('-', 3), '---');
      });

      test('"-" x 4', () {
        expect(repeat('-', 4), '----');
      });

      test('"=" x 4', () {
        expect(repeat('=', 4), '====');
      });
    });

    group('pad', () {
      test("pad('hello',6,' ', right) == ' hello'", () {
        expect(pad('hello', 6, ' ', 'right'), ' hello');
      });

      test("pad('hello',7,' ', left) == 'hello  '", () {
        expect(pad('hello', 7, ' ', 'left'), 'hello  ');
      });

      test("pad('hello',8,' ', center) == ' hello  '", () {
        expect(pad('hello', 8, ' ', 'center'), ' hello  ');
      });

      test("pad('hello',9,' ', center) == '  hello  '", () {
        expect(pad('hello', 9, ' ', 'center'), '  hello  ');
      });

      test("pad('yo',4,' ', center) == ' yo '", () {
        expect(pad('yo', 4, ' ', 'center'), ' yo ');
      });

      test('pad red(hello)', () {
        expect(pad(chalk.red('hello'), 7, ' ', 'right'), "  ${chalk.red("hello")}");
      });

      test("pad('hello', 2, ' ', right) == 'hello'", () {
        expect(pad('hello', 2, ' ', 'right'), 'hello');
      });
    });

    group('truncate', () {
      test('truncate("hello", 5) === "hello"', () {
        expect(truncate('hello', 5), 'hello');
      });

      test('truncate("hello sir", 7, "…") == "hello …"', () {
        expect(truncate('hello sir', 7, '…'), 'hello …');
      });

      test('truncate("hello sir", 6, "…") == "hello…"', () {
        expect(truncate('hello sir', 6, '…'), 'hello…');
      });

      test('truncate("goodnight moon", 8, "…") == "goodnig…"', () {
        expect(truncate('goodnight moon', 8, '…'), 'goodnig…');
      });

      test('truncate(colors.zebra("goodnight moon"), 15, "…") == colors.zebra("goodnight moon")', () {
        var original = zebra('goodnight moon');
        expect(truncate(original, 15, '…'), original);
      });

      test('truncate(colors.zebra("goodnight moon"), 8, "…") == colors.zebra("goodnig") + "…"', () {
        var original = zebra('goodnight moon');
        var expected = '${zebra('goodnig')}…';
        expect(truncate(original, 8, '…'), expected);
      });

      test('truncate(colors.zebra("goodnight moon"), 9, "…") == colors.zebra("goodnig") + "…"', () {
        var original = zebra('goodnight moon');
        var expected = '${zebra('goodnigh')}…';
        expect(truncate(original, 9, '…'), expected);
      });

      test('red(hello) + green(world) truncated to 9 chars', () {
        var original = chalk.red('hello') + chalk.green(' world');
        var expected = '${chalk.red('hello')}${chalk.green(' wo')}…';
        expect(truncate(original, 9), expected);
      });

      test('red-on-green(hello) + green-on-red(world) truncated to 9 chars', () {
        var original = chalk.red.bgGreen('hello') + chalk.green.bgRed(' world');
        var expected = '${chalk.red.bgGreen('hello')}${chalk.green.bgRed(' wo')}…';
        expect(truncate(original, 9), expected);
      });

      test('red-on-green(hello) + green-on-red(world) truncated to 10 chars - using inverse', () {
        var original = chalk.red.bgGreen('hello${chalk.inverse(' world')}');
        var expected = '${chalk.red.bgGreen('hello${chalk.inverse(' wor')}')}…';
        expect(truncate(original, 10), expected);
      });

      test('red-on-green( zebra (hello world) ) truncated to 11 chars', () {
        var original = chalk.red.bgGreen(zebra('hello world'));
        var expected = chalk.red.bgGreen(zebra('hello world'));
        expect(truncate(original, 11), expected);
      });

      test('red-on-green( zebra (hello world) ) truncated to 10 chars', () {
        var original = chalk.red.bgGreen(zebra('hello world'));
        var expected = '${chalk.red.bgGreen(zebra('hello wor'))}…';
        expect(truncate(original, 10), expected);
      });

      test('handles reset code', () {
        var original = '\x1b[31mhello\x1b[0m world';
        var expected = '\x1b[31mhello\x1b[0m wor…';
        expect(truncate(original, 10), expected);
      });

      test('handles reset code (EMPTY VERSION)', () {
        var original = '\x1b[31mhello\x1b[0m world';
        var expected = '\x1b[31mhello\x1b[0m wor…';
        expect(truncate(original, 10), expected);
      });

      test('truncateWidth("漢字テスト", 15) === "漢字テスト"', () {
        expect(truncate('漢字テスト', 15), '漢字テスト');
      });

      test('truncateWidth("漢字テスト", 6) === "漢字…"', () {
        expect(truncate('漢字テスト', 6), '漢字…');
      });

      test('truncateWidth("漢字テスト", 5) === "漢字…"', () {
        expect(truncate('漢字テスト', 5), '漢字…');
      });

      test('truncateWidth("漢字testてすと", 12) === "漢字testて…"', () {
        expect(truncate('漢字testてすと', 12), '漢字testて…');
      });

      test('handles color code with CJK chars', () {
        var original = '漢字\x1b[31m漢字\x1b[0m漢字';
        var expected = '漢字\x1b[31m漢字\x1b[0m漢…';
        expect(truncate(original, 11), expected);
      });
    });

    group('mergeOptions', () {
      test('allows you to override chars', () {
        expect(mergeOptions(), defaultOptions());
      });

      test('chars will be merged deeply', () {
        var expected = defaultOptions();
        expected['chars']['left'] = 'L';
        expect(
            mergeOptions({
              'chars': {'left': 'L'}
            }),
            expected);
      });

      test('style will be merged deeply', () {
        var expected = defaultOptions();
        expected['style']['padding-left'] = 2;
        expect(
            mergeOptions({
              'style': {'padding-left': 2}
            }),
            expected);
      });

      test('head will be overwritten', () {
        var expected = defaultOptions();
        expected['style']['head'] = [];

        expect(
            mergeOptions({
              'style': {'head': []}
            }),
            expected);
      });

      test('border will be overwritten', () {
        var expected = defaultOptions();
        expected['style']['border'] = [];

        expect(
            mergeOptions({
              'style': {'border': []}
            }),
            expected);
      });
    });

    group('wordWrap', () {
      test('length', () {
        var input = 'Hello, how are you today? I am fine, thank you!';

        var expected = 'Hello, how\nare you\ntoday? I\nam fine,\nthank you!';

        expect(wordWrap(10, input).join('\n'), expected);
      });

/*       test('length with colors', () {
        var input = chalk.red('Hello, how are') +
            chalk.blue(' you today? I') +
            chalk.green(' am fine, thank you!');

        var expected = chalk.red('Hello, how\nare') +
            chalk.blue(' you\ntoday? I') +
            chalk.green('\nam fine,\nthank you!');

        expect(wordWrap(10, input).join('\n'), expected);
      }, skip: true); */

      test('will not create an empty last line', () {
        var input = 'Hello Hello ';

        var expected = 'Hello\nHello';

        expect(wordWrap(5, input).join('\n'), expected);
      });

      test('will handle color reset code', () {
        var input = '\x1b[31mHello\x1b[0m Hello ';

        var expected = '\x1b[31mHello\x1b[0m\nHello';

        expect(wordWrap(5, input).join('\n'), expected);
      });

      test('will handle color reset code (EMPTY version)', () {
        var input = '\x1b[31mHello\x1b[m Hello ';

        var expected = '\x1b[31mHello\x1b[m\nHello';

        expect(wordWrap(5, input).join('\n'), expected);
      });

      test('words longer than limit will not create extra newlines', () {
        var input = 'disestablishment is a multiplicity someotherlongword';

        var expected = 'disestablishment\nis a\nmultiplicity\nsomeotherlongword';

        expect(wordWrap(7, input).join('\n'), expected);
      });

      test('multiple line input', () {
        var input = 'a\nb\nc d e d b duck\nm\nn\nr';
        var expected = ['a', 'b', 'c d', 'e d', 'b', 'duck', 'm', 'n', 'r'];

        expect(wordWrap(4, input), expected);
      });

      test('will not start a line with whitespace', () {
        var input = 'ab cd  ef gh  ij kl';
        var expected = ['ab cd', 'ef gh', 'ij kl'];
        expect(wordWrap(7, input), expected);
      });

      test('wraps CJK chars', () {
        var input = '漢字 漢\n字 漢字';
        var expected = ['漢字 漢', '字 漢字'];
        expect(wordWrap(7, input), expected);
      });

      test('wraps CJK chars with colors', () {
        var input = '\x1b[31m漢字\x1b[0m\n 漢字';
        var expected = ['\x1b[31m漢字\x1b[0m', ' 漢字'];
        expect(wordWrap(5, input), expected);
      });

      group('textWrap', () {
        test('wraps long words', () {
          expect(wordWrap(10, 'abcdefghijklmnopqrstuvwxyz', false), ['abcdefghij', 'klmnopqrst', 'uvwxyz']);
          expect(wordWrap(10, 'abcdefghijk lmnopqrstuv wxyz', false), ['abcdefghij', 'k lmnopqrs', 'tuv wxyz']);
          expect(wordWrap(10, 'ab cdefghijk lmnopqrstuv wx yz', false), [
            'ab cdefghi',
            'jk lmnopqr',
            'stuv wx yz',
          ]);
        });
      });
    });

    group('colorizeLines', () {
      test('foreground colors continue on each line', () {
        var input = chalk.red('Hello\nHi').split('\n');

        expect(colorizeLines(input), [chalk.red('Hello'), chalk.red('Hi')]);
      });

      test('background colors continue on each line', () {
        var input = chalk.bgRed('Hello\nHi').split('\n');

        expect(colorizeLines(input), [chalk.bgRed('Hello'), chalk.bgRed('Hi')]);
      });

      test('styles will continue on each line', () {
        var input = chalk.underline('Hello\nHi').split('\n');

        expect(colorizeLines(input), [chalk.underline('Hello'), chalk.underline('Hi')]);
      });

      test('styles that end before the break will not be applied to the next line', () {
        var input = ('${chalk.underline('Hello')}\nHi').split('\n');

        expect(colorizeLines(input), [chalk.underline('Hello'), 'Hi']);
      });

      test('the reset code can be used to drop styles', () {
        var input = '\x1b[31mHello\x1b[0m\nHi'.split('\n');
        expect(colorizeLines(input), ['\x1b[31mHello\x1b[0m', 'Hi']);
      });

      test('handles aixterm 16-color foreground', () {
        var input = '\x1b[90mHello\nHi\x1b[0m'.split('\n');
        expect(colorizeLines(input), ['\x1b[90mHello\x1b[39m', '\x1b[90mHi\x1b[0m']);
      });

      test('handles aixterm 16-color background', () {
        var input = '\x1b[100mHello\nHi\x1b[m\nHowdy'.split('\n');
        expect(colorizeLines(input), ['\x1b[100mHello\x1b[49m', '\x1b[100mHi\x1b[m', 'Howdy']);
      });

      test('handles aixterm 256-color foreground', () {
        var input = '\x1b[48;5;8mHello\nHi\x1b[0m\nHowdy'.split('\n');
        expect(colorizeLines(input), ['\x1b[48;5;8mHello\x1b[49m', '\x1b[48;5;8mHi\x1b[0m', 'Howdy']);
      });

      test('handles CJK chars', () {
        var input = chalk.red('漢字\nテスト').split('\n');

        expect(colorizeLines(input), [chalk.red('漢字'), chalk.red('テスト')]);
      });
    });

    group('hyperlink', () {
      const url = 'http://example.com';
      const text = 'hello link';
      String expected(u, t) => '\x1B]8;;$u\x07$t\x1B]8;;\x07';
      test('wraps text with link', () {
        expect(hyperlink(url, text), expected(url, text));
      });
      test('defaults text to link', () {
        expect(hyperlink(url, url), expected(url, url));
      });
    });
  });
}
