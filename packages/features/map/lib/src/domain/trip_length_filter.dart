/// Trip length filter for suggested trips (v2 — hidden until index lands).
enum TripLengthFilter {
  /// Suggested trips under 5 statute miles.
  short,

  /// Suggested trips from 5 through 10 statute miles.
  medium,

  /// Suggested trips over 10 statute miles.
  long,

  /// All suggested trips regardless of length.
  all,
}

/// Whether [distanceKm] matches [filter] using roadmap mile thresholds.
bool tripLengthFilterMatches({
  required TripLengthFilter filter,
  required double distanceKm,
}) {
  const kmPerMi = 1.609344;
  final miles = distanceKm / kmPerMi;
  return switch (filter) {
    TripLengthFilter.short => miles < 5,
    TripLengthFilter.medium => miles >= 5 && miles <= 10,
    TripLengthFilter.long => miles > 10,
    TripLengthFilter.all => true,
  };
}
