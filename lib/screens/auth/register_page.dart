import 'package:first_app/core/theme/app_colors.dart';
import 'package:first_app/core/theme/app_text_styles.dart';
import 'package:first_app/navigation/app_routes.dart';
import 'package:first_app/core/widgets/glucare_brand_header.dart';
import 'package:first_app/core/widgets/primary_pill_button.dart';
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
  bool acceptedTerms = false;
  bool isValidPhone = false;
  bool isOtpStep = false;
  bool isValidOtp = false;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
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

  void _onContinuePressed() {
    if (!isOtpStep) {
      if (!isValidPhone) {
        return;
      }
      setState(() {
        isOtpStep = true;
        acceptedTerms = true;
        otpController.text = '0000';
        isValidOtp = true;
      });
      return;
    }

    if (otpController.text.trim() == '0000') {
      if (widget.continueToProfileSetup) {
        Navigator.of(context).pushNamed(AppRoutes.medicalProfileSetup);
        return;
      }

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mã OTP không đúng, vui lòng thử lại')),
    );
  }

  void _toggleTerms() {
    setState(() {
      acceptedTerms = !acceptedTerms;
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
        title: Text(
          widget.title,
          style: AppTextStyles.appBarTitle,
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 14),
          child: Column(
            children: [
              const SizedBox(height: 4),
              const GluCareBrandHeader(
                logoWidth: 150,
                textWidth: 190,
                gap: 10,
              ),
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
                child: isOtpStep
                    ? Column(
                        key: const ValueKey('otp-step'),
                        children: [
                          const Text(
                            'Mã OTP đã được gửi tới',
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
                            controller: otpController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 4,
                            onChanged: (value) {
                              final bool nextIsValidOtp =
                                  value.trim().length == 4;
                              if (nextIsValidOtp != isValidOtp) {
                                setState(() {
                                  isValidOtp = nextIsValidOtp;
                                });
                              }
                            },
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 28,
                              letterSpacing: 6,
                            ),
                            decoration: const InputDecoration(
                              counterText: '',
                              isDense: true,
                              hintText: 'Nhập mã OTP',
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
                        ],
                      )
                    : TextField(
                        key: const ValueKey('phone-step'),
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          final bool nextIsValidPhone = _isPhoneValid(value);
                          if (nextIsValidPhone != isValidPhone) {
                            setState(() {
                              isValidPhone = nextIsValidPhone;
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
              const SizedBox(height: 56),
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
              const SizedBox(height: 16),
              if (isOtpStep) ...[
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Không nhận được mã?',
                    style: TextStyle(
                      color: AppColors.checkboxBorder,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              PrimaryPillButton(
                label: 'Tiếp theo',
                onPressed: (isOtpStep ? isValidOtp : isValidPhone)
                    ? _onContinuePressed
                    : null,
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
