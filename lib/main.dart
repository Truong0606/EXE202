import 'package:flutter/material.dart';

void main() {
  runApp(const GluCareApp());
}

class GluCareApp extends StatelessWidget {
  const GluCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPrototypePage(),
    );
  }
}

class LoginPrototypePage extends StatelessWidget {
  const LoginPrototypePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCCE0E6),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/glucare_logo.png',
                  width: 190,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                Image.asset(
                  'assets/images/glucare_text.png',
                  width: 140,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => const RegisterPage(
                              title: 'Đăng nhập',
                              continueToProfileSetup: false,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F80ED),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Đăng nhập'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F80ED),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 10,
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Đăng ký'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
        Navigator.of(context).push(
          PageRouteBuilder<void>(
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (_, animation, __) => FadeTransition(
              opacity: animation,
              child: const MedicalProfileSetupPage(),
            ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xác thực OTP thành công')),
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
      backgroundColor: const Color(0xFFCCE0E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F80ED),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 14),
          child: Column(
            children: [
              const SizedBox(height: 4),
              Image.asset(
                'assets/images/glucare_logo.png',
                width: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              Image.asset(
                'assets/images/glucare_text.png',
                width: 190,
                fit: BoxFit.contain,
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
                              color: Color(0xFF2F80ED),
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
                              color: Color(0xFF3A3A3A),
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
                              color: Color(0xFF2F80ED),
                              fontSize: 28,
                              letterSpacing: 6,
                            ),
                            decoration: const InputDecoration(
                              counterText: '',
                              isDense: true,
                              hintText: 'Nhập mã OTP',
                              hintStyle: TextStyle(
                                color: Color(0xFF2F80ED),
                                fontSize: 32,
                                fontWeight: FontWeight.w500,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF89B7CB),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF2F80ED),
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
                          color: Color(0xFF2F80ED),
                          fontSize: 32,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          hintText: 'Nhập số điện thoại',
                          hintStyle: TextStyle(
                            color: Color(0xFF2F80ED),
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF89B7CB),
                              width: 2,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF2F80ED),
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
                          color: const Color(0xFF3E7DA0),
                          width: 3,
                        ),
                      ),
                      child: acceptedTerms
                          ? const Icon(
                              Icons.check,
                              size: 22,
                              color: Color(0xFF2F80ED),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          color: Color(0xFF2F80ED),
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
                      color: Color(0xFF3E7DA0),
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (isOtpStep ? isValidOtp : isValidPhone)
                      ? _onContinuePressed
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    disabledBackgroundColor: const Color(0xFFA8A8A8),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: const Color(0xFFD9D9D9),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(36),
                    ),
                  ),
                  child: const Text(
                    'Tiếp theo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MedicalProfileSetupPage extends StatefulWidget {
  const MedicalProfileSetupPage({super.key});

  @override
  State<MedicalProfileSetupPage> createState() => _MedicalProfileSetupPageState();
}

class _MedicalProfileSetupPageState extends State<MedicalProfileSetupPage> {
  bool? isFemale;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCCE0E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F80ED),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Thiết lập hồ sơ bệnh án',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 40, 22, 22),
          child: Column(
            children: [
              const SizedBox(height: 48),
              const Text(
                'Tên của bạn',
                style: TextStyle(
                  color: Color(0xFF2F80ED),
                  fontSize: 46,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                height: 62,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFF7B8D97)),
                ),
                child: TextField(
                  controller: nameController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF2F80ED),
                    fontSize: 34,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Nhập tên của bạn',
                    hintStyle: TextStyle(
                      color: Color(0xFF7FA7BC),
                      fontSize: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Giới tính',
                style: TextStyle(
                  color: Color(0xFF2F80ED),
                  fontSize: 46,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => isFemale = false),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isFemale == false
                                ? const Color(0xFF2F80ED)
                                : Colors.transparent,
                            border: Border.all(
                              color: const Color(0xFF2F80ED),
                              width: 3,
                            ),
                          ),
                          child: isFemale == false
                              ? const Icon(
                                  Icons.check,
                                  size: 20,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Nam',
                          style: TextStyle(
                            color: Color(0xFF2F80ED),
                            fontSize: 34,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 42),
                  GestureDetector(
                    onTap: () => setState(() => isFemale = true),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isFemale == true
                                ? const Color(0xFF2F80ED)
                                : Colors.transparent,
                            border: Border.all(
                              color: const Color(0xFF2F80ED),
                              width: 3,
                            ),
                          ),
                          child: isFemale == true
                              ? const Icon(
                                  Icons.check,
                                  size: 20,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Nữ',
                          style: TextStyle(
                            color: Color(0xFF2F80ED),
                            fontSize: 34,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                'Ngày sinh',
                style: TextStyle(
                  color: Color(0xFF2F80ED),
                  fontSize: 46,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                height: 62,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFF7B8D97)),
                ),
                child: TextField(
                  controller: birthDateController,
                  keyboardType: TextInputType.datetime,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF2F80ED),
                    fontSize: 34,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Nhập ngày sinh',
                    hintStyle: TextStyle(
                      color: Color(0xFF7FA7BC),
                      fontSize: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 170),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final String displayName = nameController.text.trim();

                    Navigator.of(context).push(
                      PageRouteBuilder<void>(
                        transitionDuration: const Duration(milliseconds: 300),
                        pageBuilder: (_, animation, __) => FadeTransition(
                          opacity: animation,
                          child: ProfileGreetingPage(
                            name: displayName,
                          ),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(36),
                    ),
                  ),
                  child: const Text(
                    'Tiếp theo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileGreetingPage extends StatelessWidget {
  const ProfileGreetingPage({
    required this.name,
    super.key,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCCE0E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F80ED),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Thiết lập hồ sơ bệnh án',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Image.asset(
                'assets/images/glucare_logo.png',
                width: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              Image.asset(
                'assets/images/glucare_text.png',
                width: 190,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 140),
              const Text(
                'Xin chào!',
                style: TextStyle(
                  color: Color(0xFF2F80ED),
                  fontSize: 46,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(
                  color: Color(0xFF2F80ED),
                  fontSize: 58,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 210),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder<void>(
                        transitionDuration: const Duration(milliseconds: 300),
                        pageBuilder: (_, animation, __) => FadeTransition(
                          opacity: animation,
                          child: const OnboardingIntroPage(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(36),
                    ),
                  ),
                  child: const Text(
                    'Tiếp theo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingIntroPage extends StatelessWidget {
  const OnboardingIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCCE0E6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 14),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        'Chào mừng đến với',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF234B82),
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        'GlucoDia',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF234B82),
                          fontSize: 56,
                          height: 1.05,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ứng dụng hỗ trợ quản lý đường huyết',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF3D5F8F),
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: AspectRatio(
                          aspectRatio: 1.12,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFBED2E7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/glucare_logo.png',
                                      width: 190,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 20,
                                bottom: -2,
                                child: Image.asset(
                                  'assets/images/mascot_talk_4.png',
                                  width: 86,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(36),
                    ),
                  ),
                  child: const Text(
                    'Bắt đầu',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
