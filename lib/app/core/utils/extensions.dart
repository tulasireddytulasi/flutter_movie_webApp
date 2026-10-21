extension StringListExtension on List<String> {
  /// Returns a new list with the first letter of each string capitalized.
  List<String> capitalizeFirstLetter() {
    return this.map((str) {
      if (str.isEmpty) return str;
      return str[0].toUpperCase() + str.substring(1);
    }).toList();
  }
}