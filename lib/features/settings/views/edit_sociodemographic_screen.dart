import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/selection_card.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/facility_repository.dart';

/// Screen allowing the user to edit sociodemographic data (onboarding steps 8-12):
/// residence, health facility (puskesmas), living arrangement, education, and
/// diabetes duration.
class EditSociodemographicScreen extends ConsumerStatefulWidget {
  const EditSociodemographicScreen({super.key});

  @override
  ConsumerState<EditSociodemographicScreen> createState() =>
      _EditSociodemographicScreenState();
}

class _EditSociodemographicScreenState
    extends ConsumerState<EditSociodemographicScreen> {
  late final TextEditingController _districtController;
  late final TextEditingController _addressController;

  String _selectedFacility = '';
  String? _selectedLivingArrangement;
  String? _selectedEducation;
  String? _selectedDiabetesDuration;

  List<String> _facilities = const [];
  bool _isFacilityLoading = false;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _districtController = TextEditingController();
    _addressController = TextEditingController();
    _fetchProfile();
    _fetchFacilities();
  }

  @override
  void dispose() {
    _districtController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final profile = await authRepo.getPatientProfile();
      if (mounted) {
        _districtController.text = (profile['district'] as String?) ?? '';
        _addressController.text = (profile['address'] as String?) ?? '';
        _selectedFacility = (profile['health_facility'] as String?) ?? '';
        _selectedLivingArrangement = profile['living_arrangement'] as String?;
        _selectedEducation = profile['education_level'] as String?;
        _selectedDiabetesDuration = profile['diabetes_duration'] as String?;
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal memuat data.');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchFacilities() async {
    setState(() => _isFacilityLoading = true);
    try {
      final facilities =
          await ref.read(facilityRepositoryProvider).fetchHealthFacilities();
      if (mounted) {
        setState(() {
          _facilities = facilities;
          _isFacilityLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isFacilityLoading = false);
      }
    }
  }

  Future<void> _onSave() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFacility.trim().isEmpty) {
      AppSnackbar.showError(context, 'Pilih puskesmas terlebih dahulu.');
      return;
    }
    if (_selectedLivingArrangement == null) {
      AppSnackbar.showError(context, 'Pilih tinggal bersama siapa.');
      return;
    }
    if (_selectedEducation == null) {
      AppSnackbar.showError(context, 'Pilih pendidikan terakhir.');
      return;
    }
    if (_selectedDiabetesDuration == null) {
      AppSnackbar.showError(context, 'Pilih lama menderita diabetes.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.updateSociodemographic(
        district: _districtController.text,
        address: _addressController.text,
        healthFacility: _selectedFacility,
        livingArrangement: _selectedLivingArrangement!,
        educationLevel: _selectedEducation!,
        diabetesDuration: _selectedDiabetesDuration!,
      );

      if (mounted) {
        AppSnackbar.showSuccess(
            context, 'Data sosiodemografi berhasil diperbarui.');
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

  Future<void> _showFacilityPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FacilityPickerSheet(facilities: _facilities),
    );
    if (selected != null && mounted) {
      setState(() => _selectedFacility = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Data Sosiodemografi',
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
                            // ── Domisili ─────────────────────────────────────
                            _SectionCard(
                              title: 'Domisili',
                              children: [
                                const _FormFieldLabel(label: 'Kecamatan'),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _districtController,
                                  style: AppTextStyles.bodyLg.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: _inputDecoration(
                                    hint: AppStrings.residenceDistrictHint,
                                    icon: Icons.map_outlined,
                                  ),
                                  validator: (val) =>
                                      val == null || val.trim().isEmpty
                                          ? 'Kecamatan wajib diisi'
                                          : null,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                const _FormFieldLabel(label: 'Alamat Lengkap'),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _addressController,
                                  maxLines: 3,
                                  keyboardType: TextInputType.streetAddress,
                                  style: AppTextStyles.bodyLg.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: _inputDecoration(
                                    hint: AppStrings.residenceAddressHint,
                                    icon: Icons.home_outlined,
                                  ),
                                  validator: (val) =>
                                      val == null || val.trim().isEmpty
                                          ? 'Alamat wajib diisi'
                                          : null,
                                ),
                              ],
                            ),

                            const SizedBox(height: AppSpacing.lg),

                            // ── Puskesmas ──────────────────────────────────
                            _SectionCard(
                              title: 'Puskesmas',
                              children: [
                                const _FormFieldLabel(
                                    label: 'Puskesmas tempat berobat'),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: _isFacilityLoading
                                      ? null
                                      : _showFacilityPicker,
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
                                          Icons.local_hospital_outlined,
                                          color: AppColors.primary,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _isFacilityLoading
                                                ? AppStrings.healthFacilityLoading
                                                : _selectedFacility.isEmpty
                                                    ? AppStrings.healthFacilityHint
                                                    : _selectedFacility,
                                            style: AppTextStyles.bodyLg.copyWith(
                                              color: _selectedFacility.isEmpty
                                                  ? AppColors.outline
                                                  : AppColors.onSurface,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (_isFacilityLoading)
                                          const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.primary,
                                            ),
                                          )
                                        else
                                          const Icon(
                                            Icons.expand_more,
                                            color: AppColors.outline,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppSpacing.lg),

                            // ── Tinggal Bersama ────────────────────────────
                            _SectionCard(
                              title: AppStrings.livingArrangementTitle,
                              children: [
                                SelectionCard(
                                  label: AppStrings.livingAlone,
                                  icon: Icons.person_outline,
                                  isSelected: _selectedLivingArrangement ==
                                      AppStrings.livingAlone,
                                  isWide: true,
                                  onTap: () => setState(() =>
                                      _selectedLivingArrangement =
                                          AppStrings.livingAlone),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                SelectionCard(
                                  label: AppStrings.livingFamily,
                                  icon: Icons.groups_outlined,
                                  isSelected: _selectedLivingArrangement ==
                                      AppStrings.livingFamily,
                                  isWide: true,
                                  onTap: () => setState(() =>
                                      _selectedLivingArrangement =
                                          AppStrings.livingFamily),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppSpacing.lg),

                            // ── Pendidikan ─────────────────────────────────
                            _SectionCard(
                              title: AppStrings.educationTitle,
                              children: _buildChoiceList(
                                options: const [
                                  (AppStrings.educationNoSchool, Icons.block),
                                  (AppStrings.educationSD, Icons.school_outlined),
                                  (AppStrings.educationSMP, Icons.school_outlined),
                                  (AppStrings.educationSMK, Icons.school_outlined),
                                  (AppStrings.educationD3, Icons.account_balance_outlined),
                                  (AppStrings.educationS1, Icons.account_balance_outlined),
                                  (AppStrings.educationS2S3, Icons.workspace_premium_outlined),
                                ],
                                selected: _selectedEducation,
                                onSelect: (v) =>
                                    setState(() => _selectedEducation = v),
                              ),
                            ),

                            const SizedBox(height: AppSpacing.lg),

                            // ── Durasi Diabetes ────────────────────────────
                            _SectionCard(
                              title: AppStrings.diabetesDurationTitle,
                              children: _buildChoiceList(
                                options: const [
                                  (AppStrings.diabetesDurationLess1, Icons.looks_one_outlined),
                                  (AppStrings.diabetesDuration1to3, Icons.looks_two_outlined),
                                  (AppStrings.diabetesDuration4to6, Icons.looks_3_outlined),
                                  (AppStrings.diabetesDurationMore6, Icons.looks_4_outlined),
                                ],
                                selected: _selectedDiabetesDuration,
                                onSelect: (v) => setState(
                                    () => _selectedDiabetesDuration = v),
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
                        isLoading: _isSaving,
                        icon: Icons.check_circle_rounded,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  List<Widget> _buildChoiceList({
    required List<(String, IconData)> options,
    required String? selected,
    required ValueChanged<String> onSelect,
  }) {
    return List.generate(options.length, (i) {
      final (value, icon) = options[i];
      return Padding(
        padding: EdgeInsets.only(
          bottom: i < options.length - 1 ? AppSpacing.sm : 0,
        ),
        child: SelectionCard(
          label: value,
          isSelected: value == selected,
          isWide: true,
          icon: icon,
          onTap: () => onSelect(value),
        ),
      );
    });
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            title,
            style: AppTextStyles.labelLg.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
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

class _FacilityPickerSheet extends StatefulWidget {
  const _FacilityPickerSheet({required this.facilities});

  final List<String> facilities;

  @override
  State<_FacilityPickerSheet> createState() => _FacilityPickerSheetState();
}

class _FacilityPickerSheetState extends State<_FacilityPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final filtered = query.isEmpty
        ? widget.facilities
        : widget.facilities
            .where((f) => f.toLowerCase().contains(query))
            .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Text(
              AppStrings.healthFacilityTitle,
              style: AppTextStyles.titleMd.copyWith(color: AppColors.onSurface),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: AppStrings.healthFacilitySearchHint,
                prefixIcon: const Icon(Icons.search, color: AppColors.outline),
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintStyle: AppTextStyles.bodyLg.copyWith(
                  color: AppColors.outline,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      AppStrings.healthFacilityEmpty,
                      style: AppTextStyles.bodyLg.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final facility = filtered[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.local_hospital_outlined,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          facility,
                          style: AppTextStyles.bodyLg.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () => Navigator.of(context).pop(facility),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
