import 'package:cli_table/cli_table.dart';

import 'package:test/test.dart';

void main() {
  group('cli_table newline tests', () {
    test('test table with newlines in headers', () {
      final table = Table(
        header: ['Test', '1\n2\n3'],
        style: TableStyle(
          paddingLeft: 1,
          paddingRight: 1,
          header: [],
          border: [],
        ),
      );

      final expected = [
        '┌──────┬───┐',
        '│ Test │ 1 │',
        '│      │ 2 │',
        '│      │ 3 │',
        '└──────┴───┘'
      ];

      expect(table.toString(), expected.join('\n'));
    });

    test('test column width is accurately reflected when newlines are present',
        () {
      final table = Table(header: ['Test\nWidth'], style: TableStyle.noColor());
      expect(table.width, 9);
    });

    test('test newlines in body cells', () {
      final table = Table(style: TableStyle.noColor());

      table.addAll([
        ['something\nwith\nnewlines']
      ]);

      final expected = [
        '┌───────────┐',
        '│ something │',
        '│ with      │',
        '│ newlines  │',
        '└───────────┘'
      ];

      expect(table.toString(), expected.join('\n'));
    });

    test('test newlines in vertical cell header and body', () {
      final table = Table(
        style: TableStyle(
          paddingLeft: 0,
          paddingRight: 0,
          header: [],
          border: [],
        ),
      );

      table.addAll([
        {'v\n0.1': 'Testing\nsomething cool'}
      ]);

      final expected = [
        '┌───┬──────────────┐',
        '│v  │Testing       │',
        '│0.1│something cool│',
        '└───┴──────────────┘'
      ];

      expect(table.toString(), expected.join('\n'));
    });

    test('test newlines in cross table header and body', () {
      final table = Table(
        header: ['', 'Header\n1'],
        style: TableStyle(
          paddingLeft: 0,
          paddingRight: 0,
          header: [],
          border: [],
        ),
      );

      table.addAll([
        {
          'Header\n2': ['Testing\nsomething\ncool']
        }
      ]);

      final expected = [
        '┌──────┬─────────┐',
        '│      │Header   │',
        '│      │1        │',
        '├──────┼─────────┤',
        '│Header│Testing  │',
        '│2     │something│',
        '│      │cool     │',
        '└──────┴─────────┘',
      ];

      expect(table.toString(), expected.join('\n'));
    });
  });
}
