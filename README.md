> A Dart package that enhances the user experience by displaying _static_ tabular data in terminal.

![cli_table_preview1](https://raw.githubusercontent.com/mvitlov/cli_table/main/media/screenshot.png)

## Features

- Display data in a tabular format within the terminal
- Easy to use API
- Color/background styling in the header through [chalkdart](https://pub.dev/packages/chalkdart)
- Customize column width
- Column and row cell spans
- Content truncation based on predefined widths
- Horizontal content alignment (left/center/right)
- Vertical content alignment (top/center/bottom)
- Padding (left/right)
- Word wrapping options
- Per cell customization

![cli_table_preview2](https://raw.githubusercontent.com/mvitlov/cli_table/main/media/screenshot2.png)

## Basic example

```dart
import 'package:cli_table/cli_table.dart';

void main() {
  final table = Table(
    header: ['Rel', 'Change', "By", "When"], // Set headers
    columnWidths: [10, 20, 20, 30], // Optionally set column widhts
  );

  // Table class extends dart List,
  // so you're free to use all the usual List methods
  table
    ..add(['v0.1', 'First test', 'someone@gmail.com', '9 minutes ago'])
    ..add(['v0.1', 'Second test', 'other@gmail.com', '13 minutes ago']);

  // Call `toString()` to render the final table for output
  print(table.toString());
}
```

![cli_table_preview2](https://raw.githubusercontent.com/mvitlov/cli_table/main/media/basic_example.png)

## Table types and layouts

### Horizontal tables

```dart
final table = Table(
  header: ['Index', 'Name'],
);

table.addAll([
  ['1.', 'First'],
  ['2.', 'Second'],
]);

print(table.toString());
```

![cli_table_preview2](https://raw.githubusercontent.com/mvitlov/cli_table/main/media/horizontal_table.png)

### Vertical tables

```dart
final table = Table();

table.addAll([
  {'Some key': 'Some value'},
  {'Another key': 'Another value'},
]);

print(table.toString());
```

![cli_table_preview2](https://raw.githubusercontent.com/mvitlov/cli_table/main/media/vertical_table.png)

### Cross tables

Cross tables are very similar to vertical tables, with two key differences:

1. They require a `header` setting when instantiated that has an empty string as the first header
2. The individual rows take the general form of { "Header": ["Row", "Values"] }

```dart
final table = Table(header: ["", "Top Header 1", "Top Header 2"]);

table.addAll([
  {
    'Left Header 1': ['Value Row 1 Col 1', 'Value Row 1 Col 2']
  },
  {
    'Left Header 2': ['Value Row 2 Col 1', 'Value Row 2 Col 2']
  }
]);

print(table.toString());
```

![cli_table_preview2](https://raw.githubusercontent.com/mvitlov/cli_table/main/media/cross_table.png)

## Other usage examples with different table options

### Wrap text on word boundaries

```dart
final table = Table(
  style: TableStyle(
    border: [], // Clear border style/color (default is ["gray"])
    header: [], // Clear header style/color (defaults to ['red'])
  ),
  columnWidths: [7, 9], // Requires fixed column widths
  wordWrap: true,
);

table.addAll([
  [
    'Hello how are you?',
    'I am fine thanks! Looooooong',
    ['Words that exceed', 'the columnWidth will', 'be truncated.'].join('\n'),
    ['Text is only', 'wrapped for', 'fixed width', 'columns.'].join('\n'),
  ]
]);

print(table.toString());
```

![cli_table_preview2](https://raw.githubusercontent.com/mvitlov/cli_table/main/media/wrap_text.png)

### Use `columnSpan` to span columns

```dart
final table = Table();

table.addAll([
  [{'colSpan': 2, 'content': 'First'}], // Set custom column span
  [{'colSpan': 2, 'content': 'Second'}],
  ['Third', 'Fourth']
]);
```

![cli_table_preview2](https://raw.githubusercontent.com/mvitlov/cli_table/main/media/column_span.png)

### Use `rowSpan` to span rows

```dart
final table = Table();

table.addAll([
  [
    {'rowSpan': 2, 'content': 'First'}, // Set custom row span
    {'rowSpan': 2, 'content': 'Second', 'vAlign': VerticalAlign.center}, // Set custom horizontal alignment
    'hello'
  ],
  ['howdy']
]);
```
![cli_table_preview2](https://raw.githubusercontent.com/mvitlov/cli_table/main/media/row_span.png)


## Credits

- [Automattic/cli-table](https://github.com/Automattic/cli-table)
- [jamestalmage/cli-table2](https://github.com/jamestalmage/cli-table2)
- [cli-table/cli-table3](https://github.com/cli-table/cli-table3)
