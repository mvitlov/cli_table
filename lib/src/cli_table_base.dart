import 'dart:collection';

import 'cell/cell.dart';
import 'layout_manager.dart' as layout;
import 'options.dart';
import 'utils.dart' as utils;

/// Used to render a tabular data inside terminal.
///
/// Usage:
/// ```dart
/// import 'package:cli_table/cli_table.dart';
/// void main() {
///   final table = Table(
///     header: ['Rel', 'Change', "By", "When"], // Set headers
///     columnWidths: [10, 20, 20, 30], // Optionally set column widhts
///   );
///
///   // Table class extends dart List,
///   // so you're free to use all the usual List methods
///   table
///     ..add(['v0.1', 'First test', 'someone@gmail.com', '9 minutes ago'])
///     ..add(['v0.1', 'Second test', 'other@gmail.com', '13 minutes ago']);
///
///   // Call `toString()` to render the final table for output
///   print(table.toString());
/// }
/// ```
class Table extends ListBase<dynamic> {
  final Map<String, dynamic> options = {};

  /// Constructor
  ///
  /// Params:
  /// - `tableChars` param enables you to change table borders
  ///   and separators
  /// - `truncateChar` - set the content truncate character (defautls to `…`)
  /// - `columnWidths` - set fixed column widhts
  /// - `rowHeights` - set fixed row heights
  /// - `columnAlignment` - set fixed column horizontal alignments
  /// - `rowAlignment` - set fixed row vertical alignments
  /// - `style` - set table styles such as padding, border color, header color etc.
  /// - `header` - set table header row, the one that gets rendered first
  /// - `wordWrap` - wrap content on word boundaries
  /// - `wrapOnWordBoundary` - if set to `false`, it will ignore word boundaries
  Table({
    TableChars? tableChars,
    String? truncateChar,
    List<int>? columnWidths,
    List<int>? rowHeights,
    List<HorizontalAlign?>? columnAlignment,
    List<VerticalAlign?>? rowAlignment,
    TableStyle? style,
    List<dynamic>? header,
    bool? wordWrap,
    bool? wrapOnWordBoundary,
  }) {
    final opts = <String, dynamic>{};

    if (tableChars != null) opts['chars'] = tableChars.toMap();
    if (truncateChar != null) opts['truncate'] = truncateChar;
    if (columnWidths != null) opts['colWidths'] = columnWidths;
    if (rowHeights != null) opts['rowHeights'] = rowHeights;
    if (columnAlignment != null) opts['colAligns'] = columnAlignment;
    if (rowAlignment != null) opts['rowAligns'] = rowAlignment;
    if (style != null) opts['style'] = style.toMap();
    if (header != null) opts['head'] = header;
    if (wordWrap != null) opts['wordWrap'] = wordWrap;
    if (wrapOnWordBoundary != null) {
      opts['wrapOnWordBoundary'] = wrapOnWordBoundary;
    }

    options.addAll(utils.mergeOptions(opts));
  }

  /// Renders table to string representation,
  /// ready to be sent to terminal output.
  @override
  String toString() {
    List array = this;
    var headersPresent = options['head'] != null && options['head'].isNotEmpty;
    if (headersPresent) {
      array = [options['head']];
      if (isNotEmpty) {
        array.addAll(this);
      }
    } else {
      options['style']['head'] = [];
    }

    List<List<ICell>> cells = layout.makeTableLayout(array);

    for (var row in cells) {
      for (var cell in row) {
        cell.mergeTableOptions(options, cells);
      }
    }

    options['colWidths'] = layout.computeWidths(options['colWidths'], cells);
    options['rowHeights'] = layout.computeHeights(options['rowHeights'], cells);

    for (var row in cells) {
      for (var cell in row) {
        cell.init(options);
      }
    }

    var result = <String>[];

    for (var rowIndex = 0; rowIndex < cells.length; rowIndex++) {
      var row = cells[rowIndex];
      var heightOfRow = options['rowHeights'].isEmpty ? 0 : options['rowHeights'][rowIndex];

      if (rowIndex == 0 || !options['style']['compact'] || (rowIndex == 1 && headersPresent)) {
        _doDraw(row, 'top', result);
      }

      for (var lineNum = 0; lineNum < heightOfRow; lineNum++) {
        _doDraw(row, lineNum, result);
      }

      if (rowIndex + 1 == cells.length) {
        _doDraw(row, 'bottom', result);
      }
    }

    return result.join('\n');
  }

  int get width {
    var str = toString().split('\n');
    return str[0].length;
  }

  final _table = <dynamic>[];

  @override
  int get length => _table.length;

  @override
  set length(int value) => _table.length = value;

  @override
  operator [](int index) => _table[index];

  @override
  void operator []=(int index, dynamic value) => _table[index] = value;

  @override
  void add(element) => _table.add(element);
  @override
  void addAll(Iterable<dynamic> iterable) => _table.addAll(iterable);
}

/// Helper method
void _doDraw(List<ICell> row, lineNum, List<String> result) {
  final line = row.map((cell) => cell.draw(lineNum));

  var str = line.join('');
  if (str.isNotEmpty) result.add(str);
}
