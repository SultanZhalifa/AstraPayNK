import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:astrapay_naik_kelas/core/constants/app_constants.dart';
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

    test('Rini (bengkel) is Berkembang & eligible without an active modal', () {
      final app = AppState()..switchPersona(Persona.rini);
      expect(app.persona, Persona.rini);
      expect(app.score.level, 'Berkembang');
      expect(app.score.eligible, isTrue);
      expect(app.hasActiveObligation, isFalse);
      expect(app.availableToDraw, greaterThan(0));
      expect(app.seed.weeklyCashflow, hasLength(7));
    });

    test('QRIS MDR is 0% for micro (<=Rp500rb) and 0.3% above', () {
      expect(AppConstants.qrisMdr(40000), 0);
      expect(AppConstants.qrisMdr(500000), 0);
      expect(AppConstants.qrisMdr(1000000), closeTo(3000, 0.001));
    });

    test('Incoming micro QRIS keeps net = gross - split (MDR 0)', () async {
      final app = AppState();
      final ev = await app.receiveQris(payer: const QrisPayer('Tester', 50000));
      expect(ev.mdr, 0);
      expect(ev.net, ev.gross - ev.split);
    });

    test('Crossing 500 lifts Andi to Berkembang, unlocks modal, awards +1000',
        () async {
      final app = AppState()..switchPersona(Persona.andi);
      expect(app.score.level, 'Pemula');
      expect(app.score.eligible, isFalse);
      final startPoints = app.points;

      // Healthy QRIS nudges the score until it crosses into Berkembang.
      for (var i = 0; i < 15 && !app.score.eligible; i++) {
        await app.receiveQris(payer: const QrisPayer('Tester', 30000));
      }

      expect(app.score.eligible, isTrue);
      expect(app.score.level, 'Berkembang');
      expect(app.justLeveledUp, isTrue);
      expect(app.points,
          greaterThanOrEqualTo(startPoints + AppConstants.pointsPerLevelUp));
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
    // The nav center button pulses continuously, so the tree never "settles";
    // pump bounded frames instead of pumpAndSettle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('AstraScore'), findsWidgets);

    for (final tab in ['Modal', 'Skor', 'Profil', 'Beranda']) {
      await tester.tap(find.text(tab));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }
    expect(tester.takeException(), isNull);
  });
}
