---
marp: true
paginate: true
size: 16:9
color: #1B1430
style: |
  section { font-family: 'Segoe UI', system-ui, sans-serif; padding: 60px 70px; background: #ffffff; }
  h1 { color: #6C2BD9; font-size: 46px; }
  h2 { color: #6C2BD9; font-size: 32px; }
  strong { color: #6C2BD9; }
  section.lead { background: linear-gradient(135deg,#7C3AED,#4C1D95) !important; color: #fff; }
  section.lead h1, section.lead h2, section.lead strong, section.lead small { color: #fff !important; }
  table { font-size: 22px; }
  small { color: #6B6485; }
---

<!-- _class: lead -->

# AstraPay Naik Kelas

## Modal yang tumbuh bareng usahamu

Mesin Skor Kredit & Modal Produktif untuk Pelaku Usaha Mikro Berbasis Motor

**Tim Andalusia** · AstraPay Hackathon 2026

---

## Masalahnya

**Pak Budi** — driver ojek, omzet QRIS Rp4,5jt/bln, cicilan motor FIF lancar.
Butuh modal Rp1jt buat dagang → **ditolak**: tak ada slip gaji, tak ada agunan.

- 60+ juta pelaku usaha mikro = tulang punggung ekonomi, tapi **unbankable**
- Mereka **punya data** (QRIS, FIF, top-up) — tapi data itu menganggur
- Tanpa akses formal → lari ke **pinjol ilegal / rentenir**

> Jejak transaksinya sudah bercerita dia layak. Tinggal dibaca.

---

## Solusi — 3 Pilar yang Saling Mengunci

| Pilar | Inti |
|---|---|
| 🎯 **AstraScore** (300–850) | Skor kredit dari 5 sinyal perilaku, *explainable* |
| 💰 **Modal Jalan** (Rp500rb–3jt) | Plafon = skor **+ 40% arus kas QRIS nyata** |
| 🔄 **Bayar Sambil Jualan** | Cicilan auto-split 10–20% tiap QRIS masuk |

Ditutup loop **AstraPoints**: disiplin → skor naik → reward → *naik kelas*.

---

![bg right:42%](.playwright-mcp/08-skor-factors.png)

## AstraScore: transparan, bukan kotak hitam

Mulai basis **300**, tiap faktor menambah skor:

- Ketepatan Bayar **FIF** — **35%**
- Volume & Konsistensi **QRIS** — **30%**
- Keteraturan **Top-up** — **15%**
- **Tenure** & kelengkapan akun — **10%**
- Tren **pertumbuhan** — **10%**

<small>Rule-based berbobot hari-1 → siap upgrade ke ML, interface tak berubah.</small>

---

![bg right:42%](.playwright-mcp/06-qris-split.png)

## "Bayar Sambil Jualan" — momen inti

Tiap QRIS masuk **otomatis** terbelah:

- sebagian kecil → **cicilan Modal Jalan**
- sisanya → **saldo** merchant
- skor **naik real-time**

> Pengguna tak pernah merasa "bayar utang". Dia cuma jualan — cicilan jalan sendiri. **Tanpa jatuh tempo mencekik.**

---

![bg right:40%](.playwright-mcp/v2-09-celebration.png)

## Perjalanan "Naik Kelas"

Persona **Andi** (kurir baru, skor 498, modal terkunci):

- disiplin sedikit → skor lewati 500
- 🎉 **Modal Jalan terbuka · +1000 poin · naik kelas**

> Sistem yang **merayakan disiplin**, bukan menghukum keterlambatan. Inilah inklusi yang membangun kebiasaan finansial sehat.

---

## Kenapa AstraPay — dan susah ditiru

Hanya ekosistem Astra punya **4 sinyal di satu atap**:

| Produk | Peran di Naik Kelas |
|---|---|
| **QRIS** | Arus kas + kanal split-repayment |
| **FIF** | Disiplin kredit motor — sinyal terkuat (35%) |
| **Disbursement** | Penyaluran via FINATRA (berizin OJK) |
| **AstraPoints** | Mesin loyalitas & retensi |

**Dibangun di atas produk yang sudah ada** → risiko & biaya integrasi rendah.

---

## Bertanggung jawab & layak bisnis

**Compliance** — *Explainable* score · consent eksplisit & bisa dicabut (**UU PDP**) · penyaluran **berizin & diawasi OJK**. Beda jauh dari pinjol.

**Mitigasi gagal bayar** — plafon dibatasi **40% arus kas nyata** · cicilan dari tiap transaksi, bukan tagihan akhir bulan.

**Pendapatan** — biaya layanan bertingkat **1,8–3%** + MDR QRIS (**0% / 0,3%**, tarif resmi). Tier naik → fee turun → dorong *naik kelas*.

---

## Bukan mockup — prototipe fungsional penuh

- Mesin skor **live** · auto-split **live** · 4 persona
- **Teruji**: unit + widget test hijau
- **Sandbox-ready**: `AstraPayService` terabstraksi — colok API asli, UI tak berubah
- Aksesibilitas, haptic, trust badge, empty state — **detail matang**

<small>Flutter · provider · fl_chart · sudah deploy web (Vercel)</small>

---

<!-- _class: lead -->

# Dari data yang menganggur → akses modal yang bertanggung jawab

## AstraPay Naik Kelas

**Tim Andalusia** · Terima kasih 🙏

<small>Demo simulasi (Sandbox); angka tarif dikutip dari dokumentasi publik AstraPay.</small>
