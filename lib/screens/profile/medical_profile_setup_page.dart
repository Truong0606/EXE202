import 'package:first_app/core/theme/app_colors.dart';
import 'package:first_app/core/theme/app_text_styles.dart';
import 'package:first_app/navigation/app_router.dart';
import 'package:first_app/navigation/app_routes.dart';
import 'package:first_app/core/widgets/primary_pill_button.dart';
import 'package:flutter/material.dart';

class MedicalProfileSetupPage extends StatefulWidget {
  const MedicalProfileSetupPage({super.key});

  @override
  State<MedicalProfileSetupPage> createState() => _MedicalProfileSetupPageState();
}

class _MedicalProfileSetupPageState extends State<MedicalProfileSetupPage> {
  bool? isFemale;
  DateTime? selectedBirthDate;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

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
    emailController.dispose();
    birthDateController.dispose();
    super.dispose();
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
              const Text(
                'Tên của bạn',
                style: AppTextStyles.sectionTitle,
              ),
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
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                height: 62,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: AppColors.mediumGray),
                ),
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 34,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Nhập email của bạn',
                    hintStyle: TextStyle(
                      color: AppColors.hintBlue,
                      fontSize: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Giới tính',
                style: AppTextStyles.sectionTitle,
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
                    onTap: () => setState(() => isFemale = true),
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
              const SizedBox(height: 28),
              const Text(
                'Ngày sinh',
                style: AppTextStyles.sectionTitle,
              ),
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
              const SizedBox(height: 170),
              PrimaryPillButton(
                label: 'Tiếp theo',
                onPressed: () {
                  final String displayName = nameController.text.trim();

                  Navigator.of(context).pushNamed(
                    AppRoutes.profileGreeting,
                    arguments: ProfileGreetingRouteArgs(name: displayName),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
