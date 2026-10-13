import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Syarat & Ketentuan',
          style: AppTextStyles.headlineMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.page,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Badge & Title
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.gavel_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Terakhir diperbarui: 05-Oktober-2026',
                            style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'SYARAT DAN KETENTUAN DIBA',
                      style: AppTextStyles.headlineLg.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Diabetes Behaviour & Adherence Application',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Introduction Card
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat datang di DIBA (Diabetes Behaviour & Adherence Application).',
                      style: AppTextStyles.bodyLg.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Dengan membuat akun atau menggunakan DIBA, Anda menyatakan telah membaca, memahami, dan menyetujui Syarat dan Ketentuan ini.\n\n'
                      'Apabila Anda tidak menyetujui ketentuan yang berlaku, mohon untuk tidak menggunakan DIBA.',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Section 1
              _buildSectionCard(
                number: '1',
                title: 'Tentang DIBA',
                content: Text(
                  'DIBA adalah aplikasi digital yang dirancang untuk membantu pengguna dalam pengelolaan Diabetes Melitus Tipe 2 melalui fitur seperti:\n\n'
                  '• edukasi kesehatan;\n'
                  '• pencatatan kondisi dan aktivitas kesehatan;\n'
                  '• kuesioner;\n'
                  '• pemantauan perilaku;\n'
                  '• dukungan terhadap kepatuhan pengelolaan diabetes; dan\n'
                  '• fitur digital lainnya yang tersedia dalam aplikasi.\n\n'
                  'DIBA dikembangkan sebagai bagian dari kegiatan pengembangan dan penelitian teknologi kesehatan digital.',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.55),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Section 2 - Medical Disclaimer
              _buildSectionCard(
                number: '2',
                title: 'Bukan Pengganti Tenaga Kesehatan',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAlertBox(
                      icon: Icons.medical_services_outlined,
                      title: 'Peringatan Medis Penting',
                      text:
                          'DIBA merupakan alat pendukung dan BUKAN PENGGANTI DOKTER, tenaga kesehatan, diagnosis medis, maupun perawatan medis profesional.',
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Informasi yang tersedia dalam aplikasi ditujukan untuk mendukung edukasi dan pengelolaan mandiri.\n\n'
                      'Pengguna tidak boleh menjadikan informasi dari DIBA sebagai satu-satunya dasar untuk:',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildBulletList([
                      'mendiagnosis kondisi kesehatan;',
                      'mengubah dosis atau menghentikan obat;',
                      'memulai pengobatan tertentu; atau',
                      'mengambil keputusan medis yang seharusnya dilakukan bersama tenaga kesehatan.',
                    ]),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Apabila mengalami kondisi kesehatan yang membutuhkan perhatian medis, pengguna disarankan untuk berkonsultasi dengan tenaga kesehatan.',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Section 3
              _buildSectionCard(
                number: '3',
                title: 'Akun Pengguna',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Beberapa fitur DIBA memerlukan akun pengguna. Pengguna bertanggung jawab untuk:',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildBulletList([
                      'memberikan informasi yang benar dan akurat;',
                      'menjaga kerahasiaan informasi akun;',
                      'menjaga keamanan kredensial login;',
                      'tidak membagikan akun kepada orang lain; dan',
                      'segera melaporkan penggunaan akun yang tidak sah.',
                    ]),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Pengguna bertanggung jawab atas aktivitas yang dilakukan melalui akun miliknya sepanjang aktivitas tersebut berada dalam kendalinya.',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Section 4
              _buildSectionCard(
                number: '4',
                title: 'Keakuratan Data',
                content: Text(
                  'Pengguna bertanggung jawab untuk memasukkan informasi yang benar dan sesuai dengan kondisi sebenarnya.\n\n'
                  'Data seperti kadar gula darah, aktivitas fisik, pola makan, penggunaan obat, berat badan, dan informasi kesehatan lainnya sebaiknya dimasukkan secara akurat agar informasi yang tersimpan dalam aplikasi dapat digunakan secara tepat.\n\n'
                  'DIBA tidak bertanggung jawab atas keputusan yang diambil berdasarkan data yang dimasukkan secara tidak benar atau tidak lengkap oleh pengguna.',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.55),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Section 5
              _buildSectionCard(
                number: '5',
                title: 'Penggunaan untuk Penelitian',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DIBA dapat digunakan dalam kegiatan penelitian dan evaluasi teknologi kesehatan digital.\n\n'
                      'Data yang dikumpulkan melalui aplikasi dapat digunakan untuk analisis penelitian, evaluasi aplikasi, penyusunan laporan akademik, publikasi ilmiah, serta pengembangan penelitian lanjutan sesuai dengan dasar pemrosesan dan persetujuan yang berlaku.\n\n'
                      'Penggunaan DIBA sebagai peserta penelitian dapat memerlukan proses informed consent tersendiri.',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildAlertBox(
                      icon: Icons.assignment_turned_in_outlined,
                      title: 'Pemberitahuan Etika Penelitian',
                      text: 'Persetujuan terhadap Syarat dan Ketentuan ini TIDAK MENGGANTIKAN informed consent penelitian.',
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Section 6
              _buildSectionCard(
                number: '6',
                title: 'Penelitian Lanjutan dan Pengembangan Teknologi',
                content: Text(
                  'Data yang diperoleh melalui DIBA dapat berpotensi digunakan untuk penelitian lanjutan yang berkaitan dengan diabetes, kesehatan digital, perilaku kesehatan, kepatuhan, dan pengembangan teknologi kesehatan.\n\n'
                  'Apabila suatu penggunaan data memerlukan persetujuan tambahan berdasarkan tujuan atau ketentuan yang berlaku, proses persetujuan tambahan akan dilakukan sesuai kebutuhan.',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.55),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Section 7
              _buildSectionCard(
                number: '7',
                title: 'Artificial Intelligence dan Machine Learning',
                content: Text(
                  'DIBA dapat menggunakan atau mengembangkan teknologi Artificial Intelligence (AI), Machine Learning (ML), atau teknologi analitik lainnya.\n\n'
                  'Penggunaan data untuk pengembangan AI/ML tidak secara otomatis diberikan hanya karena pengguna menggunakan aplikasi.\n\n'
                  'Apabila diperlukan persetujuan tambahan untuk penggunaan data dalam pengembangan atau pelatihan model AI/ML, pengguna akan diberikan informasi dan dimintai persetujuan sesuai dengan ketentuan yang berlaku.',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.55),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Section 8
              _buildSectionCard(
                number: '8',
                title: 'Ketersediaan Layanan',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kami berupaya menjaga DIBA agar dapat digunakan dengan baik. Namun, kami tidak menjamin bahwa aplikasi akan:',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildBulletList([
                      'selalu tersedia tanpa gangguan;',
                      'bebas dari kesalahan;',
                      'bebas dari masalah teknis; atau',
                      'tersedia pada setiap waktu.',
                    ]),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Layanan dapat mengalami gangguan sementara karena pemeliharaan, pembaruan, masalah jaringan, kegagalan sistem, atau keadaan lain di luar kendali kami.',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Section 9
              _buildSectionCard(
                number: '9',
                title: 'Keamanan Akun dan Sistem',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengguna dilarang melakukan tindakan yang dapat mengganggu keamanan atau operasional DIBA, termasuk:',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildBulletList([
                      'mencoba memperoleh akses tanpa izin;',
                      'mengakses akun pengguna lain;',
                      'melakukan eksploitasi terhadap sistem;',
                      'menyebarkan malware;',
                      'melakukan tindakan yang mengganggu server atau layanan; atau',
                      'menggunakan aplikasi untuk tujuan yang melanggar hukum.',
                    ]),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Kami berhak melakukan tindakan yang diperlukan untuk melindungi keamanan sistem dan pengguna.',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Section 10
              _buildSectionCard(
                number: '10',
                title: 'Hak Kekayaan Intelektual',
                content: Text(
                  'Seluruh elemen DIBA, termasuk namun tidak terbatas pada:\n'
                  '• nama dan identitas aplikasi;\n'
                  '• desain antarmuka;\n'
                  '• perangkat lunak;\n'
                  '• struktur sistem;\n'
                  '• konten edukasi;\n'
                  '• logo;\n'
                  '• teks; dan\n'
                  '• materi lainnya,\n\n'
                  'merupakan milik atau digunakan secara sah oleh pihak yang mengembangkan atau mengelola DIBA, kecuali dinyatakan lain.\n\n'
                  'Pengguna tidak diperbolehkan menyalin, memodifikasi, mendistribusikan, menjual, atau menggunakan elemen DIBA untuk tujuan komersial tanpa izin yang sah.',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.55),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Section 11
              _buildSectionCard(
                number: '11',
                title: 'Larangan Penggunaan',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengguna tidak diperbolehkan menggunakan DIBA untuk:',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildNumberedList([
                      'melakukan tindakan yang melanggar hukum;',
                      'memberikan informasi palsu dengan sengaja;',
                      'mengakses data pengguna lain tanpa izin;',
                      'mengganggu keamanan atau operasional sistem;',
                      'melakukan reverse engineering tanpa dasar atau izin yang diperbolehkan;',
                      'menyebarkan konten berbahaya melalui sistem; atau',
                      'menggunakan aplikasi untuk tujuan yang bertentangan dengan fungsi dan ketentuan DIBA.',
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Section 12
              _buildSectionCard(
                number: '12',
                title: 'Batasan Tanggung Jawab',
                content: Text(
                  'DIBA disediakan sebagai sarana pendukung edukasi, pencatatan, dan pengelolaan mandiri.\n\n'
                  'Kami tidak bertanggung jawab atas keputusan medis yang dibuat pengguna secara mandiri berdasarkan informasi dalam aplikasi tanpa konsultasi dengan tenaga kesehatan.\n\n'
                  'Kami juga tidak bertanggung jawab atas kerugian yang timbul akibat:\n'
                  '• data yang dimasukkan pengguna secara tidak benar;\n'
                  '• penggunaan aplikasi yang tidak sesuai ketentuan;\n'
                  '• gangguan perangkat atau jaringan pengguna;\n'
                  '• akses akun oleh pihak yang memperoleh kredensial pengguna; atau\n'
                  '• kondisi lain yang berada di luar kendali pengelola DIBA,\n\n'
                  'sejauh diperbolehkan oleh ketentuan hukum yang berlaku.',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.55),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Section 13
              _buildSectionCard(
                number: '13',
                title: 'Penghentian atau Pembatasan Akses',
                content: Text(
                  'Kami dapat membatasi atau menghentikan akses pengguna terhadap DIBA apabila terdapat:\n'
                  '• pelanggaran terhadap Syarat dan Ketentuan;\n'
                  '• aktivitas yang mengancam keamanan sistem;\n'
                  '• penggunaan yang melanggar hukum; atau\n'
                  '• alasan teknis maupun operasional yang diperlukan untuk melindungi sistem dan pengguna.',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.55),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Section 14
              _buildSectionCard(
                number: '14',
                title: 'Perubahan Syarat dan Ketentuan',
                content: Text(
                  'Syarat dan Ketentuan ini dapat diperbarui dari waktu ke waktu untuk menyesuaikan dengan perubahan fitur DIBA, perkembangan penelitian, perkembangan teknologi, perubahan layanan, atau perubahan ketentuan hukum yang berlaku.\n\n'
                  'Perubahan penting akan diinformasikan melalui aplikasi atau media komunikasi yang sesuai.\n\n'
                  'Dengan tetap menggunakan DIBA setelah perubahan berlaku, pengguna dianggap telah membaca dan memahami ketentuan yang diperbarui.',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.55),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Final Ethics Note Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: AppRadius.card,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_outlined,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Pernyataan Persetujuan',
                            style: AppTextStyles.labelLg.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Dengan menggunakan DIBA, pengguna menyatakan bahwa pengguna telah membaca, memahami, dan menyetujui Syarat dan Ketentuan ini.\n\n'
                      'Penggunaan DIBA untuk kegiatan penelitian tetap mengikuti prosedur informed consent dan ketentuan etika penelitian yang berlaku.',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: AppShadows.soft,
      ),
      child: child,
    );
  }

  Widget _buildSectionCard({
    required String number,
    required String title,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  number,
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.headlineMdMobile.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          content,
        ],
      ),
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 7, right: 8),
                child: Icon(Icons.circle, size: 6, color: AppColors.primary),
              ),
              Expanded(
                child: Text(
                  item,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumberedList(List<String> items) {
    return Column(
      children: items.asMap().entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22,
                child: Text(
                  '${entry.key + 1}.',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  entry.value,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAlertBox({
    required IconData icon,
    required String title,
    required String text,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.labelMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
              height: 1.4,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}
