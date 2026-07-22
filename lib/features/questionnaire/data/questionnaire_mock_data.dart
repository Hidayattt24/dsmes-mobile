import '../models/questionnaire.dart';
import '../models/questionnaire_question.dart';

abstract class MockQuestionnaireData {
  MockQuestionnaireData._();

  static const List<String> categories = [
    'Semua',
    'Nutrisi',
    'Obat-obatan',
    'Aktivitas',
    'Insulin',
  ];

  static int completedCount = 8;
  static int uncompletedCount = 5;
  static double averageScore = 85.0;

  static final List<Questionnaire> _questionnaires = [
    Questionnaire(
      id: 'q_1',
      title: 'Pola Makan Sehat untuk Diabetes',
      category: 'Manajemen Diet',
      iconName: 'menu_book',
      imageUrl: 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=800',
      description:
          'Kuesioner ini bertujuan untuk mengevaluasi pemahaman Anda tentang pengaturan waktu makan, kontrol porsi, dan pemilihan jenis makanan yang tepat dalam manajemen diabetes sehari-hari.',
      difficulty: 'Mudah',
      questionCount: 10,
      estimatedMinutes: 5,
      educationStatus: 'Belum Membaca Edukasi',
      isCompleted: false,
      questions: const [
        QuestionnaireQuestion(
          id: 'q1_1',
          questionText:
              'Berapa kali porsi sayuran yang disarankan untuk dikonsumsi dalam sehari bagi penderita diabetes?',
          options: [
            '1 - 2 porsi',
            '3 - 5 porsi',
            '6 - 8 porsi',
            'Lebih dari 8 porsi',
          ],
          correctAnswerIndex: 1,
          explanation:
              'Penyandang diabetes disarankan mengonsumsi 3-5 porsi sayuran segar non-tepung sehari untuk memenuhi kebutuhan serat.',
        ),
        QuestionnaireQuestion(
          id: 'q1_2',
          questionText:
              'Manakah jenis karbohidrat yang paling baik dikonsumsi untuk mencegah lonjakan gula darah mendadak?',
          options: [
            'Nasi putih hangat porsi besar',
            'Karbohidrat kompleks berindeks glikemik rendah (Beras Merah/Oat)',
            'Minuman manis bersoda',
            'Roti tawar putih',
          ],
          correctAnswerIndex: 1,
          explanation:
              'Karbohidrat kompleks diserap lebih lambat oleh saluran cerna sehingga menjaga kadar gula darah tetap stabil.',
        ),
        QuestionnaireQuestion(
          id: 'q1_3',
          questionText:
              'Berapa porsi piring makan seimbang (Piring T) yang disarankan diisi oleh sayuran non-tepung?',
          options: [
            '1/2 piring',
            '1/4 piring',
            '3/4 piring',
            'Seluruh piring',
          ],
          correctAnswerIndex: 0,
          explanation:
              'Konsep Piring T menganjurkan 1/2 piring diisi sayuran, 1/4 karbohidrat, dan 1/4 lauk pauk protein.',
        ),
      ],
    ),
    Questionnaire(
      id: 'q_2',
      title: 'Olahraga untuk Diabetes',
      category: 'Aktivitas',
      iconName: 'fitness_center',
      iconBgColorHex: '#ABF4AC',
      imageUrl: 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800',
      description:
          'Evaluasi pemahaman tentang jenis olahraga yang aman, durasi aktivitas fisik mingguan, dan cara mencegah hipoglikemia saat berolahraga.',
      difficulty: 'Sedang',
      questionCount: 8,
      estimatedMinutes: 4,
      educationStatus: '✓ Selesai',
      isCompleted: true,
      scorePercentage: 90.0,
      questions: const [
        QuestionnaireQuestion(
          id: 'q2_1',
          questionText:
              'Berapa total durasi aktivitas fisik intensitas sedang yang direkomendasikan per minggu?',
          options: [
            'Minimal 150 menit / minggu',
            'Cukup 30 menit / minggu',
            'Minimal 300 menit / minggu',
            'Tidak direkomendasikan olahraga',
          ],
          correctAnswerIndex: 0,
          explanation:
              'Disarankan berolahraga aerobik sedang minimal 150 menit per minggu, terbagi dalam 3-5 hari.',
        ),
        QuestionnaireQuestion(
          id: 'q2_2',
          questionText:
              'Seberapa sering Anda harus memeriksa kondisi kaki jika Anda didiagnosis diabetes?',
          options: [
            'Seminggu sekali',
            'Setiap hari',
            'Sebulan sekali',
            'Hanya saat terasa sakit',
          ],
          correctAnswerIndex: 1,
          explanation:
              'Pemeriksaan kaki harian sangat penting untuk mendeteksi kapalan atau luka kecil sebelum berkembang menjadi ulkus.',
        ),
      ],
    ),
    Questionnaire(
      id: 'q_3',
      title: 'Komplikasi Diabetes',
      category: 'Umum',
      iconName: 'check_circle',
      iconBgColorHex: '#ABF4AC',
      imageUrl: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800',
      description:
          'Ketahui gejala awal komplikasi diabetes pada mata, ginjal, saraf, dan jantung serta langkah pencegahannya sejak dini.',
      difficulty: 'Sedang',
      questionCount: 15,
      estimatedMinutes: 10,
      educationStatus: '✓ Edukasi Selesai',
      isEducationCompleted: true,
      isCompleted: false,
      questions: const [
        QuestionnaireQuestion(
          id: 'q3_1',
          questionText:
              'Apa langkah pertama yang harus dilakukan saat mengalami gejala hipoglikemia (gula darah drop)?',
          options: [
            'Konsumsi 15 gram karbohidrat cepat serap (air gula/jus)',
            'Langsung tidur terlentang',
            'Suntik insulin porsi ganda',
            'Berlari maraton',
          ],
          correctAnswerIndex: 0,
          explanation:
              'Aturan 15-15: Konsumsi 15 gram gula cepat serap, tunggu 15 menit, lalu periksa ulang gula darah Anda.',
        ),
      ],
    ),
    Questionnaire(
      id: 'q_4',
      title: 'Penggunaan Obat-obatan Mandiri',
      category: 'Obat-obatan',
      iconName: 'medication',
      imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=800',
      description:
          'Pemahaman mengenai jadwal pemberian obat oral, aturan sebelum/sesudah makan, dan cara menangani efek samping obat.',
      difficulty: 'Mudah',
      questionCount: 10,
      estimatedMinutes: 6,
      educationStatus: 'Belum Membaca Edukasi',
      isCompleted: false,
      questions: const [
        QuestionnaireQuestion(
          id: 'q4_1',
          questionText:
              'Kapan waktu yang paling tepat untuk minum obat Metformin sesuai anjuran medis?',
          options: [
            'Bersamaan dengan makan atau segera setelah makan',
            'Saat perut kosong 2 jam sebelum makan',
            'Hanya saat gula darah terasa tinggi',
            'Sebelum tidur malam',
          ],
          correctAnswerIndex: 0,
          explanation:
              'Metformin diminum bersamaan atau sesudah makan untuk meminimalkan rasa mual dan gangguan pencernaan.',
        ),
      ],
    ),
  ];

  static List<Questionnaire> get questionnaires => List.unmodifiable(_questionnaires);

  static Questionnaire getQuestionnaireById(String id) {
    return _questionnaires.firstWhere(
      (q) => q.id == id,
      orElse: () => _questionnaires.first,
    );
  }

  static List<Questionnaire> filterQuestionnaires({
    String query = '',
    String category = 'Semua',
  }) {
    return _questionnaires.where((q) {
      final matchesQuery = query.isEmpty ||
          q.title.toLowerCase().contains(query.toLowerCase()) ||
          q.category.toLowerCase().contains(query.toLowerCase());
      final matchesCategory = category == 'Semua' || q.category == category;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  static void markCompleted(String id, double score) {
    final index = _questionnaires.indexWhere((q) => q.id == id);
    if (index != -1) {
      final current = _questionnaires[index];
      _questionnaires[index] = current.copyWith(
        isCompleted: true,
        scorePercentage: score,
        educationStatus: '✓ Selesai',
      );
      completedCount++;
      if (uncompletedCount > 0) uncompletedCount--;
    }
  }
}
