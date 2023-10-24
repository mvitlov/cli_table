import 'package:cli_table/src/cell/cell.dart';

/// A Cell that doesn't do anything. It just draws empty lines.
///
/// *Used as a placeholder in column spanning.*
class ColSpanCell extends ICell {
  ColSpanCell() : super();

  @override
  String draw(dynamic lineNum, [dynamic spanningCell]) {
    return '';
  }

  @override
  void init(Map<String, dynamic> tableOptions) {}

  @override
  void mergeTableOptions(Map<String, dynamic> tableOptions, cells) {}
}
