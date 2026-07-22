import '../models/education_article.dart';

abstract class MockEducationData {
  MockEducationData._();

  static final Set<String> _bookmarkedIds = {'art_featured', 'art_1'};

  static const List<String> categories = [
    'Semua',
    'Nutrisi',
    'Aktivitas',
    'Pengobatan',
    'Umum',
    'Gula Darah',
    'Komplikasi',
    'Resep Sehat',
  ];

  static final EducationArticle featuredArticle = EducationArticle(
    id: 'art_featured',
    title: 'Panduan Nutrisi Harian untuk Pengelolaan Gula Darah Optimal',
    category: 'Nutrisi',
    readTime: '12 menit',
    author: 'Dr. Syarifah M.',
    date: '24 Oktober 2023',
    views: 1240,
    tagText: 'Terbaru',
    imageUrl: 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=800',
    hasVideo: true,
    videoUrl: 'https://www.youtube.com/watch?v=mock_dsmes_nutrition',
    videoDuration: '08:45',
    channelName: 'DSMES Aceh Official',
    isBookmarked: true,
    quoteText:
        '"Diabetes Melitus adalah kondisi kronis yang memerlukan perhatian berkelanjutan. Melalui edukasi manajemen mandiri (DSMES), pasien dapat secara signifikan meningkatkan kualitas hidup dan mengurangi risiko komplikasi jangka panjang."',
    bodyParagraphs: const [
      'Dalam artikel ini, kita akan membahas pilar-pilar utama pengelolaan diabetes, mulai dari pemantauan kadar gula darah secara mandiri, pengaturan pola makan yang seimbang, hingga pentingnya aktivitas fisik yang terukur. Pemahaman mendalam mengenai mekanisme penyakit membantu pasien mengambil keputusan yang tepat dalam situasi sehari-hari.',
    ],
    galleryImageUrls: const [
      'https://images.unsplash.com/photo-1505576399279-565b52d4ac71?w=400',
      'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=400',
    ],
    sections: const [
      ArticleSectionData(
        title: 'Pentingnya Pemantauan Rutin',
        content:
            'Monitoring rutin bukan sekadar mencatat angka. Ini adalah proses belajar tentang bagaimana tubuh Anda merespons berbagai faktor seperti stres, makanan tertentu, dan olahraga. Data ini sangat krusial bagi tenaga medis untuk menyesuaikan rencana perawatan Anda secara personal.',
      ),
      ArticleSectionData(
        title: 'Rekomendasi Aktivitas Fisik',
        content:
            'Aktivitas fisik membantu sel-sel tubuh menjadi lebih sensitif terhadap insulin. Kami merekomendasikan setidaknya 150 menit aktivitas aerobik intensitas sedang per minggu, yang dibagi menjadi minimal 3 hari dalam seminggu.',
      ),
    ],
    calloutText:
        '"Kunci keberhasilan manajemen diabetes bukan pada obat semata, melainkan pada pemahaman pasien terhadap kondisi mereka sendiri."',
    tags: const ['#DIABETES', '#EDUKASIPASIEN', '#KESEHATANACEH', '#DIETSEHAT'],
  );

  static final List<EducationArticle> _rawArticles = [
    featuredArticle,
    const EducationArticle(
      id: 'art_1',
      title: 'Cara Benar Menggunakan Glukometer di Rumah',
      category: 'Pengobatan',
      readTime: '5m',
      author: 'Dr. Teuku Reiza, Sp.PD',
      date: '22 Oktober 2023',
      views: 980,
      readStatus: 'Selesai',
      imageUrl: 'https://images.unsplash.com/photo-1584017911766-d451b3d0e843?w=800',
      hasVideo: true,
      videoUrl: 'https://www.youtube.com/watch?v=mock_glucometer_guide',
      videoDuration: '05:20',
      channelName: 'Klinik DSMES Banda Aceh',
      isBookmarked: true,
      quoteText:
          '"Pengukuran gula darah mandiri di rumah memberikan gambaran yang akurat mengenai respons glukosa darah sehari-hari."',
      bodyParagraphs: [
        'Menggunakan glukometer dengan teknik yang tepat memastikan hasil tes darah akurat dan dapat dipercaya. Sebelum mengambil sampel darah, pastikan tangan dicuci bersih menggunakan air hangat dan sabun.',
      ],
      galleryImageUrls: [
        'https://images.unsplash.com/photo-1584017911766-d451b3d0e843?w=400',
        'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=400',
      ],
      sections: [
        ArticleSectionData(
          title: 'Langkah-Langkah Pengukuran yang Akurat',
          content:
              'Usahakan untuk tidak memeras jari terlalu keras setelah ditusuk lancet, karena cairan interstitial dapat bercampur dengan darah dan mempengaruhi hasil pembacaan.',
        ),
      ],
      calloutText:
          '"Selalu catat hasil gula darah beserta waktu pengukuran (sebelum atau sesudah makan) untuk dikonsultasikan dengan dokter."',
      tags: ['#GLUKOMETER', '#CEKGULADARAH', '#MANDIRI'],
      isCompleted: true,
    ),
    const EducationArticle(
      id: 'art_2',
      title: 'Manfaat Jalan Kaki 30 Menit untuk Pasien Diabetes',
      category: 'Aktivitas',
      readTime: '8m',
      author: 'Fisioterapis Cut Rahmah',
      date: '18 Oktober 2023',
      views: 1450,
      readStatus: 'Belum dibaca',
      imageUrl: 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800',
      quoteText:
          '"Jalan kaki secara teratur adalah investasi kesehatan sederhana namun sangat efektif dalam membakar glukosa darah."',
      bodyParagraphs: [
        'Aktivitas fisik ringan seperti jalan cepat selama 30 menit sehari dapat menurunkan sensitivitas insulin dan meningkatkan pembakaran kalori secara bertahap.',
      ],
      galleryImageUrls: [
        'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=400',
        'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400',
      ],
      sections: [
        ArticleSectionData(
          title: 'Waktu Terbaik untuk Berjalan Kaki',
          content:
              'Jalan kaki 15-30 menit setelah makan terbukti sangat efektif mencegah lonjakan gula darah mendadak (postprandial spike).',
        ),
      ],
      calloutText:
          '"Gunakan alas kaki yang nyaman dan periksa kaki Anda secara berkala setelah berolahraga."',
      tags: ['#OLAHARAGA', '#JALANKAKI', '#FITNESS'],
    ),
    const EducationArticle(
      id: 'art_3',
      title: 'Memahami Jenis-Jenis Insulin & Cara Kerjanya',
      category: 'Pengobatan',
      readTime: '15m',
      author: 'Apoteker Cut Fitri, M.Farm',
      date: '15 Oktober 2023',
      views: 2100,
      readStatus: 'Sedang dibaca',
      readProgress: 0.66,
      imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=800',
      hasVideo: true,
      videoUrl: 'https://www.youtube.com/watch?v=mock_insulin_types',
      videoDuration: '10:15',
      channelName: 'Edukasi Farmasi Aceh',
      quoteText:
          '"Setiap jenis insulin dirancang dengan onset, puncak kerja, dan durasi yang berbeda untuk meniru kerja pankreas alami."',
      bodyParagraphs: [
        'Memahami perbedaan antara insulin rapid-acting, short-acting, intermediate-acting, dan long-acting sangat membantu pasien menyelaraskan dosis insulin dengan jadwal makan.',
      ],
      galleryImageUrls: [
        'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400',
        'https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=400',
      ],
      sections: [
        ArticleSectionData(
          title: 'Penyimpanan & Rotasi Area Injeksi',
          content:
              'Insulin yang sedang digunakan dapat disimpan pada suhu ruangan (di bawah 30°C) selama 28 hari. Rotasi lokasi penyuntikan mencegah timbulnya lipohipertrofi.',
        ),
      ],
      calloutText:
          '"Jangan pernah menyuntikkan insulin pada area kulit yang memar, keras, atau nyeri."',
      tags: ['#INSULIN', '#PENGOBATAN', '#FARMASI'],
    ),
    const EducationArticle(
      id: 'art_4',
      title: 'Mengenali Gejala Hipoglikemia & Pertolongan Pertama',
      category: 'Umum',
      readTime: '7m',
      author: 'Dr. M. Nazir, Sp.PD',
      date: '10 Oktober 2023',
      views: 1890,
      readStatus: 'Belum dibaca',
      imageUrl: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800',
      quoteText:
          '"Hipoglikemia terjadi ketika kadar gula darah turun di bawah 70 mg/dL. Penanganan cepat dengan aturan 15-15 sangat penting."',
      bodyParagraphs: [
        'Keringat dingin, gemetar, pusing, dan jantung berdebar adalah sinyal awal hipoglikemia. Segera konsumsi 15 gram karbohidrat cepat serap seperti air gula atau jus buah.',
      ],
      galleryImageUrls: [
        'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=400',
      ],
      sections: [
        ArticleSectionData(
          title: 'Aturan 15-15',
          content:
              'Makan 15 gram karbohidrat cepat serap, tunggu 15 menit, lalu periksa kembali gula darah Anda. Ulangi jika masih di bawah 70 mg/dL.',
        ),
      ],
      calloutText:
          '"Selalu bawa permen atau tablet glukosa saat beraktivitas di luar rumah."',
      tags: ['#HIPOGLIKEMIA', '#PERTOLONGANPERTAMA', '#DARURAT'],
    ),
  ];

  static List<EducationArticle> get articles {
    return _rawArticles.map((article) {
      return article.copyWith(
        isBookmarked: _bookmarkedIds.contains(article.id),
      );
    }).toList();
  }

  static bool isBookmarked(String id) => _bookmarkedIds.contains(id);

  static void toggleBookmark(String id) {
    if (_bookmarkedIds.contains(id)) {
      _bookmarkedIds.remove(id);
    } else {
      _bookmarkedIds.add(id);
    }
  }

  static List<EducationArticle> getBookmarkedArticles() {
    return articles.where((article) => _bookmarkedIds.contains(article.id)).toList();
  }

  static EducationArticle getArticleById(String id) {
    final found = articles.firstWhere(
      (article) => article.id == id,
      orElse: () => featuredArticle,
    );
    return found.copyWith(isBookmarked: _bookmarkedIds.contains(found.id));
  }

  static List<EducationArticle> filterArticles({
    String query = '',
    String category = 'Semua',
    String sortBy = 'Terbaru',
  }) {
    var result = articles.where((article) {
      final matchesQuery = query.isEmpty ||
          article.title.toLowerCase().contains(query.toLowerCase()) ||
          article.category.toLowerCase().contains(query.toLowerCase()) ||
          article.author.toLowerCase().contains(query.toLowerCase());

      final matchesCategory = category == 'Semua' || article.category == category;

      return matchesQuery && matchesCategory;
    }).toList();

    if (sortBy == 'Terpopuler') {
      result.sort((a, b) => b.views.compareTo(a.views));
    } else if (sortBy == 'Durasi') {
      result.sort((a, b) => a.readTime.compareTo(b.readTime));
    }

    return result;
  }
}
