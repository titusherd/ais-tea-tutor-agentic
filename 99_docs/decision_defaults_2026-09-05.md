# Keputusan default konservatif — 2026-09-05

## Status

Atas instruksi pemilik proyek bahwa keputusan terbaik boleh diambil karena
waktu terbatas, keputusan substantif berikut dikunci sebagai default
konservatif. Keputusan ini tidak mengubah arsip IFLS asli. Keputusan hanya
menetapkan estimand kerja, batas klaim, dan aturan first pass.

Model tidak boleh dijalankan sebelum setiap aturan teknis di bawah melewati
audit codebook, valid-code, merge, dan sample-flow yang sesuai.

## Keputusan yang dikunci

| ID | Keputusan kerja | Alasan konservatif |
|---|---|---|
| D-010 | R1 primary hanya mother-led international work migration: parent perempuan yang terhubung sebagai ibu, alasan pindah bekerja terverifikasi, negara tujuan terverifikasi sebagai di luar Indonesia, dan anak tetap berada pada household asal. Domestic, any-parent, country tidak terverifikasi, whole-household move, weekly commuter, death, dan non-work move tidak masuk primary; jika cukup dukungan, dilaporkan sebagai supplementary. | Tidak mengubah migrasi domestik atau country yang tidak terbaca menjadi treatment internasional. |
| D-011 | R1 memakai cohort W1 saja sebagai primary. W2 hanya supplementary/replication dengan estimand terpisah dan tidak digabung diam-diam. | W1 memberi baseline yang lebih awal dan follow-up lebih panjang. |
| D-012 | R1 primary mensyaratkan kedua parent terhubung dan hadir/eligible di baseline serta tidak ada bukti left-censoring. One-parent, known nonresident/dead, no-link, unknown, dan ambiguous status dikeluarkan dari primary dan disimpan untuk sensitivity. | W1 controls tidak boleh diperlakukan sebagai pre-treatment jika status parent sudah berubah. |
| D-020 | R3 primary hanya anak usia 15 pada W2/W3. Usia 10–11 dan 12–14 tetap dibuat sebagai descriptive/feasibility output, bukan inferensi utama. W2 dan W3 dilaporkan dengan wave indicator dan sensitivity terpisah. | Support detail hours untuk usia 10–14 terlalu tipis: 0/5 pada W2 dan 0/1 pada W3. |
| D-021 | R3 primary tidak mencakup chores/domestic work dan tidak mempertahankan klaim gender/domestic division. W1 chores dapat menjadi exploratory appendix jika unit serta codebook lolos audit. | W2/W3 tidak menyediakan ukuran individual weekly housework hours yang sepadan. |
| D-022 | Treatment R3 primary adalah paid/market child labor dengan screen kerja teramati dan total jam kerja minggu lalu dari job 1 + job 2, hanya memakai nilai yang lolos valid-code rule dan berada pada 0–168; age-15 threshold primary >43 jam/minggu. Normal-week atau primary-job-only menjadi sensitivity bila tersedia dan cukup dukungan. | Total jam transparan, dapat diaudit, dan tidak memakai special code sebagai jam. |
| D-023 | Hazardous work dikeluarkan dari primary. Occupation/industry disimpan sebagai raw evidence dan hanya dipetakan kemudian dengan sumber otoritatif yang versioned. | Tidak menebak status hazard dari label pekerjaan yang belum divalidasi. |
| D-030 | Primary memakai model asosiasi tidak berbobot dengan VCE robust yang di-cluster pada origin/treatment household sesuai estimand; tidak menggunakan `svyset` generik. Weighted descriptive/sensitivity baru dijalankan bila target populasi, weight, PSU, strata, dan VCE resmi telah dipetakan. | Field geography/weight yang ditemukan belum cukup untuk mengklaim desain survey tertentu. |
| D-031 | Household PCE dan perbandingan moneter lintas-wave dikeluarkan dari primary. Earnings primary hanya dibandingkan dalam W5 dengan reference period dan valid-code rule W5 yang sama. PCE lintas-wave dan NPV diparkir. | Output PCE W5 belum teridentifikasi dan basis historis tidak lengkap. |
| D-032 | Outcome dewasa primary memakai outcome-family terpisah pada W5, dengan eligibility age 17–36 dan aturan valid-code per outcome. W4 hanya supplementary. Candidate depression tidak disebut CES-D-10 dan tidak masuk primary tanpa modul lengkap. | Coverage W5 dan modul mental health tidak lengkap untuk indeks gabungan. |
| D-033 | Ambiguous multi-resident, HHID mismatch, dan status lineage yang tidak dapat diselesaikan dikeluarkan dari primary; flag dan jumlahnya dipertahankan untuk sensitivity/sample-flow. | Menghindari assignment household yang tidak dapat dipertanggungjawabkan. |
| D-040 | Outcome-specific listwise adalah primary. IMDI 14-item tidak dipaksakan. Reduced non-monetary index hanya supplementary jika indikator, threshold missing, standardisasi, dan interpretasi dikunci setelah audit; MICE hanya sensitivity. | Tidak membentuk indeks baru dari item yang tidak comparable atau tidak tersedia. |
| D-041 | Multiplicity dikendalikan dengan Benjamini–Hochberg di dalam outcome family yang sudah diprapilih; bukan across-all-outcomes. | Menjaga family-level research question tetap terbaca tanpa menyamarkan banyak uji. |
| D-042 | Semua first-pass coefficient diberi label adjusted association. Tidak ada causal wording, IV, mediation, PSM/IPW, Heckman, FE, NPV, atau national aggregation pada first pass. | Identifikasi kausal dan extrapolation belum melewati gate tersendiri. |

## Batas implementasi

1. Numeric value hanya dipakai setelah label, special code, unit, dan
   observation level dicatat dalam crosswalk.
2. Jika sebuah variabel tidak lolos codebook/valid-code/merge gate, variabel
   itu dikeluarkan dari primary; tidak diganti dengan asumsi yang lebih longgar.
3. Treatment, control, dan unresolved dibuat sebagai status yang terpisah.
   Unresolved tidak dipaksa menjadi control.
4. Setiap model wajib menyimpan `spec_lock_id`, sample-flow, N efektif,
   outcome rule, weight rule, cluster rule, dan log Stata.
5. Jika support age-15 atau outcome W5 terlalu kecil setelah seluruh gate,
   hasilnya dipublikasikan sebagai feasibility/descriptive dan model
   inferential tidak dipaksakan.

## Review berikutnya

Review pemilik tidak diperlukan untuk memulai technical implementation dengan
default di atas. Review diperlukan lagi hanya jika bukti data membuat salah
satu default tidak dapat diimplementasikan, atau jika ingin mengubah
estimand/batas klaim.
