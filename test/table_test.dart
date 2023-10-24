import 'package:chalkdart/chalk.dart';
import 'package:cli_table/cli_table.dart';
import 'package:test/test.dart';

void main() {
  group(' Table ', () {
    test('wordWrap with colored text', () {
      final table = Table(
        style: TableStyle.noColor(),
        wordWrap: true,
        columnWidths: [7, 9],
      );

      table.add([chalk.keyword('red')('Hello how are you?'), chalk.keyword('blue')('I am fine thanks!')]);

      final expected = [
        '┌───────┬─────────┐',
        '│ ${chalk.keyword('red')('Hello')} │ ${chalk.keyword('blue')('I am')}    │',
        '│ ${chalk.keyword('red')('how')}   │ ${chalk.keyword('blue')('fine')}    │',
        '│ ${chalk.keyword('red')('are')}   │ ${chalk.keyword('blue')('thanks!')} │',
        '│ ${chalk.keyword('red')('you?')}  │         │',
        '└───────┴─────────┘',
      ];

      expect(table.toString(), expected.join('\n'));
    });

    test('allows numbers as `content` property of cells defined using object notation', () {
      var table = Table(
        style: TableStyle.noColor(),
      );

      table.addAll([
        [
          {'content': 12}
        ]
      ]);

      var expected = ['┌────┐', '│ 12 │', '└────┘'];

      expect(table.toString(), expected.join('\n'));
    });

    test('throws if content is not a string or number', () {
      var table = Table(style: TableStyle.noColor());

      expect(() {
        table.add([
          {
            'content': {'a': 'b'}
          }
        ]);
        table.toString();
      }, throwsException);
    });

    test('works with CJK values', () {
      final table = Table(style: TableStyle.noColor(), columnWidths: [5, 10, 5]);

      table.addAll([
        ['foobar', 'English test', 'baz'],
        ['foobar', '中文测试', 'baz'],
        ['foobar', '日本語テスト', 'baz'],
        ['foobar', '한국어테스트', 'baz']
      ]);

      final expected = [
        '┌─────┬──────────┬─────┐',
        '│ fo… │ English… │ baz │',
        '├─────┼──────────┼─────┤',
        '│ fo… │ 中文测试 │ baz │',
        '├─────┼──────────┼─────┤',
        '│ fo… │ 日本語…  │ baz │',
        '├─────┼──────────┼─────┤',
        '│ fo… │ 한국어…  │ baz │',
        '└─────┴──────────┴─────┘',
      ];

      expect(table.toString(), expected.join('\n'));
    });

    test('supports complex layouts', () {
      final table = Table(
        style: TableStyle(border: [], header: []),
      );
      table.addAll([
        [
          {'content': 'TOP', 'colSpan': 9, 'hAlign': HorizontalAlign.center}
        ],
        [
          {'content': 'TL', 'rowSpan': 4, 'vAlign': VerticalAlign.center},
          {'content': 'A1', 'rowSpan': 3},
          'B1',
          'C1',
          {'content': 'D1', 'rowSpan': 3, 'vAlign': VerticalAlign.center},
          'E1',
          'F1',
          {'content': 'G1', 'rowSpan': 3},
          {'content': 'TR', 'rowSpan': 4, 'vAlign': VerticalAlign.center},
        ],
        [
          {'rowSpan': 2, 'content': 'B2'},
          'C2',
          {'rowSpan': 2, 'colSpan': 2, 'content': 'E2'}
        ],
        ['C3'],
        [
          {'content': 'A2', 'colSpan': 7, 'hAlign': HorizontalAlign.center}
        ],
        [
          {'content': 'CLEAR', 'colSpan': 9, 'hAlign': HorizontalAlign.center}
        ],
        [
          {'content': 'BL', 'rowSpan': 4, 'vAlign': VerticalAlign.center},
          {'content': 'A3', 'colSpan': 7, 'hAlign': HorizontalAlign.center},
          {'content': 'BR', 'rowSpan': 4, 'vAlign': VerticalAlign.center},
        ],
        [
          {'content': 'A4', 'colSpan': 3, 'hAlign': HorizontalAlign.center},
          {'content': 'D2', 'rowSpan': 2, 'vAlign': VerticalAlign.center},
          {'content': 'E3', 'colSpan': 2, 'hAlign': HorizontalAlign.center},
          {'content': 'G2', 'rowSpan': 3, 'vAlign': VerticalAlign.center},
        ],
        [
          {'content': 'A5', 'rowSpan': 2, 'vAlign': VerticalAlign.center},
          {'content': 'B3', 'colSpan': 2, 'hAlign': HorizontalAlign.center},
          {'content': 'E4', 'rowSpan': 2, 'vAlign': VerticalAlign.center},
          {'content': 'F3', 'rowSpan': 2, 'vAlign': VerticalAlign.center},
        ],
        [
          'B4',
          {'content': 'C4', 'colSpan': 2, 'hAlign': HorizontalAlign.center}
        ],
        [
          {'content': 'BOTTOM', 'colSpan': 9, 'hAlign': HorizontalAlign.center}
        ]
      ]);
      const expected = [
        '┌────────────────────────────────────────────┐',
        '│                    TOP                     │',
        '├────┬────┬────┬────┬────┬────┬────┬────┬────┤',
        '│    │ A1 │ B1 │ C1 │    │ E1 │ F1 │ G1 │    │',
        '│    │    ├────┼────┤    ├────┴────┤    │    │',
        '│    │    │ B2 │ C2 │ D1 │ E2      │    │    │',
        '│ TL │    │    ├────┤    │         │    │ TR │',
        '│    │    │    │ C3 │    │         │    │    │',
        '│    ├────┴────┴────┴────┴─────────┴────┤    │',
        '│    │                A2                │    │',
        '├────┴──────────────────────────────────┴────┤',
        '│                   CLEAR                    │',
        '├────┬──────────────────────────────────┬────┤',
        '│    │                A3                │    │',
        '│    ├──────────────┬────┬─────────┬────┤    │',
        '│    │      A4      │    │   E3    │    │    │',
        '│ BL ├────┬─────────┤ D2 ├────┬────┤    │ BR │',
        '│    │    │   B3    │    │    │    │ G2 │    │',
        '│    │ A5 ├────┬────┴────┤ E4 │ F3 │    │    │',
        '│    │    │ B4 │   C4    │    │    │    │    │',
        '├────┴────┴────┴─────────┴────┴────┴────┴────┤',
        '│                   BOTTOM                   │',
        '└────────────────────────────────────────────┘',
      ];
      expect(table.toString(), expected.join('\n'));
    });
  });
}
