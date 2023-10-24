import 'package:chalkdart/chalk.dart';
import 'package:cli_table/src/cell/cell.dart';
import 'package:cli_table/src/cell/col_span_cell.dart';

import 'package:cli_table/src/options.dart';
import 'package:cli_table/src/utils.dart' as utils;
import 'package:test/test.dart';

import 'mock_word_wrap.dart';

void main() {
  group('Cell', () {
    setUp(() {
      utils.wordWrap = mockWordWrap.call;
    });
    group('constructor', () {
      test('colSpan and rowSpan default to 1', () {
        var cell = Cell();
        expect(cell['colSpan'], 1);
        expect(cell['rowSpan'], 1);
      });

      test('colSpan and rowSpan can be set via constructor', () {
        var cell = Cell({'rowSpan': 2, 'colSpan': 3});
        expect(cell['rowSpan'], 2);
        expect(cell['colSpan'], 3);
      });

      test('content can be set as a string', () {
        var cell = Cell('hello\nworld');
        expect(cell['content'], 'hello\nworld');
      });

      test('content can be set as a options property', () {
        var cell = Cell({'content': 'hello\nworld'});
        expect(cell['content'], 'hello\nworld');
      });

      test('default content is an empty string', () {
        var cell = Cell();
        expect(cell['content'], '');
      });

      test('Cell(null) will have empty string content', () {
        var cell = Cell(null);
        expect(cell['content'], '');
      });

      test('Cell({content: null}) will have empty string content', () {
        var cell = Cell({'content': null});
        expect(cell['content'], '');
      });

      test('Cell(0) will have "0" as content', () {
        var cell = Cell(0);
        expect(cell['content'], '0');
      });

      test('Cell({content: 0}) will have "0" as content', () {
        var cell = Cell({'content': 0});
        expect(cell['content'], '0');
      });

      test('Cell(false) will have "false" as content', () {
        var cell = Cell(false);
        expect(cell['content'], 'false');
      });

      test('Cell({content: false}) will have "false" as content', () {
        var cell = Cell({'content': false});
        expect(cell['content'], 'false');
      });
    });
    group('mergeTableOptions', () {
      group('wordwrap', () {
        late Map<String, dynamic> tableOptions;
        late Cell cell;

        initCell({wordWrap, wrapOnWordBoundary}) {
          cell = Cell({
            'content': 'some text',
            'wordWrap': wordWrap,
            'wrapOnWordBoundary': wrapOnWordBoundary
          });
          cell['x'] = cell['y'] = 0;
        }

        setUp(() {
          mockWordWrap.clear();
          tableOptions = {
            ...defaultOptions(),
            'colWidths': [50]
          };
        });

        test('no cell wordWrap override (tableOptions.wordWrap=true)', () {
          tableOptions['wordWrap'] =
              true; // wrapOnWordBoundary is true by default
          initCell();

          cell.mergeTableOptions(tableOptions);
          expect(
              mockWordWrap.toHaveBeenCalledWith(
                  isA<int>(), equals(cell['content']), isTrue),
              isTrue);
        });

        test('no cell wordWrap override (tableOptions.wordWrap=false)', () {
          tableOptions['wordWrap'] =
              false; // wrapOnWordBoundary is true by default
          initCell();

          cell.mergeTableOptions(tableOptions);
          expect(mockWordWrap.notCalled(), isTrue);
        });

        test('cell wordWrap override (cell.options.wordWrap=false)', () {
          tableOptions['wordWrap'] =
              true; // wrapOnWordBoundary is true by default
          initCell(wordWrap: false);

          cell.mergeTableOptions(tableOptions);
          expect(mockWordWrap.notCalled(), isTrue); // no wrapping done
        });

        test('cell wordWrap override (cell.options.wordWrap=true)', () {
          tableOptions['wordWrap'] =
              false; // wrapOnWordBoundary is true by default
          initCell(wordWrap: true);

          cell.mergeTableOptions(tableOptions);
          expect(mockWordWrap.called(1), isTrue);
        });

        test(
            'cell wrapOnWordBoundary override (cell.options.wrapOnWordBoundary=false)',
            () {
          tableOptions['wordWrap'] =
              true; // wrapOnWordBoundary is true by default
          initCell(wrapOnWordBoundary: false);

          cell.mergeTableOptions(tableOptions);
          expect(
              mockWordWrap.toHaveBeenCalledWith(
                  isA<int>(), equals(cell['content']), isFalse),
              isTrue);
        });

        test(
            'cell wrapOnWordBoundary override (cell.options.wrapOnWordBoundary=true)',
            () {
          tableOptions['wordWrap'] = true;
          tableOptions['wrapOnWordBoundary'] = false;
          initCell(wrapOnWordBoundary: true);

          cell.mergeTableOptions(tableOptions);
          expect(
              mockWordWrap.toHaveBeenCalledWith(isA<int>(),
                  equals(cell['content']), isTrue /*wrapOnWordBoundary*/
                  ),
              isTrue);
        });
      });

      group('chars', () {
        test('unset chars take on value of table', () {
          var cell = Cell();
          var tableOptions = defaultOptions();
          cell.mergeTableOptions(tableOptions);
          expect(cell['chars'], defaultChars());
        });

        test('set chars override the value of table', () {
          var cell = Cell({
            'chars': {'bottomRight': '='}
          });
          cell.mergeTableOptions(defaultOptions());
          var chars = defaultChars();
          chars['bottomRight'] = '=';
          expect(cell['chars'], chars);
        });

        test('hyphenated names will be converted to camel-case', () {
          var cell = Cell({
            'chars': {'bottom-left': '='}
          });
          cell.mergeTableOptions(defaultOptions());
          var chars = defaultChars();
          chars['bottomLeft'] = '=';
          expect(cell['chars'], chars);
        });
      });

      group('truncate', () {
        test('if unset takes on value of table', () {
          var cell = Cell();
          cell.mergeTableOptions(defaultOptions());
          expect(cell['truncate'], '…');
        });

        test('if set overrides value of table', () {
          var cell = Cell({'truncate': '...'});
          cell.mergeTableOptions(defaultOptions());
          expect(cell['truncate'], '...');
        });
      });

      group('style.padding-left', () {
        test('if unset will be copied from tableOptions.style', () {
          var cell = Cell();
          cell.mergeTableOptions(defaultOptions());
          expect(cell['paddingLeft'], 1);

          cell = Cell();
          var tableOptions = defaultOptions();
          tableOptions['style']['padding-left'] = 2;
          cell.mergeTableOptions(tableOptions);
          expect(cell['paddingLeft'], 2);

          cell = Cell();
          tableOptions = defaultOptions();
          tableOptions['style']['paddingLeft'] = 3;
          cell.mergeTableOptions(tableOptions);
          expect(cell['paddingLeft'], 3);
        });

        test('if set will override tableOptions.style', () {
          var cell = Cell({
            'style': {'padding-left': 2}
          });
          cell.mergeTableOptions(defaultOptions());
          expect(cell['paddingLeft'], 2);

          cell = Cell({
            'style': {'paddingLeft': 3}
          });
          cell.mergeTableOptions(defaultOptions());
          expect(cell['paddingLeft'], 3);
        });
      });

      group('style.padding-right', () {
        test('if unset will be copied from tableOptions.style', () {
          var cell = Cell();
          cell.mergeTableOptions(defaultOptions());
          expect(cell['paddingRight'], 1);

          cell = Cell();
          var tableOptions = defaultOptions();
          tableOptions['style']['padding-right'] = 2;
          cell.mergeTableOptions(tableOptions);
          expect(cell['paddingRight'], 2);

          cell = Cell();
          tableOptions = defaultOptions();
          tableOptions['style']['paddingRight'] = 3;
          cell.mergeTableOptions(tableOptions);
          expect(cell['paddingRight'], 3);
        });

        test('if set will override tableOptions.style', () {
          var cell = Cell({
            'style': {'padding-right': 2}
          });
          cell.mergeTableOptions(defaultOptions());
          expect(cell['paddingRight'], 2);

          cell = Cell({
            'style': {'paddingRight': 3}
          });
          cell.mergeTableOptions(defaultOptions());
          expect(cell['paddingRight'], 3);
        });
      });

      group('desiredWidth', () {
        test('content(hello) padding(1,1) == 7', () {
          var cell = Cell('hello');
          cell.mergeTableOptions(defaultOptions());
          expect(cell['desiredWidth'], 7);
        });

        test('content(hi) padding(1,2) == 5', () {
          var cell = Cell({
            'content': 'hi',
            'style': {'paddingRight': 2}
          });
          var tableOptions = defaultOptions();
          cell.mergeTableOptions(tableOptions);
          expect(cell['desiredWidth'], 5);
        });

        test('content(hi) padding(3,2) == 7', () {
          var cell = Cell({
            'content': 'hi',
            'style': {'paddingLeft': 3, 'paddingRight': 2},
          });
          var tableOptions = defaultOptions();
          cell.mergeTableOptions(tableOptions);
          expect(cell['desiredWidth'], 7);
        });
      });
      group('desiredHeight', () {
        test('1 lines of text', () {
          var cell = Cell('hi');
          cell.mergeTableOptions(defaultOptions());
          expect(cell['desiredHeight'], 1);
        });

        test('2 lines of text', () {
          var cell = Cell('hi\nbye');
          cell.mergeTableOptions(defaultOptions());
          expect(cell['desiredHeight'], 2);
        });

        test('2 lines of text', () {
          var cell = Cell('hi\nbye\nyo');
          cell.mergeTableOptions(defaultOptions());
          expect(cell['desiredHeight'], 3);
        });
      });
    });

    group('init', () {
      group('hAlign', () {
        test('if unset takes colAlign value from tableOptions', () {
          var tableOptions = defaultOptions();
          tableOptions['colAligns'] = ['left', 'right', 'both'];
          var cell = Cell();
          cell['x'] = 0;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['hAlign'], 'left');
          cell = Cell();
          cell['x'] = 1;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['hAlign'], 'right');
          cell = Cell();
          cell.mergeTableOptions(tableOptions);
          cell['x'] = 2;
          cell.init(tableOptions);
          expect(cell['hAlign'], 'both');
        });

        test('if set overrides tableOptions', () {
          var tableOptions = defaultOptions();
          tableOptions['colAligns'] = ['left', 'right', 'both'];
          var cell = Cell({'hAlign': 'right'});
          cell['x'] = 0;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['hAlign'], 'right');
          cell = Cell({'hAlign': 'left'});
          cell['x'] = 1;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['hAlign'], 'left');
          cell = Cell({'hAlign': 'right'});
          cell['x'] = 2;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['hAlign'], 'right');
        });
      });

      group('vAlign', () {
        test('if unset takes rowAlign value from tableOptions', () {
          var tableOptions = defaultOptions();
          tableOptions['rowAligns'] = ['top', 'bottom', 'center'];
          var cell = Cell();
          cell['y'] = 0;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['vAlign'], 'top');
          cell = Cell();
          cell['y'] = 1;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['vAlign'], 'bottom');
          cell = Cell();
          cell['y'] = 2;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['vAlign'], 'center');
        });

        test('if set overrides tableOptions', () {
          var tableOptions = defaultOptions();
          tableOptions['rowAligns'] = ['top', 'bottom', 'center'];

          var cell = Cell({'vAlign': 'bottom'});
          cell['y'] = 0;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['vAlign'], 'bottom');

          cell = Cell({'vAlign': 'top'});
          cell['y'] = 1;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['vAlign'], 'top');

          cell = Cell({'vAlign': 'center'});
          cell['y'] = 2;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['vAlign'], 'center');
        });
      });
      group('width', () {
        test('will match colWidth of x', () {
          var tableOptions = defaultOptions();
          tableOptions['colWidths'] = [5, 10, 15];

          var cell = Cell();
          cell['x'] = 0;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['width'], 5);

          cell = Cell();
          cell['x'] = 1;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['width'], 10);

          cell = Cell();
          cell['x'] = 2;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['width'], 15);
        });

        test('will add colWidths if colSpan > 1 with wordWrap false', () {
          var tableOptions = defaultOptions();
          tableOptions['colWidths'] = [5, 10, 15];

          var cell = Cell({'colSpan': 2});
          cell['x'] = 0;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['width'], 16);

          cell = Cell({'colSpan': 2});
          cell['x'] = 1;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['width'], 26);

          cell = Cell({'colSpan': 3});
          cell['x'] = 0;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['width'], 32);
        });

        test('will add colWidths if colSpan > 1 with wordWrap true', () {
          var tableOptions = defaultOptions();
          tableOptions['colWidths'] = [5, 10, 15];
          tableOptions['wordWrap'] = true;

          var cell = Cell({'colSpan': 2});
          cell['x'] = 0;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['width'], 16);

          cell = Cell({'colSpan': 2});
          cell['x'] = 1;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['width'], 26);

          cell = Cell({'colSpan': 3});
          cell['x'] = 0;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['width'], 32);
        });

        test(
            'will use multiple columns for wordWrap text when using colSpan and wordWrap together',
            () {
          var tableOptions = defaultOptions();
          tableOptions['colWidths'] = [7, 7, 17];
          tableOptions['wordWrap'] = true;

          var cell = Cell({'content': 'the quick brown fox', 'colSpan': 2});
          cell['x'] = 0;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['lines'].length, 2);
          expect(cell['lines'][0], contains('quick'));
          expect(cell['lines'][1], contains('fox'));

          cell = Cell({'content': 'the quick brown fox', 'colSpan': 2});
          cell['x'] = 1;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['lines'].length, 1);
          expect(cell['lines'][0], contains('fox'));

          cell = Cell({'content': 'the quick brown fox', 'colSpan': 3});
          cell['x'] = 0;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['lines'].length, 1);
          expect(cell['lines'][0], contains('fox'));
        });

        test(
            'will only use one column for wordWrap text when not using colSpan',
            () {
          var tableOptions = defaultOptions();
          tableOptions['colWidths'] = [7, 7, 7];
          tableOptions['wordWrap'] = true;

          var cell = Cell({'content': 'the quick brown fox'});
          cell['x'] = 0;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['lines'].length, 4);
          expect(cell['lines'][1], contains('quick'));
          expect(cell['lines'][3], contains('fox'));
        });
      });

      group('height', () {
        test('will match rowHeight of x', () {
          var tableOptions = defaultOptions();
          tableOptions['rowHeights'] = [5, 10, 15];

          var cell = Cell();
          cell['y'] = 0;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['height'], 5);

          cell = Cell();
          cell['y'] = 1;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['height'], 10);

          cell = Cell();
          cell['y'] = 2;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['height'], 15);
        });

        test('will add rowHeights if rowSpan > 1', () {
          var tableOptions = defaultOptions();
          tableOptions['rowHeights'] = [5, 10, 15];

          var cell = Cell({'rowSpan': 2});
          cell['y'] = 0;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['height'], 16);

          cell = Cell({'rowSpan': 2});
          cell['y'] = 1;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['height'], 26);

          cell = Cell({'rowSpan': 3});
          cell['y'] = 0;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['height'], 32);
        });
      });

      group('drawRight', () {
        late Map<String, dynamic> tableOptions;

        setUp(() {
          tableOptions = defaultOptions();
          tableOptions['colWidths'] = [20, 20, 20];
        });

        test('col 1 of 3, with default colspan', () {
          var cell = Cell();
          cell['x'] = 0;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['drawRight'], false);
        });

        test('col 2 of 3, with default colspan', () {
          var cell = Cell();
          cell['x'] = 1;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['drawRight'], false);
        });

        test('col 3 of 3, with default colspan', () {
          var cell = Cell();
          cell['x'] = 2;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['drawRight'], true);
        });

        test('col 3 of 4, with default colspan', () {
          var cell = Cell();
          cell['x'] = 2;
          tableOptions['colWidths'] = [20, 20, 20, 20];
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['drawRight'], false);
        });

        test('col 2 of 3, with colspan of 2', () {
          var cell = Cell({'colSpan': 2});
          cell['x'] = 1;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['drawRight'], true);
        });

        test('col 1 of 3, with colspan of 3', () {
          var cell = Cell({'colSpan': 3});
          cell['x'] = 0;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['drawRight'], true);
        });

        test('col 1 of 3, with colspan of 2', () {
          var cell = Cell({'colSpan': 2});
          cell['x'] = 0;
          cell.mergeTableOptions(tableOptions);
          cell.init(tableOptions);
          expect(cell['drawRight'], false);
        });
      });
    });

    group('drawLine', () {
      late Cell cell;

      setUp(() {
        cell = Cell();

        //manually init
        cell['chars'] = defaultChars();
        cell['paddingLeft'] = cell['paddingRight'] = 1;
        cell['width'] = 7;
        cell['height'] = 3;
        cell['hAlign'] = HorizontalAlign.center;
        cell['vAlign'] = VerticalAlign.center;
        cell['chars']['left'] = 'L';
        cell['chars']['right'] = 'R';
        cell['chars']['middle'] = 'M';
        cell['content'] = 'hello\nhowdy\ngoodnight';
        cell['lines'] = cell['content'].split('\n');
        cell['x'] = cell['y'] = 0;
      });

      group('top line', () {
        test('will draw the top left corner when x=0,y=0', () {
          cell['x'] = cell['y'] = 0;
          expect(cell.draw('top'), '┌───────');
          cell['drawRight'] = true;
          expect(cell.draw('top'), '┌───────┐');
        });

        test('will draw the top mid corner when x=1,y=0', () {
          cell['x'] = 1;
          cell['y'] = 0;
          expect(cell.draw('top'), '┬───────');
          cell['drawRight'] = true;
          expect(cell.draw('top'), '┬───────┐');
        });

        test('will draw the left mid corner when x=0,y=1', () {
          cell['x'] = 0;
          cell['y'] = 1;
          expect(cell.draw('top'), '├───────');
          cell['drawRight'] = true;
          expect(cell.draw('top'), '├───────┤');
        });

        test('will draw the mid mid corner when x=1,y=1', () {
          cell['x'] = 1;
          cell['y'] = 1;
          expect(cell.draw('top'), '┼───────');
          cell['drawRight'] = true;
          expect(cell.draw('top'), '┼───────┤');
        });

        test('will draw in the color specified by border style', () {
          cell['border'] = ['gray'];
          expect(cell.draw('top'), chalk.keyword('gray')('┌───────'));
        });
      });

      group('bottom line', () {
        test('will draw the bottom left corner if x=0', () {
          cell['x'] = 0;
          cell['y'] = 1;
          expect(cell.draw('bottom'), '└───────');
          cell['drawRight'] = true;
          expect(cell.draw('bottom'), '└───────┘');
        });

        test('will draw the bottom left corner if x=1', () {
          cell['x'] = 1;
          cell['y'] = 1;
          expect(cell.draw('bottom'), '┴───────');
          cell['drawRight'] = true;
          expect(cell.draw('bottom'), '┴───────┘');
        });

        test('will draw in the color specified by border style', () {
          cell['border'] = ['gray'];
          expect(cell.draw('bottom'), chalk.keyword('gray')('└───────'));
        });
      });

      group('drawBottom', () {
        test('draws an empty line 1', () {
          expect(cell.drawEmpty(), 'L       ');
          expect(cell.drawEmpty(true), 'L       R');
        });

        test('draws an empty line 2', () {
          cell['border'] = ['gray'];
          cell['head'] = ['red'];
          var empty = cell.drawEmpty();
          var expected =
              chalk.keyword('gray')('L') + chalk.keyword('red')('       ');
          expect(empty, expected);

          expect(
              cell.drawEmpty(true),
              chalk.keyword('gray')('L') +
                  chalk.keyword('red')('       ') +
                  chalk.keyword('gray')('R'));
        });
      });

      group('first line of text', () {
        setUp(() {
          cell['width'] = 9;
        });

        test('will draw left side if x=0', () {
          cell['x'] = 0;
          expect(cell.draw(0), 'L  hello  ');
          cell['drawRight'] = true;
          expect(cell.draw(0), 'L  hello  R');
        });

        test('will draw mid side if x=1', () {
          cell['x'] = 1;
          expect(cell.draw(0), 'M  hello  ');
          cell['drawRight'] = true;
          expect(cell.draw(0), 'M  hello  R');
        });

        test('will align left', () {
          cell['x'] = 1;
          cell['hAlign'] = HorizontalAlign.left;
          expect(cell.draw(0), 'M hello   ');
          cell['drawRight'] = true;
          expect(cell.draw(0), 'M hello   R');
        });

        test('will align right', () {
          cell['x'] = 1;
          cell['hAlign'] = HorizontalAlign.right;
          expect(cell.draw(0), 'M   hello ');
          cell['drawRight'] = true;
          expect(cell.draw(0), 'M   hello R');
        });

        test('left and right will be drawn in color of border style', () {
          cell['border'] = ['gray'];
          cell['x'] = 0;
          expect(cell.draw(0), "${chalk.keyword('gray')("L")}  hello  ");
          cell['drawRight'] = true;
          expect(cell.draw(0),
              "${chalk.keyword('gray')("L")}  hello  ${chalk.keyword('gray')("R")}");
        });

        test('text will be drawn in color of head style if y == 0', () {
          cell['head'] = ['red'];
          cell['x'] = cell['y'] = 0;
          expect(cell.draw(0), "L${chalk.keyword('red')("  hello  ")}");
          cell['drawRight'] = true;
          expect(cell.draw(0), "L${chalk.keyword('red')("  hello  ")}R");
        });

        test('text will NOT be drawn in color of head style if y == 1', () {
          cell['head'] = ['red'];
          cell['x'] = cell['y'] = 1;
          expect(cell.draw(0), 'M  hello  ');
          cell['drawRight'] = true;
          expect(cell.draw(0), 'M  hello  R');
        });

        test('head and border colors together', () {
          cell['border'] = ['gray'];
          cell['head'] = ['red'];
          cell['x'] = cell['y'] = 0;
          expect(cell.draw(0),
              chalk.keyword('gray')('L') + chalk.keyword('red')('  hello  '));
          cell['drawRight'] = true;
          expect(
              cell.draw(0),
              chalk.keyword('gray')('L') +
                  chalk.keyword('red')('  hello  ') +
                  chalk.keyword('gray')('R'));
        });
      });

      group('second line of text', () {
        setUp(() {
          cell['width'] = 9;
        });

        test('will draw left side if x=0', () {
          cell['x'] = 0;
          expect(cell.draw(1), 'L  howdy  ');
          cell['drawRight'] = true;
          expect(cell.draw(1), 'L  howdy  R');
        });

        test('will draw mid side if x=1', () {
          cell['x'] = 1;
          expect(cell.draw(1), 'M  howdy  ');
          cell['drawRight'] = true;
          expect(cell.draw(1), 'M  howdy  R');
        });

        test('will align left', () {
          cell['x'] = 1;
          cell['hAlign'] = HorizontalAlign.left;
          expect(cell.draw(1), 'M howdy   ');
          cell['drawRight'] = true;
          expect(cell.draw(1), 'M howdy   R');
        });

        test('will align right', () {
          cell['x'] = 1;
          cell['hAlign'] = HorizontalAlign.right;
          expect(cell.draw(1), 'M   howdy ');
          cell['drawRight'] = true;
          expect(cell.draw(1), 'M   howdy R');
        });
      });

      group('truncated line of text', () {
        setUp(() {
          cell['width'] = 9;
        });

        test('will draw left side if x=0', () {
          cell['x'] = 0;
          expect(cell.draw(2), 'L goodni… ');
          cell['drawRight'] = true;
          expect(cell.draw(2), 'L goodni… R');
        });

        test('will draw mid side if x=1', () {
          cell['x'] = 1;
          expect(cell.draw(2), 'M goodni… ');
          cell['drawRight'] = true;
          expect(cell.draw(2), 'M goodni… R');
        });

        test('will not change when aligned left', () {
          cell['x'] = 1;
          cell['hAlign'] = HorizontalAlign.left;
          expect(cell.draw(2), 'M goodni… ');
          cell['drawRight'] = true;
          expect(cell.draw(2), 'M goodni… R');
        });

        test('will not change when aligned right', () {
          cell['x'] = 1;
          cell['hAlign'] = HorizontalAlign.right;
          expect(cell.draw(2), 'M goodni… ');
          cell['drawRight'] = true;
          expect(cell.draw(2), 'M goodni… R');
        });
      });

      group('vAlign', () {
        setUp(() {
          cell['height'] = 5;
        });

        test('center', () {
          cell['vAlign'] = VerticalAlign.center;
          expect(cell.draw(0), 'L       ');
          expect(cell.draw(1), 'L hello ');
          expect(cell.draw(2), 'L howdy ');
          expect(cell.draw(3), 'L good… ');
          expect(cell.draw(4), 'L       ');

          cell['drawRight'] = true;
          expect(cell.draw(0), 'L       R');
          expect(cell.draw(1), 'L hello R');
          expect(cell.draw(2), 'L howdy R');
          expect(cell.draw(3), 'L good… R');
          expect(cell.draw(4), 'L       R');

          cell['x'] = 1;
          cell['drawRight'] = false;
          expect(cell.draw(0), 'M       ');
          expect(cell.draw(1), 'M hello ');
          expect(cell.draw(2), 'M howdy ');
          expect(cell.draw(3), 'M good… ');
          expect(cell.draw(4), 'M       ');
        });

        test('top', () {
          cell['vAlign'] = VerticalAlign.top;
          expect(cell.draw(0), 'L hello ');
          expect(cell.draw(1), 'L howdy ');
          expect(cell.draw(2), 'L good… ');
          expect(cell.draw(3), 'L       ');
          expect(cell.draw(4), 'L       ');

          cell['vAlign'] = null; //top is the default
          cell['drawRight'] = true;
          expect(cell.draw(0), 'L hello R');
          expect(cell.draw(1), 'L howdy R');
          expect(cell.draw(2), 'L good… R');
          expect(cell.draw(3), 'L       R');
          expect(cell.draw(4), 'L       R');

          cell['x'] = 1;
          cell['drawRight'] = false;
          expect(cell.draw(0), 'M hello ');
          expect(cell.draw(1), 'M howdy ');
          expect(cell.draw(2), 'M good… ');
          expect(cell.draw(3), 'M       ');
          expect(cell.draw(4), 'M       ');
        });

        test('center', () {
          cell['vAlign'] = VerticalAlign.bottom;
          expect(cell.draw(0), 'L       ');
          expect(cell.draw(1), 'L       ');
          expect(cell.draw(2), 'L hello ');
          expect(cell.draw(3), 'L howdy ');
          expect(cell.draw(4), 'L good… ');

          cell['drawRight'] = true;
          expect(cell.draw(0), 'L       R');
          expect(cell.draw(1), 'L       R');
          expect(cell.draw(2), 'L hello R');
          expect(cell.draw(3), 'L howdy R');
          expect(cell.draw(4), 'L good… R');

          cell['x'] = 1;
          cell['drawRight'] = false;
          expect(cell.draw(0), 'M       ');
          expect(cell.draw(1), 'M       ');
          expect(cell.draw(2), 'M hello ');
          expect(cell.draw(3), 'M howdy ');
          expect(cell.draw(4), 'M good… ');
        });
      });

      test('vertically truncated will show truncation on last visible line',
          () {
        cell['height'] = 2;
        expect(cell.draw(0), 'L hello ');
        expect(cell.draw(1), 'L howd… ');
      });

      test("won't vertically truncate if the lines just fit", () {
        cell['height'] = 2;
        cell['content'] = 'hello\nhowdy';
        cell['lines'] = cell['content'].split('\n');
        expect(cell.draw(0), 'L hello ');
        expect(cell.draw(1), 'L howdy ');
      });

      test('will vertically truncate even if last line is short', () {
        cell['height'] = 2;
        cell['content'] = 'hello\nhi\nhowdy';
        cell['lines'] = cell['content'].split('\n');
        expect(cell.draw(0), 'L hello ');
        expect(cell.draw(1), 'L  hi…  ');
      });

      test('allows custom truncation', () {
        cell['height'] = 2;
        cell['truncate'] = '...';
        cell['content'] = 'hello\nhi\nhowdy';
        cell['lines'] = cell['content'].split('\n');
        expect(cell.draw(0), 'L hello ');
        expect(cell.draw(1), 'L hi... ');

        cell['content'] = 'hello\nhowdy\nhi';
        cell['lines'] = cell['content'].split('\n');
        expect(cell.draw(0), 'L hello ');
        expect(cell.draw(1), 'L ho... ');
      });
    });

    group('ColSpanCell', () {
      test('draw returns an empty string', () {
        expect(ColSpanCell().draw('top'), '');
        expect(ColSpanCell().draw('bottom'), '');
        expect(ColSpanCell().draw(1), '');
      });
    });
  });
}

Map<String, dynamic> defaultOptions() {
  //overwrite coloring of head and border by default for easier testing.
  return utils.mergeOptions({
    'style': {'head': [], 'border': []}
  });
}

Map<String, String> defaultChars() {
  return {
    'top': '─',
    'topMid': '┬',
    'topLeft': '┌',
    'topRight': '┐',
    'bottom': '─',
    'bottomMid': '┴',
    'bottomLeft': '└',
    'bottomRight': '┘',
    'left': '│',
    'leftMid': '├',
    'mid': '─',
    'midMid': '┼',
    'right': '│',
    'rightMid': '┤',
    'middle': '│',
  };
}
