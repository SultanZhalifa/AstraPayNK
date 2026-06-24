# 🏆 AstraPay Naik Kelas — Playbook Demo & Pitch

Panduan presentasi untuk **AstraPay Hackathon 2026** · Tim Andalusia.
Tujuan: menang. Dokumen ini = hook, skrip demo klik-per-klik, framing ke kriteria juri, dan jawaban Q&A.

---

## 1. Hook 30 Detik (hafalkan ini)

> "Pak Budi, driver ojek, punya omzet QRIS Rp4,5 juta/bulan dan cicil motornya di FIF tepat waktu. Tapi saat butuh modal Rp1 juta buat dagang, dia ditolak bank — **tidak ada slip gaji, tidak ada agunan.** Padahal jejak transaksinya sudah bercerita dia layak.
>
> **AstraPay Naik Kelas** mengubah jejak transaksi itu jadi skor kredit, membuka modal kerja yang dibayar otomatis dari tiap QRIS masuk — *bayar sambil jualan*. Semua di atas produk yang AstraPay sudah punya."

**Satu kalimat:** Mesin skor kredit alternatif + modal produktif untuk 60+ juta pelaku usaha mikro, dibangun di atas ekosistem Astra (QRIS, FIF, Disbursement, AstraPoints).

---

## 2. Masalah (kenapa ini penting)

- Pelaku usaha mikro berbasis motor (ojol, warung, bengkel, kurir) = tulang punggung ekonomi, tapi **unbankable**: tak punya berkas kredit formal.
- Mereka **punya** data: arus kas QRIS, disiplin angsuran FIF, keteraturan top-up. Selama ini data itu menganggur.
- Akibatnya mereka lari ke pinjol ilegal / rentenir. Ada celah yang AstraPay bisa isi secara bertanggung jawab.

---

## 3. Solusi — 3 Pilar yang Saling Mengunci

| Pilar | Inti | Kenapa kuat |
|---|---|---|
| **AstraScore** (300–850) | Skor dari 5 sinyal perilaku, *explainable* | Transparan, bisa dicabut (UU PDP), upgradable ke ML |
| **Modal Jalan** (Rp500rb–3jt) | Plafon = skor **+ 40% arus kas QRIS nyata** | Pinjaman disesuaikan kapasitas → gagal bayar rendah |
| **Bayar Sambil Jualan** | Cicilan auto-split 10–20% tiap QRIS masuk | Tanpa jatuh tempo mencekik → retensi & disiplin naik |

Ditutup loop **AstraPoints**: disiplin → skor naik → poin & reward → naik kelas.

---

## 4. SKRIP DEMO (3–5 menit) — klik per klik

> **Sebelum mulai:** buka app, pastikan di persona **Budi**. Kalau sempat ngetes, **Profil → Reset Demo** dulu biar bersih.

### Babak 1 — "Datamu punya nilai" (Budi, ~60 dtk)
1. **Dashboard Budi.** Tunjuk gauge: *"AstraScore 593, level Berkembang, naik +35 bulan ini."*
2. Tunjuk kartu **Modal Jalan Aktif** (37% lunas). *"Budi sudah cairkan Rp1 juta, dan sedang dicicil otomatis."*
3. Tap **Skor** → tunjuk **Faktor Penilaian (explainable)**. *"Skornya bukan kotak hitam — 35% dari disiplin FIF, 30% dari arus kas QRIS. Tiap angka bisa dijelaskan ke pengguna."*

### Babak 2 — KILLER MOMENT: bayar sambil jualan (Budi, ~90 dtk)
4. Tap tombol tengah **Terima QRIS** (yang berdenyut).
5. Tap **"Simulasi QRIS Masuk"** 3–4×. **Tunjuk live:** *"Tiap pembayaran masuk, lihat — sebagian otomatis nyicil Modal Jalan (16.200), sisanya ke saldo (91.800). MDR 0% untuk transaksi mikro. Skornya bahkan naik real-time."*
6. *"Ini intinya: dia tidak pernah merasa 'membayar utang'. Dia cuma jualan, cicilan jalan sendiri."*

### Babak 3 — Inklusi & momen emosional (Andi, ~90 dtk)
7. Tap avatar → **Ganti Profil** → **Andi** (kurir baru, skor 498, **terkunci**).
8. Tunjuk: *"Andi belum eligible — Modal Jalan terkunci. Tapi sistem kasih dia jalan."* Tunjuk *"2 poin lagi menuju 500"*.
9. Tap **Skor** → scroll → **"Simulasi: Bayar Angsuran Tepat Waktu"**.
10. 🎉 **Celebration overlay muncul:** *"Andi naik kelas, Modal Jalan terbuka, +1000 poin. Inilah perjalanan 'naik kelas' yang kami jual — sistem yang merayakan disiplin, bukan menghukum."*

### Babak 4 — Tutup (15 dtk)
11. *"Semua ini bukan bikin produk baru — kami menyatukan QRIS, FIF, Disbursement, dan AstraPoints yang AstraPay sudah punya. Arsitekturnya sudah Sandbox-ready: tinggal colok API asli, UI tak berubah."*

---

## 5. Kenapa Kami Menang (framing ke kriteria juri)

**Inovasi** — Bukan "pinjol lagi". Inovasinya di *alternative credit scoring dari data in-ecosystem* + *split-repayment yang mengikat ke arus kas*, bukan tenor kaku.

**Dampak** — Menyentuh segmen terbesar & paling underserved (usaha mikro motor). Mengubah data menganggur jadi akses modal yang bertanggung jawab.

**Kelayakan teknis** — Dibangun **di atas produk AstraPay yang ada**, bukan greenfield. Risiko & biaya integrasi rendah. Mesin skor sudah terabstraksi (`AstraScoreEngine`) → siap upgrade ke ML.

**Viabilitas bisnis** — Pendapatan jelas: biaya layanan bertingkat (1,8–3%) + MDR QRIS (sesuai skema resmi: 0% ≤Rp500rb, 0,3% di atasnya). Plafon terikat arus kas → NPL rendah → unit economics sehat.

**Tanggung jawab & compliance** — *Explainable* score, consent eksplisit & dapat dicabut (**UU PDP**), penyaluran lewat **FINATRA (berizin & diawasi OJK)**. Ini membedakan dari pinjol.

**Eksekusi** — Prototipe **fungsional penuh** (bukan mockup): mesin skor live, auto-split live, 4 persona, teruji (unit + widget test), sudah deploy web. Detail matang (a11y, haptic, empty state, trust badge).

---

## 6. Antisipasi Q&A Juri (jawaban siap tembak)

**"Bagaimana cegah gagal bayar?"**
→ Tiga lapis: (1) plafon dibatasi **40% arus kas QRIS nyata** — tak pernah lebih besar dari kapasitas; (2) cicilan **auto-split** dari tiap transaksi, bukan tagihan akhir bulan; (3) skor naik kalau disiplin, jadi insentif selaras.

**"Apa bedanya dengan pinjol?"**
→ Explainable & transparan, consent UU PDP yang bisa dicabut, penyaluran via penyalur berizin OJK, dan dibayar dari arus kas usaha — bukan jebakan bunga harian.

**"Kenapa harus AstraPay, bukan pemain lain?"**
→ Hanya ekosistem Astra yang punya **keempat sinyal di satu atap**: QRIS (arus kas), **FIF** (disiplin kredit motor — sinyal terkuat, bobot 35%), Disbursement (penyaluran), AstraPoints (loyalitas). Tak bisa ditiru gampang.

**"Model skornya valid?"**
→ Sekarang rule-based berbobot (selaras proposal §6.2), sengaja transparan untuk hari-1. Interface `AstraScoreEngine` identik saat di-upgrade ke model statistik/ML begitu ada data AstraPay riil — tanpa ubah UI.

**"Monetisasi & skala?"**
→ Biaya layanan bertingkat + MDR. Makin tinggi tier, fee makin murah → mendorong naik kelas. Skala: tinggal aktifkan untuk basis pengguna QRIS + FIF yang sudah ada.

**"Data privasi?"**
→ Skor hanya dihitung atas **persetujuan eksplisit**, transparan, bisa dicabut kapan saja — selaras UU PDP. Ada toggle consent di Profil (tunjukkan kalau ditanya).

---

## 7. Angka untuk Dikutip

- Skor **300–850**, 5 sinyal berbobot (FIF 35%, QRIS 30%, Top-up 15%, Tenure 10%, Growth 10%).
- Modal **Rp500rb–Rp3jt**, plafon = min(plafon-level, **40%** volume QRIS bulanan).
- MDR usaha mikro: **0%** (≤Rp500rb) / **0,3%** (di atasnya) — *angka resmi AstraPay*.
- Settlement QRIS **H+1**, cut-off **23:30 WIB**.
- 4 persona demo (Budi, Sari, Andi, Rini) · prototipe teruji & Sandbox-ready.

---

## 8. Checklist Hari-H

- [ ] **Reset Demo** sebelum tampil (Profil → Reset Demo).
- [ ] Mulai dari persona **Budi**.
- [ ] Latihan alur Babak 1→4 minimal 2× sampai mulus < 5 menit.
- [ ] Siapkan **fallback**: kalau demo live gagal, buka screenshot di `.playwright-mcp/` (01–13, v2/v3).
- [ ] Buka **link Vercel** di tab cadangan (jaga-jaga internet venue).
- [ ] Hafalkan **hook 30 detik** & **satu kalimat**.
- [ ] Siapkan jawaban Q&A #6 — terutama "cegah gagal bayar" & "beda dengan pinjol".

---

*Demo ini simulasi (Sandbox); seluruh data & integrasi tidak mewakili data/tarif resmi AstraPay kecuali yang dikutip dari dokumentasi publik.*
