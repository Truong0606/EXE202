part of 'home_page.dart';

class Glucose24hDetailPage extends StatelessWidget {
  const Glucose24hDetailPage({super.key, required this.dataPoints});

  final List<double> dataPoints;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4E3EA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A2150),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 30),
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.white,
        ),
        title: const Text(
          'Đường huyết trong 24h qua',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFFDFF5FF), Color(0xFF6BD0FF)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7EAF4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed(
                        AppRoutes.home,
                        arguments: const HomeRouteArgs(initialTabIndex: 2),
                      );
                    },
                    child: Row(
                      children: [
                        const _SafeAssetImage(
                          path: 'assets/images/homepage/Mascot Head 2 3.png',
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Hỏi Cam Cam: Tôi nên ăn gì hôm nay?',
                            style: TextStyle(
                              color: Color(0xFF6D8A9E),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.mic,
                          color: Color(0xFF2D7FB4),
                          size: 23,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFFDFF5FF), Color(0xFF6BD0FF)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Biểu đồ',
                      style: TextStyle(
                        color: Color(0xFF124A70),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF2B8BD7),
                          width: 3,
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 230,
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 34,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '200',
                                        style: TextStyle(
                                          color: Color(0xFF5485A5),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '100',
                                        style: TextStyle(
                                          color: Color(0xFF5485A5),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '50',
                                        style: TextStyle(
                                          color: Color(0xFF5485A5),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _Glucose24hGraph(
                                    dataPoints: dataPoints,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              Text(
                                '6AM',
                                style: TextStyle(
                                  color: Color(0xFF4B7898),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Spacer(),
                              Text(
                                '12PM',
                                style: TextStyle(
                                  color: Color(0xFF4B7898),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Spacer(),
                              Text(
                                '18PM',
                                style: TextStyle(
                                  color: Color(0xFF4B7898),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBFE2F2),
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            color: Color(0xFF3B769B),
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Chỉnh sửa',
                            style: TextStyle(
                              color: Color(0xFF3B769B),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBFE2F2),
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.share_outlined,
                            color: Color(0xFF3B769B),
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Chia sẻ',
                            style: TextStyle(
                              color: Color(0xFF3B769B),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _HomeBottomNav(
        currentIndex: 0,
        onSelected: (int index) {
          Navigator.of(context).pushReplacementNamed(
            AppRoutes.home,
            arguments: HomeRouteArgs(initialTabIndex: index),
          );
        },
      ),
    );
  }
}

class QuickEntryPage extends StatefulWidget {
  const QuickEntryPage({super.key, this.onGlucoseSaved});

  final Future<void> Function()? onGlucoseSaved;

  @override
  State<QuickEntryPage> createState() => _QuickEntryPageState();
}

class _QuickEntryPageState extends State<QuickEntryPage> {
  final BackendApiService _backendApiService = BackendApiService.instance;

  static const Map<String, String> _mealContextMap = <String, String>{
    'Trước ăn': 'BEFORE_MEAL',
    'Sau ăn': 'AFTER_MEAL',
    'Lúc đói': 'FASTING',
    'Trước khi ngủ': 'BEDTIME',
  };

  static const Map<String, String> _mealTypeMap = <String, String>{
    'Bữa sáng': 'BREAKFAST',
    'Bữa trưa': 'LUNCH',
    'Bữa tối': 'DINNER',
    'Bữa phụ': 'SNACK',
  };

  int selectedQuickType = 0;
  TimeOfDay selectedTime = const TimeOfDay(hour: 6, minute: 0);
  String selectedNote = 'Trước ăn';
  String selectedMealType = 'Bữa sáng';
  String selectedMedicationUnit = 'mg';
  bool isSavingGlucose = false;
  late final TextEditingController glucoseController;
  late final TextEditingController caloriesController;
  late final TextEditingController carbsController;
  late final TextEditingController foodNameController;
  late final TextEditingController doseController;
  late final TextEditingController medicineNameController;

  @override
  void initState() {
    super.initState();
    glucoseController = TextEditingController(text: '136');
    caloriesController = TextEditingController(text: '500');
    carbsController = TextEditingController(text: '50');
    foodNameController = TextEditingController(text: 'Phở bò');
    doseController = TextEditingController(text: '5');
    medicineNameController = TextEditingController(text: 'Astrapid');
  }

  @override
  void dispose() {
    glucoseController.dispose();
    caloriesController.dispose();
    carbsController.dispose();
    foodNameController.dispose();
    doseController.dispose();
    medicineNameController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  DateTime _buildRecordedAtFromSelectedTime() {
    final DateTime now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }

  Future<void> _showSavedSuccessPopup() async {
    if (!mounted) {
      return;
    }

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'save-success',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (BuildContext dialogContext, _, __) {
        final NavigatorState navigator = Navigator.of(dialogContext);
        Future<void>.delayed(const Duration(seconds: 1), () {
          if (navigator.mounted && navigator.canPop()) {
            navigator.pop();
          }
        });

        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xEE17324F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Đã lưu thành công',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveGlucoseReading() async {
    if (isSavingGlucose) {
      return;
    }

    final String glucoseText = glucoseController.text.trim();
    final double? glucoseValue = double.tryParse(glucoseText);
    if (glucoseValue == null || glucoseValue <= 0) {
      return;
    }

    final String mealContext = _mealContextMap[selectedNote] ?? 'BEFORE_MEAL';
    final DateTime recordedAt = _buildRecordedAtFromSelectedTime();

    setState(() {
      isSavingGlucose = true;
    });

    try {
      await _backendApiService.createGlucoseReading(
        glucoseValue: glucoseValue,
        mealContext: mealContext,
        recordedAt: recordedAt,
      );

      if (!mounted) {
        return;
      }

      if (widget.onGlucoseSaved != null) {
        await widget.onGlucoseSaved!.call();
      }
      await _showSavedSuccessPopup();
    } catch (_) {
      if (!mounted) {
        return;
      }
    } finally {
      if (mounted) {
        setState(() {
          isSavingGlucose = false;
        });
      }
    }
  }

  Future<void> _saveMealEntry() async {
    if (isSavingGlucose) {
      return;
    }

    final String foodName = foodNameController.text.trim();
    final double? calories = double.tryParse(caloriesController.text.trim());
    final double? carbs = double.tryParse(carbsController.text.trim());
    if (foodName.isEmpty || calories == null || carbs == null) {
      return;
    }

    final String mealType = _mealTypeMap[selectedMealType] ?? 'BREAKFAST';
    final DateTime recordedAt = _buildRecordedAtFromSelectedTime();

    setState(() {
      isSavingGlucose = true;
    });

    try {
      await _backendApiService.createMealEntry(
        foodName: foodName,
        mealType: mealType,
        calories: calories,
        carbs: carbs,
        recordedAt: recordedAt,
      );

      if (!mounted) {
        return;
      }
      await _showSavedSuccessPopup();
    } catch (_) {
      if (!mounted) {
        return;
      }
    } finally {
      if (mounted) {
        setState(() {
          isSavingGlucose = false;
        });
      }
    }
  }

  Future<void> _saveMedicationEntry() async {
    if (isSavingGlucose) {
      return;
    }

    final String medicineName = medicineNameController.text.trim();
    final double? dosage = double.tryParse(doseController.text.trim());
    if (medicineName.isEmpty || dosage == null || dosage <= 0) {
      return;
    }

    final DateTime recordedAt = _buildRecordedAtFromSelectedTime();

    setState(() {
      isSavingGlucose = true;
    });

    try {
      await _backendApiService.createMedicationEntry(
        medicineName: medicineName,
        dosage: dosage,
        unit: selectedMedicationUnit,
        recordedAt: recordedAt,
      );

      if (!mounted) {
        return;
      }
      await _showSavedSuccessPopup();
    } catch (_) {
      if (!mounted) {
        return;
      }
    } finally {
      if (mounted) {
        setState(() {
          isSavingGlucose = false;
        });
      }
    }
  }

  Future<void> _openAiGlucoseScanner() async {
    if (selectedQuickType != 0 || isSavingGlucose) {
      return;
    }

    final double? scannedValue = await Navigator.of(context).push<double>(
      MaterialPageRoute<double>(
        builder: (_) => const _AiGlucoseScanPage(),
      ),
    );
    if (scannedValue == null || !mounted) {
      return;
    }

    setState(() {
      glucoseController.text = scannedValue == scannedValue.roundToDouble()
          ? scannedValue.toStringAsFixed(0)
          : scannedValue.toStringAsFixed(1);
      selectedTime = TimeOfDay.now();
      selectedQuickType = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMealMode = selectedQuickType == 1;
    final bool isMedicineMode = selectedQuickType == 2;

    return Scaffold(
      backgroundColor: const Color(0xFFC7D9E2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A2150),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Nhập nhanh',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFB4D8EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedQuickType = 0;
                          });
                        },
                        child: _QuickActionChip(
                          label: '+ Đo',
                          icon: Icons.water_drop,
                          iconColor: const Color(0xFFFFA29D),
                          isSelected: selectedQuickType == 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedQuickType = 1;
                          });
                        },
                        child: _QuickActionChip(
                          label: '+ Bữa',
                          icon: Icons.ramen_dining,
                          iconColor: const Color(0xFF5ED5B7),
                          isSelected: selectedQuickType == 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedQuickType = 2;
                          });
                        },
                        child: _QuickActionChip(
                          label: '+ Thuốc',
                          icon: Icons.medication,
                          iconColor: const Color(0xFFFFA000),
                          isSelected: selectedQuickType == 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFFDFF5FF), Color(0xFF6BD0FF)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Text(
                      isMedicineMode
                          ? 'Nhập nhanh thuốc'
                          : isMealMode
                          ? 'Nhập nhanh bữa ăn'
                          : 'Nhập nhanh đường huyết',
                      style: const TextStyle(
                        color: Color(0xFF17324F),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Thời gian',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF17324F),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            isMedicineMode
                                ? 'Liều lượng'
                                : isMealMode
                                ? 'Calo'
                                : 'ĐH',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF17324F),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            isMedicineMode
                                ? 'Tên thuốc'
                                : isMealMode
                                ? 'Carbs'
                                : 'Ghi chú',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF17324F),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 42,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD7EAF4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: _pickTime,
                              child: Center(
                                child: Text(
                                  _formatTime(selectedTime),
                                  style: const TextStyle(
                                    color: Color(0xFF17324F),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 42,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD7EAF4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: isMedicineMode
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 34,
                                        child: TextField(
                                          controller: doseController,
                                          textAlign: TextAlign.right,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          style: const TextStyle(
                                            color: Color(0xFF17324F),
                                            fontSize: 24,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: selectedMedicationUnit,
                                          isDense: true,
                                          style: const TextStyle(
                                            color: Color(0xFF17324F),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          icon: const Icon(
                                            Icons.arrow_drop_down,
                                            color: Color(0xFF17324F),
                                            size: 20,
                                          ),
                                          onChanged: (String? value) {
                                            if (value != null) {
                                              setState(() {
                                                selectedMedicationUnit = value;
                                              });
                                            }
                                          },
                                          items: const [
                                            DropdownMenuItem<String>(
                                              value: 'mg',
                                              child: Text('mg'),
                                            ),
                                            DropdownMenuItem<String>(
                                              value: 'ml',
                                              child: Text('ml'),
                                            ),
                                            DropdownMenuItem<String>(
                                              value: 'viên',
                                              child: Text('viên'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : TextField(
                                  controller: isMealMode
                                    ? caloriesController
                                    : glucoseController,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    style: const TextStyle(
                                      color: Color(0xFF17324F),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 42,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD7EAF4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: isMedicineMode
                                ? TextField(
                                    controller: medicineNameController,
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    style: const TextStyle(
                                      color: Color(0xFF17324F),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: isMealMode
                                        ? TextField(
                                            controller: carbsController,
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.digitsOnly,
                                            ],
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                            style: const TextStyle(
                                              color: Color(0xFF17324F),
                                              fontSize: 24,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                        : DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: selectedNote,
                                              isExpanded: true,
                                              isDense: true,
                                              alignment: Alignment.centerLeft,
                                              borderRadius: BorderRadius.circular(10),
                                              style: const TextStyle(
                                                color: Color(0xFF17324F),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              icon: const Icon(
                                                Icons.arrow_drop_down,
                                                color: Color(0xFF17324F),
                                              ),
                                              selectedItemBuilder:
                                                  (BuildContext context) =>
                                                      const <Widget>[
                                                        Align(
                                                          alignment:
                                                              Alignment.centerLeft,
                                                          child: Text(
                                                            'Trước ăn',
                                                            overflow:
                                                                TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              Alignment.centerLeft,
                                                          child: Text(
                                                            'Sau ăn',
                                                            overflow:
                                                                TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              Alignment.centerLeft,
                                                          child: Text(
                                                            'Lúc đói',
                                                            overflow:
                                                                TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              Alignment.centerLeft,
                                                          child: Text(
                                                            'Trước khi ngủ',
                                                            overflow:
                                                                TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ],
                                              onChanged: (String? value) {
                                                if (value != null) {
                                                  setState(() {
                                                    selectedNote = value;
                                                  });
                                                }
                                              },
                                              items: const [
                                                DropdownMenuItem<String>(
                                                  value: 'Trước ăn',
                                                  child: Text(
                                                    'Trước ăn',
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                                DropdownMenuItem<String>(
                                                  value: 'Sau ăn',
                                                  child: Text(
                                                    'Sau ăn',
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                                DropdownMenuItem<String>(
                                                  value: 'Lúc đói',
                                                  child: Text(
                                                    'Lúc đói',
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                                DropdownMenuItem<String>(
                                                  value: 'Trước khi ngủ',
                                                  child: Text(
                                                    'Trước khi ngủ',
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    if (isMealMode) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 42,
                              alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD7EAF4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextField(
                                controller: foodNameController,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintText: 'Tên món',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF17324F),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 42,
                              alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD7EAF4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedMealType,
                                    isExpanded: true,
                                    isDense: true,
                                    alignment: Alignment.centerLeft,
                                    borderRadius: BorderRadius.circular(10),
                                    style: const TextStyle(
                                      color: Color(0xFF17324F),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Color(0xFF17324F),
                                    ),
                                    onChanged: (String? value) {
                                      if (value != null) {
                                        setState(() {
                                          selectedMealType = value;
                                        });
                                      }
                                    },
                                    items: const [
                                      DropdownMenuItem<String>(
                                        value: 'Bữa sáng',
                                        child: Text('Bữa sáng'),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'Bữa trưa',
                                        child: Text('Bữa trưa'),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'Bữa tối',
                                        child: Text('Bữa tối'),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'Bữa phụ',
                                        child: Text('Bữa phụ'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _openAiGlucoseScanner,
                            child: _QuickActionChip(
                              label: 'Quét AI',
                              isSelected: selectedQuickType == 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: !isSavingGlucose
                                ? selectedQuickType == 0
                                      ? _saveGlucoseReading
                                      : isMealMode
                                      ? _saveMealEntry
                                  : isMedicineMode
                                  ? _saveMedicationEntry
                                      : null
                                : null,
                            child: _QuickActionChip(
                              label: isSavingGlucose ? 'Đang lưu...' : 'Lưu',
                              isSelected: isSavingGlucose,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: _QuickActionChip(label: 'Cân bằng')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _HomeBottomNav(
        currentIndex: 0,
        onSelected: (int index) {
          Navigator.of(context).pushReplacementNamed(
            AppRoutes.home,
            arguments: HomeRouteArgs(initialTabIndex: index),
          );
        },
      ),
    );
  }
}

class _AiGlucoseScanPage extends StatefulWidget {
  const _AiGlucoseScanPage();

  @override
  State<_AiGlucoseScanPage> createState() => _AiGlucoseScanPageState();
}

class _AiGlucoseScanPageState extends State<_AiGlucoseScanPage> {
  final BackendApiService _backendApiService = BackendApiService.instance;
  CameraController? _cameraController;

  bool _isInitializingCamera = true;
  bool _isProcessing = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    unawaited(_prepareCamera());
  }

  @override
  void dispose() {
    unawaited(_cameraController?.dispose());
    super.dispose();
  }

  Future<void> _prepareCamera() async {
    final bool hasAccess = await _requestCameraAccess();
    if (!hasAccess) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isInitializingCamera = false;
        _errorText = 'Ứng dụng cần quyền camera để quét máy đo trong app.';
      });
      return;
    }

    await _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraController?.dispose();

      final List<CameraDescription> cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isInitializingCamera = false;
          _errorText = 'Không tìm thấy camera trên thiết bị này.';
        });
        return;
      }

      final CameraDescription selectedCamera = cameras.firstWhere(
        (CameraDescription camera) =>
            camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final CameraController controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _isInitializingCamera = false;
        _errorText = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isInitializingCamera = false;
        _errorText = 'Không thể mở camera trong app. Hãy thử lại.';
      });
    }
  }


  Future<bool> _requestCameraAccess() async {
    final PermissionStatus currentStatus = await Permission.camera.status;
    if (currentStatus.isGranted) {
      return true;
    }

    if (!mounted) {
      return false;
    }

    final bool shouldRequest = await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Cho phép dùng camera'),
              content: const Text(
                'Ứng dụng cần quyền camera để chụp ảnh máy đo và dùng AI điền nhanh chỉ số đường huyết.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Để sau'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Cho phép'),
                ),
              ],
            );
          },
        ) ??
        false;
    if (!shouldRequest) {
      return false;
    }

    final PermissionStatus newStatus = await Permission.camera.request();
    if (newStatus.isGranted) {
      return true;
    }

    if (!mounted) {
      return false;
    }

    if (newStatus.isPermanentlyDenied || newStatus.isRestricted) {
      final bool openSettings = await showDialog<bool>(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: const Text('Bật quyền camera'),
                content: const Text(
                  'Camera đang bị chặn. Hãy mở Cài đặt ứng dụng và cho phép quyền camera.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Hủy'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text('Mở cài đặt'),
                  ),
                ],
              );
            },
          ) ??
          false;
      if (openSettings) {
        await openAppSettings();
      }
    }

    return false;
  }

  double? _extractGlucoseValue(AiChatResultData result) {
    double? parseNumber(dynamic value) {
      final String text = (value ?? '').toString().trim().replaceAll(',', '.');
      if (text.isEmpty) {
        return null;
      }
      final double? parsed = double.tryParse(text);
      if (parsed == null || parsed < 20 || parsed > 600) {
        return null;
      }
      return parsed;
    }

    final List<dynamic> candidates = <dynamic>[
      result.rawData['glucoseValue'],
      result.rawData['value'],
      result.rawData['reading'],
      result.rawData['detectedValue'],
      result.reply,
      result.rawData['message'],
      result.rawData['content'],
    ];

    final dynamic extractedData = result.rawData['extractedData'];
    if (extractedData is Map<String, dynamic>) {
      candidates.addAll(<dynamic>[
        extractedData['glucoseValue'],
        extractedData['value'],
        extractedData['reading'],
      ]);
    }

    for (final dynamic candidate in candidates) {
      final double? direct = parseNumber(candidate);
      if (direct != null) {
        return direct;
      }

      final String text = (candidate ?? '').toString();
      final Iterable<RegExpMatch> matches = RegExp(
        r'(?<!\d)(\d{2,3}(?:[.,]\d)?)(?!\d)',
      ).allMatches(text);
      for (final RegExpMatch match in matches) {
        final double? parsed = parseNumber(match.group(1));
        if (parsed != null) {
          return parsed;
        }
      }
    }

    return null;
  }

  Future<void> _captureAndAnalyze() async {
    final CameraController? controller = _cameraController;
    if (_isProcessing || controller == null || !controller.value.isInitialized) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorText = null;
    });

    try {
      final XFile file = await controller.takePicture();

      final AiChatResultData result = await _backendApiService.sendAiChatMessage(
        message:
            'Hãy đọc chỉ số đường huyết từ ảnh máy đo. Chỉ trả về một giá trị số glucose mg/dL rõ ràng. Nếu không đọc được, trả về UNKNOWN.',
        file: File(file.path),
      );
      final double? glucoseValue = _extractGlucoseValue(result);
      if (!mounted) {
        return;
      }

      if (glucoseValue == null) {
        setState(() {
          _isProcessing = false;
          _errorText =
              'AI chưa đọc được chỉ số đường huyết từ ảnh này. Hãy chụp rõ màn hình máy đo hơn.';
        });
        return;
      }

      Navigator.of(context).pop(glucoseValue);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isProcessing = false;
        _errorText =
            'Không thể quét ảnh lúc này. Hãy thử lại với ảnh rõ hơn.';
      });
    }
  }

  Widget _buildCameraFrameContent() {
    if (_isInitializingCamera) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6BD7FF)),
        ),
      );
    }

    final CameraController? controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.videocam_off_outlined,
                color: Color(0x886BD7FF),
                size: 52,
              ),
              const SizedBox(height: 12),
              Text(
                _errorText ?? 'Không thể mở camera',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xCCFFFFFF),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isInitializingCamera = true;
                    _errorText = null;
                  });
                  unawaited(_prepareCamera());
                },
                child: const Text(
                  'Thử lại',
                  style: TextStyle(
                    color: Color(0xFF6BD7FF),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final Size? previewSize = controller.value.previewSize;
    if (previewSize == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              alignment: Alignment.center,
              child: SizedBox(
                width: previewSize.height,
                height: previewSize.width,
                child: CameraPreview(controller),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.34),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Đưa máy đo vào trong khung',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1934),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF17324F), Color(0xFF091935)],
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Chụp ảnh',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 320,
                              maxHeight: 420,
                            ),
                            child: AspectRatio(
                              aspectRatio: 0.82,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                      child: _buildCameraFrameContent(),
                                  ),
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: const _AiScanFramePainter(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        decoration: BoxDecoration(
                          color: const Color(0xAA6A4E54),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            const _SafeAssetImage(
                              path: 'assets/images/homepage/Mascot Talk 3 1.png',
                              width: 80,
                              height: 80,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'NHẤN CHỤP HÌNH ĐỂ MỞ CAMERA\nVÀ GỬI ẢNH MÁY ĐO CHO AI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_errorText != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xEED74D63),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            _errorText!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      const Text(
                        'Chụp hình',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _captureAndAnalyze,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF2B7BFF),
                              width: 7,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x66000000),
                                blurRadius: 18,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: _isProcessing
                                    ? const Color(0xFF17324F)
                                    : Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: _isProcessing
                                  ? const Padding(
                                      padding: EdgeInsets.all(14),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
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

class _AiScanFramePainter extends CustomPainter {
  const _AiScanFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF6BD7FF)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double cornerLength = 42;
    const double inset = 10;

    final Path path = Path()
      ..moveTo(inset + cornerLength, inset)
      ..lineTo(inset, inset)
      ..lineTo(inset, inset + cornerLength)
      ..moveTo(size.width - inset - cornerLength, inset)
      ..lineTo(size.width - inset, inset)
      ..lineTo(size.width - inset, inset + cornerLength)
      ..moveTo(inset, size.height - inset - cornerLength)
      ..lineTo(inset, size.height - inset)
      ..lineTo(inset + cornerLength, size.height - inset)
      ..moveTo(size.width - inset - cornerLength, size.height - inset)
      ..lineTo(size.width - inset, size.height - inset)
      ..lineTo(size.width - inset, size.height - inset - cornerLength);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.label,
    this.icon,
    this.iconColor,
    this.isSelected = false,
  });

  final String label;
  final IconData? icon;
  final Color? iconColor;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF4A93F3) : const Color(0xFFD6E8F1),
        borderRadius: BorderRadius.circular(11),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: iconColor ?? const Color(0xFF17324F)),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF17324F),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiAssistantTab extends StatefulWidget {
  const _AiAssistantTab({required this.onBackToHome});

  final VoidCallback onBackToHome;

  @override
  State<_AiAssistantTab> createState() => _AiAssistantTabState();
}

class _AiAssistantTabState extends State<_AiAssistantTab> {
  final TextEditingController _messageController = TextEditingController();
  final BackendApiService _backendApiService = BackendApiService.instance;
  final ScrollController _messagesScrollController = ScrollController();
  final List<_AiMessage> _messages = <_AiMessage>[];
  final List<AiChatSessionSummaryData> _sessions = <AiChatSessionSummaryData>[];
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();

  File? _selectedFile;
  String? _selectedFileName;
  String? _sessionId;
  bool _isSending = false;
  bool _isRecording = false;
  bool _isLoadingSessions = true;
  bool _isLoadingSessionMessages = false;
  bool _isManagingSession = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadSessions());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messagesScrollController.dispose();
    unawaited(_audioRecorder.dispose());
    super.dispose();
  }

  Future<void> _loadSessions({bool autoOpenLatest = true}) async {
    final List<AiChatSessionSummaryData> sessions =
        await _backendApiService.fetchAiSessions();
    if (!mounted) {
      return;
    }

    setState(() {
      _sessions
        ..clear()
        ..addAll(sessions);
      _isLoadingSessions = false;
    });

    if (!autoOpenLatest) {
      return;
    }

    if (_sessionId != null &&
        sessions.any((AiChatSessionSummaryData item) => item.id == _sessionId)) {
      return;
    }

    if (sessions.isNotEmpty) {
      await _selectSession(sessions.first.id);
    }
  }

  Future<void> _refreshSessionSummaries() async {
    final List<AiChatSessionSummaryData> sessions =
        await _backendApiService.fetchAiSessions();
    if (!mounted) {
      return;
    }

    setState(() {
      _sessions
        ..clear()
        ..addAll(sessions);
    });
  }

  String _deriveSessionTitle(String source) {
    final String singleLine = source
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (singleLine.isEmpty) {
      return 'Cuộc trò chuyện mới';
    }
    if (singleLine.length <= 32) {
      return singleLine;
    }
    return '${singleLine.substring(0, 32).trimRight()}...';
  }

  bool _isGenericSessionTitle(String title) {
    final String normalized = title.trim().toLowerCase();
    return normalized.isEmpty ||
        normalized == 'cuộc trò chuyện' ||
        normalized == 'cuoc tro chuyen' ||
        normalized == 'cuộc trò chuyện mới' ||
        normalized == 'new chat';
  }

  void _upsertSessionLocally({
    required String sessionId,
    required String title,
  }) {
    final int existingIndex = _sessions.indexWhere(
      (AiChatSessionSummaryData item) => item.id == sessionId,
    );
    final AiChatSessionSummaryData summary = AiChatSessionSummaryData(
      id: sessionId,
      title: title,
      updatedAt: DateTime.now(),
    );

    setState(() {
      if (existingIndex >= 0) {
        _sessions[existingIndex] = summary;
      } else {
        _sessions.insert(0, summary);
      }
    });
  }

  Future<void> _showRenameSessionDialog(AiChatSessionSummaryData session) async {
    if (_isManagingSession || _isSending || _isRecording) {
      return;
    }

    final TextEditingController controller = TextEditingController(
      text: session.title,
    );
    final String? renamed = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Đổi tên cuộc trò chuyện'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 255,
            decoration: const InputDecoration(
              hintText: 'Nhập tên cuộc trò chuyện',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (renamed == null) {
      return;
    }

    final String trimmedTitle = renamed.trim();
    if (trimmedTitle.isEmpty || trimmedTitle == session.title) {
      return;
    }

    setState(() {
      _isManagingSession = true;
    });

    try {
      await _backendApiService.renameAiSession(session.id, trimmedTitle);
      if (!mounted) {
        return;
      }

      final int index = _sessions.indexWhere(
        (AiChatSessionSummaryData item) => item.id == session.id,
      );
      if (index >= 0) {
        setState(() {
          _sessions[index] = AiChatSessionSummaryData(
            id: session.id,
            title: trimmedTitle,
            updatedAt: DateTime.now(),
            preview: session.preview,
          );
        });
      }
    } catch (error) {
      _appendErrorMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isManagingSession = false;
        });
      }
    }
  }

  Future<void> _deleteSession(AiChatSessionSummaryData session) async {
    if (_isManagingSession || _isSending || _isRecording) {
      return;
    }

    final bool confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Xóa cuộc trò chuyện'),
              content: Text('Xóa "${session.title}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Xóa'),
                ),
              ],
            );
          },
        ) ??
        false;
    if (!confirmed) {
      return;
    }

    setState(() {
      _isManagingSession = true;
    });

    try {
      await _backendApiService.deleteAiSession(session.id);
      if (!mounted) {
        return;
      }

      setState(() {
        _sessions.removeWhere((AiChatSessionSummaryData item) => item.id == session.id);
        if (_sessionId == session.id) {
          _sessionId = null;
          _messages.clear();
          _selectedFile = null;
          _selectedFileName = null;
        }
      });

      if (_sessionId == null && _sessions.isNotEmpty) {
        await _selectSession(_sessions.first.id);
      }
    } catch (error) {
      _appendErrorMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isManagingSession = false;
        });
      }
    }
  }

  Future<void> _selectSession(String sessionId) async {
    if (_isSending || _isRecording) {
      return;
    }

    setState(() {
      _sessionId = sessionId;
      _isLoadingSessionMessages = true;
      _selectedFile = null;
      _selectedFileName = null;
      _messages.clear();
    });

    final List<AiChatMessageData> history = await _backendApiService
        .fetchAiSessionMessages(sessionId);
    if (!mounted) {
      return;
    }

    setState(() {
      _messages
        ..clear()
        ..addAll(
          history.map(
            (AiChatMessageData item) => _AiMessage(
              text: item.text,
              isUser: item.isUser,
              attachmentName: item.attachmentName,
              disclaimer: item.disclaimer,
            ),
          ),
        );
      _isLoadingSessionMessages = false;
    });
    _scrollToBottom();
  }

  void _startNewChat() {
    if (_isSending || _isRecording) {
      return;
    }

    setState(() {
      _sessionId = null;
      _selectedFile = null;
      _selectedFileName = null;
      _messages.clear();
      _isLoadingSessionMessages = false;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_messagesScrollController.hasClients) {
        return;
      }

      _messagesScrollController.animateTo(
        _messagesScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  void _appendErrorMessage(String message) {
    if (!mounted) {
      return;
    }

    setState(() {
      _messages.add(
        _AiMessage(
          text: message,
          isUser: false,
          isError: true,
        ),
      );
    });
    _scrollToBottom();
  }

  String _fileNameFromPath(String path) {
    final List<String> segments = path.split(RegExp(r'[\\/]'));
    return segments.isEmpty ? path : segments.last;
  }

  Future<void> _pickAttachment() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>['jpg', 'jpeg', 'png', 'mp3', 'wav', 'm4a'],
      withData: false,
    );
    if (result == null || result.files.isEmpty) {
      return;
    }

    final PlatformFile file = result.files.first;
    final String? path = file.path;
    if (path == null || !mounted) {
      return;
    }

    setState(() {
      _selectedFile = File(path);
      _selectedFileName = file.name;
    });
  }

  Future<bool> _requestCameraAccess() async {
    final PermissionStatus currentStatus = await Permission.camera.status;
    if (currentStatus.isGranted) {
      return true;
    }

    if (!mounted) {
      return false;
    }

    final bool shouldRequest = await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Cho phép dùng camera'),
              content: const Text(
                'Ứng dụng cần quyền camera để chụp ảnh và tự động đính kèm vào đoạn chat AI.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Để sau'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Cho phép'),
                ),
              ],
            );
          },
        ) ??
        false;
    if (!shouldRequest) {
      return false;
    }

    final PermissionStatus newStatus = await Permission.camera.request();
    if (newStatus.isGranted) {
      return true;
    }

    if (!mounted) {
      return false;
    }

    if (newStatus.isPermanentlyDenied || newStatus.isRestricted) {
      final bool openSettings = await showDialog<bool>(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: const Text('Bật quyền camera'),
                content: const Text(
                  'Camera đang bị chặn. Hãy mở Cài đặt ứng dụng và cho phép quyền camera.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Hủy'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text('Mở cài đặt'),
                  ),
                ],
              );
            },
          ) ??
          false;
      if (openSettings) {
        await openAppSettings();
      }
    }

    return false;
  }

  Future<void> _captureImage() async {
    try {
      final bool hasAccess = await _requestCameraAccess();
      if (!hasAccess) {
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image == null || !mounted) {
        return;
      }

      setState(() {
        _selectedFile = File(image.path);
        _selectedFileName = image.name;
      });
    } catch (_) {
      _appendErrorMessage(
        'Không thể mở camera. Hãy kiểm tra quyền camera hoặc khởi động lại ứng dụng.',
      );
    }
  }

  void _clearSelectedFile() {
    setState(() {
      _selectedFile = null;
      _selectedFileName = null;
    });
  }

  Future<void> _toggleRecording() async {
    if (_isSending) {
      return;
    }

    if (_isRecording) {
      await _stopRecordingAndSend();
      return;
    }

    await _startRecording();
  }

  Future<void> _startRecording() async {
    try {
      final bool hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        _appendErrorMessage('Chưa được cấp quyền microphone để ghi âm.');
        return;
      }

      final Directory directory = await getTemporaryDirectory();
      final String filePath =
          '${directory.path}${Platform.pathSeparator}ai_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isRecording = true;
      });
    } catch (_) {
      _appendErrorMessage('Không thể bắt đầu ghi âm lúc này.');
    }
  }

  Future<void> _stopRecordingAndSend() async {
    try {
      final String? path = await _audioRecorder.stop();
      if (!mounted) {
        return;
      }

      setState(() {
        _isRecording = false;
      });

      if (path == null || path.isEmpty) {
        _appendErrorMessage('Không thể lưu file ghi âm.');
        return;
      }

      final File audioFile = File(path);
      if (!audioFile.existsSync()) {
        _appendErrorMessage('Không tìm thấy file ghi âm vừa tạo.');
        return;
      }

      setState(() {
        _selectedFile = audioFile;
        _selectedFileName = _fileNameFromPath(path);
      });
      await _sendMessage();
    } catch (_) {
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }
      _appendErrorMessage('Không thể kết thúc ghi âm.');
    }
  }

  Future<void> _sendMessage() async {
    final String text = _messageController.text.trim();
    final File? file = _selectedFile;
    if (text.isEmpty && file == null) {
      return;
    }
    if (_isSending) {
      return;
    }

    final String? attachmentName = _selectedFileName;
    final String? currentSessionId = _sessionId;
    final String localDraftTitle = _deriveSessionTitle(
      text.isNotEmpty ? text : (attachmentName ?? 'Cuộc trò chuyện mới'),
    );

    setState(() {
      _messages.add(
        _AiMessage(
          text: text,
          isUser: true,
          attachmentName: attachmentName,
        ),
      );
      _isSending = true;
    });
    _scrollToBottom();

    setState(() {
      _messageController.clear();
      _selectedFile = null;
      _selectedFileName = null;
    });

    try {
      final AiChatResultData result = await _backendApiService.sendAiChatMessage(
        message: text.isEmpty ? null : text,
        sessionId: _sessionId,
        file: file,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _sessionId = result.sessionId ?? _sessionId;
        _messages.add(
          _AiMessage(
            text: result.reply,
            isUser: false,
            disclaimer: (result.rawData['medicalDisclaimer'] ??
                    result.rawData['disclaimer'])
                ?.toString(),
          ),
        );

        final String? effectiveSessionId = result.sessionId ?? _sessionId;
        if (effectiveSessionId != null) {
          final int existingIndex = _sessions.indexWhere(
            (AiChatSessionSummaryData item) => item.id == effectiveSessionId,
          );
          final String serverOrFallbackTitle =
              existingIndex >= 0 && !_isGenericSessionTitle(_sessions[existingIndex].title)
              ? _sessions[existingIndex].title
              : localDraftTitle;
          if (existingIndex >= 0) {
            _sessions.removeAt(existingIndex);
          }
          _sessions.insert(
            0,
            AiChatSessionSummaryData(
              id: effectiveSessionId,
              title: serverOrFallbackTitle,
              updatedAt: DateTime.now(),
              preview: result.reply,
            ),
          );
        }
      });
      _scrollToBottom();
      unawaited(_refreshSessionSummaries());

      if (currentSessionId == null && result.sessionId != null) {
        setState(() {
          _sessionId = result.sessionId;
        });
        _upsertSessionLocally(
          sessionId: result.sessionId!,
          title: localDraftTitle,
        );
      }
    } catch (error) {
      _appendErrorMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasMessages = _messages.isNotEmpty;
    final bool showEmptyState =
        !_isLoadingSessionMessages && !_isLoadingSessions && !hasMessages;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(6, 8, 10, 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.28, 0.73],
                colors: [Color(0xFF1564A6), Color(0xFF07173A)],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.onBackToHome,
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Hỏi AI',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F4FB),
              border: Border(
                bottom: BorderSide(color: Color(0xFFCAE4F2)),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _startNewChat,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _sessionId == null
                          ? const Color(0xFF1564A6)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFB5D9EB)),
                    ),
                    child: Text(
                      'Mới',
                      style: TextStyle(
                        color: _sessionId == null
                            ? Colors.white
                            : const Color(0xFF29506F),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: _isLoadingSessions
                        ? const Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _sessions.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final AiChatSessionSummaryData session =
                                  _sessions[index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: session.id == _sessionId
                                      ? const Color(0xFF1564A6)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFB5D9EB),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        bottomLeft: Radius.circular(12),
                                      ),
                                      onTap: () => _selectSession(session.id),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 140,
                                          ),
                                          child: Text(
                                            session.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: session.id == _sessionId
                                                  ? Colors.white
                                                  : const Color(0xFF29506F),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      enabled: !_isManagingSession &&
                                          !_isSending &&
                                          !_isRecording,
                                      padding: EdgeInsets.zero,
                                      color: Colors.white,
                                      icon: Icon(
                                        Icons.more_horiz_rounded,
                                        size: 18,
                                        color: session.id == _sessionId
                                            ? Colors.white
                                            : const Color(0xFF29506F),
                                      ),
                                      onSelected: (String value) async {
                                        if (value == 'rename') {
                                          await _showRenameSessionDialog(session);
                                          return;
                                        }
                                        if (value == 'delete') {
                                          await _deleteSession(session);
                                        }
                                      },
                                      itemBuilder: (BuildContext context) =>
                                          const <PopupMenuEntry<String>>[
                                            PopupMenuItem<String>(
                                              value: 'rename',
                                              child: Text('Đổi tên'),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'delete',
                                              child: Text('Xóa'),
                                            ),
                                          ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: _isLoadingSessionMessages
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF1564A6),
                            ),
                          ),
                        )
                      : hasMessages
                      ? ListView.builder(
                          controller: _messagesScrollController,
                          padding: const EdgeInsets.fromLTRB(10, 12, 10, 128),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final _AiMessage message = _messages[index];
                            if (message.isUser) {
                              return Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  constraints: const BoxConstraints(
                                    maxWidth: 250,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD0E5F0),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x24000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    message.attachmentName == null ||
                                            message.attachmentName!.isEmpty
                                        ? message.text
                                        : '${message.text.isEmpty ? 'Đã gửi tệp đính kèm' : message.text}\n\nTệp: ${message.attachmentName}',
                                    style: const TextStyle(
                                      color: Color(0xFF355B75),
                                      fontSize: 12,
                                      height: 1.3,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                constraints: const BoxConstraints(
                                  maxWidth: 300,
                                ),
                                decoration: BoxDecoration(
                                  color: message.isError
                                      ? const Color(0xFFF5C6CF)
                                      : const Color(0xFF9ED0E8),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x24000000),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _SafeAssetImage(
                                      path:
                                          'assets/images/homepage/Mascot6.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            message.text,
                                            style: TextStyle(
                                              color: message.isError
                                                  ? const Color(0xFF7A2736)
                                                  : const Color(0xFF22465F),
                                              fontSize: 12,
                                              height: 1.35,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          if (message.disclaimer != null &&
                                              message.disclaimer!.trim().isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Text(
                                              message.disclaimer!,
                                              style: const TextStyle(
                                                color: Color(0xFF53758B),
                                                fontSize: 10,
                                                height: 1.35,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : showEmptyState
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Xin chào,\nTôi có thể giúp gì cho bạn hôm nay?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF243B53),
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const _SafeAssetImage(
                              path: 'assets/images/homepage/Mascot6.png',
                              width: 110,
                              height: 110,
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9ED5F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD6E8F1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const _SafeAssetImage(
                                      path:
                                          'assets/images/homepage/Mascot Head 2 3.png',
                                      width: 18,
                                      height: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: TextField(
                                        controller: _messageController,
                                        enabled: !_isRecording,
                                        textInputAction: TextInputAction.send,
                                        onSubmitted: (_) => _sendMessage(),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          border: InputBorder.none,
                                          hintText: 'Hỏi Cam Cam',
                                          hintStyle: TextStyle(
                                            color: Color(0xFF8CA7BA),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: const TextStyle(
                                          color: Color(0xFF355B75),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _isSending ? null : _sendMessage,
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFC8DCE8),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.arrow_upward_rounded,
                                          color: Color(0xFF5D7F97),
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_isRecording) ...[
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE0E4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.fiber_manual_record_rounded,
                                  color: Color(0xFFD9405C),
                                  size: 14,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Đang ghi âm, chạm mic lần nữa để gửi',
                                  style: TextStyle(
                                    color: Color(0xFF8E3143),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (_selectedFileName != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD6E8F1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.insert_drive_file_outlined,
                                  color: Color(0xFF5F7E95),
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _selectedFileName!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF355B75),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _clearSelectedFile,
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: Color(0xFF6A8CA4),
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: (_isSending || _isRecording)
                                  ? null
                                  : _pickAttachment,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD6E8F1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.attach_file_rounded,
                                      color: Color(0xFF6A8CA4),
                                      size: 10,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      'Đính kèm',
                                      style: TextStyle(
                                        color: Color(0xFF6A8CA4),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: (_isSending || _isRecording)
                                  ? null
                                  : _captureImage,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD6E8F1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.photo_camera_outlined,
                                      color: Color(0xFF6A8CA4),
                                      size: 10,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      'Chụp ảnh',
                                      style: TextStyle(
                                        color: Color(0xFF6A8CA4),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: _toggleRecording,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 28,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: _isRecording
                                      ? const Color(0xFFFFD5DC)
                                      : const Color(0xFFD6E8F1),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: _isSending
                                    ? const SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.8,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Color(0xFF4C7A9B),
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        _isRecording
                                            ? Icons.stop_rounded
                                            : Icons.mic,
                                        color: _isRecording
                                            ? const Color(0xFFD9405C)
                                            : const Color(0xFF4C7A9B),
                                        size: 14,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AiMessage {
  const _AiMessage({
    required this.text,
    required this.isUser,
    this.attachmentName,
    this.disclaimer,
    this.isError = false,
  });

  final String text;
  final bool isUser;
  final String? attachmentName;
  final String? disclaimer;
  final bool isError;
}

class _DiaryTab extends StatefulWidget {
  const _DiaryTab({required this.followMembers});

  final List<FollowMemberData> followMembers;

  @override
  State<_DiaryTab> createState() => _DiaryTabState();
}

class _DiaryTabState extends State<_DiaryTab> {
  int selectedView = 0;
  int selectedFollowMode = 0;
  final BackendApiService _backendApiService = BackendApiService.instance;
  final List<double> _glucose24hPoints = <double>[];
  double? _avgGlucose;
  double? _variability;
  double? _tir;
  double? _hba1c;

  @override
  void initState() {
    super.initState();
    unawaited(_loadGlucoseGraph24hData());
    unawaited(_loadDiaryAnalytics());
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadGlucoseGraph24hData() async {
    final List<GlucoseHistoryItemData> records = await _backendApiService
        .fetchGlucoseHistoryLast24Hours();
    if (!mounted) {
      return;
    }

    setState(() {
      _glucose24hPoints
        ..clear()
        ..addAll(records.map((GlucoseHistoryItemData item) => item.glucoseValue));
    });
  }

  Future<void> _loadDiaryAnalytics() async {
    final GlucoseAnalyticsData? analytics = await _backendApiService
        .fetchGlucoseAnalytics(days: 1);
    if (!mounted || analytics == null) {
      return;
    }

    final List<double> values = analytics.chartValues;
    final double? average = values.isEmpty
        ? null
        : values.reduce((double a, double b) => a + b) / values.length;
    final double? variability = values.isEmpty
        ? null
        : values.reduce(math.max) - values.reduce(math.min);

    setState(() {
      _avgGlucose = average;
      _variability = variability;
      _tir = analytics.tir;
      _hba1c = analytics.hba1c;
    });
  }

  String _formatNumber(double? value, {int digits = 0}) {
    if (value == null) {
      return '--';
    }
    return value.toStringAsFixed(digits);
  }

  Widget _buildPersonalPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Biểu đồ',
          style: TextStyle(
            color: Color(0xFF16507A),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF2B8BD7), width: 3),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 190,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 34,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '200',
                            style: TextStyle(
                              color: Color(0xFF5485A5),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '100',
                            style: TextStyle(
                              color: Color(0xFF5485A5),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '50',
                            style: TextStyle(
                              color: Color(0xFF5485A5),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Glucose24hGraph(dataPoints: _glucose24hPoints),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Text(
                    '6AM',
                    style: TextStyle(
                      color: Color(0xFF4B7898),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  Text(
                    '12PM',
                    style: TextStyle(
                      color: Color(0xFF4B7898),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  Text(
                    '18PM',
                    style: TextStyle(
                      color: Color(0xFF4B7898),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _DiaryMetricTile(
                title: 'Trung bình',
                value: _formatNumber(_avgGlucose),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DiaryMetricTile(
                title: 'Dao động',
                value: _formatNumber(_variability),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _DiaryMetricTile(
                title: 'TIR',
                value: '${_formatNumber(_tir)}%',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DiaryMetricTile(
                title: 'HbA1c',
                value: _formatNumber(_hba1c, digits: 1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              Navigator.of(context).pushNamed(
                AppRoutes.glucose24hDetail,
                arguments: _glucose24hPoints,
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: Text(
                'Xem thống kê chi tiết →',
                style: TextStyle(
                  color: Color(0xFF3D7EA6),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFCBEAF8),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(
                Icons.medical_services_outlined,
                color: Color(0xFF4A88AA),
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Rất tốt! Đường huyết của bạn\nđang ổn định, hãy tiếp tục cố gắng!',
                  style: TextStyle(
                    color: Color(0xFF3A7B9F),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFollowPanel() {
    final List<FollowMemberData> members = widget.followMembers.isNotEmpty
        ? widget.followMembers
        : const <FollowMemberData>[
            FollowMemberData(
              name: 'Nguyễn Văn A',
              glucoseText: '165 mmol/L',
              level: 'Nguy hiểm',
              isDanger: true,
            ),
            FollowMemberData(
              name: 'Nguyễn Văn A',
              glucoseText: '165 mmol/L',
              level: 'Bình thường',
              isDanger: false,
            ),
            FollowMemberData(
              name: 'Nguyễn Văn A',
              glucoseText: '165 mmol/L',
              level: 'Bình thường',
              isDanger: false,
            ),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 46,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF0B2D63),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFollowMode = 0;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: selectedFollowMode == 0
                          ? const Color(0xFFF3F4F6)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Danh sách',
                      style: TextStyle(
                        color: selectedFollowMode == 0
                            ? const Color(0xFF243A59)
                            : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFollowMode = 1;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: selectedFollowMode == 1
                          ? const Color(0xFFF3F4F6)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Tổng quan',
                      style: TextStyle(
                        color: selectedFollowMode == 1
                            ? const Color(0xFF243A59)
                            : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFCCD2D6),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Mức độ',
                  style: TextStyle(
                    color: Color(0xFF1F314B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF1F314B),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (selectedFollowMode == 0) ...[
          ...members.asMap().entries.map((entry) {
            final int index = entry.key;
            final FollowMemberData member = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == members.length - 1 ? 0 : 10,
              ),
              child: _FollowPersonTile(member: member),
            );
          }),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE5EDF2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Tổng quan theo dõi sẽ được cập nhật từ API.',
              style: TextStyle(
                color: Color(0xFF3C546E),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE1E1E4),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFAED2E5),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedView = 0;
                              });
                            },
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: selectedView == 0
                                    ? const Color(0xFF62B9E6)
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  topRight: Radius.circular(14),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'CÁ NHÂN',
                                style: TextStyle(
                                  color: const Color(0xFF1C3552),
                                  fontSize: 22,
                                  fontWeight: selectedView == 0
                                      ? FontWeight.w800
                                      : FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedView = 1;
                              });
                            },
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: selectedView == 1
                                    ? const Color(0xFF62B9E6)
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  topRight: Radius.circular(14),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'THEO DÕI',
                                style: TextStyle(
                                  color: const Color(0xFF1C3552),
                                  fontSize: 22,
                                  fontWeight: selectedView == 1
                                      ? FontWeight.w800
                                      : FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7CC6E8),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: selectedView == 0
                          ? _buildPersonalPanel(context)
                          : _buildFollowPanel(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiaryMetricTile extends StatelessWidget {
  const _DiaryMetricTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD2E5EE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF26425A),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF4283A6),
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowPersonTile extends StatelessWidget {
  const _FollowPersonTile({required this.member});

  final FollowMemberData member;

  @override
  Widget build(BuildContext context) {
    final String avatarLetter = member.name.trim().isEmpty
        ? 'A'
        : member.name.trim().characters.first.toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8ECEF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD0D7DE)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0xFF2F80ED),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              avatarLetter,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(
                    color: Color(0xFF202F44),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  member.glucoseText,
                  style: const TextStyle(
                    color: Color(0xFF263446),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: member.isDanger
                  ? const Color(0xFFFF1F1F)
                  : const Color(0xFF72E26D),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              member.level,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlogTab extends StatefulWidget {
  const _BlogTab({
    required this.onBackToHome,
    required this.onRetry,
    this.articles = const <BlogArticleData>[],
    this.errorMessage,
    this.isLoading = false,
  });

  final VoidCallback onBackToHome;
  final Future<void> Function() onRetry;
  final List<BlogArticleData> articles;
  final String? errorMessage;
  final bool isLoading;

  @override
  State<_BlogTab> createState() => _BlogTabState();
}

class _BlogTabState extends State<_BlogTab> {
  final BackendApiService _backendApiService = BackendApiService.instance;

  final Map<String, BlogArticleData> _articleCache = <String, BlogArticleData>{};
  String? _selectedArticleId;
  BlogArticleData? _selectedArticle;
  String? _selectedArticleErrorMessage;
  bool _isLoadingSelectedArticle = false;

  @override
  void initState() {
    super.initState();
    _syncArticles(forceSelectFirst: true);
  }

  @override
  void didUpdateWidget(covariant _BlogTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.articles != widget.articles ||
        oldWidget.isLoading != widget.isLoading) {
      _syncArticles(forceSelectFirst: oldWidget.articles.isEmpty);
    }
  }

  void _syncArticles({bool forceSelectFirst = false}) {
    for (final BlogArticleData article in widget.articles) {
      if (article.id.isNotEmpty && !_articleCache.containsKey(article.id)) {
        _articleCache[article.id] = article;
      }
    }

    if (widget.articles.isEmpty) {
      if (!mounted) {
        _selectedArticleId = null;
        _selectedArticle = null;
        _selectedArticleErrorMessage = null;
        _isLoadingSelectedArticle = false;
        return;
      }
      setState(() {
        _selectedArticleId = null;
        _selectedArticle = null;
        _selectedArticleErrorMessage = null;
        _isLoadingSelectedArticle = false;
      });
      return;
    }

    final bool currentSelectionStillExists = _selectedArticleId != null &&
        widget.articles.any((BlogArticleData article) => article.id == _selectedArticleId);
    final BlogArticleData nextArticle = currentSelectionStillExists && !forceSelectFirst
        ? widget.articles.firstWhere(
            (BlogArticleData article) => article.id == _selectedArticleId,
          )
        : widget.articles.first;

    unawaited(_selectArticle(nextArticle, fetchDetail: true));
  }

  Future<void> _selectArticle(
    BlogArticleData article, {
    bool fetchDetail = true,
  }) async {
    final String articleId = article.id.trim();
    final BlogArticleData cachedArticle = articleId.isEmpty
        ? article
        : (_articleCache[articleId] ?? article);

    if (mounted) {
      setState(() {
        _selectedArticleId = articleId.isEmpty ? null : articleId;
        _selectedArticle = cachedArticle;
        _selectedArticleErrorMessage = null;
      });
    } else {
      _selectedArticleId = articleId.isEmpty ? null : articleId;
      _selectedArticle = cachedArticle;
      _selectedArticleErrorMessage = null;
    }

    if (!fetchDetail || articleId.isEmpty || cachedArticle.body.isNotEmpty) {
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingSelectedArticle = true;
      });
    } else {
      _isLoadingSelectedArticle = true;
    }

    try {
      final BlogArticleData? detail = await _backendApiService
          .fetchBlogArticleDetail(articleId);
      if (!mounted || _selectedArticleId != articleId || detail == null) {
        return;
      }

      final BlogArticleData mergedDetail = BlogArticleData(
        id: detail.id.isEmpty ? articleId : detail.id,
        title: detail.title.trim().isEmpty ? article.title : detail.title,
        publishedInfo: detail.publishedInfo.trim().isEmpty
            ? article.publishedInfo
            : detail.publishedInfo,
        summary: detail.summary.trim().isEmpty ? article.summary : detail.summary,
        body: detail.body,
        imageUrl: detail.imageUrl ?? article.imageUrl,
      );

      _articleCache[articleId] = mergedDetail;
      setState(() {
        _selectedArticle = mergedDetail;
      });
    } catch (error) {
      if (!mounted || _selectedArticleId != articleId) {
        return;
      }
      setState(() {
        _selectedArticleErrorMessage = error
            .toString()
            .replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted && _selectedArticleId == articleId) {
        setState(() {
          _isLoadingSelectedArticle = false;
        });
      } else {
        _isLoadingSelectedArticle = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFC6D8E1),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(6, 8, 10, 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.28, 0.73],
                colors: [Color(0xFF1564A6), Color(0xFF07173A)],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.onBackToHome,
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Tin tức',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: widget.onRetry,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.articles.isNotEmpty) ...[
                      const Text(
                        'Chọn bài viết',
                        style: TextStyle(
                          color: Color(0xFF17324F),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 118,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.articles.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (BuildContext context, int index) {
                            final BlogArticleData item = widget.articles[index];
                            final bool isSelected = item.id.isNotEmpty
                                ? item.id == _selectedArticleId
                                : identical(item, _selectedArticle);
                            return _BlogArticleOptionCard(
                              article: item,
                              isSelected: isSelected,
                              onTap: () {
                                unawaited(_selectArticle(item, fetchDetail: true));
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                    _BlogArticleCard(
                      article: _selectedArticle,
                      errorMessage: _selectedArticleErrorMessage ?? widget.errorMessage,
                      isLoading: widget.isLoading,
                      isRefreshingDetail: _isLoadingSelectedArticle,
                      onRetry: widget.onRetry,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlogArticleCard extends StatelessWidget {
  const _BlogArticleCard({
    this.article,
    this.errorMessage,
    this.isLoading = false,
    this.isRefreshingDetail = false,
    this.onRetry,
  });

  final BlogArticleData? article;
  final String? errorMessage;
  final bool isLoading;
  final bool isRefreshingDetail;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    const Color skeletonColor = Color(0xFF9AB4C2);

    Widget skeletonLine(double widthFactor, {double height = 10}) {
      return FractionallySizedBox(
        widthFactor: widthFactor,
        alignment: Alignment.centerLeft,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: skeletonColor.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      );
    }

    if (isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            skeletonLine(0.42, height: 9),
            const SizedBox(height: 10),
            skeletonLine(0.95, height: 22),
            const SizedBox(height: 8),
            skeletonLine(0.84, height: 22),
            const SizedBox(height: 14),
            skeletonLine(0.98),
            const SizedBox(height: 7),
            skeletonLine(0.92),
            const SizedBox(height: 7),
            skeletonLine(0.95),
            const SizedBox(height: 7),
            skeletonLine(0.89),
            const SizedBox(height: 14),
            skeletonLine(0.77),
            const SizedBox(height: 7),
            skeletonLine(0.82),
            const SizedBox(height: 7),
            skeletonLine(0.74),
            const SizedBox(height: 7),
            skeletonLine(0.87),
          ],
        ),
      );
    }

    if (article == null) {
      final String message = (errorMessage ?? 'Không có bài viết để hiển thị').trim();
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFB7D0DE),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Color(0xFF17324F),
                  size: 22,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Blog chưa tải được',
                    style: TextStyle(
                      color: Color(0xFF17324F),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                color: Color(0xFF29475C),
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'API hiện được tài liệu hóa ở /v1/patient/articles?language=VI và yêu cầu đăng nhập.',
              style: TextStyle(
                color: Color(0xFF446276),
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 42,
              child: ElevatedButton(
                onPressed: onRetry == null ? null : () => onRetry!.call(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF17324F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Thử tải lại'),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isRefreshingDetail) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFD6E8F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Đang tải chi tiết bài viết...',
                      style: TextStyle(
                        color: Color(0xFF29475C),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if ((errorMessage ?? '').trim().isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE0EAF0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                errorMessage!.trim(),
                style: const TextStyle(
                  color: Color(0xFF29475C),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            article!.publishedInfo,
            style: const TextStyle(
              color: Color(0xFF5B6E7C),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            article!.title,
            style: const TextStyle(
              color: Color(0xFF1E2D3A),
              fontSize: 37,
              height: 1.08,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            article!.summary,
            style: const TextStyle(
              color: Color(0xFF2C4354),
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          ...(article!.body.isEmpty
              ? <Widget>[
                  Text(
                    article!.summary,
                    style: const TextStyle(
                      color: Color(0xFF2C4354),
                      fontSize: 14,
                      height: 1.55,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ]
              : article!.body.map(
            (String paragraph) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                paragraph,
                style: const TextStyle(
                  color: Color(0xFF2C4354),
                  fontSize: 14,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class _BlogArticleOptionCard extends StatelessWidget {
  const _BlogArticleOptionCard({
    required this.article,
    required this.isSelected,
    required this.onTap,
  });

  final BlogArticleData article;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 220,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF17324F) : const Color(0xFFD9EAF3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF07173A) : const Color(0xFFB1CAD7),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : const <BoxShadow>[],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.publishedInfo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? const Color(0xFFD6EAF5) : const Color(0xFF557488),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                article.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF17324F),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              article.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? const Color(0xFFE7F3FA) : const Color(0xFF456276),
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
