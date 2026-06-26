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
    // Continuous attention animations (nav pulse) never settle, so pump a
    // bounded number of frames instead of pumpAndSettle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('AstraScore'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
