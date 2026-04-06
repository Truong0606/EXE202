import 'package:first_app/core/services/backend_api_service.dart';
import 'package:first_app/core/theme/app_colors.dart';
import 'package:first_app/core/theme/app_text_styles.dart';
import 'package:first_app/navigation/app_router.dart';
import 'package:first_app/navigation/app_routes.dart';
import 'package:first_app/core/widgets/primary_pill_button.dart';
import 'package:flutter/material.dart';

class MedicalProfileSetupPage extends StatefulWidget {
  const MedicalProfileSetupPage({super.key, this.args});

  final MedicalProfileSetupRouteArgs? args;

  @override
  State<MedicalProfileSetupPage> createState() =>
      _MedicalProfileSetupPageState();
}

class _MedicalProfileSetupPageState extends State<MedicalProfileSetupPage> {
  final BackendApiService _backendApiService = BackendApiService.instance;

  bool? isFemale;
  bool isSubmitting = false;
  bool showValidationErrors = false;
  DateTime? selectedBirthDate;
  String? submitErrorMessage;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  String? get _nameError {
    if (!showValidationErrors) {
      return null;
    }
    final String fullName = nameController.text.trim();
    if (fullName.isEmpty) {
      return 'Vui lòng nhập tên';
    }
    if (fullName.length < 2) {
      return 'Tên phải có ít nhất 2 ký tự';
    }
    return null;
  }

  String? get _genderError {
    if (!showValidationErrors) {
      return null;
    }
    if (isFemale == null) {
      return 'Vui lòng chọn giới tính';
    }
    return null;
  }

  String? get _birthDateError {
    if (!showValidationErrors) {
      return null;
    }
    if (selectedBirthDate == null) {
      return 'Vui lòng chọn ngày sinh';
    }
    return null;
  }

  Future<void> _pickBirthDate() async {
    final DateTime now = DateTime.now();
    final DateTime suggestedInitialDate = DateTime(
      now.year - 18,
      now.month,
      now.day,
    );
    final DateTime initialDate = selectedBirthDate ?? suggestedInitialDate;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(now) ? now : initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Chọn ngày sinh',
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      selectedBirthDate = pickedDate;
      birthDateController.text = _formatDate(pickedDate);
      if (showValidationErrors) {
        showValidationErrors = false;
      }
      submitErrorMessage = null;
    });
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day/$month/$year';
  }

  @override
  void dispose() {
    nameController.dispose();
    birthDateController.dispose();
    super.dispose();
  }

  Future<void> _onSubmitProfile() async {
    if (isSubmitting) {
      return;
    }

    final String fullName = nameController.text.trim();
    setState(() {
      showValidationErrors = true;
      submitErrorMessage = null;
    });

    if (_nameError != null || _birthDateError != null || _genderError != null) {
      return;
    }

    if (fullName.isEmpty || selectedBirthDate == null || isFemale == null) {
      setState(() {
        showValidationErrors = true;
      });
      return;
    }

    final String? phoneNumber = widget.args?.phoneNumber;
    final String? password = widget.args?.password;
    if (phoneNumber == null || password == null) {
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final String gender = isFemale == true ? 'FEMALE' : 'MALE';
      final String dateOfBirth =
          '${selectedBirthDate!.year.toString().padLeft(4, '0')}-${selectedBirthDate!.month.toString().padLeft(2, '0')}-${selectedBirthDate!.day.toString().padLeft(2, '0')}';

      await _backendApiService.registerPatient(
        phoneNumber: phoneNumber,
        password: password,
        fullName: fullName,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushNamed(
        AppRoutes.profileGreeting,
        arguments: ProfileGreetingRouteArgs(name: fullName),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Thiết lập hồ sơ bệnh án',
          style: AppTextStyles.appBarTitle,
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 40, 22, 22),
          child: Column(
            children: [
              const SizedBox(height: 48),
              const Text('Tên của bạn', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                height: 62,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: AppColors.mediumGray),
                ),
                child: TextField(
                  controller: nameController,
                  onChanged: (_) {
                    if (showValidationErrors || submitErrorMessage != null) {
                      setState(() {
                        showValidationErrors = false;
                        submitErrorMessage = null;
                      });
                    }
                  },
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 34,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Nhập tên của bạn',
                    hintStyle: TextStyle(
                      color: AppColors.hintBlue,
                      fontSize: 28,
                    ),
                  ),
                ),
              ),
              if (_nameError != null) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _nameError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              const Text('Giới tính', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isFemale = false;
                        if (showValidationErrors) {
                          showValidationErrors = false;
                        }
                      });
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isFemale == false
                                ? AppColors.primaryBlue
                                : Colors.transparent,
                            border: Border.all(
                              color: AppColors.primaryBlue,
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
                            color: AppColors.primaryBlue,
                            fontSize: 34,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 42),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isFemale = true;
                        if (showValidationErrors) {
                          showValidationErrors = false;
                        }
                      });
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isFemale == true
                                ? AppColors.primaryBlue
                                : Colors.transparent,
                            border: Border.all(
                              color: AppColors.primaryBlue,
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
                            color: AppColors.primaryBlue,
                            fontSize: 34,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_genderError != null) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _genderError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              const Text('Ngày sinh', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                height: 62,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: AppColors.mediumGray),
                ),
                child: TextField(
                  controller: birthDateController,
                  readOnly: true,
                  onTap: _pickBirthDate,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 34,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Nhập ngày sinh',
                    hintStyle: const TextStyle(
                      color: AppColors.hintBlue,
                      fontSize: 28,
                    ),
                    suffixIcon: IconButton(
                      onPressed: _pickBirthDate,
                      icon: const Icon(
                        Icons.calendar_month,
                        color: AppColors.primaryBlue,
                      ),
                      tooltip: 'Chọn ngày sinh',
                    ),
                  ),
                ),
              ),
              if (_birthDateError != null) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _birthDateError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              if ((submitErrorMessage ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 18),
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
              ],
              const SizedBox(height: 170),
              PrimaryPillButton(
                label: isSubmitting ? 'Đang xử lý...' : 'Tiếp theo',
                onPressed: _onSubmitProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
