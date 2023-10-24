import 'package:string_width/string_width.dart';

/// Match ANSI escape codes with or without capturing them
RegExp _codeRegex([bool capture = false]) {
  return capture ? RegExp(r'\u001b\[((?:\d*;){0,5}\d*)m') : RegExp(r'\u001b\[(?:\d*;){0,5}\d*m');
}

/// Calculates length of the given string
int strlen(String str) {
  var code = _codeRegex();
  var stripped = str.replaceAll(code, '');
  var split = stripped.split('\n');
  return split.fold(0, (memo, s) {
    return stringWidth(s) > memo ? stringWidth(s) : memo;
  });
}

/// Repeat given string `n` times
String repeat(String string, int n) {
  return List.filled(n + 1, '').join(string);
}

/// Pad given string
String pad(String string, int len, String padCharacter, String? direction) {
  var length = strlen(string);
  if (len + 1 >= length) {
    var padlen = len - length;
    switch (direction) {
      case 'right':
        {
          string = repeat(padCharacter, padlen) + string;
          break;
        }
      case 'center':
        {
          var right = (padlen / 2).ceil();
          var left = padlen - right;
          string = repeat(padCharacter, left) + string + repeat(padCharacter, right);
          break;
        }
      default:
        {
          string = string + repeat(padCharacter, padlen);
          break;
        }
    }
  }
  return string;
}

var cacheInit = false;
var codeCache = <String, Map<String, dynamic>>{};

void _addToCodeCache(String name, String on, String off) {
  on = '\u001b[${on}m';
  off = '\u001b[${off}m';
  codeCache[on] = {'set': name, 'to': true};
  codeCache[off] = {'set': name, 'to': false};
  codeCache[name] = {'on': on, 'off': off};
}

// https://github.com/Marak/colors.js/blob/master/lib/styles.js
void _cache() {
  _addToCodeCache('bold', '1', '22');
  _addToCodeCache('italics', '3', '23');
  _addToCodeCache('underline', '4', '24');
  _addToCodeCache('inverse', '7', '27');
  _addToCodeCache('strikethrough', '9', '29');
  cacheInit = true;
}

void _updateState(Map<String, dynamic> state, RegExpMatch controlChars) {
  if (!cacheInit) _cache();
  var controlCode = controlChars[1] != null && controlChars[1] != '' ? int.parse(controlChars[1]!.split(';')[0]) : 0;
  if ((controlCode >= 30 && controlCode <= 39) || (controlCode >= 90 && controlCode <= 97)) {
    state['lastForegroundAdded'] = controlChars[0];
    return;
  }
  if ((controlCode >= 40 && controlCode <= 49) || (controlCode >= 100 && controlCode <= 107)) {
    state['lastBackgroundAdded'] = controlChars[0];
    return;
  }
  if (controlCode == 0) {
    for (var i in [...state.keys]) {
      /* istanbul ignore else */
      // if (Object.prototype.hasOwnProperty.call(state, i)) {
      state.remove(i);
      // }
    }
    return;
  }
  var info = codeCache[controlChars[0]];
  if (info != null) {
    state[info['set']] = info['to'];
  }
}

Map<String, dynamic> _readState(String line) {
  var code = _codeRegex(true);
  var controlChars = code.allMatches(line);
  var state = <String, dynamic>{};

  for (var controlChar in controlChars) {
    _updateState(state, controlChar);
  }
/*   while (controlChars != null) {
    _updateState(state, controlChars);
    controlChars = code.firstMatch(line);
  } */
  return state;
}

_unwindState(Map<String, dynamic> state, ret) {
  if (!cacheInit) _cache();
  var lastBackgroundAdded = state['lastBackgroundAdded'];
  var lastForegroundAdded = state['lastForegroundAdded'];

  state.remove('lastBackgroundAdded');
  state.remove('lastForegroundAdded');

  for (var key in (state.keys)) {
    if (state[key]) {
      ret += codeCache[key]!['off'];
    }
  }

  if (lastBackgroundAdded != null && lastBackgroundAdded != '\u001b[49m') {
    ret += '\u001b[49m';
  }
  if (lastForegroundAdded != null && lastForegroundAdded != '\u001b[39m') {
    ret += '\u001b[39m';
  }

  return ret;
}

_rewindState(Map<String, dynamic> state, ret) {
  if (!cacheInit) _cache();
  var lastBackgroundAdded = state['lastBackgroundAdded'];
  var lastForegroundAdded = state['lastForegroundAdded'];

  state.remove('lastBackgroundAdded');
  state.remove('lastForegroundAdded');

  for (var key in (state.keys)) {
    if (state[key]) {
      ret = codeCache[key]!['on'] + ret;
    }
  }

  if (lastBackgroundAdded != null && lastBackgroundAdded != '\u001b[49m') {
    ret = lastBackgroundAdded + ret;
  }
  if (lastForegroundAdded != null && lastForegroundAdded != '\u001b[39m') {
    ret = lastForegroundAdded + ret;
  }

  return ret;
}

_truncateWidth(String str, int desiredLength) {
  if (str.length == strlen(str)) {
    return str.substring(0, desiredLength);
  }

  while (strlen(str) > desiredLength) {
    str = str.substring(0, str.length - 1);
  }

  return str;
}

_truncateWidthWithAnsi(String str, int desiredLength) {
  var code = _codeRegex(true);
  var split = str.split(_codeRegex());
  var splitIndex = 0;
  var retLen = 0;
  var ret = '';
  RegExpMatch? myArray;
  var state = <String, dynamic>{};
  var matchIndex = 0;

  while (retLen < desiredLength) {
    myArray = code.allMatches(str).elementAtOrNull(matchIndex++);

    var toAdd = split[splitIndex];
    splitIndex++;
    if (retLen + strlen(toAdd) > desiredLength) {
      toAdd = _truncateWidth(toAdd, desiredLength - retLen);
    }
    ret += toAdd;
    retLen += strlen(toAdd);

    if (retLen < desiredLength) {
      if (myArray == null) {
        break;
      } // full-width chars may cause a whitespace which cannot be filled
      ret += myArray[0]!;
      _updateState(state, myArray);
    }
  }

  return _unwindState(state, ret);
}

/// Truncates the given string
String truncate(String str, int desiredLength, [String? truncateChar]) {
  truncateChar ??= '…';
  var lengthOfStr = strlen(str);
  if (lengthOfStr <= desiredLength) {
    return str;
  }
  desiredLength -= strlen(truncateChar);

  var ret = _truncateWidthWithAnsi(str, desiredLength);

  return ret + truncateChar;
}

/// Default Table options & styles
Map<String, dynamic> _defaultOptions() {
  return {
    'chars': {
      'top': '─',
      'top-mid': '┬',
      'top-left': '┌',
      'top-right': '┐',
      'bottom': '─',
      'bottom-mid': '┴',
      'bottom-left': '└',
      'bottom-right': '┘',
      'left': '│',
      'left-mid': '├',
      'mid': '─',
      'mid-mid': '┼',
      'right': '│',
      'right-mid': '┤',
      'middle': '│',
    },
    'truncate': '…',
    'colWidths': <int>[],
    'rowHeights': <int>[],
    'colAligns': [],
    'rowAligns': [],
    'style': {
      'padding-left': 1,
      'padding-right': 1,
      'head': ['red'],
      'border': ['grey'],
      'compact': false,
    },
    'head': [],
  };
}

/// Helper method for producing valid options from user input & Table defaults
Map<String, dynamic> mergeOptions([Map<String, dynamic>? options, Map<String, dynamic>? defaults]) {
  options ??= {};
  defaults ??= _defaultOptions();
  var ret = {...defaults, ...options};
  ret['chars'] = {...(defaults['chars'] as Map), ...(options['chars'] ?? {})};
  ret['style'] = {...(defaults['style'] as Map), ...(options['style'] ?? {})};
  return ret;
}

/// Wrap on word boundary
List<String> _wordWrap(int maxLength, String input) {
  var lines = <String>[];

  final split = input.splitWithDelim(RegExp(r'(\s+)', multiLine: true));
  var line = [];
  var lineLength = 0;
  String? whitespace;
  for (var i = 0; i < split.length; i += 2) {
    var word = split[i];
    var newLength = lineLength + strlen(word);
    if (lineLength > 0 && whitespace != null && whitespace.isNotEmpty) {
      newLength += whitespace.length;
    }
    if (newLength > maxLength) {
      if (lineLength != 0) {
        lines.add(line.join(''));
      }
      line = [word];
      lineLength = strlen(word);
    } else {
      line.addAll([whitespace ?? '', word]);
      lineLength = newLength;
    }
    whitespace = split.elementAtOrNull(i + 1);
  }
  if (lineLength != 0) {
    lines.add(line.join(''));
  }
  return lines;
}

/// Wrap text (ignoring word boundaries)
List<String> _textWrap(int maxLength, String input) {
  var lines = <String>[];
  var line = '';
  pushLine(String str, String? ws) {
    if (line.isNotEmpty && ws != null) line += ws;
    line += str;
    while (line.length > maxLength) {
      lines.add(line.substring(0, maxLength));
      line = line.substring(maxLength);
    }
  }

  var split = input.splitWithDelim(RegExp(r'(\s+)', multiLine: true));
  for (var i = 0; i < split.length; i += 2) {
    pushLine(split[i], i > 0 ? split[i - 1] : null);
  }
  if (line.isNotEmpty) lines.add(line);
  return lines;
}

List<String> multiLineWordWrap(int maxLength, String string, [bool wrapOnWordBoundary = true]) {
  var output = <String>[];
  var input = string.split('\n');
  final handler = wrapOnWordBoundary ? _wordWrap : _textWrap;
  for (var line in input) {
    output.addAll(handler(maxLength, line));
  }
  /* for (var i = 0; i < input.length; i++) {
    output.addAll([...output, ...handler(maxLength, input[i])]);
  } */
  return output;
}

var wordWrap = multiLineWordWrap;

List<String> colorizeLines(input) {
  var state = <String, dynamic>{};
  var output = <String>[];
  for (var i = 0; i < input.length; i++) {
    var line = _rewindState(state, input[i]);
    state = _readState(line);
    var temp = {...state};
    output.add(_unwindState(temp, line));
  }
  return output;
}

/// Credit: Matheus Sampaio https://github.com/matheussampaio
String hyperlink(String? url, String text) {
  if (url == null || url.isEmpty) {
    url = text;
  }
  const osc = '\u001B]';
  const bel = '\u0007';
  const sep = ';';

  return [osc, '8', sep, sep, url, bel, text, osc, '8', sep, sep, bel].join('');
}

extension RegExpExtension on RegExp {
  List<String> allMatchesWithSep(String input, [int start = 0]) {
    var result = <String>[];
    for (var match in allMatches(input, start)) {
      result.add(input.substring(start, match.start));
      result.add(match[0]!);
      start = match.end;
    }
    result.add(input.substring(start));
    return result;
  }
}

extension StringExtension on String {
  List<String> splitWithDelim(RegExp pattern) => pattern.allMatchesWithSep(this);
}
