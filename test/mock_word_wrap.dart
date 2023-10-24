import 'package:cli_table/src/utils.dart';
import 'package:test/test.dart';

class _MockWordWrap {
  static var _called = 0;
  final _params = <String, dynamic>{};
  List<String> call(int maxLength, String string,
      [bool wrapOnWordBoundary = true]) {
    _called++;
    _params['maxLength'] = maxLength;
    _params['string'] = string;
    _params['wrapOnWordBoundary'] = wrapOnWordBoundary;

    return multiLineWordWrap(maxLength, string, wrapOnWordBoundary);
  }

  bool toHaveBeenCalledWith(Matcher a, Matcher b, Matcher c) {
    return a.matches(_params['maxLength'], {}) &&
        b.matches(_params['string'], {}) &&
        c.matches(_params['wrapOnWordBoundary'], {});
  }

  bool called(int times) => _called == times;
  bool notCalled() => _called == 0;

  void clear() {
    _called = 0;
    _params.clear();
  }
}

final mockWordWrap = _MockWordWrap();
