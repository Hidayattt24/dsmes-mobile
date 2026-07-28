/// Static content for Settings feature screens (FAQs, activity options).
abstract final class SettingsMockData {
  SettingsMockData._();

  static const List<(String, String)> activityOptions = [
    ('Sangat Jarang', 'Minim aktivitas fisik, banyak duduk'),
    ('Aktivitas Ringan', 'Olahraga ringan 1-3 hari/minggu'),
    ('Aktivitas Sedang', 'Olahraga sedang 3-5 hari/minggu'),
    ('Aktivitas Berat', 'Olahraga berat 6-7 hari/minggu'),
    ('Sangat Aktif', 'Olahraga sangat berat / pekerjaan fisik'),
  ];

  static const List<(String, String)> faqList = [
    (
      'Apa itu aplikasi DSMES Aceh?',
      'DSMES (Diabetes Self-Management Education and Support) Aceh adalah aplikasi edukasi dan pemantauan mandiri untuk membantu pasien diabetes mengelola kesehatan harian secara optimal.'
    ),
    (
      'Bagaimana cara menghitung kebutuhan kalori harian saya?',
      'Aplikasi DSMES menghitung kalori harian berdasarkan pengukuran tinggi badan, berat badan, usia, jenis kelamin, dan tingkat aktivitas harian Anda menggunakan rumus Mifflin-St Jeor.'
    ),
    (
      'Seberapa sering saya harus memperbarui indikator tubuh?',
      'Disarankan untuk memperbarui berat badan dan tingkat aktivitas setiap 2-4 minggu sekali atau saat mengalami perubahan pola aktivitas fisik yang signifikan.'
    ),
    (
      'Apakah data kesehatan saya aman?',
      'Ya, seluruh data tersimpan secara terbatas pada perangkat Anda dan dilindungi dengan standar keamanan privasi data kesehatan.'
    ),
    (
      'Bagaimana cara mengaktifkan pengingat obat dan gula darah?',
      'Buka menu Pengaturan > Pengaturan Pengingat, lalu aktifkan sakelar pengingat dan atur waktu jam pengingat sesuai jadwal harian Anda.'
    ),
  ];
}
