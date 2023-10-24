import 'dart:collection';
import 'dart:math' as math;

import 'package:chalkdart/chalk.dart';

import '../utils.dart' as utils;
import 'col_span_cell.dart';
import 'row_span_cell.dart';

abstract class ICell extends MapBase {
  final _attrs = {};
  @override
  operator [](Object? key) => _attrs[key];

  @override
  void operator []=(key, value) => _attrs[key] = value;

  @override
  void clear() => _attrs.clear();

  @override
  Iterable get keys => _attrs.keys;

  @override
  remove(Object? key) => _attrs.remove(key);

  void mergeTableOptions(Map<String, dynamic> tableOptions, cells);

  void init(Map<String, dynamic> tableOptions);
  String draw(dynamic lineNum, [dynamic spanningCell]);
}

class Cell extends ICell {
  Cell([dynamic options]) : super() {
    setOptions(options);
  }

  void setOptions(dynamic opts) {
    var options = <String, dynamic>{};
    if (opts is num || opts is bool || opts is String) {
      options = {'content': '$opts'};
    } else if (opts is Map) {
      options = Map<String, dynamic>.from(opts);
    }

    this['options'] = options;
    var content = options['content'];
    if (content is num || content is bool || content is String) {
      this['content'] = '$content';
    } else if (content == null) {
      this['content'] = this['options']['href'] ?? '';
    } else {
      throw Exception('Content needs to be a primitive, got: ${content.runtimeType}');
    }
    this['colSpan'] = options['colSpan'] ?? 1;
    this['rowSpan'] = options['rowSpan'] ?? 1;
    this['href'] = this['options']['href'];
  }

  @override
  void mergeTableOptions(Map<String, dynamic> tableOptions, [cells]) {
    this['cells'] = cells;

    var optionsChars = this['options']['chars'] ?? {};
    var tableChars = tableOptions['chars'];
    this['chars'] = {};
    var chars = this['chars'];

    for (var name in _charNames) {
      setOption(optionsChars, tableChars, name, chars);
    }

    this['truncate'] = this['options']['truncate'] ?? tableOptions['truncate'];

    this['options']['style'] ??= <String, String>{};
    var style = this['options']['style'];
    var tableStyle = tableOptions['style'];
    setOption(style, tableStyle, 'padding-left', _attrs);
    setOption(style, tableStyle, 'padding-right', _attrs);
    this['head'] = style?['head'] ?? tableStyle['head'];
    this['border'] = style?['border'] ?? tableStyle['border'];

    this['fixedWidth'] = (tableOptions['colWidths'] as List).elementAtOrNull(this['x'] ?? 0);
    this['lines'] = computeLines(tableOptions);

    this['desiredWidth'] =
        utils.strlen(this['content']) + (this['paddingLeft'] as int? ?? 0) + (this['paddingRight'] as int? ?? 0);
    this['desiredHeight'] = this['lines'].length;
  }

  List<String> computeLines(Map<String, dynamic> tableOptions) {
    final tableWordWrap = tableOptions['wordWrap'] ?? tableOptions['textWrap'];
    final wordWrap = this['options']['wordWrap'] ?? tableWordWrap;
    if (this['fixedWidth'] != null && wordWrap == true) {
      this['fixedWidth'] -= this['paddingLeft'] + this['paddingRight'];
      if (this['colSpan'] != 0) {
        var i = 1;
        while (i < this['colSpan']) {
          this['fixedWidth'] = this['fixedWidth']! + (tableOptions['colWidths'][this['x'] + i] as int? ?? 0);
          i++;
        }
      }
      final bool tableWrapOnWordBoundary = tableOptions['wrapOnWordBoundary'] ?? true;
      final bool wrapOnWordBoundary = this['options']['wrapOnWordBoundary'] ?? tableWrapOnWordBoundary;

      final wrapped = utils.wordWrap(this['fixedWidth']!, this['content'], wrapOnWordBoundary);
      return wrapLines(wrapped);
    }
    return wrapLines(this['content'].split('\n'));
  }

  List<String> wrapLines(List<String> computedLines) {
    final lines = utils.colorizeLines(computedLines);
    if (this['href'] != null && this['href']!.isNotEmpty) {
      return lines.map((line) => utils.hyperlink(this['href'], line)).toList();
    }
    return lines;
  }

  /// Initializes the Cells data structure.
  ///
  /// @param tableOptions - A fully populated set of tableOptions.
  /// In addition to the standard default values, tableOptions must have fully populated the
  /// `colWidths` and `rowWidths` arrays. Those arrays must have lengths equal to the number
  /// of columns or rows (respectively) in this table, and each array item must be a Number.
  @override
  void init(Map<String, dynamic> tableOptions) {
    var x = this['x'];
    var y = this['y'];
    this['widths'] =
        tableOptions['colWidths'].isEmpty ? <int>[] : tableOptions['colWidths'].sublist(x, x + this['colSpan']);
    this['heights'] =
        tableOptions['rowHeights'].isEmpty ? <int>[] : tableOptions['rowHeights'].sublist(y, y + this['rowSpan']);
    this['width'] = (this['widths'] as List<int>).fold<int>(-1, sumPlusOne);
    this['height'] = (this['heights'] as List<int>).fold<int>(-1, sumPlusOne);

    try {
      this['hAlign'] = this['options']['hAlign'] ?? tableOptions['colAligns'][x];
    } catch (_) {
      //
    }

    try {
      this['vAlign'] = this['options']['vAlign'] ?? tableOptions['rowAligns'][y];
    } catch (_) {
      //
    }

    this['drawRight'] = (x ?? 0) + this['colSpan'] == tableOptions['colWidths'].length;
  }

  /// Draws the given line of the cell.
  ///
  /// This default implementation defers to methods `drawTop`, `drawBottom`, `drawLine` and `drawEmpty`.
  @override
  String draw(dynamic lineNum, [dynamic spanningCell]) {
    if (lineNum == 'top') return drawTop(this['drawRight']);
    if (lineNum == 'bottom') return drawBottom(this['drawRight']);

    var padLen = math.max<int>((this['height'] as int) - this['lines'].length as int, 0);
    late int padTop;
    switch (this['vAlign']?.name) {
      case 'center':
        padTop = (padLen / 2).ceil();
        break;
      case 'bottom':
        padTop = padLen;
        break;
      default:
        padTop = 0;
    }
    if (lineNum < padTop || lineNum >= padTop + this['lines'].length) {
      return drawEmpty(this['drawRight'], spanningCell);
    }
    var forceTruncation = this['lines'].length > this['height'] && lineNum + 1 >= this['height'];
    return drawLine(lineNum - padTop, this['drawRight'], forceTruncation, spanningCell);
  }

  /// Renders the top line of the cell.
  /// [drawRight] when `true`, this method should render the right edge of the cell.
  String drawTop([bool? drawRight]) {
    drawRight ??= false;
    var content = [];
    if (this['cells'] != null) {
      // Cells should always exist - some tests don't fill it in though
      var index = -1;
      for (var width in (this['widths'] as List<int>)) {
        index++;
        content.add(_topLeftChar(index));
        content.add(utils.repeat(this['chars'][this['y'] == 0 ? 'top' : 'mid']!, width));
      }
    } else {
      content.add(_topLeftChar(0));
      content.add(utils.repeat(this['chars'][this['y'] == 0 ? 'top' : 'mid']!, this['width']));
    }
    if (drawRight) {
      content.add(this['chars'][this['y'] == 0 ? 'topRight' : 'rightMid']);
    }
    return wrapWithStyleColors('border', content.join(''));
  }

  String _topLeftChar(int offset) {
    var x = this['x'] + offset;
    late String leftChar;
    if (this['y'] == 0) {
      leftChar = x == 0
          ? 'topLeft'
          : offset == 0
              ? 'topMid'
              : 'top';
    } else {
      if (x == 0) {
        leftChar = 'leftMid';
      } else {
        leftChar = offset == 0 ? 'midMid' : 'bottomMid';
        if (this['cells'] != null) {
          // Cells should always exist - some tests don't fill it in though
          var spanAbove = (this['cells'][this['y'] - 1] as List).elementAtOrNull(x) is ColSpanCell;
          if (spanAbove) {
            leftChar = offset == 0 ? 'topMid' : 'mid';
          }
          if (offset == 0) {
            var i = 1;
            while (this['cells'][this['y']][x - i] is ColSpanCell) {
              i++;
            }
            if (this['cells'][this['y']][x - i] is RowSpanCell) {
              leftChar = 'leftMid';
            }
          }
        }
      }
    }
    return this['chars'][leftChar];
  }

  String wrapWithStyleColors(String styleProperty, String content) {
    if (this[styleProperty] != null && this[styleProperty].isNotEmpty) {
      try {
        Chalk? colors;

        for (var i = this[styleProperty].length - 1; i >= 0; i--) {
          colors = chalk.keyword(this[styleProperty][i]);
        }
        return colors?.call(content) ?? content;
      } catch (e) {
        return content;
      }
    } else {
      return content;
    }
  }

  /// Renders a line of text.
  /// @param lineNum - Which line of text to render. This is not necessarily the line within the cell.
  /// There may be top-padding above the first line of text.
  /// @param drawRight - true if this method should render the right edge of the cell.
  /// @param forceTruncationSymbol - `true` if the rendered text should end with the truncation symbol even
  /// if the text fits. This is used when the cell is vertically truncated. If `false` the text should
  /// only include the truncation symbol if the text will not fit horizontally within the cell width.
  /// @param spanningCell - a number of if being called from a RowSpanCell. (how many rows below). otherwise undefined.
  /// @returns {String}
  String drawLine(lineNum, bool? drawRight, bool forceTruncationSymbol, spanningCell) {
    drawRight ??= false;
    var left = this['chars'][this['x'] == 0 ? 'left' : 'middle']!;
    if (this['x'] != 0 && spanningCell != null && this['cells'] != null) {
      var cellLeft = this['cells'][this['y'] + spanningCell][this['x'] - 1];
      while (cellLeft is ColSpanCell) {
        cellLeft = this['cells'][cellLeft['y']][cellLeft['x'] - 1];
      }
      if (cellLeft is! RowSpanCell) {
        left = this['chars']['rightMid']!;
      }
    }
    var leftPadding = utils.repeat(' ', this['paddingLeft']);
    var right = drawRight ? this['chars']['right']! : '';
    var rightPadding = utils.repeat(' ', this['paddingRight']);
    var line = this['lines'][lineNum];
    var len = this['width'] - (this['paddingLeft'] + this['paddingRight']);
    if (forceTruncationSymbol) line += this['truncate'] ?? '…';
    var content = utils.truncate(line, len, this['truncate']);
    content = utils.pad(content, len, ' ', this['hAlign']?.name);
    content = leftPadding + content + rightPadding;
    return stylizeLine(left, content, right);
  }

  String stylizeLine(String left, String content, String right) {
    if (left.isNotEmpty) {
      left = wrapWithStyleColors('border', left);
    }
    if (right.isNotEmpty) {
      right = wrapWithStyleColors('border', right);
    }
    if (this['y'] == 0 && content.isNotEmpty) {
      content = wrapWithStyleColors('head', content);
    }
    return left + content + right;
  }

  /// Renders the bottom line of the cell.
  /// @param drawRight - true if this method should render the right edge of the cell.
  /// @returns {String}
  String drawBottom([bool? drawRight]) {
    drawRight ??= false;
    var left = this['chars'][this['x'] == 0 ? 'bottomLeft' : 'bottomMid']!;
    var content = utils.repeat(this['chars']['bottom']!, this['width']);
    var right = drawRight ? this['chars']['bottomRight']! : '';
    return wrapWithStyleColors('border', left + content + right);
  }

  /// Renders a blank line of text within the cell. Used for top and/or bottom padding.
  /// @param drawRight - true if this method should render the right edge of the cell.
  /// @param spanningCell - a number of if being called from a RowSpanCell. (how many rows below). otherwise undefined.
  /// @returns {String}
  String drawEmpty([bool? drawRight, spanningCell]) {
    drawRight ??= false;
    String left = this['chars'][this['x'] == 0 ? 'left' : 'middle']!;
    if (this['x'] != 0 && spanningCell != null && this['cells'] != null) {
      var cellLeft = this['cells'][this['y'] + spanningCell][this['x'] - 1];
      while (cellLeft is ColSpanCell) {
        cellLeft = this['cells'][cellLeft['y']][cellLeft['x'] - 1];
      }
      if (cellLeft is! RowSpanCell) {
        left = this['chars']['rightMid']!;
      }
    }
    var right = drawRight ? this['chars']['right']! : '';
    var content = utils.repeat(' ', this['width']);
    return stylizeLine(left, content, right);
  }
}

// HELPER FUNCTIONS
dynamic firstDefined(List<dynamic> args) => args.firstWhere((v) => v != null, orElse: () => null);

void setOption(Map? objA, Map objB, String nameB, Map targetObj) {
  var nameAsplit = nameB.split('-');
  if (nameAsplit.length > 1) {
    nameAsplit[1] = nameAsplit[1][0].toUpperCase() + nameAsplit[1].substring(1);
    var nameA = nameAsplit.join('');
    targetObj[nameA] = firstDefined([objA?[nameA], objA?[nameB], objB[nameA], objB[nameB]]);
  } else {
    targetObj[nameB] = firstDefined([objA?[nameB], objB[nameB]]);
  }
}

int findDimension(List dimensionTable, int startingIndex, int span) {
  var ret = dimensionTable[startingIndex];
  for (var i = 1; i < span; i++) {
    ret += 1 + dimensionTable[startingIndex + i];
  }
  return ret;
}

int sumPlusOne(int a, int b) {
  return a + b + 1;
}

const _charNames = [
  'top',
  'top-mid',
  'top-left',
  'top-right',
  'bottom',
  'bottom-mid',
  'bottom-left',
  'bottom-right',
  'left',
  'left-mid',
  'mid',
  'mid-mid',
  'right',
  'right-mid',
  'middle',
];
