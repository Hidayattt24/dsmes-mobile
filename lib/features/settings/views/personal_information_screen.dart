import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../home/viewmodels/home_dashboard_notifier.dart';

class PersonalInformationScreen extends ConsumerStatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  ConsumerState<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState
    extends ConsumerState<PersonalInformationScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _nicknameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  late String _selectedGender;
  late DateTime _selectedBirthDate;
  late String _selectedBloodType;
  String? _profilePhotoUrl;
  File? _localPhotoFile;

  double _heightCm = 0;
  double _weightKg = 0;
  String _activityLevel = '';

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nicknameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _selectedGender = 'Laki-laki';
    _selectedBirthDate = DateTime(1990, 1, 1);
    _selectedBloodType = 'Tidak Tahu';
    _fetchProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final profile = await authRepo.getPatientProfile();
      if (mounted) {
        _nameController.text = (profile['full_name'] as String?) ?? '';
        _nicknameController.text = (profile['nickname'] as String?) ?? '';
        _emailController.text = (profile['email'] as String?) ?? '';
        _phoneController.text = (profile['whatsapp_number'] as String?) ?? '';
        _selectedGender = _mapGender(profile['gender'] as String?);
        final dobStr = profile['date_of_birth'] as String?;
        if (dobStr != null && dobStr.isNotEmpty) {
          _selectedBirthDate = DateTime.tryParse(dobStr) ?? _selectedBirthDate;
        }
        _selectedBloodType = _mapBloodType(profile['blood_type'] as String?);
        _profilePhotoUrl = profile['profile_photo_url'] as String?;
        _heightCm = (profile['height_cm'] as num?)?.toDouble() ?? 0;
        _weightKg = (profile['weight_kg'] as num?)?.toDouble() ?? 0;
        _activityLevel =
            (profile['physical_activity_level'] as String?) ?? 'Aktivitas Ringan';
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal memuat data profil.');
        setState(() => _isLoading = false);
      }
    }
  }

  String _mapGender(String? gender) {
    if (gender == null) return 'Laki-laki';
    final lower = gender.toLowerCase();
    if (lower.contains('perempuan') || lower == 'female') return 'Perempuan';
    return 'Laki-laki';
  }

  String _mapBloodType(String? bloodType) {
    if (bloodType == null) return 'Tidak Tahu';
    final lower = bloodType.toLowerCase().replaceAll('_', ' ');
    if (lower == 'tidak tahu') return 'Tidak Tahu';
    final upper = bloodType.toUpperCase();
    if (['A', 'B', 'AB', 'O'].contains(upper)) return upper;
    return 'Tidak Tahu';
  }

  String _mapGenderToApi(String label) {
    return label == 'Perempuan' ? 'perempuan' : 'laki-laki';
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate,
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedBirthDate = picked);
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked != null && mounted) {
      setState(() {
        _localPhotoFile = File(picked.path);
      });
    }
  }

  Future<void> _onSave() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.updatePatientProfile(
        fullName: _nameController.text.trim(),
        nickname: _nicknameController.text.trim(),
        whatsappNumber: _phoneController.text.trim(),
        heightCm: _heightCm > 0 ? _heightCm : 170,
        weightKg: _weightKg > 0 ? _weightKg : 65,
        activityLevel: _activityLevel.isNotEmpty ? _activityLevel : 'Aktivitas Ringan',
        gender: _mapGenderToApi(_selectedGender),
        dateOfBirth: DateFormat('yyyy-MM-dd').format(_selectedBirthDate),
        bloodType: _selectedBloodType,
      );

      if (_localPhotoFile != null) {
        AppSnackbar.showInfo(
          context,
          'Foto profil akan diupload nanti. Data lainnya tersimpan.',
        );
      }

      await _fetchProfile();
      ref.invalidate(homeDashboardProvider);

      if (mounted) {
        AppSnackbar.showSuccess(
            context, 'Informasi pribadi berhasil diperbarui.');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedBirthDate =
        DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedBirthDate);
    final initials = _nameController.text.isNotEmpty
        ? _nameController.text
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Informasi Pribadi',
          style: AppTextStyles.headlineMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(AppSpacing.page),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 108,
                                    height: 108,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.1),
                                        width: 4,
                                      ),
                                    ),
                                    child: _localPhotoFile != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(54),
                                            child: Image.file(
                                              _localPhotoFile!,
                                              width: 108,
                                              height: 108,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : AppAvatar(
                                            imageUrl: _profilePhotoUrl ?? '',
                                            radius: 48,
                                            initials: initials,
                                            hasBorder: false,
                                          ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Material(
                                      color: AppColors.primary,
                                      shape: const CircleBorder(),
                                      elevation: 3,
                                      child: InkWell(
                                        customBorder: const CircleBorder(),
                                        onTap: _pickPhoto,
                                        child: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.camera_alt_rounded,
                                            color: AppColors.onPrimary,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLowest,
                                borderRadius: AppRadius.card,
                                border: Border.all(
                                  color: AppColors.outlineVariant
                                      .withValues(alpha: 0.3),
                                ),
                                boxShadow: AppShadows.soft,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Data Diri',
                                    style: AppTextStyles.labelLg.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  _FormFieldLabel(label: 'Nama Lengkap'),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _nameController,
                                    style: AppTextStyles.bodyLg.copyWith(
                                      color: AppColors.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: _inputDecoration(
                                      hint: 'Masukkan nama lengkap',
                                      icon: Icons.person_outline_rounded,
                                    ),
                                    validator: (val) =>
                                        val == null || val.trim().isEmpty
                                            ? 'Nama wajib diisi'
                                            : null,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  _FormFieldLabel(label: 'Nama Panggilan'),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _nicknameController,
                                    style: AppTextStyles.bodyLg.copyWith(
                                      color: AppColors.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: _inputDecoration(
                                      hint: 'Masukkan nama panggilan',
                                      icon: Icons.face_rounded,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  _FormFieldLabel(label: 'Alamat Email'),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    enabled: false,
                                    style: AppTextStyles.bodyLg.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: _inputDecoration(
                                      hint: 'nama@email.com',
                                      icon: Icons.mail_outline_rounded,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  _FormFieldLabel(label: 'Nomor WhatsApp'),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    style: AppTextStyles.bodyLg.copyWith(
                                      color: AppColors.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: _inputDecoration(
                                      hint: '+62 8xx-xxxx-xxxx',
                                      icon: Icons.phone_outlined,
                                    ),
                                    validator: (val) =>
                                        val == null || val.trim().isEmpty
                                            ? 'Nomor telepon wajib diisi'
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLowest,
                                borderRadius: AppRadius.card,
                                border: Border.all(
                                  color: AppColors.outlineVariant
                                      .withValues(alpha: 0.3),
                                ),
                                boxShadow: AppShadows.soft,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Data Medis & Demografi',
                                    style: AppTextStyles.labelLg.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  _FormFieldLabel(label: 'Jenis Kelamin'),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _ChoiceChipOption(
                                          label: 'Laki-laki',
                                          icon: Icons.male_rounded,
                                          isSelected:
                                              _selectedGender == 'Laki-laki',
                                          onTap: () => setState(
                                              () => _selectedGender =
                                                  'Laki-laki'),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: _ChoiceChipOption(
                                          label: 'Perempuan',
                                          icon: Icons.female_rounded,
                                          isSelected:
                                              _selectedGender == 'Perempuan',
                                          onTap: () => setState(
                                              () => _selectedGender =
                                                  'Perempuan'),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  _FormFieldLabel(label: 'Tanggal Lahir'),
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: _selectBirthDate,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.lg),
                                        border: Border.all(
                                          color: AppColors.outlineVariant
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today_rounded,
                                            color: AppColors.primary,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            formattedBirthDate,
                                            style: AppTextStyles.bodyLg.copyWith(
                                              color: AppColors.onSurface,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const Spacer(),
                                          const Icon(
                                            Icons.edit_calendar_rounded,
                                            color: AppColors.outline,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  _FormFieldLabel(label: 'Golongan Darah'),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      'A',
                                      'B',
                                      'AB',
                                      'O',
                                      'Tidak Tahu'
                                    ].map((type) {
                                      final isSel = _selectedBloodType == type;
                                      return ChoiceChip(
                                        label: Text(
                                          type,
                                          style: AppTextStyles.labelLg.copyWith(
                                            color: isSel
                                                ? Colors.white
                                                : AppColors.onSurface,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        selected: isSel,
                                        onSelected: (_) {
                                          setState(
                                              () => _selectedBloodType = type);
                                        },
                                        selectedColor: AppColors.primary,
                                        backgroundColor:
                                            AppColors.surfaceContainerLow,
                                        labelStyle:
                                            AppTextStyles.labelLg.copyWith(
                                          color: isSel
                                              ? Colors.white
                                              : AppColors.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.page),
                      child: AppButton(
                        label: 'Simpan Perubahan',
                        onPressed: _isSaving ? null : _onSave,
                        icon: Icons.check_circle_rounded,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      {required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}

class _FormFieldLabel extends StatelessWidget {
  const _FormFieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelMd.copyWith(
        color: AppColors.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ChoiceChipOption extends StatelessWidget {
  const _ChoiceChipOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.onPrimary
                  : AppColors.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.labelLg.copyWith(
                  color: isSelected
                      ? AppColors.onPrimary
                      : AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
