import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:astrapay_naik_kelas/core/state/app_state.dart';
import 'package:astrapay_naik_kelas/core/theme/app_theme.dart';
import 'package:astrapay_naik_kelas/features/home/home_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('Home builds and shows the AstraScore hero', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: MaterialApp(theme: AppTheme.lightTheme, home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('AstraScore'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
