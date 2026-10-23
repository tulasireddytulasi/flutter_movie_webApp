extension StringListExtension on List<String> {
  /// Returns a new list with the first letter of each string capitalized.
  List<String> capitalizeFirstLetter() {
    return this.map((str) {
      if (str.isEmpty) return str;
      return str[0].toUpperCase() + str.substring(1);
    }).toList();
  }
}

extension NumberFormattingExtension on num {
  /// Converts numbers into readable short formats like 3K, 3.2K, 2L, 4.9M, 4Cr, etc.
  String toCompactCurrencyFormat() {
    if (this >= 10000000) {
      double cr = this / 10000000;
      return '${cr.toStringAsFixed(cr.truncateToDouble() == cr ? 0 : 1)}Cr';
    } else if (this >= 100000) {
      double l = this / 100000;
      return '${l.toStringAsFixed(l.truncateToDouble() == l ? 0 : 1)}L';
    } else if (this >= 1000) {
      double k = this / 1000;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}K';
    } else {
      return toString();
    }
  }
}