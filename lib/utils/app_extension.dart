// Extension  on String ------------------------------->
// Sentence case
extension StringMethod on String {
  String toSentenceCase() => this[0].toUpperCase() + substring(1).toLowerCase();
}
