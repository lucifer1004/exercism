/// A counter that determines the number of eggs based on binary representation.
///
/// Uses bit manipulation to count set bits (1s) in the binary form of a number,
/// where each set bit represents one egg.
class EggCounter {
  /// Counts the number of set bits in the binary representation of [eggs].
  ///
  /// This implements a standard bit-counting algorithm: check the least
  /// significant bit, then right-shift until all bits are processed.
  ///
  /// Example:
  /// ```dart
  /// final counter = EggCounter();
  /// counter.count(5);  // Returns 2 (binary: 101 has two 1s)
  /// counter.count(16); // Returns 1 (binary: 10000 has one 1)
  /// ```
  ///
  /// Throws [ArgumentError] if [eggs] is negative.
  ///
  /// Returns the count of set bits in [eggs].
  int count(int eggs) {
    if (eggs < 0) {
      throw ArgumentError.value(eggs, 'eggs', 'must be non-negative');
    }

    int count = 0;
    while (eggs > 0) {
      count += eggs & 1;
      eggs >>= 1;
    }
    return count;
  }
}
