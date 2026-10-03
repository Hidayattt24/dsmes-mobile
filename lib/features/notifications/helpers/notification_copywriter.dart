import '../models/notification_item.dart';

class NotificationCopywriter {
  NotificationCopywriter._();

  static (String title, String description) getInteractiveCopy({
    required String rawTitle,
    required String rawDescription,
    required NotificationType type,
  }) {
    final lowerTitle = rawTitle.toLowerCase();
    final lowerDesc = rawDescription.toLowerCase();

    // 1. Blood sugar logging
    if (lowerTitle.contains('gula darah') || lowerDesc.contains('gula darah') || lowerTitle.contains('cek_gula')) {
      if (lowerDesc.contains('tinggi') || lowerDesc.contains('hiperglikemia')) {
        return (
          'Waspada Gula Darah Tinggi 🚨',
          'Kadar gula darahmu tercatat tinggi. Yuk istirahat sejenak, minum air putih, dan konsumsi obat sesuai aturan! ❤️',
        );
      }
      if (lowerDesc.contains('rendah') || lowerDesc.contains('hipoglikemia')) {
        return (
          'Perhatian: Gula Darah Rendah! ⚠️',
          'Kadar gula darahmu sedang di bawah normal. Segera minum teh manis hangat atau sedikit karbohidrat ya! 🍯',
        );
      }
      return (
        'Waktunya Cek Kadar Gula Darah! 🩸',
        'Yuk luangkan 1 menit untuk mencatat angka gula darahmu. Perhatian kecil hari ini buat tubuh tetap prima! ✨',
      );
    }

    // 2. Medication / Insulin
    if (lowerTitle.contains('obat') || lowerDesc.contains('obat') || lowerTitle.contains('insulin') || lowerDesc.contains('insulin')) {
      return (
        'Jangan Lupa Obat / Insulinmu Ya! 💊',
        'Saatnya konsumsi obat sesuai jadwal agar gula darah tetap aman dan terkontrol. Kamu pasti bisa! 💪',
      );
    }

    // 3. Meal / Food logging
    if (lowerTitle.contains('makan') || lowerDesc.contains('makan') || lowerTitle.contains('nutrisi') || lowerDesc.contains('asupan')) {
      return (
        'Sudah Catat Asupan Makanmu Hari Ini? 🥗',
        'Yuk intip menu makanmu. Mencatat asupan bantu energimu tetap seimbang sepanjang hari! 🍏',
      );
    }

    // 4. Physical activity / Routine
    if (lowerTitle.contains('jalan') || lowerDesc.contains('jalan') || lowerTitle.contains('olahraga') || lowerTitle.contains('aktivitas')) {
      return (
        'Waktunya Bergerak & Segarkan Tubuh! 🏃‍♂️',
        'Jalan santai 15 menit sangat ampuh menjaga kadar gula darah tetap stabil. Semangat! 🌟',
      );
    }

    // 5. Hydration
    if (lowerTitle.contains('air') || lowerDesc.contains('air') || lowerTitle.contains('minum')) {
      return (
        'Segelas Air Putih Segar Menunggumu! 💧',
        'Jaga hidrasi tubuhmu hari ini. Minum air putih bantu metabolisme tetap lancar & segar! 🌊',
      );
    }

    // 6. Education
    if (type == NotificationType.education || lowerTitle.contains('edukasi') || lowerTitle.contains('materi')) {
      return (
        'Ilmu Baru Menunggumu Hari Ini! 💡',
        rawDescription.isNotEmpty
            ? rawDescription
            : 'Ada tips kesehatan praktis khusus untukmu. Baca 2 menit untuk hidup lebih sehat! 📖',
      );
    }

    // 7. Target Achieved / Success
    if (type == NotificationType.targetAchieved || lowerTitle.contains('target') || lowerTitle.contains('selesai')) {
      return (
        'Luar Biasa! Target Kesehatanmu Tercapai! 🎉',
        'Kerja hebat! Gula darah & rutinitasmu terkontrol dengan sangat baik hari ini. Pertahankan kebiasaan baik ini! ⭐',
      );
    }

    // Default Fallback
    return (
      rawTitle.isNotEmpty ? rawTitle : 'Pengingat Kesehatan DSMES 🔔',
      rawDescription.isNotEmpty
          ? rawDescription
          : 'Yuk terus jaga konsistensi rutinitas kesehatanmu hari ini! ✨',
    );
  }
}
