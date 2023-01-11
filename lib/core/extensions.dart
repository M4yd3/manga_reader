import 'dart:math';

extension NaturalSorting on String {
  int naturalCompareTo(String b) {
    var a = this;
    if (a.contains(RegExp(r'\d')) && b.contains(RegExp(r'\d'))) {
      final pattern = RegExp(r'\d+');
      var size = 0;

      final matches =
          pattern.allMatches(a).toList() + pattern.allMatches(b).toList();

      for (final element in matches) {
        size = max(size, element[0]!.length);
      }
      a = _fixString(a, size);
      b = _fixString(b, size);
    }

    return a.compareTo(b);
  }

  String _fixString(String string, int size) {
    return string.splitMapJoin(RegExp(r'\d+'), onMatch: (match) {
      if (match[0] == null) return '';
      return '0' * max(size - match[0]!.length, 0) + match[0]!;
    });
  }
}
