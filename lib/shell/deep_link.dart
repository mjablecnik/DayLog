import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_identity.dart';
import 'destination.dart';

/// The Destination a `zafling://<destination>` link opens. Null for any other
/// link, so a stray URL is ignored.
Destination? destinationFromUri(Uri uri) {
  if (uri.scheme != appLinkScheme) return null;
  final String name = uri.host.isNotEmpty
      ? uri.host
      : (uri.pathSegments.isEmpty ? '' : uri.pathSegments.first);
  for (final Destination destination in Destination.values) {
    if (destination.linkName == name.toLowerCase()) return destination;
  }
  return null;
}

/// The links that open the app, the one that launched it first. Empty by
/// default (tests, Linux); `main` swaps in [appLinksStream] on the device.
final deepLinksProvider = Provider<Stream<Uri>>(
  (ref) => const Stream<Uri>.empty(),
);

/// The launching link, then every later one, from the platform.
Stream<Uri> appLinksStream() async* {
  final AppLinks links = AppLinks();
  final Uri? first = await links.getInitialLink();
  if (first != null) yield first;
  yield* links.uriLinkStream;
}
