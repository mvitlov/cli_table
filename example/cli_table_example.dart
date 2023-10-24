import 'package:chalkdart/chalk.dart';
import 'package:cli_table/cli_table.dart';

void main() {
  // 1. Instantiate Table instance and set options
  final table = Table(
    header: [
      {'content': 'Test Coverage Report', 'colSpan': 6, 'hAlign': HorizontalAlign.center},
    ],
    style: TableStyle(header: ['blue']),
  );

  // 2. Add table data
  table.addAll([
    ['Module', 'Component', 'Test Cases', 'Failures', 'Durations', 'Success Rate'],
    [
      {'rowSpan': 2, 'content': chalk.grey('Services'), 'vAlign': VerticalAlign.center},
      'User',
      50,
      4,
      '3m 7s',
      chalk.bgGreen.black(' 92.0% ')
    ],
    ['Payment', 100, 80, '7m 15s', chalk.yellow(' 80.0% ')],
    [
      {'content': chalk.underline.grey('Subtotal'), 'colSpan': 2, 'hAlign': HorizontalAlign.right},
      150,
      84,
      '10m 22s',
      chalk.bgRed.black(' 38.3% ')
    ],
    [
      {'rowSpan': 2, 'content': chalk.grey('Controllers'), 'vAlign': VerticalAlign.center},
      'User',
      24,
      18,
      '1m 30s',
      chalk.yellow(' 75.0% ')
    ],
    ['Payment', 30, 2, '50s', chalk.bgGreen.black(' 98.9% ')],
    [
      {'content': chalk.underline.grey('Subtotal'), 'colSpan': 2, 'hAlign': HorizontalAlign.right},
      54,
      42,
      '2m 20s',
      chalk.yellow(' 77.3% ')
    ],
    [
      {'content': chalk.underline.bold('TOTAL'), 'colSpan': 2, 'hAlign': HorizontalAlign.right},
      chalk.bold(204),
      152,
      '12m 42s',
      chalk.yellow(' 74.5% ')
    ],
  ]);

  // 3. Output to console
  print(table.toString());
}
