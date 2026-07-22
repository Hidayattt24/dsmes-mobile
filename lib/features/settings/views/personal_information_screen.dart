import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../data/settings_mock_data.dart';
import '../models/user_profile.dart';

/// Personal Information Screen allowing users to view and update their personal & medical profile details.
class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState
    extends State<PersonalInformationScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  late String _selectedGender;
  late DateTime _selectedBirthDate;
  late String _selectedBloodType;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final profile = SettingsMockData.initialProfile;
    _nameController = TextEditingController(text: profile.fullName);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
    _selectedGender = profile.gender;
    _selectedBirthDate = profile.birthDate;
    _selectedBloodType = profile.bloodType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
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
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    SettingsMockData.initialProfile = UserProfile(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      gender: _selectedGender,
      birthDate: _selectedBirthDate,
      bloodType: _selectedBloodType,
    );

    AppSnackbar.showSuccess(context, 'Informasi pribadi berhasil diperbarui.');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final formattedBirthDate =
        DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedBirthDate);

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
        child: Form(
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
                      // Avatar Profile Header
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
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  width: 4,
                                ),
                              ),
                              child: const AppAvatar(
                                imageUrl: SettingsMockData.profileAvatarUrl,
                                radius: 48,
                                initials: 'BS',
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
                                  onTap: () {
                                    AppSnackbar.showInfo(
                                      context,
                                      'Pilih foto baru dari galeri.',
                                    );
                                  },
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

                      // Form Container Card
                      Container(
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
                            Text(
                              'Data Diri',
                              style: AppTextStyles.labelLg.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Full Name Field
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
                              validator: (val) => val == null || val.trim().isEmpty
                                  ? 'Nama wajib diisi'
                                  : null,
                            ),

                            const SizedBox(height: AppSpacing.md),

                            // Email Field
                            _FormFieldLabel(label: 'Alamat Email'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: AppTextStyles.bodyLg.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: _inputDecoration(
                                hint: 'nama@email.com',
                                icon: Icons.mail_outline_rounded,
                              ),
                              validator: (val) => val == null || !val.contains('@')
                                  ? 'Email tidak valid'
                                  : null,
                            ),

                            const SizedBox(height: AppSpacing.md),

                            // Phone Field
                            _FormFieldLabel(label: 'Nomor Telepon'),
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
                              validator: (val) => val == null || val.trim().isEmpty
                                  ? 'Nomor telepon wajib diisi'
                                  : null,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Medical Data Card
                      Container(
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
                            Text(
                              'Data Medis & Demografi',
                              style: AppTextStyles.labelLg.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Gender Selector
                            _FormFieldLabel(label: 'Jenis Kelamin'),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: _ChoiceChipOption(
                                    label: 'Laki-laki',
                                    icon: Icons.male_rounded,
                                    isSelected: _selectedGender == 'Laki-laki',
                                    onTap: () => setState(
                                        () => _selectedGender = 'Laki-laki'),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: _ChoiceChipOption(
                                    label: 'Perempuan',
                                    icon: Icons.female_rounded,
                                    isSelected: _selectedGender == 'Perempuan',
                                    onTap: () => setState(
                                        () => _selectedGender = 'Perempuan'),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppSpacing.md),

                            // Birthdate Picker
                            _FormFieldLabel(label: 'Tanggal Lahir'),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: _selectBirthDate,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.lg),
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

                            // Blood Type Selector
                            _FormFieldLabel(label: 'Golongan Darah'),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: ['A+', 'B+', 'AB+', 'O+'].map((type) {
                                final isSel = _selectedBloodType == type;
                                return ChoiceChip(
                                  label: Text(type),
                                  selected: isSel,
                                  onSelected: (_) {
                                    setState(() => _selectedBloodType = type);
                                  },
                                  selectedColor: AppColors.primaryContainer,
                                  backgroundColor: AppColors.surfaceContainerLow,
                                  labelStyle: AppTextStyles.labelLg.copyWith(
                                    color: isSel
                                        ? AppColors.onPrimary
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

              // Bottom Save Action
              Padding(
                padding: const EdgeInsets.all(AppSpacing.page),
                child: AppButton(
                  label: 'Simpan Perubahan',
                  onPressed: _onSave,
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
              color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.labelLg.copyWith(
                  color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
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
