import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import 'core/font_licenses.dart';
import 'database/app_database.dart';
import 'shell/deep_link.dart';
import 'startup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerFontLicenses();
  runApp(
    await buildApp(
      // Opens the on-device file database lazily on first query.
      database: AppDatabase(),
      documentsDirectory: await getApplicationDocumentsDirectory(),
      deepLinks: appLinksStream(),
    ),
  );
}
