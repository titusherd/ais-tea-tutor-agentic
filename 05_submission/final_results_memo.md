# Memo hasil akhir — Riset 1 dan Riset 3

Tanggal: 5 September 2026  
Status: `READY_FOR_INTERNAL_REVIEW_WITH_OPEN_EXTERNAL_SUBMISSION_ITEMS`

## Narasi hasil yang boleh dipakai

### Riset 1 / Paper 1

Pada frame analisis utama yang dikunci, 3.847 anak IFLS W1 usia 0–12
terhubung ke outcome dewasa W5; 25 masuk treatment dan 3.822 menjadi control.
Treatment hanya berarti migrasi kerja internasional yang terverifikasi oleh ibu
yang terhubung, setelah W1, dengan anak tetap di household asal serta link
orang tua dan household yang lolos audit.

Dalam model asosiasi teradjust dengan kontrol W1 dan standard error robust yang
di-cluster pada household asal, treatment berasosiasi dengan probabilitas
college attainment yang lebih rendah sebesar 20,7 percentage points (95% CI:
−30,2 sampai −11,3; q < 0,001). Treatment juga berasosiasi dengan probabilitas
good self-rated health yang lebih tinggi sebesar 11,2 percentage points (95%
CI: 2,7 sampai 19,7; q = 0,041). Hasil headline lain tidak memiliki q-value di
bawah 0,05 dalam family yang telah ditentukan. Profit tidak diinterpretasikan
karena hanya memiliki 4 treated observations.

Kalimat penutup yang aman: “These estimates are adjusted associations in a
selected longitudinal sample and should not be interpreted as causal effects
of maternal migration.”

### Riset 3 / Paper 3

Riset 3 menggunakan observasi person-wave W2/W3 pada anak yang berusia tepat
15 tahun. Treatment adalah market work dengan total jam kerja job 1 dan job 2
minggu lalu lebih dari 43 jam, setelah screen dan jam melewati valid-code rule.
Usia 10–14 hanya disimpan sebagai descriptive/feasibility karena dukungan
screen/jam tidak cukup untuk inferensi utama.

Frame common W1–W5 berisi 753 observasi; 44 treated dan 709 control. Dalam model
asosiasi teradjust dengan kontrol baseline, indikator wave, dan standard error
robust yang di-cluster pada treatment-wave household, treatment berasosiasi
dengan probabilitas college attainment yang lebih rendah sebesar 17,0
percentage points (95% CI: −20,6 sampai −13,3; q < 0,001). Treatment juga
berasosiasi dengan probabilitas married/cohabiting yang lebih tinggi sebesar
3,0 percentage points (95% CI: 1,0 sampai 5,0; q = 0,029) dan skor trust item 3
yang lebih tinggi sebesar 0,292 poin (95% CI: 0,082 sampai 0,502; q = 0,029).
Outcome headline lainnya tidak memiliki q-value di bawah 0,05.

Kalimat penutup yang aman: “These estimates are conditional associations in a
selected longitudinal sample and should not be interpreted as causal effects
of child labor.”

## Fakta, inferensi, dan yang belum ditetapkan

### FAKTA dari output Stata

- Canonical Stata chain selesai dengan exit code 0.
- Final first-pass gate: `FINAL_QUALITY_GATE_PASS_WITH_OPEN_PROVENANCE`.
- Publication-support audit: `PUBLICATION_SUPPORT_AUDIT_PASS`.
- Semua model first-pass diberi label `adjusted_association`.
- Full table menyimpan 33 adjusted primary rows; headline table menyimpan 14
  rows; baseline descriptives menyimpan 20 rows.
- Hasil tersimpan di `tables/all_adjusted_primary_results.csv` dan
  `tables/headline_adjusted_results.csv`.

### INFERENSI yang masih terbatas

- Pola R1 dan R3 konsisten dengan perbedaan outcome dewasa di antara kelompok
  yang memiliki exposure terdefinisi, setelah kontrol yang tersedia.
- Sinyal college attainment cukup kuat secara statistik di first pass, tetapi
  bukan bukti bahwa exposure menyebabkan perubahan tersebut.
- Ukuran treated yang kecil membuat sensitivitas terhadap household tertentu
  tetap menjadi risiko.

### TIDAK DITETAPKAN dan tidak boleh ditulis sebagai hasil

- causal effect, impact, long-term causal consequence, atau counterfactual;
- IMDI 14-item final atau indeks multidimensi tervalidasi;
- CES-D-10 atau klaim mental-health scale;
- hazardous child labour atau chores/domestic-work effect;
- NPV, national earnings/productivity loss, atau policy-cost estimate;
- substantive result untuk Riset 2;
- generalisasi nasional atau estimasi prevalence;
- acceptance probability, ranking jurnal, fee, atau reviewer outcome.

## Status pengiriman

Paket ini siap dikirim kepada pembimbing atau reviewer internal melalui
`final_project_package.html`. Paket belum boleh disebut telah dikirim ke jurnal
eksternal karena metadata penulis, provenance release IFLS, dan review
substantif akhir belum diisi/ditutup.
