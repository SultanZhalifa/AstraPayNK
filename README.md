# AstraPay Naik Kelas

> **Modal yang tumbuh bareng usahamu.**
> Mesin Skor & Modal Produktif untuk Pelaku Usaha Mikro Berbasis Motor.

Prototipe untuk **AstraPay Hackathon 2026** oleh **Tim Andalusia** (Sultan & Misha).

Naik Kelas adalah lapisan intelijen tipis di atas produk AstraPay yang sudah ada (QRIS, Disbursement, AstraPoints). Ia mengubah jejak transaksi digital pelaku usaha mikro — driver ojol, warung, bengkel, kurir — menjadi **akses modal kerja** yang adil, transparan, dan dibayar seiring usaha berjalan. Tanpa slip gaji, tanpa agunan.

---

## Masalah & Solusi

Pelaku usaha mikro berbasis motor punya arus kas, tapi tak punya "berkas" yang dikenali bank: tak ada slip gaji, tak ada agunan, tak ada riwayat kredit formal. Akibatnya mereka terkunci dari modal kerja produktif — padahal jejak transaksi digital mereka (QRIS, angsuran FIF, top-up) sebenarnya bercerita banyak tentang kelayakan kredit.

Naik Kelas menutup celah itu dengan tiga pilar yang saling mengunci:

| Pilar | Apa | Bagaimana |
|---|---|---|
| 🎯 **AstraScore** | Skor kredit alternatif **300–850** | Dihitung dari 5 sinyal perilaku di ekosistem Astra, *explainable* dan dapat dicabut (UU PDP) |
| 💰 **Modal Jalan** | Modal kerja **Rp500rb–Rp3jt** | Plafon di-*size* dari skor **+ arus kas QRIS nyata**, cair lewat penyalur berlisensi (FINATRA) |
| 🔄 **Bayar Sambil Jualan** | Cicilan auto-split | Tiap QRIS masuk otomatis menyisihkan **10/15/20%** untuk cicilan — tanpa jatuh tempo mencekik |

Ditambah loop **AstraPoints**: disiplin bayar & transaksi sehat → skor naik → poin & reward → "naik kelas".

---

## Cara Kerja AstraScore

Skor dihitung sebagai `300 + fraction × 550` dari 5 sinyal berbobot (sesuai proposal §6.2):

| Sinyal | Bobot |
|---|---|
| Ketepatan Bayar Angsuran FIF | **35%** |
| Volume & Konsistensi QRIS | **30%** |
| Keteraturan Top-up | **15%** |
| Tenure & Kelengkapan Akun | **10%** |
| Tren Pertumbuhan | **10%** |

**Level:** Pemula (<500) · Berkembang (<650) · Mandiri (<750) · Bintang (≥750).
**Eligible Modal Jalan** mulai skor **≥500**.

**Plafon = `min(plafon-per-level, 40% × volume QRIS bulanan)`**, dibulatkan ke kelipatan Rp100rb. Artinya: sizing selalu mengikuti arus kas nyata — bahkan skor tinggi tetap dibatasi kapasitas usaha. Biaya layanan menurun seiring level naik (3,0% → 1,8%).

Mesinnya *pure & deterministik* (`AstraScoreEngine`) sehingga mudah di-upgrade dari rule-based ke model statistik/ML dengan data AstraPay nyata, **tanpa mengubah UI**.

---

## Arsitektur

State management memakai `provider` / `ChangeNotifier` dengan satu sumber kebenaran (`AppState`). Setiap aksi merecompute lewat engine sehingga seluruh layar tersinkron otomatis.

```
lib/
├── core/
│   ├── constants/   AppConstants — seluruh parameter bisnis (threshold, bobot, MDR)
│   ├── engine/      AstraScoreEngine — mesin skor murni & teruji
│   ├── services/    AstraPayService (abstract) + MockAstraPayService
│   ├── state/       AppState — single source of truth (provider)
│   ├── theme/       AppColors (violet + amber), AppTheme
│   └── utils/       Formatters (Rupiah/tanggal, locale id_ID), Responsive
├── shared/
│   ├── data/        Personas — 4 persona seed
│   ├── models/      TransactionModel, ActiveModal
│   └── widgets/     GlassCard, ScoreGauge, AnimatedCounter, PinPad, dll.
└── features/        splash → onboarding → login → home (Beranda · Modal · Skor ·
                     Profil) + Terima QRIS, Pencairan, Aktivitas, AstraPoints
```

**Sandbox-ready by design.** Seluruh integrasi diabstraksi lewat `AstraPayService`. `MockAstraPayService` meniru bentuk panggilan AstraPay Sandbox (reference number, timing settlement, penyalur FINATRA), jadi demo berjalan penuh tanpa backend. Untuk produksi, tinggal ganti dengan `HttpAstraPayService` yang memanggil endpoint `docs.astrapay.com` — sisa aplikasi tak berubah.

---

## Persona Demo

Empat persona menceritakan spektrum lengkap dalam satu tap "Ganti Profil Demo":

| Persona | Usaha | Tier | Kondisi |
|---|---|---|---|
| **Budi Santoso** | Driver Ojol | Plus | Berkembang · **modal aktif** → lihat cicilan auto-split jalan |
| **Sari Wulandari** | Warung Sembako | Preferred | Mandiri · eligible → lihat flow pencairan |
| **Andi Pratama** | Kurir (akun baru) | Basic | Pemula · **terkunci** → lihat cara naikkan skor |
| **Rini Kusuma** | Bengkel Motor | Plus | Berkembang · eligible → arus kas musiman |

---

## Menjalankan

Prasyarat: **Flutter SDK** (Dart `^3.12.2`).

```bash
flutter pub get          # ambil dependency
flutter run              # jalankan di device/emulator
flutter run -d chrome    # jalankan sebagai web app
flutter test             # jalankan unit + widget test
```

Alur demo yang disarankan: Onboarding → Login (PIN apa saja, 6 digit) → buka **Terima QRIS** dari tombol tengah → tekan **Auto** dan lihat cicilan, saldo, skor, serta poin bergerak real-time. Ganti persona kapan saja lewat avatar di pojok kiri atas.

---

## Testing

`test/app_smoke_test.dart` mencakup:
- **Mesin skor & state:** eligibility per persona, split-repayment QRIS, disbursement, perhitungan MDR.
- **Widget smoke test:** seluruh tab utama render tanpa error/overflow.

```bash
flutter test
```

---

## Deploy (Vercel)

Aplikasi di-deploy sebagai web statis dari `build/web`:

```bash
flutter build web        # hasil di build/web/
```

`vercel.json` menyetel `outputDirectory: build/web` dengan SPA rewrite ke `index.html`. `.vercelignore` mengecualikan artefak native & berat agar deploy ringan.

---

## Tech Stack

Flutter · Material (light theme) · `provider` · `fl_chart` · `google_fonts` · `flutter_svg` · `smooth_page_indicator` · `intl` (id_ID) · `shimmer`.

---

## Privasi

AstraScore hanya dihitung atas **persetujuan eksplisit** pengguna, bersifat transparan (*explainable*), dan dapat dicabut kapan saja — selaras **UU PDP**. Toggle persetujuan tersedia di menu Profil.

---

> **Catatan:** Ini prototipe demonstrasi. Seluruh data transaksi, persona, dan integrasi adalah simulasi (Sandbox) dan tidak mewakili data atau tarif resmi AstraPay.

**Tim Andalusia** · AstraPay Hackathon 2026
