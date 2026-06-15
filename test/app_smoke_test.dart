import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:astrapay_naik_kelas/core/state/app_state.dart';
import 'package:astrapay_naik_kelas/core/theme/app_theme.dart';
import 'package:astrapay_naik_kelas/shared/data/personas.dart';
import 'package:astrapay_naik_kelas/features/home/home_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  // ===== Functional core: AstraScore engine + AppState =====
  group('AstraScore engine & AppState', () {
    test('Budi is eligible with an active modal', () {
      final app = AppState();
      expect(app.persona, Persona.budi);
      expect(app.score.score, inInclusiveRange(300, 850));
      expect(app.score.eligible, isTrue);
      expect(app.hasActiveObligation, isTrue);
    });

    test('Andi is a Pemula and not yet eligible for Modal Jalan', () {
      final app = AppState()..switchPersona(Persona.andi);
      expect(app.score.level, 'Pemula');
      expect(app.score.eligible, isFalse);
      expect(app.availableToDraw, 0);
    });

    test('Incoming QRIS splits to repayment and lifts balance + points', () async {
      final app = AppState();
      final startBalance = app.balance;
      final startPaid = app.activeModal!.amountPaid;
      final startPoints = app.points;

      final ev = await app.receiveQris(
        payer: const QrisPayer('Tester', 40000),
      );

      expect(ev.gross, 40000);
      expect(ev.split, greaterThan(0));
      expect(ev.net, ev.gross - ev.split);
      expect(app.activeModal!.amountPaid, greaterThan(startPaid));
      expect(app.balance, greaterThan(startBalance));
      expect(app.points, greaterThan(startPoints));
    });

    test('Disbursement creates an active modal and credits balance', () async {
      final app = AppState()..switchPersona(Persona.sari);
      expect(app.hasActiveObligation, isFalse);
      final before = app.balance;
      await app.disburseModal(amount: 1000000, tenorDays: 30);
      expect(app.hasActiveObligation, isTrue);
      expect(app.balance, before + 1000000);
    });
  });

  // ===== Widget smoke: every main tab renders without overflow =====
  testWidgets('Home tabs render without errors', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: MaterialApp(theme: AppTheme.lightTheme, home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('AstraScore'), findsWidgets);

    for (final tab in ['Modal', 'Skor', 'Profil', 'Beranda']) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });
}
