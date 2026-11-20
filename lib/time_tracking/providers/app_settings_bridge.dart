import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';

/// The language the app is shown in. The time tracking feature does not own a
/// language setting: the app root overrides this provider with the one setting
/// of the whole app, so notifications and screens always agree.
final timeLocaleProvider = Provider<Locale>((ref) => const Locale('en'));

/// Resolves the localizations for code that has no BuildContext (notification
/// texts, scheduling services).
typedef LocalizationsLoader = Future<AppLocalizations> Function();

/// Loads the localizations of the language in effect when it is called.
final localizationsLoaderProvider = Provider<LocalizationsLoader>((ref) {
  return () async => lookupAppLocalizations(ref.read(timeLocaleProvider));
});
