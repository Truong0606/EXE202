import 'package:first_app/core/services/backend_api_service.dart';
import 'package:first_app/core/theme/app_colors.dart';
import 'package:first_app/core/theme/app_text_styles.dart';
import 'package:first_app/core/widgets/glucare_brand_header.dart';
import 'package:first_app/core/widgets/primary_pill_button.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final BackendApiService _backendApiService = BackendApiService.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isSubmitting = false;
  bool _showValidationErrors = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _submitErrorMessage;
  String? _successMessage;

  String? get _phoneError {
    if (!_showValidationErrors) {
      return null;
    }

    final String input = _phoneController.text.trim();
    if (input.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    if (!_isPhoneValid(input)) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  String? get _passwordError {
    if (!_showValidationErrors) {
      return null;
    }

    final String password = _passwordController.text.trim();
    if (password.isEmpty) {
      return 'Vui lòng nhập mật khẩu mới';
    }
    if (password.length < 6) {
      return 'Mật khẩu mới phải có ít nhất 6 ký tự';
    }
    return null;
  }

  String? get _confirmPasswordError {
    if (!_showValidationErrors) {
      return null;
    }

    final String confirmPassword = _confirmPasswordController.text.trim();
    if (confirmPassword.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu mới';
    }
    if (confirmPassword != _passwordController.text.trim()) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isPhoneValid(String input) {
    final String normalized = input.replaceAll(RegExp(r'\s+'), '');
    return RegExp(r'^0\d{9}$').hasMatch(normalized) ||
        RegExp(r'^\+84\d{9}$').hasMatch(normalized);
  }

  String _toLocalPhone(String input) {
    final String normalized = input.replaceAll(RegExp(r'\s+'), '');
    if (RegExp(r'^\+84\d{9}$').hasMatch(normalized)) {
      return '0${normalized.substring(3)}';
    }
    return normalized;
  }

  Future<void> _submit() async {
    setState(() {
      _showValidationErrors = true;
      _submitErrorMessage = null;
      _successMessage = null;
    });

    if (_phoneError != null ||
        _passwordError != null ||
        _confirmPasswordError != null ||
        _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _backendApiService.forgotPassword(
        phoneNumber: _toLocalPhone(_phoneController.text.trim()),
        newPassword: _passwordController.text.trim(),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _successMessage =
            'Mật khẩu đã được cập nhật. Bạn có thể quay lại đăng nhập.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _submitErrorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildErrorText(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
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
        title: Text('Quên mật khẩu', style: AppTextStyles.appBarTitle),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              const Center(
                child: GluCareBrandHeader(
                  logoWidth: 150,
                  textWidth: 190,
                  gap: 10,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Đặt lại mật khẩu',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nhập số điện thoại đã đăng ký và mật khẩu mới. Thông báo sẽ hiển thị ngay trên màn hình này.',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Số điện thoại',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                onChanged: (_) {
                  if (_showValidationErrors ||
                      _submitErrorMessage != null ||
                      _successMessage != null) {
                    setState(() {
                      _submitErrorMessage = null;
                      _successMessage = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: '0901 234 567',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              if (_phoneError != null) _buildErrorText(_phoneError!),
              const SizedBox(height: 16),
              const Text(
                'Mật khẩu mới',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                onChanged: (_) {
                  if (_showValidationErrors ||
                      _submitErrorMessage != null ||
                      _successMessage != null) {
                    setState(() {
                      _submitErrorMessage = null;
                      _successMessage = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Tối thiểu 6 ký tự',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
              ),
              if (_passwordError != null) _buildErrorText(_passwordError!),
              const SizedBox(height: 16),
              const Text(
                'Xác nhận mật khẩu mới',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                onChanged: (_) {
                  if (_showValidationErrors ||
                      _submitErrorMessage != null ||
                      _successMessage != null) {
                    setState(() {
                      _submitErrorMessage = null;
                      _successMessage = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Nhập lại mật khẩu mới',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
              ),
              if (_confirmPasswordError != null)
                _buildErrorText(_confirmPasswordError!),
              const SizedBox(height: 18),
              if ((_submitErrorMessage ?? '').trim().isNotEmpty) ...[
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
                    _submitErrorMessage!,
                    style: const TextStyle(
                      color: Color(0xFFB3261E),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              if ((_successMessage ?? '').trim().isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F7E9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF97D8A1)),
                  ),
                  child: Text(
                    _successMessage!,
                    style: const TextStyle(
                      color: Color(0xFF166534),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              PrimaryPillButton(
                label: _isSubmitting ? 'Đang xử lý...' : 'Cập nhật mật khẩu',
                onPressed: _isSubmitting ? null : _submit,
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
