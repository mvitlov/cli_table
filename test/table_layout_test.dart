import 'package:cli_table/src/cell/cell.dart';
import 'package:cli_table/src/cell/row_span_cell.dart';
import 'package:cli_table/src/layout_manager.dart';
import 'package:test/test.dart';

void main() {
  group('table_layout', () {
    test('simple 2x2 layout', () {
      var actual = makeTableLayout([
        ['hello', 'goodbye'],
        ['hola', 'adios'],
      ]);

      var expected = [
        ['hello', 'goodbye'],
        ['hola', 'adios'],
      ];

      checkLayout(actual, expected);
    });

    test('cross table', () {
      var actual = makeTableLayout([
        {
          '1.0': ['yes', 'no']
        },
        {
          '2.0': ['hello', 'goodbye']
        }
      ]);

      var expected = [
        ['1.0', 'yes', 'no'],
        ['2.0', 'hello', 'goodbye'],
      ];

      checkLayout(actual, expected);
    });

    test('vertical table', () {
      var actual = makeTableLayout([
        {'1.0': 'yes'},
        {'2.0': 'hello'}
      ]);

      var expected = [
        ['1.0', 'yes'],
        ['2.0', 'hello'],
      ];

      checkLayout(actual, expected);
    });

    test('colSpan adds RowSpanCells to the right', () {
      var actual = makeTableLayout([
        [
          {'content': 'hello', 'colSpan': 2}
        ],
        ['hola', 'adios']
      ]);

      var expected = [
        [
          {'content': 'hello', 'colSpan': 2},
          null
        ],
        ['hola', 'adios'],
      ];

      checkLayout(actual, expected);
    });

    test('rowSpan adds RowSpanCell below', () {
      var actual = makeTableLayout([
        [
          {'content': 'hello', 'rowSpan': 2},
          'goodbye'
        ],
        ['adios']
      ]);

      var expected = [
        ['hello', 'goodbye'],
        [
          {
            'spannerFor': [0, 0]
          },
          'adios'
        ],
      ];

      checkLayout(actual, expected);
    });

    test('rowSpan and cellSpan together', () {
      var actual = makeTableLayout([
        [
          {'content': 'hello', 'rowSpan': 2, 'colSpan': 2},
          'goodbye'
        ],
        ['adios']
      ]);

      var expected = [
        ['hello', null, 'goodbye'],
        [
          {
            'spannerFor': [0, 0]
          },
          null,
          'adios'
        ],
      ];

      checkLayout(actual, expected);
    });

    test('complex layout', () {
      final actual = makeTableLayout([
        [
          {'content': 'hello', 'rowSpan': 2, 'colSpan': 2},
          {'content': 'yo', 'rowSpan': 2, 'colSpan': 2},
          'goodbye'
        ],
        ['adios'],
      ]);

      final expected = [
        ['hello', null, 'yo', null, 'goodbye'],
        [
          {
            'spannerFor': [0, 0]
          },
          null,
          {
            'spannerFor': [0, 2]
          },
          null,
          'adios'
        ],
      ];

      checkLayout(actual, expected);
    });

    test('complex layout2', () {
      final actual = makeTableLayout([
        [
          'a',
          'b',
          {'content': 'c', 'rowSpan': 3, 'colSpan': 2},
          'd'
        ],
        [
          {'content': 'e', 'rowSpan': 2, 'colSpan': 2},
          'f'
        ],
        ['g'],
      ]);

      final expected = [
        ['a', 'b', 'c', null, 'd'],
        [
          'e',
          null,
          {
            'spannerFor': [0, 2]
          },
          null,
          'f'
        ],
        [
          {
            'spannerFor': [1, 0]
          },
          null,
          {
            'spannerFor': [0, 2]
          },
          null,
          'g'
        ],
      ];

      checkLayout(actual, expected);
    });

    test('stairstep spans', () {
      final actual = makeTableLayout([
        [
          {'content': '', 'rowSpan': 2},
          ''
        ],
        [
          {'content': '', 'rowSpan': 2}
        ],
        ['']
      ]);

      final expected = [
        [
          {'content': '', 'rowSpan': 2},
          ''
        ],
        [
          {
            'spannerFor': [0, 0]
          },
          {'content': '', 'rowSpan': 2}
        ],
        [
          '',
          {
            'spannerFor': [1, 1]
          }
        ],
      ];

      checkLayout(actual, expected);
    });

    group('fillInTable', () {
      ICell mc(opts, y, x) {
        final cell = Cell(opts);
        cell['x'] = x;
        cell['y'] = y;
        return cell;
      }

      test('will blank out individual cells', () {
        final cells = <List<ICell>>[
          [mc('a', 0, 1)],
          [mc('b', 1, 0)]
        ];
        fillInTable(cells);

        checkLayout(cells, [
          ['', 'a'],
          ['b', ''],
        ]);
      });

      test('will autospan to the right', () {
        var cells = <List<ICell>>[
          [],
          [mc('a', 1, 1)]
        ];
        fillInTable(cells);

        checkLayout(cells, [
          [
            {'content': '', 'colSpan': 2},
            null
          ],
          ['', 'a'],
        ]);
      });

      test('will autospan down', () {
        final cells = <List<ICell>>[
          [mc('a', 0, 1)],
          []
        ];
        fillInTable(cells);
        addRowSpanCells(cells);

        checkLayout(cells, [
          [
            {'content': '', 'rowSpan': 2},
            'a'
          ],
          [
            {
              'spannerFor': [0, 0]
            },
            ''
          ],
        ]);
      });

      test('will autospan right and down', () {
        final cells = <List<ICell>>[
          [mc('a', 0, 2)],
          [],
          [mc('b', 2, 1)]
        ];
        fillInTable(cells);
        addRowSpanCells(cells);

        checkLayout(cells, [
          [
            {'content': '', 'colSpan': 2, 'rowSpan': 2},
            null,
            'a'
          ],
          [
            {
              'spannerFor': [0, 0]
            },
            null,
            {'content': '', 'colSpan': 1, 'rowSpan': 2}
          ],
          [
            '',
            'b',
            {
              'spannerFor': [1, 2]
            }
          ],
        ]);
      });
    });

    group('computeWidths', () {
      ICell mc(y, x, [desiredWidth, colSpan]) {
        return Cell()..addAll({'x': x, 'y': y, 'desiredWidth': desiredWidth, 'colSpan': colSpan});
      }

      test('finds the maximum desired width of each column', () {
        final cells = <List<ICell>>[
          [mc(0, 0, 7), mc(0, 1, 3), mc(0, 2, 5)],
          [mc(1, 0, 8), mc(1, 1, 5), mc(1, 2, 2)],
          [mc(2, 0, 6), mc(2, 1, 9), mc(2, 2, 1)],
        ];

        final widths = computeWidths([], cells);

        expect(widths, [8, 9, 5]);
      });

      test("won't touch hard coded values", () {
        final cells = <List<ICell>>[
          [mc(0, 0, 7), mc(0, 1, 3), mc(0, 2, 5)],
          [mc(1, 0, 8), mc(1, 1, 5), mc(1, 2, 2)],
          [mc(2, 0, 6), mc(2, 1, 9), mc(2, 2, 1)],
        ];

        final widths = computeWidths([null, 3], cells);

        expect(widths, [8, 3, 5]);
      });

      test('assumes undefined desiredWidth is 1', () {
        final cells = <List<ICell>>[
          [mc(0, 0)],
          [mc(1, 0)],
          [mc(2, 0)]
        ];
        final widths = computeWidths([], cells);
        expect(widths, [1]);
      });

      test('takes into account colSpan and wont over expand', () {
        final cells = <List<ICell>>[
          [mc(0, 0, 10, 2), mc(0, 2, 5)],
          [mc(1, 0, 5), mc(1, 1, 5), mc(1, 2, 2)],
          [mc(2, 0, 4), mc(2, 1, 2), mc(2, 2, 1)],
        ];
        final widths = computeWidths([], cells);
        expect(widths, [5, 5, 5]);
      });

      test('will expand rows involved in colSpan in a balanced way', () {
        var cells = <List<ICell>>[
          [mc(0, 0, 13, 2), mc(0, 2, 5)],
          [mc(1, 0, 5), mc(1, 1, 5), mc(1, 2, 2)],
          [mc(2, 0, 4), mc(2, 1, 2), mc(2, 2, 1)],
        ];
        final widths = computeWidths([], cells);
        expect(widths, [6, 6, 5]);
      });

      test('expands across 3 cols', () {
        final cells = [
          [mc(0, 0, 25, 3)],
          [mc(1, 0, 5), mc(1, 1, 5), mc(1, 2, 2)],
          [mc(2, 0, 4), mc(2, 1, 2), mc(2, 2, 1)]
        ];
        final widths = computeWidths([], cells);
        expect(widths, [9, 9, 5]);
      });

      test('multiple spans in same table', () {
        final cells = [
          [mc(0, 0, 25, 3)],
          [mc(1, 0, 30, 3)],
          [mc(2, 0, 4), mc(2, 1, 2), mc(2, 2, 1)]
        ];
        final widths = computeWidths([], cells);
        expect(widths, [11, 9, 8]);
      });

      test('spans will only edit uneditable tables', () {
        final cells = [
          [mc(0, 0, 20, 3)],
          [mc(1, 0, 4), mc(1, 1, 20), mc(1, 2, 5)]
        ];
        final widths = computeWidths([null, 3], cells);
        expect(widths, [7, 3, 8]);
      });

      test('spans will only edit uneditable tables - first column uneditable', () {
        final cells = [
          [mc(0, 0, 20, 3)],
          [mc(1, 0, 4), mc(1, 1, 3), mc(1, 2, 5)]
        ];
        final widths = computeWidths([3], cells);
        expect(widths, [3, 7, 8]);
      });
    });

    group('computeHeights', () {
      ICell mc(y, x, [desiredHeight, colSpan]) {
        return Cell()..addAll({'x': x, 'y': y, 'desiredHeight': desiredHeight, 'rowSpan': colSpan});
      }

      test('finds the maximum desired height of each row', () {
        final cells = [
          [mc(0, 0, 7), mc(0, 1, 3), mc(0, 2, 5)],
          [mc(1, 0, 8), mc(1, 1, 5), mc(1, 2, 2)],
          [mc(2, 0, 6), mc(2, 1, 9), mc(2, 2, 1)],
        ];

        final heights = computeHeights([], cells);

        expect(heights, [7, 8, 9]);
      });

      test("won't touch hard coded values", () {
        final cells = [
          [mc(0, 0, 7), mc(0, 1, 3), mc(0, 2, 5)],
          [mc(1, 0, 8), mc(1, 1, 5), mc(1, 2, 2)],
          [mc(2, 0, 6), mc(2, 1, 9), mc(2, 2, 1)],
        ];

        final heights = computeHeights([null, 3], cells);

        expect(heights, [7, 3, 9]);
      });

      test('assumes undefined desiredHeight is 1', () {
        final cells = [
          [
            mc(0, 0),
            mc(0, 1),
            mc(0, 2),
          ],
        ];
        final heights = computeHeights([], cells);
        expect(heights, [1]);
      });

      test('takes into account rowSpan and wont over expand', () {
        final cells = [
          [mc(0, 0, 10, 2), mc(0, 1, 5), mc(0, 2, 2)],
          [mc(1, 1, 5), mc(1, 2, 2)],
          [mc(2, 0, 4), mc(2, 1, 2), mc(2, 2, 1)],
        ];
        final heights = computeHeights([], cells);
        expect(heights, [5, 5, 4]);
      });

      test('will expand rows involved in rowSpan in a balanced way', () {
        final cells = [
          [mc(0, 0, 13, 2), mc(0, 1, 5), mc(0, 2, 5)],
          [mc(1, 1, 5), mc(1, 2, 2)],
          [mc(2, 0, 4), mc(2, 1, 2), mc(2, 2, 1)],
        ];
        final heights = computeHeights([], cells);
        expect(heights, [6, 6, 4]);
      });

      test('expands across 3 rows', () {
        final cells = [
          [mc(0, 0, 25, 3), mc(0, 1, 5), mc(0, 2, 4)],
          [mc(1, 1, 5), mc(1, 2, 2)],
          [mc(2, 1, 2), mc(2, 2, 1)],
        ];
        final heights = computeHeights([], cells);
        expect(heights, [9, 9, 5]);
      });

      test('multiple spans in same table', () {
        final cells = [
          [mc(0, 0, 25, 3), mc(0, 1, 30, 3), mc(0, 2, 4)],
          [mc(1, 2, 2)],
          [mc(2, 2, 1)]
        ];
        final heights = computeHeights([], cells);
        expect(heights, [11, 9, 8]);
      });
    });
  });
}

/// Provides a shorthand for validating a table of cells.
/// To pass, both arrays must have the same dimensions, and each cell in `actualRows` must
/// satisfy the shorthand assertion of the corresponding location in `expectedRows`.
void checkLayout(List<List<ICell>> actualTable, List<List> expectedTable) {
  var y = -1;
  for (var expectedRow in expectedTable) {
    y++;
    var x = -1;
    for (var expectedCell in expectedRow) {
      x++;
      if (expectedCell != null) {
        final actualCell = findCell(actualTable, x, y);
        checkExpectation(actualCell!, expectedCell, x, y, actualTable);
      }
    }
  }
}

ICell? findCell(List<List<ICell>> table, int x, int y) {
  for (var i = 0; i < table.length; i++) {
    var row = table[i];
    for (var j = 0; j < row.length; j++) {
      var cell = row[j];
      if (cell['x'] == x && cell['y'] == y) {
        return cell;
      }
    }
  }
  return null;
}

void checkExpectation(ICell actualCell, dynamic expected, x, y, actualTable) {
  Map expectedCell = expected is String ? {'content': expected} : expected;

  if (expectedCell.containsKey('content')) {
    expect(actualCell, isA<Cell>());
    expect(actualCell['content'], expectedCell['content']);
  }
  if (expectedCell.containsKey('rowSpan')) {
    expect(actualCell, isA<Cell>());
    expect(actualCell['rowSpan'], expectedCell['rowSpan']);
  }
  if (expectedCell.containsKey('colSpan')) {
    expect(actualCell, isA<Cell>());
    expect(actualCell['colSpan'], expectedCell['colSpan']);
  }
  if (expectedCell.containsKey('spannerFor')) {
    expect(actualCell, isA<RowSpanCell>());
    expect((actualCell as RowSpanCell).originalCell, isA<Cell>());
    expect(
        actualCell.originalCell, findCell(actualTable, expectedCell['spannerFor'][1], expectedCell['spannerFor'][0]));
    // retest here x,y coords
  }
}
