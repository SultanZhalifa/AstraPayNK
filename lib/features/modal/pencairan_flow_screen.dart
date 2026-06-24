import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/pin_pad.dart';
import '../../shared/widgets/sub_app_bar.dart';
import '../../shared/widgets/svg_icon.dart';

class PencairanFlowScreen extends StatefulWidget {
  final double amount;
  final int tenor;

  const PencairanFlowScreen({
    super.key,
    required this.amount,
    required this.tenor,
  });

  @override
  State<PencairanFlowScreen> createState() => _PencairanFlowScreenState();
}

class _PencairanFlowScreenState extends State<PencairanFlowScreen>
    with SingleTickerProviderStateMixin {
  int _step = 0; // 0 review · 1 pin · 2 processing · 3 success
  int _pin = 0;
  late double _fee;
  late double _total;

  late final AnimationController _success = AnimationController(
    duration: const Duration(milliseconds: 700),
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    final rate = context.read<AppState>().score.serviceFeeRate;
    _fee = widget.amount * rate;
    _total = widget.amount + _fee;
  }

  @override
  void dispose() {
    _success.dispose();
    super.dispose();
  }

  void _onKey(String _) {
    if (_pin >= 6) return;
    setState(() => _pin++);
    if (_pin == 6) _process();
  }

  Future<void> _process() async {
    setState(() => _step = 2);
    await context
        .read<AppState>()
        .disburseModal(amount: widget.amount, tenorDays: widget.tenor);
    if (!mounted) return;
    setState(() => _step = 3);
    _success.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveCenter(
          child: Column(
            children: [
              if (_step < 3)
                SubAppBar(
                  title: 'Pencairan Modal Jalan',
                  onBack: () {
                    if (_step == 1) {
                      setState(() {
                        _step = 0;
                        _pin = 0;
                      });
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
              if (_step < 2) _stepIndicator(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: _content(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 14),
      child: Row(
        children: [
          _dot(0, 'Tinjau'),
          _line(0),
          _dot(1, 'PIN'),
        ],
      ),
    );
  }

  Widget _dot(int step, String label) {
    final active = _step >= step;
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.primary : AppColors.surfaceAlt,
            border: Border.all(
                color: active ? AppColors.primary : AppColors.border, width: 2),
          ),
          child: Center(
            child: _step > step
                ? const AppIcon(SvgIcons.check, size: 14, color: Colors.white)
                : Text('${step + 1}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: active ? Colors.white : AppColors.textTertiary)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.primary : AppColors.textTertiary)),
      ],
    );
  }

  Widget _line(int step) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 18),
        color: _step > step ? AppColors.primary : AppColors.border,
      ),
    );
  }

  Widget _content() {
    switch (_step) {
      case 0:
        return _review();
      case 1:
        return _pinStep();
      case 2:
        return _processing();
      default:
        return _successStep();
    }
  }

  Widget _review() {
    return SingleChildScrollView(
      key: const ValueKey('review'),
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
      child: Column(
        children: [
          GlassCard(
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                      child: AppIcon(SvgIcons.shield,
                          size: 28, color: AppColors.primary)),
                ),
                const SizedBox(height: 12),
                const Text('Tinjau Pencairan',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 18),
                _row('Nominal Modal', Formatters.currency(widget.amount)),
                _row('Tenor', '${widget.tenor} hari'),
                _row('Biaya Layanan', Formatters.currency(_fee)),
                _row('Metode Cicilan', 'Auto-split QRIS'),
                const Divider(height: 22),
                _row('Total Pengembalian', Formatters.currency(_total),
                    bold: true),
                _row('Estimasi cicilan/hari',
                    '±${Formatters.currency(_total / widget.tenor)}',
                    valueColor: AppColors.accentDark),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const InfoNote(
            color: AppColors.info,
            icon: AppIcon(SvgIcons.info, size: 18, color: AppColors.info),
            text:
                'Dana langsung masuk ke saldo AstraPay-mu via FINATRA (penyalur berlisensi). Cicilan otomatis dipotong dari tiap QRIS masuk — tanpa jatuh tempo mencekik.',
          ),
          const SizedBox(height: 12),
          _trustBadge(),
          const SizedBox(height: 22),
          GradientButton(
            text: 'Konfirmasi & Masukkan PIN',
            icon: const AppIcon(SvgIcons.lock, size: 18, color: Colors.white),
            onPressed: () => setState(() => _step = 1),
          ),
        ],
      ),
    );
  }

  Widget _pinStep() {
    return SingleChildScrollView(
      key: const ValueKey('pin'),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
                child:
                    AppIcon(SvgIcons.lock, size: 26, color: AppColors.primary)),
          ),
          const SizedBox(height: 14),
          const Text('Masukkan PIN AstraPay',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Konfirmasi pencairan ${Formatters.currency(widget.amount)}',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 26),
          PinDots(filled: _pin),
          const SizedBox(height: 30),
          PinPad(
            onKey: _onKey,
            onDelete: () {
              if (_pin > 0) setState(() => _pin--);
            },
          ),
        ],
      ),
    );
  }

  Widget _processing() {
    return Center(
      key: const ValueKey('processing'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          SizedBox(
            width: 58,
            height: 58,
            child: CircularProgressIndicator(
                strokeWidth: 3, color: AppColors.primary),
          ),
          SizedBox(height: 22),
          Text('Memproses pencairan...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          SizedBox(height: 6),
          Text('Menghubungi penyalur FINATRA',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _successStep() {
    final app = context.watch<AppState>();
    final m = app.activeModal;
    return FadeTransition(
      key: const ValueKey('success'),
      opacity: _success,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 30, 22, 24),
        child: Column(
          children: [
            ScaleTransition(
              scale: CurvedAnimation(parent: _success, curve: Curves.elasticOut),
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  gradient: AppColors.successGradient,
                  shape: BoxShape.circle,
                  boxShadow:
                      AppColors.softShadow(AppColors.success, opacity: 0.4),
                ),
                child: const Center(
                    child:
                        AppIcon(SvgIcons.check, size: 40, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 22),
            const Text('Pencairan Berhasil!',
                style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success)),
            const SizedBox(height: 8),
            Text(
              '${Formatters.currency(widget.amount)} telah masuk ke saldo AstraPay-mu',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 22),
            if (m != null)
              GlassCard(
                child: Column(
                  children: [
                    _row('No. Referensi', m.referenceNo),
                    _row('Penyalur', m.partner),
                    _row('Tenor', '${m.tenorDays} hari'),
                    _row('Metode Cicilan',
                        'Auto-split ${(m.splitRate * 100).toStringAsFixed(0)}% QRIS'),
                    _row('Jatuh Tempo', Formatters.date(m.dueDate)),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            const InfoNote(
              color: AppColors.success,
              icon: AppIcon(SvgIcons.split, size: 18, color: AppColors.success),
              text:
                  'Mulai sekarang, setiap QRIS yang masuk otomatis menyicil Modal Jalan-mu. Coba di menu "Terima QRIS".',
            ),
            const SizedBox(height: 12),
            _trustBadge(),
            const SizedBox(height: 22),
            GradientButton(
              text: 'Kembali ke Beranda',
              onPressed: () =>
                  Navigator.of(context).popUntil((r) => r.isFirst),
            ),
          ],
        ),
      ),
    );
  }

  /// Compact compliance/trust strip — important reassurance on a money screen.
  Widget _trustBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const AppIcon(SvgIcons.shield, size: 16, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    height: 1.4),
                children: [
                  TextSpan(
                      text: 'Disalurkan FINATRA',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(
                      text:
                          ' — penyalur pembiayaan berizin & diawasi OJK. Datamu dilindungi sesuai UU PDP.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value,
      {bool bold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: bold ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
                    color: valueColor ?? AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
