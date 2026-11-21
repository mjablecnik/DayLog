/// The dates an occurrence that starts on [start] and spans [spanDays] touches.
/// The oracle of the multi-day occurrence properties.
List<DateTime> coveredDates(DateTime start, int spanDays) => <DateTime>[
  for (int i = 0; i <= spanDays; i++) DateTime(start.year, start.month, start.day + i),
];
