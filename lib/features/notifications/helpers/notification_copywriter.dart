import '../models/notification_item.dart';

class NotificationCopywriter {
  NotificationCopywriter._();

  static (String title, String description) getInteractiveCopy({
    required String rawTitle,
    required String rawDescription,
    required NotificationType type,
    String? iconName,
    String? activityName,
  }) {
    final lowerTitle = rawTitle.toLowerCase();
    final lowerDesc = rawDescription.toLowerCase();
    final lowerIcon = (iconName ?? '').toLowerCase();

    // Determine clean activity name
    String cleanActivity = activityName?.trim() ?? '';
    if (cleanActivity.isEmpty) {
      if (rawTitle.isNotEmpty &&
          rawTitle != 'Pengingat DSMES' &&
          rawTitle != 'Pengingat DIBA' &&
          rawTitle != 'Materi Edukasi Baru' &&
          !rawTitle.startsWith('🔔')) {
        cleanActivity = rawTitle.trim();
      } else if (rawDescription.startsWith('Waktunya melakukan ')) {
        cleanActivity = rawDescription
            .replaceFirst('Waktunya melakukan ', '')
            .replaceAll('.', '')
            .trim();
      }
    }

    // ── 1. Education Notifications ──────────────────────────────────────────
    if (type == NotificationType.education ||
        lowerTitle.contains('edukasi') ||
        lowerTitle.contains('materi')) {
      String articleTitle = cleanActivity.isNotEmpty
          ? cleanActivity
          : (rawTitle.isNotEmpty &&
                  rawTitle != 'Materi Edukasi Baru' &&
                  rawTitle != 'Edukasi'
              ? rawTitle
                  .replaceAll('Edukasi Baru:', '')
                  .replaceAll('Materi Baru:', '')
                  .trim()
              : rawDescription);

      // Extract article title if quoted in rawDescription
      final match = RegExp(r'["\x27]([^"\x27]+)["\x27]').firstMatch(rawDescription);
      if (match != null && match.group(1) != null && match.group(1)!.isNotEmpty) {
        articleTitle = match.group(1)!.trim();
      }

      if (articleTitle.isEmpty ||
          articleTitle.toLowerCase() == 'materi edukasi baru' ||
          articleTitle.toLowerCase() == 'edukasi') {
        return (
          'Edukasi Baru Tersedia 📖',
          'Yuk pelajari tips dan panduan kesehatan terbarumu hari ini ✨',
        );
      }

      return (
        'Edukasi Baru: $articleTitle 📖',
        'Yuk pelajari "$articleTitle" untuk panduan sehatmu hari ini ✨',
      );
    }

    // ── 2. Target Achieved / Success ─────────────────────────────────────────
    if (type == NotificationType.targetAchieved ||
        lowerTitle.contains('target') ||
        lowerTitle.contains('selesai')) {
      return (
        'Luar Biasa! Target Kesehatanmu Tersapai! 🎉',
        'Kerja hebat! Gula darah & rutinitasmu terkontrol dengan sangat baik hari ini. Pertahankan kebiasaan baik ini! ⭐',
      );
    }

    // ── 3. Blood Sugar (Icon: blood or keywords) ─────────────────────────────
    if (lowerIcon == 'blood' ||
        lowerTitle.contains('gula') ||
        lowerDesc.contains('gula') ||
        lowerTitle.contains('glukosa') ||
        lowerTitle.contains('cek_gula') ||
        cleanActivity.toLowerCase().contains('gula')) {
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
      final title = cleanActivity.isNotEmpty
          ? (cleanActivity.toLowerCase().startsWith('waktunya')
              ? '$cleanActivity! 🩸'
              : 'Waktunya $cleanActivity! 🩸')
          : 'Waktunya Cek Kadar Gula Darah! 🩸';
      final desc = cleanActivity.isNotEmpty
          ? 'Saatnya mencatat angka $cleanActivity demi memantau gula darah & kesehatan tubuhmu tetap prima ✨'
          : 'Luangkan 1 menit untuk mencatat angka gula darahmu demi tubuh tetap prima ✨';
      return (title, desc);
    }

    // ── 4. Medication / Insulin (Icon: medicine, pill or keywords) ─────────
    if (lowerIcon == 'medicine' ||
        lowerIcon == 'pill' ||
        lowerTitle.contains('obat') ||
        lowerDesc.contains('obat') ||
        lowerTitle.contains('insulin') ||
        lowerDesc.contains('insulin') ||
        cleanActivity.toLowerCase().contains('obat') ||
        cleanActivity.toLowerCase().contains('insulin')) {
      final title = cleanActivity.isNotEmpty
          ? (cleanActivity.toLowerCase().startsWith('waktunya')
              ? '$cleanActivity! 💊'
              : 'Waktunya $cleanActivity! 💊')
          : 'Waktunya Konsumsi Obat / Insulin 💊';
      final desc = cleanActivity.isNotEmpty
          ? 'Saatnya konsumsi $cleanActivity tepat waktu sesuai anjuran dokter agar tubuh tetap stabil 💪'
          : 'Jaga kestabilan tubuh dengan minum obat tepat waktu sesuai anjuran dokter 💪';
      return (title, desc);
    }

    // ── 5. Physical Activity (Icon: walk, run, exercise, bike, yoga) ─────────
    if (lowerIcon == 'walk' ||
        lowerIcon == 'run' ||
        lowerIcon == 'exercise' ||
        lowerIcon == 'bike' ||
        lowerIcon == 'yoga' ||
        lowerTitle.contains('jalan') ||
        lowerDesc.contains('jalan') ||
        lowerTitle.contains('olahraga') ||
        lowerTitle.contains('aktivitas') ||
        lowerTitle.contains('senam') ||
        cleanActivity.toLowerCase().contains('jalan') ||
        cleanActivity.toLowerCase().contains('olahraga') ||
        cleanActivity.toLowerCase().contains('senam')) {
      final title = cleanActivity.isNotEmpty
          ? (cleanActivity.toLowerCase().startsWith('waktunya')
              ? '$cleanActivity! 🏃‍♂️'
              : 'Waktunya $cleanActivity! 🏃‍♂️')
          : 'Waktunya Bergerak & Segarkan Tubuh! 🏃‍♂️';
      final desc = cleanActivity.isNotEmpty
          ? 'Yuk lakukan $cleanActivity sejenak untuk membantu menjaga kadar gula darah tetap stabil 🌟'
          : 'Jalan santai sejenak sangat membantu menjaga kadar gula darah tetap stabil 🌟';
      return (title, desc);
    }

    // ── 6. Nutrition / Meal (Icon: breakfast, lunch, dinner, restaurant) ─────
    if (lowerIcon == 'breakfast' ||
        lowerIcon == 'lunch' ||
        lowerIcon == 'dinner' ||
        lowerIcon == 'restaurant' ||
        lowerTitle.contains('makan') ||
        lowerDesc.contains('makan') ||
        lowerTitle.contains('sarapan') ||
        lowerTitle.contains('nutrisi') ||
        lowerTitle.contains('asupan') ||
        cleanActivity.toLowerCase().contains('makan') ||
        cleanActivity.toLowerCase().contains('sarapan')) {
      final title = cleanActivity.isNotEmpty
          ? (cleanActivity.toLowerCase().startsWith('waktunya')
              ? '$cleanActivity! 🥗'
              : 'Waktunya $cleanActivity! 🥗')
          : 'Waktunya Jadwal Makan Sehat 🥗';
      final desc = cleanActivity.isNotEmpty
          ? 'Saatnya $cleanActivity. Penuhi nutrisi seimbang sesuai takaran piring sehatmu hari ini 🍏'
          : 'Penuhi nutrisi seimbang sesuai takaran piring sehatmu hari ini 🍏';
      return (title, desc);
    }

    // ── 7. Hydration (Icon: water or keywords) ───────────────────────────────
    if (lowerIcon == 'water' ||
        lowerTitle.contains('air') ||
        lowerDesc.contains('air') ||
        lowerTitle.contains('minum') ||
        cleanActivity.toLowerCase().contains('air')) {
      final title = cleanActivity.isNotEmpty
          ? (cleanActivity.toLowerCase().startsWith('waktunya')
              ? '$cleanActivity! 💧'
              : 'Waktunya $cleanActivity! 💧')
          : 'Waktunya Minum Air Putih 💧';
      final desc = cleanActivity.isNotEmpty
          ? 'Segelas air putih segar siap bantu metabolisme dan hidrasi tubuhmu tetap lancar 🌊'
          : 'Segelas air putih segar siap bantu metabolisme tubuh tetap lancar 🌊';
      return (title, desc);
    }

    // ── 8. Sleep / Rest (Icon: sleep or keywords) ────────────────────────────
    if (lowerIcon == 'sleep' ||
        lowerTitle.contains('tidur') ||
        lowerDesc.contains('tidur') ||
        lowerTitle.contains('istirahat') ||
        cleanActivity.toLowerCase().contains('tidur') ||
        cleanActivity.toLowerCase().contains('istirahat')) {
      final title = cleanActivity.isNotEmpty
          ? (cleanActivity.toLowerCase().startsWith('waktunya')
              ? '$cleanActivity! 🌙'
              : 'Waktunya $cleanActivity! 🌙')
          : 'Waktunya Istirahat yang Cukup 🌙';
      final desc = cleanActivity.isNotEmpty
          ? 'Tidur berkualitas dan $cleanActivity sangat penting untuk pemulihan metabolisme tubuhmu 😴'
          : 'Tidur berkualitas sangat penting untuk pemulihan dan kestabilan metabolisme tubuhmu 😴';
      return (title, desc);
    }

    // ── 9. Hospital / Consultation (Icon: hospital or keywords) ─────────────
    if (lowerIcon == 'hospital' ||
        lowerTitle.contains('puskesmas') ||
        lowerTitle.contains('dokter') ||
        lowerTitle.contains('kontrol') ||
        lowerTitle.contains('konsultasi') ||
        cleanActivity.toLowerCase().contains('kontrol') ||
        cleanActivity.toLowerCase().contains('dokter')) {
      final title = cleanActivity.isNotEmpty
          ? (cleanActivity.toLowerCase().startsWith('jadwal')
              ? '$cleanActivity 🏥'
              : 'Jadwal $cleanActivity 🏥')
          : 'Jadwal Pemeriksaan Kesehatan 🏥';
      final desc = cleanActivity.isNotEmpty
          ? 'Jangan lupa jadwal $cleanActivity untuk pemantauan kesehatan yang optimal 🩺'
          : 'Jangan lupa jadwal konsultasi/kontrol kesehatanmu untuk pemantauan yang optimal 🩺';
      return (title, desc);
    }

    // ── 10. Heart Care (Icon: heart) ────────────────────────────────────────
    if (lowerIcon == 'heart' || lowerTitle.contains('jantung')) {
      final title = cleanActivity.isNotEmpty
          ? (cleanActivity.toLowerCase().startsWith('waktunya')
              ? '$cleanActivity! ❤️'
              : 'Waktunya $cleanActivity! ❤️')
          : 'Jaga Kesehatan Jantung & Tubuhmu ❤️';
      final desc = cleanActivity.isNotEmpty
          ? 'Yuk lakukan $cleanActivity untuk menjaga detak jantung dan tekanan darah tetap stabil 🧘'
          : 'Yuk lakukan rileksasi sejenak untuk menjaga detak jantung dan tekanan darah tetap stabil 🧘';
      return (title, desc);
    }

    // ── 11. Custom Reminder / Fallback ──────────────────────────────────────
    final displayTitle = cleanActivity.isNotEmpty
        ? (cleanActivity.toLowerCase().startsWith('waktunya')
            ? '$cleanActivity ⏰'
            : 'Waktunya $cleanActivity ⏰')
        : (rawTitle.isNotEmpty && rawTitle != 'Pengingat DSMES'
            ? rawTitle
            : 'Pengingat Rutinitas DIBA ⏰');

    final displayDesc = cleanActivity.isNotEmpty
        ? 'Halo! Saatnya melakukan $cleanActivity. Yuk jaga konsistensi rutinitas sehatmu hari ini! ✨'
        : (rawDescription.isNotEmpty && !rawDescription.startsWith('Waktunya melakukan')
            ? rawDescription
            : 'Yuk terus jaga konsistensi rutinitas kesehatanmu hari ini! ✨');

    return (displayTitle, displayDesc);
  }
}
