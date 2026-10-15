import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/repositories/auth_repository.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.validationRequired;
    }
    final clean = _normalizePhone(value);
    if (!RegExp(r'^\d{8,15}$').hasMatch(clean)) {
      return AppStrings.validationPhoneNumber;
    }
    return null;
  }

  String _normalizePhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('62')) return digits;
    if (digits.startsWith('0')) return '62${digits.substring(1)}';
    return digits;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final phoneNumber = _normalizePhone(_phoneController.text);
      await ref
          .read(authRepositoryProvider)
          .checkPhoneNumber(phoneNumber: phoneNumber);
      if (mounted) {
        setState(() => _isLoading = false);
        await context.push(RouteNames.resetPassword, extra: phoneNumber);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackbar.showError(context, e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackbar.showError(context, AppStrings.errorGeneral);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
          tooltip: 'Kembali',
        ),
      ),
      body: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.page,
                  AppSpacing.page,
                  AppSpacing.page + bottomInset,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - bottomInset).clamp(
                      0.0,
                      double.infinity,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ForgotPasswordHeader(),
                      const SizedBox(height: AppSpacing.xl),
                      Form(
                        key: _formKey,
                        child: AppTextField(
                          label: AppStrings.forgotPasswordPhone,
                          hint: AppStrings.forgotPasswordPhoneHint,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          prefixIcon: Icons.phone_outlined,
                          semanticLabel: 'Kolom nomor handphone',
                          validator: _validatePhone,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        label: AppStrings.forgotPasswordButton,
                        isLoading: _isLoading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Center(
                        child: TextButton(
                          onPressed: () => context.go(RouteNames.login),
                          child: Text(
                            AppStrings.forgotPasswordBackToLogin,
                            style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ForgotPasswordHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          child: const Icon(
            Icons.lock_reset_outlined,
            color: AppColors.onSecondaryContainer,
            size: 28,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          AppStrings.forgotPasswordTitle,
          style: AppTextStyles.poppinsHeadline,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          AppStrings.forgotPasswordSubtitle,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
