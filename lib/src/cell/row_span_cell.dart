import 'cell.dart';

/// A placeholder Cell for a Cell that spans multiple rows.
///
/// *It delegates rendering to the original cell, but adds the appropriate offset.*
class RowSpanCell extends ICell {
  RowSpanCell(this.originalCell) : super();
  final ICell originalCell;

  @override
  void init(Map<String, dynamic> tableOptions) {
    var y = this['y'];
    var originalY = originalCell['y'];
    this['cellOffset'] = y - originalY;
    this['offset'] = findDimension(tableOptions['rowHeights'], originalY, this['cellOffset']);
  }

  @override
  String draw(dynamic lineNum, [dynamic spanningCell]) {
    if (lineNum == 'top') {
      return originalCell.draw(this['offset'], this['cellOffset']);
    }
    if (lineNum == 'bottom') {
      return originalCell.draw('bottom');
    }

    return originalCell.draw(this['offset'] + 1 + lineNum);
  }

  @override
  void mergeTableOptions(Map<String, dynamic> tableOptions, cells) {}
}
