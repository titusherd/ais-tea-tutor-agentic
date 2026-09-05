# Riset 3 — definisi treatment yang diimplementasikan

Tanggal implementasi: 2026-09-05  
Status: `technical_gate_pass`  
Specification lock: `R3-MAIN-D020-D021-D022-D023-D030-D031-D032-D033-D040-D041-D042`

## Keputusan primer

Unit analisis treatment adalah person-wave pada W2 (1997) dan W3 (2000).
Primary hanya memakai anak yang berusia tepat 15 tahun pada wave treatment,
berada pada roster, memiliki `hhid_wave`, dan mempunyai work screen yang
terobservasi. W2 dan W3 tidak digabung tanpa indikator wave; output
menyimpan wave dan household treatment masing-masing.

Treatment primary (`r3_treatment = 1`) mensyaratkan:

1. work screen menunjukkan aktivitas ekonomi/market work;
2. jam kerja job 1 valid: status `tk21ax == 1` dan `tk21a` berada pada
   0--168;
3. job 2 dinyatakan tidak ada (`tk27 == 3`) atau jam job 2 valid: status
   `tk21bx == 1` dan `tk21b` berada pada 0--168;
4. total jam minggu lalu adalah `tk21a + tk21b` jika job 2 ada, atau `tk21a`
   jika job 2 tidak ada; dan
5. total jam lebih dari 43.

Work screen market/economic work dibuat dari `tk01 == 1` atau `tk02 == 1`
atau `tk04 == 1`. `tk03 == 1` (memiliki pekerjaan tetapi tidak bekerja pada
minggu lalu) disimpan sebagai raw evidence; sendirian tidak membuktikan
market work pada minggu referensi. Pada W2, label lokal `tk01 == 1` adalah
`Work`. Pada W3, file DTA yang tersedia tidak membawa value label untuk
`tk01`--`tk04`; aturan numeric dipertahankan dan fakta ini menjadi batas
interpretasi W3.

## Control dan unresolved

`r3_treatment = 0` diberikan hanya pada status yang dapat diverifikasi tidak
memenuhi treatment:

- screen jelas tidak menunjukkan market work; atau
- market work terobservasi dan total jam valid tetapi berada pada atau di
  bawah threshold usia yang berlaku.

Screen yang tidak terobservasi, activity code yang tidak diketahui, status
khusus, jam job 1 yang tidak valid, atau job 2 yang tidak dapat ditentukan
diberi status `unresolved_screen` atau `unresolved_hours`. Unresolved tidak
dipaksa menjadi control.

Threshold deskriptif/feasibility untuk usia yang lebih muda tetap dibuat:

| Age band | Threshold | Status penggunaan |
|---|---:|---|
| 10--11 | >= 1 jam/minggu | descriptive/feasibility |
| 12--14 | >= 14 jam/minggu | descriptive/feasibility |
| 15 | > 43 jam/minggu | primary |

Chores, housekeeping, hazardous work, dan occupation/industry mapping tidak
masuk treatment primary.

## Support yang teramati

| Wave | Age 15 person-wave | Screen teramati | Primary eligible | Treated | Control | Unresolved hours | Unresolved screen |
|---|---:|---:|---:|---:|---:|---:|---:|
| W2, 1997 | 913 | 741 | 740 | 35 | 705 | 1 | 172 |
| W3, 2000 | 978 | 394 | 391 | 36 | 355 | 3 | 584 |
| Gabungan | 1,891 | 1,135 | 1,131 | 71 | 1,060 | 4 | 756 |

Age 10--11 tidak memiliki screen yang terhubung pada working extraction:
1.515 person-wave W2 dan 1.781 person-wave W3 menjadi unresolved screen.
Age 12--14 hanya menghasilkan 4 treated W2 dan 1 treated W3; karena itu
tidak dipakai sebagai inferential primary.

Primary support dikelompokkan pada 727 household W2 dan 386 household W3.
Angka treated yang kecil harus disebutkan sebagai keterbatasan support; model
tidak boleh memperlebar treatment untuk menaikkan jumlah treated.

## Audit dan reproducibility

Dofile utama:

- `dofiles/22_codebook_validity_audit.do`
- `dofiles/24_build_r3_locked_treatment.do`

Raw input:

- `00_raw/wave2_hh97/b3a_tk1.dta`
- `00_raw/wave2_hh97/b3a_tk2.dta`
- `00_raw/wave3_hh00/b3a_tk1.dta`
- `00_raw/wave3_hh00/b3a_tk2.dta`

Output:

- `02_derived/r3_child_labor_treatment.dta`
- `04_output/diagnostics/r3_treatment_sample_flow.csv`
- `04_output/diagnostics/r3_treatment_prevalence_by_wave_age.csv`
- `04_output/logs/24_build_r3_locked_treatment.log`

Gate yang lulus:

- satu baris per `pidlink x wave`;
- primary eligibility hanya usia 15;
- primary status hanya `treated` atau `control`;
- special numeric hours tidak dipakai sebagai jam;
- screen/hour unresolved dipertahankan dan dikeluarkan dari primary.

## Batas klaim

Treatment ini mengidentifikasi kelompok observasional berdasarkan aktivitas
kerja dan jam pada minggu referensi. Koefisien first pass akan ditulis sebagai
adjusted association, bukan causal effect. Tidak ada klaim hazardous work,
chores, CES-D-10, atau dampak nasional yang boleh ditambahkan dari file ini.
