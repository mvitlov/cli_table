import 'package:cli_table/src/cell/cell.dart';
import 'package:cli_table/src/cell/row_span_cell.dart';
import 'package:cli_table/src/layout_manager.dart';
import 'package:test/test.dart';

void main() {
  group('layout_manager', () {
    group('layoutTable', () {
      test('sets x and y', () {
        var table = [
          [Cell(), Cell()],
          [Cell(), Cell()],
        ];

        layoutTable(table);

        expect(table[0][0]['x'], 0);
        expect(table[0][0]['y'], 0);
        expect(table[0][1]['x'], 1);
        expect(table[0][1]['y'], 0);

        expect(table[1][0]['x'], 0);
        expect(table[1][0]['y'], 1);
        expect(table[1][1]['x'], 1);
        expect(table[1][1]['y'], 1);

        final w = maxWidth(table);
        expect(w, 2);
      });

      test('colSpan will push x values to the right', () {
        final table = [
          [
            Cell({'colSpan': 2}),
            Cell()
          ],
          [
            Cell(),
            Cell({'colSpan': 2})
          ],
        ];

        layoutTable(table);

        expect(table[0][0]['x'], 0);
        expect(table[0][0]['y'], 0);
        expect(table[0][0]['colSpan'], 2);

        expect(table[0][1]['x'], 2);
        expect(table[0][1]['y'], 0);

        expect(table[1][0]['x'], 0);
        expect(table[1][0]['y'], 1);
        expect(table[1][1]['x'], 1);
        expect(table[1][1]['y'], 1);
        expect(table[1][1]['colSpan'], 2);

        expect(maxWidth(table), 3);
      });

      test('rowSpan will push x values on cells below', () {
        final table = [
          [
            Cell({'rowSpan': 2}),
            Cell()
          ],
          [
            Cell(),
          ]
        ];

        layoutTable(table);

        expect(table[0][0]['x'], 0);
        expect(table[0][0]['y'], 0);
        expect(table[0][0]['rowSpan'], 2);

        expect(table[0][1]['x'], 1);
        expect(table[0][1]['y'], 0);

        expect(table[1][0]['x'], 1);
        expect(table[1][0]['y'], 1);

        expect(maxWidth(table), 2);
      });

      test('colSpan and rowSpan together', () {
        final table = [
          [
            Cell({'rowSpan': 2, 'colSpan': 2}),
            Cell()
          ],
          [Cell()]
        ];

        layoutTable(table);

        expect(table[0][0]['x'], 0);
        expect(table[0][0]['y'], 0);
        expect(table[0][0]['rowSpan'], 2);
        expect(table[0][0]['colSpan'], 2);

        expect(table[0][1]['x'], 2);
        expect(table[0][1]['y'], 0);

        expect(table[1][0]['x'], 2);
        expect(table[1][0]['y'], 1);

        expect(maxWidth(table), 3);
      });

      test('complex layout', () {
        final table = [
          [
            Cell(),
            Cell(),
            Cell({'rowSpan': 3, 'colSpan': 2}),
            Cell(),
          ],
          [
            Cell({'rowSpan': 2, 'colSpan': 2}),
            Cell()
          ],
          [Cell()],
        ];

        layoutTable(table);

        expect(table[0][0]['y'], 0);
        expect(table[0][0]['x'], 0);

        expect(table[0][1]['y'], 0);
        expect(table[0][1]['x'], 1);

        expect(table[0][2]['y'], 0);
        expect(table[0][2]['x'], 2);
        expect(table[0][2]['rowSpan'], 3);
        expect(table[0][2]['colSpan'], 2);

        expect(table[0][3]['y'], 0);
        expect(table[0][3]['x'], 4);

        expect(table[1][0]['y'], 1);
        expect(table[1][0]['x'], 0);
        expect(table[1][0]['rowSpan'], 2);
        expect(table[1][0]['colSpan'], 2);

        expect(table[1][1]['y'], 1);
        expect(table[1][1]['x'], 4);

        expect(table[2][0]['y'], 2);
        expect(table[2][0]['x'], 4);
      });

      test('complex layout 2', () {
        final table = [
          [
            Cell({'rowSpan': 3}),
            Cell({'rowSpan': 2}),
            Cell({'colSpan': 2}),
            Cell({'rowSpan': 2}),
          ],
          [Cell(), Cell()],
          [Cell(), Cell(), Cell(), Cell()],
          [Cell(), Cell(), Cell(), Cell(), Cell()],
        ];

        layoutTable(table);

        expect(table[0][0]['x'], 0);
        expect(table[0][0]['y'], 0);
        expect(table[0][0]['rowSpan'], 3);
        expect(table[0][1]['x'], 1);
        expect(table[0][1]['y'], 0);
        expect(table[0][1]['rowSpan'], 2);
        expect(table[0][2]['x'], 2);
        expect(table[0][2]['y'], 0);
        expect(table[0][2]['colSpan'], 2);
        expect(table[0][3]['x'], 4);
        expect(table[0][3]['y'], 0);
        expect(table[0][3]['rowSpan'], 2);

        expect(table[1][0]['x'], 2);
        expect(table[1][0]['y'], 1);
        expect(table[1][1]['x'], 3);
        expect(table[1][1]['y'], 1);

        expect(table[2][0]['x'], 1);
        expect(table[2][0]['y'], 2);
        expect(table[2][1]['x'], 2);
        expect(table[2][1]['y'], 2);
        expect(table[2][2]['x'], 3);
        expect(table[2][2]['y'], 2);
        expect(table[2][3]['x'], 4);
        expect(table[2][3]['y'], 2);

        expect(table[3][0]['x'], 0);
        expect(table[3][0]['y'], 3);
        expect(table[3][1]['x'], 1);
        expect(table[3][1]['y'], 3);
        expect(table[3][2]['x'], 2);
        expect(table[3][2]['y'], 3);
        expect(table[3][3]['x'], 3);
        expect(table[3][3]['y'], 3);
        expect(table[3][4]['x'], 4);
        expect(table[3][4]['y'], 3);
      });

      test('maxWidth of single element', () {
        final table = [
          [Cell()]
        ];
        layoutTable(table);
        expect(maxWidth(table), 1);
      });
    });

    group('addRowSpanCells', () {
      test('will insert a rowSpan cell - beginning of line', () {
        final table = [
          <ICell>[
            Cell({'x': 0, 'y': 0, 'rowSpan': 2}),
            Cell({'x': 1, 'y': 0}),
          ],
          <ICell>[
            Cell({'x': 1, 'y': 1})
          ],
        ];

        addRowSpanCells(table);

        expect(table[0][0]['rowSpan'], 2);

        expect(table[1].length, 2);
        expect(table[1][0], isA<RowSpanCell>());
      });

      test('will insert a rowSpan cell - end of line', () {
        final table = [
          <ICell>[
            Cell()..addAll({'x': 0, 'y': 0}),
            Cell({'rowSpan': 2})..addAll({'x': 1, 'y': 0}),
          ],
          <ICell>[
            Cell()..addAll({'x': 0, 'y': 1})
          ],
        ];

        addRowSpanCells(table);

        expect(table[0].length, 2);
        expect(table[0][1]['rowSpan'], 2);

        expect(table[1].length, 2);
        expect(table[1][1], isA<RowSpanCell>());
      });

      test('will insert a rowSpan cell - middle of line', () {
        final table = <List<ICell>>[
          [
            Cell()..addAll({'x': 0, 'y': 0}),
            Cell({'rowSpan': 2})..addAll({'x': 1, 'y': 0}),
            Cell()..addAll({'x': 2, 'y': 0}),
          ],
          [
            Cell()..addAll({'x': 0, 'y': 1}),
            Cell()..addAll({'x': 2, 'y': 1}),
          ],
        ];

        addRowSpanCells(table);

        expect(table[0].length, 3);
        expect(table[0][1]['rowSpan'], 2);

        expect(table[1].length, 3);
        expect(table[1][1], isA<RowSpanCell>());
      });

      test('will insert a rowSpan cell - multiple on the same line', () {
        final table = <List<ICell>>[
          [
            Cell()..addAll({'x': 0, 'y': 0}),
            Cell({'rowSpan': 2})..addAll({'x': 1, 'y': 0}),
            Cell({'rowSpan': 2})..addAll({'x': 2, 'y': 0}),
            Cell()..addAll({'x': 3, 'y': 0}),
          ],
          [
            Cell()..addAll({'x': 0, 'y': 1}),
            Cell()..addAll({'x': 3, 'y': 1}),
          ],
        ];

        addRowSpanCells(table);

        expect(table[0].length, 4);
        expect(table[0][1]['rowSpan'], 2);
        expect(table[0][2]['rowSpan'], 2);

        expect(table[1].length, 4);
        expect(table[1][1], isA<RowSpanCell>());
        expect(table[1][2], isA<RowSpanCell>());
      });
    });
  });
}
