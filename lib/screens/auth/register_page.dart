import 'package:first_app/core/services/backend_api_service.dart';
import 'package:first_app/core/services/auth_storage_service.dart';
import 'package:first_app/core/theme/app_colors.dart';
import 'package:first_app/core/theme/app_text_styles.dart';
import 'package:first_app/core/widgets/glucare_brand_header.dart';
import 'package:first_app/core/widgets/primary_pill_button.dart';
import 'package:first_app/navigation/app_router.dart';
import 'package:first_app/navigation/app_routes.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
    this.title = 'Đăng ký tài khoản mới',
    this.continueToProfileSetup = true,
  });

  final String title;
  final bool continueToProfileSetup;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final BackendApiService _backendApiService = BackendApiService.instance;
  final AuthStorageService _authStorageService = AuthStorageService.instance;

  bool acceptedTerms = false;
  bool isValidPhone = false;
  bool isPasswordStep = false;
  bool isValidPassword = false;
  bool isPasswordVisible = false;
  bool isSubmitting = false;
  bool showValidationErrors = false;
  String? submitErrorMessage;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  int get _minPasswordLength => widget.continueToProfileSetup ? 8 : 6;

  String? get _phoneError {
    if (!showValidationErrors) {
      return null;
    }

    final String input = phoneController.text.trim();
    if (input.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    if (!_isPhoneValid(input)) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  String? get _passwordError {
    if (!showValidationErrors || !isPasswordStep) {
      return null;
    }

    final String password = passwordController.text.trim();
    if (password.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (password.length < _minPasswordLength) {
      return 'Mật khẩu phải có ít nhất $_minPasswordLength ký tự';
    }
    return null;
  }

  String? get _termsError {
    if (!widget.continueToProfileSetup || !showValidationErrors) {
      return null;
    }
    if (!acceptedTerms) {
      return 'Bạn cần đồng ý điều khoản để tiếp tục';
    }
    return null;
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool _isPhoneValid(String input) {
    final String normalized = input.replaceAll(RegExp(r'\s+'), '');

    if (RegExp(r'^0\d{9}$').hasMatch(normalized)) {
      return true;
    }

    if (RegExp(r'^\+84\d{9}$').hasMatch(normalized)) {
      return true;
    }

    return false;
  }

  String _toLocalPhone(String input) {
    final String normalized = input.replaceAll(RegExp(r'\s+'), '');
    if (RegExp(r'^0\d{9}$').hasMatch(normalized)) {
      return normalized;
    }
    if (RegExp(r'^\+84\d{9}$').hasMatch(normalized)) {
      return '0${normalized.substring(3)}';
    }
    return normalized;
  }

  String _formatPhoneForDisplay(String localPhone) {
    if (RegExp(r'^0\d{9}$').hasMatch(localPhone)) {
      return '${localPhone.substring(0, 4)} ${localPhone.substring(4, 7)} ${localPhone.substring(7, 10)}';
    }
    return localPhone;
  }

  Future<void> _onContinuePressed() async {
    if (!isPasswordStep) {
      setState(() {
        showValidationErrors = true;
        submitErrorMessage = null;
      });

      if (_phoneError != null || _termsError != null) {
        return;
      }

      setState(() {
        isPasswordStep = true;
        showValidationErrors = false;
      });
      return;
    }

    setState(() {
      showValidationErrors = true;
      submitErrorMessage = null;
    });

    if (_passwordError != null || isSubmitting) {
      return;
    }

    final String phone = _toLocalPhone(phoneController.text.trim());
    final String password = passwordController.text.trim();

    setState(() {
      isSubmitting = true;
    });

    try {
      if (!widget.continueToProfileSetup) {
        final Map<String, dynamic> response = await _backendApiService
            .loginUser(phoneNumber: phone, password: password);

        final Map<String, dynamic> data =
            (response['data'] as Map<String, dynamic>?) ??
            const <String, dynamic>{};
        await _authStorageService.saveSession(
          accessToken: (data['accessToken'] ?? '').toString(),
          refreshToken: (data['refreshToken'] ?? '').toString(),
          userId: (data['userId'] ?? '').toString(),
          role: (data['role'] ?? '').toString(),
        );

        if (!mounted) {
          return;
        }

        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
        return;
      }

      Navigator.of(context).pushNamed(
        AppRoutes.medicalProfileSetup,
        arguments: MedicalProfileSetupRouteArgs(
          phoneNumber: phone,
          password: password,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        submitErrorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  void _toggleTerms() {
    setState(() {
      acceptedTerms = !acceptedTerms;
      submitErrorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: Text(widget.title, style: AppTextStyles.appBarTitle),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 14),
          child: Column(
            children: [
              const SizedBox(height: 4),
              const GluCareBrandHeader(logoWidth: 150, textWidth: 190, gap: 10),
              const SizedBox(height: 56),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1,
                    child: child,
                  ),
                ),
                child: isPasswordStep
                    ? Column(
                        key: const ValueKey('password-step'),
                        children: [
                          const Text(
                            'Nhập mật khẩu cho số',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatPhoneForDisplay(
                              _toLocalPhone(phoneController.text),
                            ),
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            controller: passwordController,
                            obscureText: !isPasswordVisible,
                            textAlign: TextAlign.center,
                            onChanged: (value) {
                              final bool nextIsValidPassword =
                                  value.trim().length >= _minPasswordLength;
                              if (nextIsValidPassword != isValidPassword ||
                                  showValidationErrors ||
                                  submitErrorMessage != null) {
                                setState(() {
                                  isValidPassword = nextIsValidPassword;
                                  submitErrorMessage = null;
                                });
                              }
                            },
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 26,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Nhập mật khẩu',
                              hintStyle: const TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: 30,
                                fontWeight: FontWeight.w500,
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.lightBlue,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.primaryBlue,
                                  width: 2,
                                ),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                                icon: Icon(
                                  isPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          ),
                          if (_passwordError != null) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _passwordError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Tối thiểu $_minPasswordLength ký tự',
                                style: const TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ],
                      )
                    : TextField(
                        key: const ValueKey('phone-step'),
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          final bool nextIsValidPhone = _isPhoneValid(value);
                          if (nextIsValidPhone != isValidPhone ||
                              showValidationErrors ||
                              submitErrorMessage != null) {
                            setState(() {
                              isValidPhone = nextIsValidPhone;
                              submitErrorMessage = null;
                            });
                          }
                        },
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 32,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          hintText: 'Nhập số điện thoại',
                          hintStyle: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.lightBlue,
                              width: 2,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryBlue,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
              ),
              if (!isPasswordStep && _phoneError != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _phoneError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 56),
              if (widget.continueToProfileSetup) ...[
                Row(
                  children: [
                    GestureDetector(
                      onTap: _toggleTerms,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.checkboxBorder,
                            width: 3,
                          ),
                        ),
                        child: acceptedTerms
                            ? const Icon(
                                Icons.check,
                                size: 22,
                                color: AppColors.primaryBlue,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 18,
                          ),
                          children: [
                            TextSpan(text: 'Tôi đã đọc và đồng ý '),
                            TextSpan(
                              text: 'Điều khoản sử dụng',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (_termsError != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _termsError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],
              if ((submitErrorMessage ?? '').trim().isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE7E7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFB7B7)),
                  ),
                  child: Text(
                    submitErrorMessage!,
                    style: const TextStyle(
                      color: Color(0xFFB3261E),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              PrimaryPillButton(
                label: isSubmitting ? 'Đang xử lý...' : 'Tiếp theo',
                onPressed: isSubmitting ? null : _onContinuePressed,
                disabledBackgroundColor: AppColors.disabledButton,
                disabledForegroundColor: AppColors.disabledText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
