/// Vertical alignment of the table cell content
///
/// Can be used when creating new Table by setting the `rowAlignment` param,
/// or when used directly inside cell, use `vAlign` key to set alignment on a cell basis.
///
/// Using `rowAlignment`:
/// ```dart
/// final table = Table(
///   rowAlignment: [VerticalAlign.bottom, VerticalAlign.center],
/// );
/// ```
///
/// ---
///
/// Using `vAlign`:
/// ```dart
/// final table = Table();
///
/// table.add({'content': 'foo', 'vAlign': VerticalAlign.bottom});
///
/// ```
enum VerticalAlign {
  top('top'),
  center('center'),
  bottom('bottom');

  const VerticalAlign(this.name);
  final String name;
}

/// Horizontal alignment of the table cell content
///
/// Can be used when creating new Table by setting the `columnAlignment` param,
/// or when used directly inside cell, use `hAlign` key to set alignment on a cell basis.
///
/// Using `columnAlignment`:
/// ```dart
/// final table = Table(
///   columnAlignment: [HorizontalAlign.right, HorizontalAlign.center],
/// );
/// ```
///
/// ---
///
/// Using `hAlign`:
/// ```dart
/// final table = Table();
///
/// table.add({'content': 'foo', 'hAlign': VerticalAlign.bottom});
///
/// ```
enum HorizontalAlign {
  left('left'),
  center('center'),
  right('right');

  const HorizontalAlign(this.name);
  final String name;
}

/// Used for styling table borders and separators
class TableChars {
  /// Top border character, defaults to `─`
  final String top;

  /// Top-Middle border character, defaults to `┬`
  final String topMid;

  /// Top-Middle border character, defaults to `┌`
  final String topLeft;

  /// Top-Right border character, defaults to `┐`
  final String topRight;

  /// Bottom border character, defaults to `─`
  final String bottom;

  /// Bottom-Middle border character, defaults to `┴`
  final String bottomMid;

  /// Bottom-Left border character, defaults to `└`
  final String bottomLeft;

  /// Bottom-Right border character, defaults to `┘`
  final String bottomRight;

  /// Left border character, defaults to `│`
  final String left;

  /// Left-Middle border character, defaults to `├`
  final String leftMid;

  /// Middle border character, defaults to `─`
  final String mid;

  /// Middle-Middle border character, defaults to `┼`
  final String midMid;

  /// Right border character, defaults to `│`
  final String right;

  /// Right-Middle border character, defaults to `┤`
  final String rightMid;

  /// Middle border character, defaults to `│`
  final String middle;

  const TableChars({
    String? top,
    String? topMid,
    String? topLeft,
    String? topRight,
    String? bottom,
    String? bottomMid,
    String? bottomLeft,
    String? bottomRight,
    String? left,
    String? leftMid,
    String? mid,
    String? midMid,
    String? right,
    String? rightMid,
    String? middle,
  })  : top = top ?? '─',
        topMid = topMid ?? '┬',
        topLeft = topLeft ?? '┌',
        topRight = topRight ?? '┐',
        bottom = bottom ?? '─',
        bottomMid = bottomMid ?? '┴',
        bottomLeft = bottomLeft ?? '└',
        bottomRight = bottomRight ?? '┘',
        left = left ?? '│',
        leftMid = leftMid ?? '├',
        mid = mid ?? '─',
        midMid = midMid ?? '┼',
        right = right ?? '│',
        rightMid = rightMid ?? '┤',
        middle = middle ?? '│';

  Map<String, String> toMap() => {
        'top': top,
        'topMid': topMid,
        'topLeft': topLeft,
        'topRight': topRight,
        'bottom': bottom,
        'bottomMid': bottomMid,
        'bottomLeft': bottomLeft,
        'bottomRight': bottomRight,
        'left': left,
        'leftMid': leftMid,
        'mid': mid,
        'midMid': midMid,
        'right': right,
        'rightMid': rightMid,
        'middle': middle,
      };

  factory TableChars.fromMap(Map<String, String> map) {
    return TableChars(
      top: map['top'],
      topMid: map['topMid'],
      topLeft: map['topLeft'],
      topRight: map['topRight'],
      bottom: map['bottom'],
      bottomMid: map['bottomMid'],
      bottomLeft: map['bottomLeft'],
      bottomRight: map['bottomRight'],
      left: map['left'],
      leftMid: map['leftMid'],
      mid: map['mid'],
      midMid: map['midMid'],
      right: map['right'],
      rightMid: map['rightMid'],
      middle: map['middle'],
    );
  }
}

/// Used for styling table with padding, colors etc.
class TableStyle {
  /// Sets padding space on the left
  final int paddingLeft;

  /// Sets padding space on the right
  final int paddingRight;

  /// Sequence of `chalkdart` keywords that will be used to
  /// construct style string for table headers
  final List<String> header;

  /// Sequence of `chalkdart` keywords that will be used to
  /// construct style string for table borders
  final List<String> border;

  /// Use compact layout with no decorations
  final bool compact;

  const TableStyle({
    int? paddingLeft,
    int? paddingRight,
    List<String>? header,
    List<String>? border,
    bool? compact,
  })  : paddingLeft = paddingLeft ?? 1,
        paddingRight = paddingRight ?? 1,
        header = header ?? const ['red'],
        border = border ?? const ['grey'],
        compact = compact ?? false;

  Map<String, dynamic> toMap() => {
        'paddingLeft': paddingLeft,
        'paddingRight': paddingRight,
        'head': header,
        'border': border,
        'compact': compact,
      };

  factory TableStyle.noColor() => TableStyle(border: [], header: []);
  factory TableStyle.fromMap(Map<String, dynamic> map) {
    return TableStyle(
      paddingLeft: map['paddingLeft'],
      paddingRight: map['paddingRight'],
      header: map['head'],
      border: map['border'],
      compact: map['compact'],
    );
  }
}
