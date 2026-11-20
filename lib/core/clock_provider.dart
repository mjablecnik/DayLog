import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'clock.dart';

/// The source of the current time. Tests override it with a fixed clock.
final clockProvider = Provider<Clock>((ref) => const SystemClock());
