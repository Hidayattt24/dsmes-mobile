abstract final class AppStrings {
  AppStrings._();

  static const String appName = 'DSMES Aceh';
  static const String appTagline =
      'Diabetes Self-Management Education & Support';

  // ── Welcome ────────────────────────────────────────────────────────────────
  static const String welcomeTitle = 'Selamat Datang di\nDSMES Aceh';
  static const String welcomeSubtitle =
      'Dukungan manajemen mandiri diabetes yang dipersonalisasi untuk kesehatan Anda yang lebih baik.';
  static const String welcomeMulai = 'Mulai';
  static const String welcomeLogin = 'Masuk';
  static const String welcomeRegister = 'Daftar Sekarang';
  static const String welcomeAlreadyHaveAccount = 'Sudah memiliki akun? ';
  static const String welcomeNoAccount = 'Belum punya akun?';

  // ── Auth — Login ───────────────────────────────────────────────────────────
  static const String loginTitle = 'Selamat Datang';
  static const String loginSubtitle = 'Masuk ke akun DSMES Aceh Anda';
  static const String loginPhone = 'Nomor Handphone';
  static const String loginPhoneHint = 'Contoh: 081234567890';
  static const String loginEmail = 'Email';
  static const String loginEmailHint = 'Masukkan email Anda';
  static const String loginPassword = 'Kata Sandi';
  static const String loginPasswordHint = 'Masukkan kata sandi Anda';
  static const String loginForgotPassword = 'Lupa kata sandi?';
  static const String loginButton = 'Masuk';
  static const String loginNoAccount = 'Belum punya akun? ';
  static const String loginSignUp = 'Daftar';

  // ── Auth — Forgot Password ─────────────────────────────────────────────────
  static const String forgotPasswordTitle = 'Lupa Kata Sandi';
  static const String forgotPasswordSubtitle =
      'Masukkan nomor handphone Anda yang terdaftar untuk mereset kata sandi.';
  static const String forgotPasswordPhone = 'Nomor Handphone';
  static const String forgotPasswordPhoneHint = 'Masukkan nomor handphone Anda';
  static const String forgotPasswordButton = 'Lanjut';
  static const String forgotPasswordBackToLogin = 'Kembali ke masuk';

  // ── Auth — Reset Password ──────────────────────────────────────────────────
  static const String resetPasswordTitle = 'Buat Kata Sandi Baru';
  static const String resetPasswordSubtitle =
      'Kata sandi baru minimal 8 karakter.';
  static const String resetPasswordNewLabel = 'Kata Sandi Baru';
  static const String resetPasswordNewHint = 'Masukkan kata sandi baru';
  static const String resetPasswordConfirmLabel = 'Konfirmasi Kata Sandi';
  static const String resetPasswordConfirmHint = 'Masukkan ulang kata sandi';
  static const String resetPasswordButton = 'Reset Kata Sandi';
  static const String resetPasswordSuccess =
      'Kata sandi berhasil direset. Silakan masuk dengan kata sandi baru Anda.';

  // ── Validation ─────────────────────────────────────────────────────────────
  static const String validationRequired = 'Kolom ini wajib diisi';
  static const String validationEmail = 'Masukkan email yang valid';
  static const String validationPasswordMin =
      'Kata sandi minimal 8 karakter';
  static const String validationPasswordNotMatch =
      'Kata sandi tidak cocok';
  static const String validationPhoneNumber =
      'Masukkan nomor telepon yang valid';
  static const String validationNumberOnly = 'Hanya angka yang diizinkan';

  // ── Onboarding — Progress ──────────────────────────────────────────────────
  static const String onboardingStepOf = 'Langkah';
  static const String onboardingOf = 'dari';

  // ── Step 1: Nama Lengkap ───────────────────────────────────────────────────
  static const String step1Title = 'Siapa nama lengkap Anda?';
  static const String step1Subtitle =
      'Nama lengkap Anda akan digunakan dalam profil kesehatan Anda.';
  static const String step1FieldLabel = 'Nama Lengkap';
  static const String step1FieldHint = 'Contoh: Budi Santoso';

  // ── Step 2: Nama Panggilan ─────────────────────────────────────────────────
  static const String stepNicknameTitle = 'Siapa nama panggilan Anda?';
  static const String stepNicknameSubtitle =
      'Nama panggilan Anda akan digunakan untuk menyapa Anda di dalam aplikasi.';
  static const String stepNicknameFieldLabel = 'Nama Panggilan';
  static const String stepNicknameFieldHint = 'Contoh: Budi';
  static const String step13LabelNickname = 'Nama Panggilan';


  // ── Step 2: Email ──────────────────────────────────────────────────────────
  static const String step2Title = 'Apa alamat email Anda? (Opsional)';
  static const String step2Subtitle =
      'Email bersifat opsional untuk notifikasi tambahan.';
  static const String step2FieldLabel = 'Alamat Email (Opsional)';
  static const String step2FieldHint = 'Contoh: email@domain.com';

  // ── Step 3: Nomor Handphone ────────────────────────────────────────────────
  static const String step3Title = 'Berapa nomor handphone Anda?';
  static const String step3Subtitle =
      'Kami akan mengirimkan pesan untuk verifikasi.';
  static const String step3FieldLabel = 'Nomor Handphone';
  static const String step3FieldHint = '812 3456 7890';
  static const String step3SecurityTitle = 'Keamanan data Anda\nprioritas utama kami.';
  static const String step3Terms = 'Dengan mendaftar, Anda menyetujui Syarat & Ketentuan serta Kebijakan Privasi kami.';

  // ── Step 4: Buat Kata Sandi ────────────────────────────────────────────────
  static const String step4Title = 'Buat kata sandi';
  static const String step4Subtitle =
      'Kata sandi minimal 8 karakter untuk keamanan akun Anda.';
  static const String step4FieldLabel = 'Kata Sandi';
  static const String step4FieldHint = 'Masukkan kata sandi';
  static const String step4StrengthWeak = 'Lemah';
  static const String step4StrengthMedium = 'Sedang';
  static const String step4StrengthStrong = 'Kuat';

  // ── Step 5: Konfirmasi Kata Sandi ──────────────────────────────────────────
  static const String step5Title = 'Konfirmasi kata sandi';
  static const String step5Subtitle =
      'Masukkan ulang kata sandi untuk memastikan tidak ada kesalahan.';
  static const String step5FieldLabel = 'Konfirmasi Kata Sandi';
  static const String step5FieldHint = 'Masukkan ulang kata sandi';

  // ── Step 6: Welcome Introduction ───────────────────────────────────────────
  static const String step6Title = 'Lengkapi Data Diri Anda';
  static const String step6Subtitle =
      'Kami akan menyesuaikan pengalaman Digital DSMES berdasarkan informasi tempat tinggal, sosial, pendidikan, dan riwayat diabetes Anda.';
  static const String step6Button = 'Lanjutkan';

  // ── Step 8: Tempat Tinggal ──────────────────────────────────────────────────
  static const String residenceTitle = 'Di mana tempat tinggal Anda?';
  static const String residenceSubtitle =
      'Informasi ini membantu kami menghubungkan Anda dengan fasilitas kesehatan terdekat.';
  static const String residenceCityLabel = 'Kota/Kabupaten';
  static const String residenceDistrictLabel = 'Kecamatan';
  static const String residenceDistrictHint = 'Tulis kecamatan Anda';
  static const String residenceAddressLabel = 'Alamat Lengkap';
  static const String residenceAddressHint = 'Contoh: Jl. Contoh Raya No. 1';

  // ── Step 9: Fasilitas Kesehatan ─────────────────────────────────────────────
  static const String healthFacilityTitle = 'Puskesmas tempat Anda berobat?';
  static const String healthFacilitySubtitle =
      'Pilih puskesmas tempat Anda saat ini berobat.';
  static const String healthFacilityHint = 'Pilih puskesmas';
  static const String healthFacilitySearchHint = 'Cari puskesmas...';
  static const String healthFacilityEmpty = 'Belum ada puskesmas tersedia.';
  static const String healthFacilityLoading = 'Memuat daftar puskesmas...';

  // ── Step 10: Informasi Sosial ───────────────────────────────────────────────
  static const String livingArrangementTitle = 'Tinggal bersama siapa?';
  static const String livingArrangementSubtitle =
      'Informasi ini membantu kami memberikan dukungan yang lebih sesuai.';
  static const String livingAlone = 'Sendiri';
  static const String livingFamily = 'Keluarga';

  // ── Step 11: Pendidikan ─────────────────────────────────────────────────────
  static const String educationTitle = 'Pendidikan terakhir Anda?';
  static const String educationSubtitle =
      'Informasi ini membantu kami menyesuaikan materi edukasi diabetes.';
  static const String educationNoSchool = 'Tidak sekolah';
  static const String educationSD = 'SD';
  static const String educationSMP = 'SMP';
  static const String educationSMK = 'SMA/SMK';
  static const String educationD3 = 'D3';
  static const String educationS1 = 'S1';
  static const String educationS2S3 = 'S2/S3';

  // ── Step 12: Informasi Diabetes ─────────────────────────────────────────────
  static const String diabetesDurationTitle =
      'Lama menderita Diabetes Tipe 2?';
  static const String diabetesDurationSubtitle =
      'Informasi ini membantu kami menyesuaikan program edukasi Anda.';
  static const String diabetesDurationLess1 = '< 1 tahun';
  static const String diabetesDuration1to3 = '1–3 tahun';
  static const String diabetesDuration4to6 = '4–6 tahun';
  static const String diabetesDurationMore6 = '> 6 tahun';

  // ── Step 7: Jenis Kelamin ──────────────────────────────────────────────────
  static const String step7Title = 'Apa jenis kelamin Anda?';
  static const String step7Subtitle =
      'Informasi ini digunakan untuk menghitung kebutuhan kalori harian Anda secara akurat.';
  static const String step7Male = 'Laki-laki';
  static const String step7Female = 'Perempuan';

  // ── Step 8: Tanggal Lahir ──────────────────────────────────────────────────
  static const String step8Title = 'Kapan tanggal lahir Anda?';
  static const String step8Subtitle =
      'Informasi ini membantu kami menyesuaikan program edukasi diabetes sesuai rentang usia Anda.';
  static const String step8FieldLabel = 'Tanggal Lahir';
  static const String step8FieldHint = 'Pilih tanggal lahir';

  // ── Step 9: Golongan Darah ─────────────────────────────────────────────────
  static const String step9Title = 'Apa golongan darah Anda?';
  static const String step9Subtitle =
      'Informasi ini membantu tim medis kami memberikan rekomendasi yang lebih personal.';

  // ── Step 10: Tinggi Badan ──────────────────────────────────────────────────
  static const String step10Title = 'Berapa tinggi badan Anda?';
  static const String step10Subtitle =
      'Informasi ini membantu kami menghitung Indeks Massa Tubuh (IMT) Anda secara akurat.';
  static const String step10Unit = 'cm';

  // ── Step 11: Berat Badan ───────────────────────────────────────────────────
  static const String step11Title = 'Berapa berat badan Anda?';
  static const String step11Subtitle =
      'Informasi ini membantu kami menghitung Indeks Massa Tubuh (IMT) Anda secara akurat.';
  static const String step11Unit = 'kg';

  // ── Step 12: Aktivitas Harian ──────────────────────────────────────────────
  static const String step12Title = 'Pilih Level Aktivitas Harian Anda';
  static const String step12Subtitle =
      'Informasi ini digunakan untuk menghitung kebutuhan kalori harian Anda secara medis.';
  static const String step12Sedentary = 'Sangat Rendah';
  static const String step12SedentaryDesc = 'Jarang berolahraga / aktivitas fisik minimal';
  static const String step12LightlyActive = 'Ringan';
  static const String step12LightlyActiveDesc = 'Olahraga ringan 1–3 hari/minggu';
  static const String step12ModeratelyActive = 'Sedang';
  static const String step12ModeratelyActiveDesc = 'Olahraga intensitas sedang 3–5 hari/minggu';
  static const String step12Active = 'Aktif';
  static const String step12ActiveDesc = 'Olahraga berat 6–7 hari/minggu';
  static const String step12VeryActive = 'Sangat Aktif';
  static const String step12VeryActiveDesc = 'Aktivitas fisik berat setiap hari / atlet';

  // ── Step 13: Result / Summary ──────────────────────────────────────────────
  static const String step13Title = 'Ringkasan Data Diri';
  static const String step13Subtitle =
      'Pastikan data Anda sudah benar sebelum membuat akun.';
  static const String step13LabelName = 'Nama Lengkap';
  static const String step13LabelEmail = 'Email';
  static const String step13LabelPhone = 'Nomor HP';
  static const String step13LabelGender = 'Jenis Kelamin';
  static const String step13LabelBirthDate = 'Tanggal Lahir';
  static const String step13LabelBloodType = 'Golongan Darah';
  static const String step13LabelHeight = 'Tinggi Badan';
  static const String step13LabelWeight = 'Berat Badan';
  static const String step13LabelActivity = 'Aktivitas Harian';
  static const String summaryLabelAddress = 'Alamat';
  static const String summaryLabelDistrict = 'Kecamatan';
  static const String summaryLabelFacility = 'Puskesmas';
  static const String summaryLabelLiving = 'Tinggal Bersama';
  static const String summaryLabelEducation = 'Pendidikan';
  static const String summaryLabelDiabetesDuration = 'Lama Diabetes';
  static const String step13ButtonBack = 'Kembali';
  static const String step13ButtonCreate = 'Buat Akun';
  static const String step13CelebrationTitle = 'Selamat! Profil Anda Siap';
  static const String step13CelebrationSubtitle =
      'Akun Anda telah berhasil dibuat. Mari mulai perjalanan menuju hidup yang lebih sehat.';
  static const String step13CalorieTitle = 'Estimasi Kebutuhan Kalori';
  static const String step13CalorieUnit = 'kcal/hari';
  static const String step13CalorieNote =
      'Jaga pola makan dan aktivitas fisik untuk hasil yang optimal.';
  static const String step13SummaryTitle = 'Data Diri Anda';
  static const String step13RecommendationTitle = 'Rekomendasi Kesehatan';
  static const String step13RecCalories = 'Kebutuhan Kalori Harian';
  static const String step13RecCaloriesValue = 'Sesuaikan asupan dengan kebutuhan kalori harian Anda.';
  static const String step13RecWeight = 'Berat Badan Ideal';
  static const String step13RecWeightValue = 'Jaga berat badan ideal dengan pola makan seimbang.';
  static const String step13RecActivity = 'Aktivitas Fisik';
  static const String step13RecActivityValue = 'Lakukan olahraga rutin minimal 30 menit per hari.';
  static const String step13RecHydration = 'Hidrasi';
  static const String step13RecHydrationValue = 'Minum air putih minimal 8 gelas per hari.';
  static const String step13RecEating = 'Pola Makan Sehat';
  static const String step13RecEatingValue = 'Konsumsi makanan bergizi seimbang sesuai panduan.';
  static const String step13NextStepsTitle = 'Langkah Selanjutnya';
  static const String step13NextStepBloodSugar = 'Catat Gula Darah';
  static const String step13NextStepBloodSugarDesc = 'Pantau kadar gula darah Anda secara rutin.';
  static const String step13NextStepMeals = 'Catat Makanan';
  static const String step13NextStepMealsDesc = 'Lacak asupan nutrisi harian Anda.';
  static const String step13NextStepActivity = 'Lacak Aktivitas Fisik';
  static const String step13NextStepActivityDesc = 'Catat olahraga dan aktivitas harian Anda.';
  static const String step13NextStepEducation = 'Belajar dari Artikel';
  static const String step13NextStepEducationDesc = 'Tingkatkan pengetahuan tentang diabetes.';
  static const String step13NextStepJourney = 'Mulai Perjalanan';

  // ── Daily Routine Setup ────────────────────────────────────────────────────
  static const String dailyRoutineTitle = 'Kustom Waktu Rutinitas';
  static const String dailyRoutineSubtitle =
      'Tentukan jadwal aktivitas sesuai kenyamanan Anda.';
  static const String dailyRoutineInfo =
      'Mengatur jam rutin membantu sistem Digital DSMES menyesuaikan waktu pengingat medis dan saran nutrisi yang paling ideal untuk kestabilan gula darah Anda.';
  static const String dailyRoutineActivity1 = 'Jalan Pagi';
  static const String dailyRoutineActivity1Desc = '07:00';
  static const String dailyRoutineActivity2 = 'Minum Air Putih';
  static const String dailyRoutineActivity2Desc = 'Setiap 2 jam';
  static const String dailyRoutineActivity3 = 'Cek Gula Darah';
  static const String dailyRoutineActivity3Desc = 'Setelah bangun';
  static const String dailyRoutineCustomTimeLabel = 'Waktu Kustom';
  static const String dailyRoutineAddCustom = 'Tambah Rutinitas Kustom';
  static const String dailyRoutineAddCustomTime = 'Tambah Waktu Kustom';
  static const String dailyRoutineAddTitle = 'Tambah Rutinitas Baru';
  static const String dailyRoutineNameLabel = 'Nama Rutinitas';
  static const String dailyRoutineNameHint = 'Contoh: Sarapan';
  static const String dailyRoutineDescHint = 'Deskripsi (opsional)';
  static const String dailyRoutineTimeLabel = 'Waktu';
  static const String dailyRoutineAddButton = 'Tambahkan';
  static const String dailyRoutineReminderQuestion =
      'Apakah ingin menggunakan reminder otomatis?';
  static const String dailyRoutineReminderYes = 'Ya';
  static const String dailyRoutineReminderNo = 'Tidak';
  static const String dailyRoutineButton = 'Lanjut';
  static const String routineDeleteLabel = 'Hapus Rutinitas';
  static const String routineConfirmDeleteTitle = 'Hapus Rutinitas';
  static const String routineConfirmDeleteMessage =
      'Apakah Anda yakin ingin menghapus rutinitas ini?';
  static const String routineIconPickerTitle = 'Pilih Ikon';
  static const String routineRenameTitle = 'Ubah Nama Rutinitas';
  static const String routineIconLabel = 'Ikon';
  static const String labelCancel = 'Batal';
  static const String labelDelete = 'Hapus';
  static const String labelSave = 'Simpan';

  // ── Account Created Successfully ───────────────────────────────────────────
  static const String successTitle = 'Akun Berhasil Dibuat';
  static const String successSubtitle =
      'Selamat datang di DSMES Aceh. Akun Anda telah berhasil dibuat dan rutinitas harian Anda telah dikonfigurasi. Anda sekarang siap untuk memulai perjalanan manajemen mandiri diabetes Anda.';
  static const String successButton = 'Masuk Aplikasi';
  static const String successFeatureRoutineTitle = 'Rutinitas Harian Dikonfigurasi';
  static const String successFeatureRoutineDesc = 'Jadwal aktivitas harian Anda telah disesuaikan.';
  static const String successFeatureProfileTitle = 'Profil Pribadi Diselesaikan';
  static const String successFeatureProfileDesc = 'Data fisik dan kesehatan Anda telah disimpan dengan aman.';
  static const String successFeatureBloodSugarTitle = 'Siap Memantau Gula Darah';
  static const String successFeatureBloodSugarDesc = 'Catat dan pantau perkembangan gula darah secara berkala.';
  static const String successFeatureEducationTitle = 'Fitur Edukasi Tersedia';
  static const String successFeatureEducationDesc = 'Akses artikel dan rekomendasi kesehatan kapan saja.';

  // ── Common ─────────────────────────────────────────────────────────────────
  static const String buttonNext = 'Lanjut';
  static const String buttonPrevious = 'Kembali';
  static const String buttonSaveAndContinue = 'Simpan & Lanjut';
  static const String buttonFinish = 'Selesai';
  static const String loading = 'Memuat...';
  static const String errorGeneral = 'Terjadi kesalahan. Coba lagi.';
  static const String errorNetwork = 'Tidak ada koneksi internet.';
}
