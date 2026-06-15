import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/svg_icon.dart';
import '../auth/login_screen.dart';
import '../home/dashboard_view.dart' show levelColor;
import '../home/persona_switcher.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final pad = Responsive.pagePadding(context);
    final lc = levelColor(app.score.level);

    return SafeArea(
      bottom: false,
      child: ResponsiveCenter(
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 14, pad, 110),
          children: [
            const Text('Profil',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            _profileCard(app, lc),
            const SizedBox(height: 16),
            _sectionLabel('Kontrol Demo'),
            GlassCard(
              padding: const EdgeInsets.all(6),
              child: Column(
                children: [
                  _tile(SvgIcons.users, 'Ganti Profil Demo',
                      subtitle: app.seed.name,
                      onTap: () => showPersonaSwitcher(context)),
                  const Divider(height: 1, indent: 56),
                  _tile(SvgIcons.refresh, 'Reset Demo',
                      subtitle: 'Kembalikan data ke kondisi awal', onTap: () {
                    context.read<AppState>().resetDemo();
                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(const SnackBar(
                          content: Text('Demo direset ke kondisi awal')));
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _sectionLabel('Privasi & Persetujuan Data'),
            _consentCard(context, app),
            const SizedBox(height: 16),
            _sectionLabel('Integrasi Ekosistem'),
            _integrationCard(app),
            const SizedBox(height: 16),
            _sectionLabel('Tentang'),
            GlassCard(
              padding: const EdgeInsets.all(6),
              child: Column(
                children: [
                  _tile(SvgIcons.document, 'Tentang Naik Kelas',
                      subtitle: AppConstants.appTagline),
                  const Divider(height: 1, indent: 56),
                  _tile(SvgIcons.headset, 'Bantuan & Dukungan'),
                  const Divider(height: 1, indent: 56),
                  _tile(SvgIcons.users, 'Tim Andalusia',
                      subtitle: 'Sultan & Misha · AstraPay Hackathon 2026'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _logoutButton(context),
            const SizedBox(height: 14),
            Center(
              child: Text('Versi 1.0.0 · Prototype',
                  style: const TextStyle(
                      fontSize: 11.5, color: AppColors.textTertiary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileCard(AppState app, Color lc) {
    return GlassCard(
      gradient: AppColors.heroGradient,
      border: Border.all(color: Colors.transparent),
      shadow: AppColors.softShadow(AppColors.primary, opacity: 0.28),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(app.seed.initials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(app.seed.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800)),
                        ),
                        if (app.seed.isVerified) ...[
                          const SizedBox(width: 6),
                          const AppIcon(SvgIcons.checkCircle,
                              size: 16, color: Colors.white),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(app.seed.businessName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12.5)),
                    Text('+62 ${app.seed.phone}',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _miniStat('AstraScore', '${app.score.score}'),
                _vline(),
                _miniStat('Level', app.score.level),
                _vline(),
                _miniStat('Akun', app.seed.accountTier),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
          const SizedBox(height: 3),
          FittedBox(
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _vline() => Container(
      width: 1, height: 26, color: Colors.white.withValues(alpha: 0.18));

  Widget _consentCard(BuildContext context, AppState app) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Center(
                    child: AppIcon(SvgIcons.shield,
                        size: 19, color: AppColors.success)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Izin Olah Data Transaksi',
                    style:
                        TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
              ),
              Switch.adaptive(
                value: app.dataConsent,
                activeThumbColor: AppColors.success,
                onChanged: (v) => context.read<AppState>().setConsent(v),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'AstraScore hanya dihitung atas persetujuan eksplisitmu, transparan, dan bisa dicabut kapan saja — selaras UU PDP.',
            style: TextStyle(
                fontSize: 12, color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _integrationCard(AppState app) {
    final items = [
      ('QRIS', 'Sumber arus kas & kanal split repayment', SvgIcons.qris),
      ('Disbursement', 'Pencairan Modal Jalan via FINATRA', SvgIcons.handCoins),
      ('Angsuran FIF', 'Sinyal disiplin kredit terkuat', SvgIcons.motorcycle),
      ('AstraPoints', 'Mesin loyalitas & reward', SvgIcons.star),
    ];
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppIcon(SvgIcons.server,
                        size: 13, color: AppColors.primary),
                    const SizedBox(width: 5),
                    Text(app.environment,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                  ],
                ),
              ),
              const Spacer(),
              const Text('Sandbox-ready',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Dirancang di atas produk AstraPay yang sudah ada — siap dihubungkan ke AstraPay Sandbox.',
            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 12),
          ...items.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                          child: AppIcon(e.$3,
                              size: 18, color: AppColors.primary)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.$1,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700)),
                          Text(e.$2,
                              style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const AppIcon(SvgIcons.checkCircle,
                        size: 17, color: AppColors.success),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Text(text,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary)),
    );
  }

  Widget _tile(String icon, String title,
      {String? subtitle, VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                    child: AppIcon(icon, size: 18, color: AppColors.primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 13.5, fontWeight: FontWeight.w600)),
                    if (subtitle != null)
                      Text(subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11.5, color: AppColors.textTertiary)),
                  ],
                ),
              ),
              if (onTap != null)
                const AppIcon(SvgIcons.chevronRight,
                    size: 18, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (r) => false,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.errorSoft,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(SvgIcons.logout, size: 18, color: AppColors.error),
            SizedBox(width: 8),
            Text('Keluar',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error)),
          ],
        ),
      ),
    );
  }
}
