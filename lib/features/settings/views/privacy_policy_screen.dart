import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Kebijakan Privasi',
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
              // Header Badge & App Title
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
                            Icons.verified_user_outlined,
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
                      'KEBIJAKAN PRIVASI DIBA',
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
                      'DIBA adalah aplikasi digital yang dikembangkan untuk membantu pengguna dalam mendukung pengelolaan mandiri Diabetes Melitus Tipe 2 melalui edukasi, pencatatan kesehatan, kuesioner, serta pemantauan perilaku dan kepatuhan terhadap pengelolaan diabetes.\n\n'
                      'DIBA juga dikembangkan dalam konteks penelitian dan pengembangan teknologi kesehatan digital. Kami memahami bahwa data kesehatan merupakan informasi pribadi yang sensitif. Oleh karena itu, kami berkomitmen untuk mengelola data pengguna secara bertanggung jawab, aman, dan sesuai dengan tujuan pemrosesan serta ketentuan yang berlaku.',
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
                title: 'Data yang Kami Kumpulkan',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Untuk menjalankan fitur dan mendukung kegiatan penelitian, DIBA dapat memproses beberapa jenis data:',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildSubHeader('A. Data Identitas dan Akun'),
                    _buildBulletList([
                      'Nama',
                      'Alamat email',
                      'Nomor telepon, apabila diperlukan',
                      'Informasi demografis yang relevan',
                      'Informasi autentikasi akun',
                      'Informasi lain yang diberikan pengguna saat menggunakan aplikasi',
                    ]),
                    const SizedBox(height: AppSpacing.md),
                    _buildSubHeader('B. Data Kesehatan'),
                    _buildBulletList([
                      'Catatan kadar gula darah',
                      'Aktivitas fisik',
                      'Pola makan',
                      'Penggunaan obat',
                      'Berat badan dan indeks massa tubuh (BMI)',
                      'Hasil kuesioner',
                      'Informasi terkait perilaku pengelolaan diabetes',
                      'Informasi kepatuhan terhadap pengobatan atau aktivitas pengelolaan diabetes',
                      'Informasi kesehatan lain yang diberikan secara sukarela melalui aplikasi',
                    ]),
                    const SizedBox(height: AppSpacing.sm),
                    _buildHighlightNotice(
                      'Data dan informasi kesehatan merupakan data pribadi yang bersifat spesifik sehingga akan dikelola dengan perhatian khusus terhadap keamanan dan privasinya.',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildSubHeader('C. Data Aktivitas dan Penggunaan Aplikasi'),
                    _buildBulletList([
                      'Waktu dan frekuensi penggunaan',
                      'Fitur yang digunakan',
                      'Aktivitas pada aplikasi',
                      'Penyelesaian materi edukasi',
                      'Pengisian kuesioner',
                      'Informasi teknis yang diperlukan untuk menjaga keamanan dan pengoperasian aplikasi',
                    ]),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Data penggunaan tersebut dapat digunakan untuk memahami penggunaan aplikasi, termasuk tingkat penggunaan, kepatuhan, penyelesaian aktivitas, dan pengalaman pengguna.',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Section 2
              _buildSectionCard(
                number: '2',
                title: 'Tujuan Penggunaan Data',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data pengguna dapat digunakan untuk:',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildNumberedList([
                      'Membuat dan mengelola akun pengguna;',
                      'Menyediakan fitur dan layanan DIBA;',
                      'Menyediakan edukasi dan dukungan pengelolaan mandiri diabetes;',
                      'Menyimpan dan menampilkan catatan kesehatan yang dimasukkan pengguna;',
                      'Mendukung pemantauan perilaku dan kepatuhan dalam pengelolaan diabetes;',
                      'Mengevaluasi usability, acceptability, feasibility, dan pengalaman pengguna;',
                      'Melakukan analisis dan evaluasi penelitian;',
                      'Menyusun laporan dan publikasi ilmiah;',
                      'Mendukung penelitian dan pengembangan DIBA di masa mendatang; dan',
                      'Menjaga keamanan, stabilitas, dan kualitas sistem.',
                    ]),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Data hanya akan diproses sesuai dengan tujuan yang telah diinformasikan kepada pengguna dan dasar pemrosesan yang berlaku.',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Section 3
              _buildSectionCard(
                number: '3',
                title: 'Penggunaan Data untuk Penelitian',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DIBA dikembangkan dalam konteks penelitian mengenai pemanfaatan teknologi digital untuk mendukung pengelolaan Diabetes Melitus Tipe 2.\n\n'
                      'Data yang dikumpulkan melalui DIBA dapat digunakan dalam analisis penelitian, termasuk data kuesioner, aktivitas penggunaan aplikasi, catatan kesehatan, dan informasi lain yang relevan dengan penelitian.\n\n'
                      'Hasil penelitian dapat digunakan untuk:',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildBulletList([
                      'Laporan penelitian',
                      'Tugas akhir atau karya akademik',
                      'Publikasi jurnal',
                      'Presentasi ilmiah',
                      'Pengembangan aplikasi',
                      'Kegiatan akademik atau penelitian lainnya yang relevan',
                    ]),
                    const SizedBox(height: AppSpacing.sm),
                    _buildHighlightNotice(
                      'Dalam publikasi atau penyampaian hasil penelitian, data akan diupayakan dalam bentuk agregat, anonim, atau melalui proses lain yang sesuai sehingga identitas pengguna tidak diungkapkan secara langsung.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Section 4
              _buildSectionCard(
                number: '4',
                title: 'Penelitian dan Pengembangan di Masa Mendatang',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data yang diperoleh melalui DIBA dapat berpotensi digunakan untuk penelitian lanjutan yang masih berkaitan dengan pengelolaan diabetes, kesehatan digital, perilaku kesehatan, kepatuhan, maupun evaluasi dan pengembangan DIBA.\n\n'
                      'Penelitian lanjutan dapat mencakup, antara lain:',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildBulletList([
                      'Evaluasi efektivitas aplikasi',
                      'Penelitian dengan jumlah pengguna yang lebih besar',
                      'Analisis perilaku dan kepatuhan',
                      'Analisis dampak kesehatan, sosial, atau ekonomi',
                      'Pengembangan fitur kesehatan digital',
                      'Evaluasi teknologi pendukung pengelolaan diabetes',
                    ]),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Apabila terdapat penggunaan data untuk tujuan baru yang memerlukan dasar pemrosesan atau persetujuan tambahan, pengguna akan diberikan informasi dan/atau dimintai persetujuan sesuai dengan ketentuan yang berlaku.',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Section 5
              _buildSectionCard(
                number: '5',
                title: 'Penggunaan Data untuk AI dan Machine Learning',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DIBA dapat menggunakan atau mengembangkan teknologi Artificial Intelligence (AI), Machine Learning (ML), atau teknologi analitik lainnya di masa mendatang.\n\n'
                      'Data pengguna dapat dipertimbangkan untuk digunakan dalam:',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildBulletList([
                      'Penelitian dan pengembangan model AI/ML',
                      'Evaluasi performa model',
                      'Pengembangan sistem prediksi',
                      'Pengembangan sistem rekomendasi',
                      'Pengembangan teknologi kesehatan digital lainnya',
                    ]),
                    const SizedBox(height: AppSpacing.sm),
                    _buildHighlightNotice(
                      'Penggunaan aplikasi DIBA tidak secara otomatis berarti bahwa seluruh data pengguna dapat digunakan untuk melatih model AI.\n\n'
                      'Apabila penggunaan data untuk pengembangan atau pelatihan AI menjadi tujuan baru yang memerlukan persetujuan tambahan, pengguna akan diberikan informasi yang relevan dan persetujuan tambahan akan diperoleh apabila diperlukan.\n\n'
                      'Sedapat mungkin, data yang digunakan untuk pengembangan AI/ML akan melalui proses de-identifikasi atau pseudonimisasi, dan hanya data yang relevan dengan tujuan pengembangan yang akan digunakan.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Section 6
              _buildSectionCard(
                number: '6',
                title: 'Penggunaan Data yang Tidak Diizinkan',
                content: Text(
                  'Data pengguna tidak akan digunakan untuk tujuan yang tidak berkaitan dengan fungsi aplikasi atau tujuan penelitian yang telah diinformasikan tanpa dasar pemrosesan yang sah.\n\n'
                  'DIBA juga tidak menjual data kesehatan pengguna kepada pihak lain.',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Section 7
              _buildSectionCard(
                number: '7',
                title: 'Akses terhadap Data',
                content: Text(
                  'Akses terhadap data dibatasi berdasarkan kebutuhan dan kewenangan.\n\n'
                  'Data dapat diakses oleh pihak yang berwenang dalam pengelolaan DIBA, pelaksanaan penelitian, pengembangan sistem, atau penyediaan layanan teknis yang diperlukan.\n\n'
                  'Akses diberikan berdasarkan prinsip need-to-know, yaitu hanya pihak yang membutuhkan data untuk menjalankan tanggung jawabnya yang dapat memperoleh akses sesuai kewenangannya.',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Section 8
              _buildSectionCard(
                number: '8',
                title: 'Keamanan Data',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kami menerapkan langkah-langkah teknis dan organisasi yang wajar untuk menjaga data pengguna dari:',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildBulletList([
                      'Akses yang tidak sah',
                      'Kehilangan',
                      'Penyalahgunaan',
                      'Perubahan tanpa izin',
                      'Pengungkapan tanpa izin',
                      'Penghancuran yang tidak sah',
                    ]),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Meskipun demikian, tidak ada sistem elektronik yang dapat menjamin keamanan secara mutlak.\n\n'
                      'Apabila terjadi insiden keamanan yang memenuhi ketentuan pemberitahuan berdasarkan peraturan yang berlaku, tindakan penanganan dan pemberitahuan akan dilakukan sesuai ketentuan tersebut.',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Section 9
              _buildSectionCard(
                number: '9',
                title: 'Penyimpanan dan Retensi Data',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data pengguna dapat disimpan selama diperlukan untuk:',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildBulletList([
                      'Menyediakan layanan DIBA',
                      'Menjalankan dan mengevaluasi penelitian',
                      'Mendukung pengembangan aplikasi',
                      'Memenuhi kewajiban hukum dan administratif',
                      'Menjaga integritas serta validitas hasil penelitian',
                    ]),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Setelah data tidak lagi diperlukan, data dapat dihapus, dimusnahkan, atau dianonimkan sesuai kebutuhan dan ketentuan yang berlaku.',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Section 10
              _buildSectionCard(
                number: '10',
                title: 'Hak Pengguna',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengguna pada prinsipnya memiliki hak atas data pribadinya sesuai dengan ketentuan yang berlaku. Hak tersebut dapat mencakup hak untuk:',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildBulletList([
                      'Memperoleh informasi mengenai pemrosesan data',
                      'Memperbaiki data yang tidak akurat',
                      'Memperoleh akses terhadap data sesuai ketentuan',
                      'Meminta penghapusan data dalam kondisi yang diperbolehkan',
                      'Menggunakan hak lain yang diberikan oleh peraturan perundang-undangan',
                    ]),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Permintaan terkait data pribadi dapat disampaikan melalui kontak resmi DIBA.\n\n'
                      'Dalam konteks penelitian, terdapat kondisi tertentu di mana data mungkin tetap perlu dipertahankan untuk kepentingan penelitian, audit, kewajiban hukum, atau menjaga integritas hasil penelitian sesuai ketentuan yang berlaku.',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Section 11
              _buildSectionCard(
                number: '11',
                title: 'Penyedia Layanan dan Pihak Ketiga',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Untuk menjalankan DIBA, kami dapat menggunakan penyedia layanan teknologi seperti:',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildBulletList([
                      'Server dan infrastruktur cloud',
                      'Penyimpanan data',
                      'Layanan notifikasi (FCM)',
                      'Layanan autentikasi',
                      'Layanan teknis lainnya',
                    ]),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Pihak ketiga hanya diberikan akses sejauh diperlukan untuk menjalankan layanan dan sesuai dengan kewenangan yang diberikan.',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Section 12
              _buildSectionCard(
                number: '12',
                title: 'Perubahan Kebijakan Privasi',
                content: Text(
                  'Kebijakan Privasi ini dapat diperbarui dari waktu ke waktu untuk menyesuaikan dengan perubahan fitur DIBA, perkembangan penelitian, perkembangan teknologi, perubahan proses pemrosesan data, atau perubahan ketentuan hukum yang berlaku.\n\n'
                  'Perubahan penting akan diinformasikan melalui aplikasi atau media komunikasi yang sesuai.',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Section 13
              _buildSectionCard(
                number: '13',
                title: 'Hubungi Kami',
                content: Text(
                  'Apabila Anda memiliki pertanyaan mengenai Kebijakan Privasi, penggunaan data, atau perlindungan data pribadi, Anda dapat menghubungi tim pengembang DIBA melalui Pusat Bantuan atau kontak resmi institusi penelitian.',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Mandatory Ethics / Research Disclaimer Box
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
                            'Pemberitahuan Etika Penelitian',
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
                      'Dengan menggunakan DIBA, pengguna menyatakan telah membaca dan memahami Kebijakan Privasi ini.\n\n'
                      'Kebijakan Privasi ini tidak menggantikan informed consent penelitian. Apabila pengguna diikutsertakan sebagai peserta penelitian, proses persetujuan penelitian akan dilakukan sesuai dengan prosedur dan ketentuan etika penelitian yang berlaku.',
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

  Widget _buildSubHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: AppTextStyles.bodyLg.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
          fontSize: 14,
        ),
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

  Widget _buildHighlightNotice(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.tertiaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.tertiary.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyMd.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w500,
          height: 1.45,
          fontSize: 12.5,
        ),
      ),
    );
  }
}
