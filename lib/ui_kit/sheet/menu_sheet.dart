import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../layout/grouped_list.dart';
import 'app_sheet.dart';

typedef SheetMenuItem<T> = ({
  T value,
  String label,
  String icon,
  bool destructive,
});

Future<T?> showMenuSheet<T>(
  BuildContext context, {
  required String title,
  required List<SheetMenuItem<T>> items,
}) => showAppSheet<T>(
  context,
  builder: (sheetContext) => AppSheet(
    title: title,
    child: GroupedList(
      children: [
        for (final item in items)
          ListRow(
            leading: IconTile(item.icon),
            title: item.label,
            titleColor: item.destructive
                ? sheetContext.palette.destructiveText
                : null,
            onTap: () => AppSheet.close(sheetContext, item.value),
          ),
      ],
    ),
  ),
);
