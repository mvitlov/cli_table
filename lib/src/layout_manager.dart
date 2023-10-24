import 'dart:math' as math;

import 'cell/cell.dart';
import 'cell/col_span_cell.dart';
import 'cell/row_span_cell.dart';

int _next(Map<int, int> alloc, int col) {
  if (alloc[col] != null && alloc[col]! > 0) {
    return _next(alloc, col + 1);
  }
  return col;
}

void layoutTable(List<List<ICell>> table) {
  var alloc = <int, int>{};
  var rowIndex = -1;
  for (var row in table) {
    rowIndex++;
    var col = 0;
    for (var cell in row) {
      cell['y'] = rowIndex;
      // Avoid erroneous call to next() on first row
      cell['x'] = rowIndex != 0 ? _next(alloc, col) : col;
      final rowSpan = cell['rowSpan'];
      final colSpan = cell['colSpan'];
      if (rowSpan > 1) {
        for (var cs = 0; cs < colSpan; cs++) {
          alloc[cell['x'] + cs] = rowSpan;
        }
      }
      col = cell['x'] + colSpan;
    }
    for (var idx in [...alloc.keys]) {
      alloc[idx] = alloc[idx]! - 1;
      if (alloc[idx]! < 1) alloc.remove(idx);
    }
  }
}

int maxWidth(List<List<ICell>> table) {
  var mw = 0;
  for (var row in table) {
    for (var cell in row) {
      mw = math.max(mw, cell['x'] + (cell['colSpan']));
    }
  }
  return mw;
}

int _maxHeight(table) {
  return table.length;
}

bool _cellsConflict(Map cell1, Cell cell2) {
  var yMin1 = cell1['y'];
  var yMax1 = cell1['y'] - 1 + (cell1['rowSpan'] ?? 1);
  var yMin2 = cell2['y'];
  var yMax2 = cell2['y'] - 1 + (cell2['rowSpan']);
  var yConflict = !(yMin1 > yMax2 || yMin2 > yMax1);

  var xMin1 = cell1['x'];
  var xMax1 = cell1['x'] - 1 + (cell1['colSpan'] ?? 1);
  var xMin2 = cell2['x'];
  var xMax2 = cell2['x'] - 1 + (cell2['colSpan']);
  var xConflict = !(xMin1 > xMax2 || xMin2 > xMax1);

  return yConflict && xConflict;
}

bool _conflictExists(rows, x, y) {
  int iMax = math.min(rows.length - 1, y);
  var cell = {'x': x, 'y': y};
  for (var i = 0; i <= iMax; i++) {
    var row = rows[i];
    for (var j = 0; j < row.length; j++) {
      if (_cellsConflict(cell, row[j])) {
        return true;
      }
    }
  }
  return false;
}

bool _allBlank(rows, y, xMin, xMax) {
  for (var x = xMin; x < xMax; x++) {
    if (_conflictExists(rows, x, y)) {
      return false;
    }
  }
  return true;
}

void addRowSpanCells(List<List<ICell>> table) {
  var rowIndex = -1;
  for (var row in table) {
    rowIndex++;
    for (var cell in row) {
      for (var i = 1; i < (cell['rowSpan'] ?? 0); i++) {
        var rowSpanCell = RowSpanCell(cell);
        rowSpanCell['x'] = cell['x'] ?? 0;
        rowSpanCell['y'] = (cell['y'] ?? 0) + i;
        rowSpanCell['colSpan'] = cell['colSpan'];
        table[rowIndex + i] = _insertCell(rowSpanCell, table[rowIndex + i]);
      }
    }
  }
}

void _addColSpanCells(List<List<ICell>> cellRows) {
  for (var rowIndex = cellRows.length - 1; rowIndex >= 0; rowIndex--) {
    var cellColumns = cellRows[rowIndex];
    for (var columnIndex = 0; columnIndex < cellColumns.length; columnIndex++) {
      var cell = cellColumns[columnIndex];
      for (var k = 1; k < (cell['colSpan'] ?? 0); k++) {
        var colSpanCell = ColSpanCell();
        colSpanCell['x'] = cell['x'] + k;
        colSpanCell['y'] = cell['y'];
        cellColumns.replaceRange(columnIndex + 1, columnIndex + 1, [colSpanCell]);
      }
    }
  }
}

List<ICell> _insertCell(ICell cell, List<ICell> row) {
  row = List<ICell>.from(row);
  var x = 0;
  while (x < row.length && (row[x]['x'] ?? 0) < cell['x']) {
    x++;
  }

  return row.cast<ICell>().splice(x, 0, cell);
}

void fillInTable(List<List<ICell>> table) {
  var hMax = _maxHeight(table);
  var wMax = maxWidth(table);

  for (var y = 0; y < hMax; y++) {
    for (var x = 0; x < wMax; x++) {
      if (!_conflictExists(table, x, y)) {
        var opts = {'x': x, 'y': y, 'colSpan': 1, 'rowSpan': 1};
        x++;
        while (x < wMax && !_conflictExists(table, x, y)) {
          opts['colSpan'] = opts['colSpan']! + 1;
          x++;
        }
        var y2 = y + 1;
        while (y2 < hMax && _allBlank(table, y2, opts['x'], opts['x']! + opts['colSpan']!)) {
          opts['rowSpan'] = opts['rowSpan']! + 1;
          y2++;
        }
        var cell = Cell(opts);
        cell['x'] = opts['x']!;
        cell['y'] = opts['y']!;

        table[y] = _insertCell(cell, table[y]);
      }
    }
  }
}

List<List<ICell>> _generateCells(List<dynamic> rows) {
  return rows.map((row) {
    if (row is! List) {
      var key = (row.keys).elementAt(0);
      row = row[key];
      if (row is List) {
        row = row.sublist(0);
        row.insert(0, key);
      } else {
        row = [key, row];
      }
    }
    return row.map<ICell>((cell) {
      return Cell(cell);
    }).toList();
  }).toList();
}

List<List<ICell>> makeTableLayout(List rows) {
  var cellRows = _generateCells(rows);

  layoutTable(cellRows);
  fillInTable(cellRows);
  addRowSpanCells(cellRows);
  _addColSpanCells(cellRows);
  return cellRows;
}

final computeWidths = makeComputeWidths('colSpan', 'desiredWidth', 'x', 1);
final computeHeights = makeComputeWidths('rowSpan', 'desiredHeight', 'y', 1);

List<int> Function(List<int?>, List<List<ICell>>) makeComputeWidths(
    String colSpan, String desiredWidth, String x, int forcedMin) {
  return (vals, table) {
    var result = <int?>[];
    var spanners = <ICell>[];
    var auto = {};
    for (var row in table) {
      for (var cell in row) {
        if ((cell[colSpan] ?? 1) > 1) {
          spanners.add(cell);
        } else {
          var res =
              math.max<int>(result.elementAtOrNull(cell[x]) ?? 0, math.max<int>(cell[desiredWidth] ?? 0, forcedMin));

          try {
            result[cell[x]] = res;
          } catch (e) {
            while (result.length <= cell[x]) {
              result.add(null);
            }
            result[cell[x]] = res;
          }
        }
      }
    }

    var index = -1;
    for (var val in vals) {
      index++;
      if (val is int) {
        result[index] = val;
      }
    }

    //spanners.forEach(function(cell){
    for (var k = spanners.length - 1; k >= 0; k--) {
      var cell = spanners[k];
      var span = cell[colSpan];
      var col = cell[x];
      var existingWidth = result[col];
      var editableCols = vals.elementAtOrNull(col) is int ? 0 : 1;
      if (existingWidth is int) {
        for (var i = 1; i < span; i++) {
          existingWidth = existingWidth! + 1 + result[col + i]!;
          if (vals.elementAtOrNull(col + i) is! int) {
            editableCols++;
          }
        }
      } else {
        existingWidth = desiredWidth == 'desiredWidth' ? cell['desiredWidth'] - 1 : 1;
        if (auto[col] == null || auto[col] == 0 || auto[col] < existingWidth) {
          auto[col] = existingWidth;
        }
      }

      if ((cell[desiredWidth] ?? 0) > existingWidth) {
        var i = 0;
        while (editableCols > 0 && cell[desiredWidth] > existingWidth) {
          if (vals.elementAtOrNull(col + i) is! int) {
            var dif = (((cell[desiredWidth] as int) - existingWidth!) / editableCols).round();
            existingWidth += dif;
            result[col + i] = result[col + i]! + dif;
            editableCols--;
          }
          i++;
        }
      }
    }

    // Object.assign(vals, result, auto);
    vals = result;
    // vals = [...vals, ...result, ...auto.values];
    for (var j = 0; j < vals.length; j++) {
      vals[j] = math.max<int>(forcedMin, vals.elementAtOrNull(j) ?? 0);
    }
    return vals.cast<int>();
  };
}

extension ListExtensions<T> on List<T> {
  List<T> splice(int start, [int deleteCount = 0, T? replacement]) {
    removeRange(start, start + deleteCount);

    if (replacement != null) {
      insert(start, replacement);
    }

    return this;
  }
}
