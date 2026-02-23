import 'package:first_app/core/theme/app_colors.dart';
import 'package:first_app/core/widgets/primary_pill_button.dart';
import 'package:first_app/navigation/app_routes.dart';
import 'package:flutter/material.dart';

class UserGroupSelectionPage extends StatefulWidget {
  const UserGroupSelectionPage({super.key});

  @override
  State<UserGroupSelectionPage> createState() => _UserGroupSelectionPageState();
}

class _UserGroupSelectionPageState extends State<UserGroupSelectionPage> {
  int? selectedIndex;

  final List<_GroupOption> options = const <_GroupOption>[
    _GroupOption(
      emoji: '🧬',
      title: 'Là người bị tiểu đường',
      subtitle: 'type 1 / type 2',
    ),
    _GroupOption(
      emoji: '🤰',
      title: 'Mẹ bầu bị',
      subtitle: 'tiểu đường thai kỳ',
    ),
    _GroupOption(
      emoji: '❤️',
      title: 'Người thân',
      subtitle: 'đang chăm sóc',
    ),
    _GroupOption(
      emoji: '🧑‍⚕️',
      title: 'Bác sĩ',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 36, 22, 22),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Bạn thuộc nhóm nào?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.deepBlue,
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 34),
              Expanded(
                child: ListView.separated(
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (BuildContext context, int index) {
                    final _GroupOption option = options[index];
                    final bool isSelected = selectedIndex == index;

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.background
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryBlue
                                : AppColors.lightBlue,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryBlue
                                    : AppColors.deepBlue,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  option.emoji,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.title,
                                    style: TextStyle(
                                      color: AppColors.deepBlue,
                                      fontSize: 22,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  if (option.subtitle != null)
                                    Text(
                                      option.subtitle!,
                                      style: TextStyle(
                                        color: AppColors.deepBlue,
                                        fontSize: 20,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primaryBlue,
                                size: 28,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              PrimaryPillButton(
                label: 'Tiếp tục',
                onPressed: selectedIndex == null
                    ? null
                    : () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.forgotRecordPrompt,
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

class _GroupOption {
  const _GroupOption({
    required this.emoji,
    required this.title,
    this.subtitle,
  });

  final String emoji;
  final String title;
  final String? subtitle;
}
