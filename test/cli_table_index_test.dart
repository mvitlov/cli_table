import 'package:chalkdart/chalk.dart';
import 'package:cli_table/cli_table.dart';
import 'package:test/test.dart';

void main() {
  group('cli-table index tests', () {
    test('test complete table', () {
      final table = Table(
        header: ['Rel', 'Change', 'By', 'When'],
        style: TableStyle(
          paddingLeft: 1,
          paddingRight: 1,
          header: [],
          border: [],
        ),
        columnWidths: [6, 21, 25, 17],
      );

      table.addAll([
        ['v0.1', 'Testing something cool', 'rauchg@gmail.com', '7 minutes ago'],
        ['v0.1', 'Testing something cool', 'rauchg@gmail.com', '8 minutes ago']
      ]);

      final expected = [
        '┌──────┬─────────────────────┬─────────────────────────┬─────────────────┐',
        '│ Rel  │ Change              │ By                      │ When            │',
        '├──────┼─────────────────────┼─────────────────────────┼─────────────────┤',
        '│ v0.1 │ Testing something … │ rauchg@gmail.com        │ 7 minutes ago   │',
        '├──────┼─────────────────────┼─────────────────────────┼─────────────────┤',
        '│ v0.1 │ Testing something … │ rauchg@gmail.com        │ 8 minutes ago   │',
        '└──────┴─────────────────────┴─────────────────────────┴─────────────────┘',
      ];

      expect(table.toString(), expected.join('\n'));
      //expect(table.render()).should.eql(expected.join("\n"));
    });

    test('test width property', () {
      final table = Table(
        header: ['Cool'],
        style: TableStyle.noColor(),
      );

      expect(table.width, 8);
    });

    test('test vertical table output', () {
      final table = Table(
        style: TableStyle(
          paddingLeft: 0,
          paddingRight: 0,
          header: [],
          border: [],
        ),
      ); // clear styles to prevent color output

      table.addAll([
        {'v0.1': 'Testing something cool'},
        {'v0.1': 'Testing something cool'}
      ]);

      final expected = [
        '┌────┬──────────────────────┐',
        '│v0.1│Testing something cool│',
        '├────┼──────────────────────┤',
        '│v0.1│Testing something cool│',
        '└────┴──────────────────────┘',
      ];

      expect(table.toString(), expected.join('\n'));
    });

    test('test cross table output', () {
      final table = Table(
        header: ['', 'Header 1', 'Header 2'],
        style: TableStyle(
          paddingLeft: 0,
          paddingRight: 0,
          header: [],
          border: [],
        ),
      ); // clear styles to prevent color output

      table.addAll([
        {
          'Header 3': ['v0.1', 'Testing something cool']
        },
        {
          'Header 4': ['v0.1', 'Testing something cool']
        }
      ]);

      final expected = [
        '┌────────┬────────┬──────────────────────┐',
        '│        │Header 1│Header 2              │',
        '├────────┼────────┼──────────────────────┤',
        '│Header 3│v0.1    │Testing something cool│',
        '├────────┼────────┼──────────────────────┤',
        '│Header 4│v0.1    │Testing something cool│',
        '└────────┴────────┴──────────────────────┘',
      ];

      expect(table.toString(), expected.join('\n'));
    });

    test('test table colors', () {
      final table = Table(
        header: ['Rel', 'By'],
        style: TableStyle(
          header: ['red'],
          border: ['grey'],
        ),
      );

      table.addAll([
        [chalk.keyword('orange')('v0.1'), 'rauchg@gmail.com']
      ]);

      // The expectation from the original cli-table is commented out below.
      // The output from cli-table2 will still look the same, but the border color is
      // toggled off and back on at the border of each cell.

      /*let expected = [
          grey + '┌──────┬──────────────────┐' + off
        , grey + '│' + off + red + ' Rel  ' + off + grey + '│' + off + red + ' By               ' + off + grey + '│' + off
        , grey + '├──────┼──────────────────┤' + off
        , grey + '│' + off + ' ' + c256s + ' ' + grey + '│' + off + ' rauchg@gmail.com ' + grey + '│' + off
        , grey + '└──────┴──────────────────┘' + off
      ];*/

      final expected = [
        chalk.keyword('gray')('┌──────') +
            chalk.keyword('gray')('┬──────────────────┐'),
        chalk.keyword('gray')('│') +
            chalk.keyword('red')(' Rel  ') +
            chalk.keyword('gray')('│') +
            chalk.keyword('red')(' By               ') +
            chalk.keyword('gray')('│'),
        chalk.keyword('gray')('├──────') +
            chalk.keyword('gray')('┼──────────────────┤'),
        '${chalk.keyword('gray')('│')} ${chalk.keyword('orange')('v0.1')} ${chalk.keyword('gray')('│')} rauchg@gmail.com ${chalk.keyword('gray')('│')}',
        chalk.keyword('gray')('└──────') +
            chalk.keyword('gray')('┴──────────────────┘'),
      ];

      expect(table.toString(), expected.join('\n'));
    });

    test('test custom chars', () {
      final table = Table(
        tableChars: TableChars(
          top: '═',
          topMid: '╤',
          topLeft: '╔',
          topRight: '╗',
          bottom: '═',
          bottomMid: '╧',
          bottomLeft: '╚',
          bottomRight: '╝',
          left: '║',
          leftMid: '╟',
          right: '║',
          rightMid: '╢',
        ),
        style: TableStyle.noColor(),
      );

      table.addAll([
        ['foo', 'bar', 'baz'],
        ['frob', 'bar', 'quuz']
      ]);

      final expected = [
        '╔══════╤═════╤══════╗',
        '║ foo  │ bar │ baz  ║',
        '╟──────┼─────┼──────╢',
        '║ frob │ bar │ quuz ║',
        '╚══════╧═════╧══════╝',
      ];

      expect(table.toString(), expected.join('\n'));
    });

    test('test compact shortand', () {
      final table = Table(
        style: TableStyle(
          header: [],
          border: [],
          compact: true,
        ),
      );

      table.addAll([
        ['foo', 'bar', 'baz'],
        ['frob', 'bar', 'quuz']
      ]);

      final expected = [
        '┌──────┬─────┬──────┐',
        '│ foo  │ bar │ baz  │',
        '│ frob │ bar │ quuz │',
        '└──────┴─────┴──────┘'
      ];

      expect(table.toString(), expected.join('\n'));
    });

    test('test compact empty mid line', () {
      final table = Table(
        tableChars: TableChars(
          mid: '',
          leftMid: '',
          midMid: '',
          rightMid: '',
        ),
        style: TableStyle.noColor(),
      );

      table.addAll([
        ['foo', 'bar', 'baz'],
        ['frob', 'bar', 'quuz']
      ]);

      final expected = [
        '┌──────┬─────┬──────┐',
        '│ foo  │ bar │ baz  │',
        '│ frob │ bar │ quuz │',
        '└──────┴─────┴──────┘'
      ];

      expect(table.toString(), expected.join('\n'));
    });
    test('test decoration lines disabled', () {
      final table = Table(
        tableChars: TableChars(
          top: '',
          topMid: '',
          topLeft: '',
          topRight: '',
          bottom: '',
          bottomMid: '',
          bottomLeft: '',
          bottomRight: '',
          left: '',
          leftMid: '',
          mid: '',
          midMid: '',
          right: '',
          rightMid: '',
          middle: ' ', // a single space
        ),
        style: TableStyle(
          header: [],
          border: [],
          paddingLeft: 0,
          paddingRight: 0,
        ),
      );

      table.addAll([
        ['foo', 'bar', 'baz'],
        ['frobnicate', 'bar', 'quuz']
      ]);

      final expected = ['foo        bar baz ', 'frobnicate bar quuz'];

      expect(table.toString(), expected.join('\n'));
    });

    test('test with null as values or column names', () {
      final table = Table(style: TableStyle.noColor());

      table.addAll([
        [null, null, 0]
      ]);

      // This is the expectation from the original cli-table.
      // The empty columns have widths based on the strings `null` and `undefined`
      // That does not make sense to me, so I am deviating from the original behavior here.

      /*let expected = [
          '┌──────┬───────────┬───┐'
        , '│      │           │ 0 │'
        , '└──────┴───────────┴───┘'
      ];  */

      final expected = ['┌──┬──┬───┐', '│  │  │ 0 │', '└──┴──┴───┘'];

      expect(table.toString(), expected.join('\n'));
    });
  });
}
