import '../models/body_metrics.dart';
import '../models/user_profile.dart';

/// Mock data and static content for all Settings feature screens.
abstract final class SettingsMockData {
  SettingsMockData._();

  static const String userName = 'Budi Santoso';
  static const String userRole = 'Pasien Diabetes Tipe 2';
  static const String bloodSugarAvg = '124';
  static const String bloodSugarUnit = 'mg/dL';
  static const String bloodSugarStatus = 'Normal';
  static const String profileAvatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBktC0DtJxqbEtNlEPYV1FVAVbANqqOBrBP4UKQsgl2AlACvOPfp2gA6pqoDmKE7cFGQ115Pb60OUS0JMdyb6kbmp6ZPz2ApHtoOK6Cbra5JXSI2FYJkYLVFhEin75-HuAeCkwLYdQP3KU_qDRu3AjscTeEpO5rDfc0UKV-MjDc0ZP-On-CobtdXCXQ5H-U8pcIW1xEWFI7J7HxqJhc1v1wuQrDXyiFaSEQjS8w7kx7q5CzMEqaWpgYZLex-c_q79WzMrr1NIJJ0rB1';

  static UserProfile initialProfile = UserProfile(
    fullName: 'Budi Santoso',
    email: 'budi.santoso@gmail.com',
    phone: '+62 812-3456-7890',
    gender: 'Laki-laki',
    birthDate: DateTime(1981, 5, 14),
    bloodType: 'O+',
  );

  static const BodyMetrics initialMetrics = BodyMetrics(
    heightCm: 168.0,
    weightKg: 68.0,
    activityLevel: 'Aktivitas Sedang',
    gender: 'Laki-laki',
    age: 45,
  );

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
