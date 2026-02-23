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
  const QuickEntryPage({super.key});

  @override
  State<QuickEntryPage> createState() => _QuickEntryPageState();
}

class _QuickEntryPageState extends State<QuickEntryPage> {
  int selectedQuickType = 0;
  TimeOfDay selectedTime = const TimeOfDay(hour: 6, minute: 0);
  String selectedNote = 'Trước ăn';
  late final TextEditingController glucoseController;
  late final TextEditingController doseController;
  late final TextEditingController medicineNameController;

  @override
  void initState() {
    super.initState();
    glucoseController = TextEditingController(text: '136');
    doseController = TextEditingController(text: '5');
    medicineNameController = TextEditingController(text: 'Astrapid');
  }

  @override
  void dispose() {
    glucoseController.dispose();
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

  @override
  Widget build(BuildContext context) {
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
                            isMedicineMode ? 'Liều lượng' : 'ĐH',
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
                            isMedicineMode ? 'Tên thuốc' : 'Ghi chú',
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
                                      const Text(
                                        ' mg',
                                        style: TextStyle(
                                          color: Color(0xFF17324F),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  )
                                : TextField(
                                    controller: glucoseController,
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
                                : Center(
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: selectedNote,
                                        borderRadius: BorderRadius.circular(10),
                                        style: const TextStyle(
                                          color: Color(0xFF17324F),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        icon: const Icon(
                                          Icons.arrow_drop_down,
                                          color: Color(0xFF17324F),
                                        ),
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
                                            child: Text('Trước ăn'),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: 'Sau ăn',
                                            child: Text('Sau ăn'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        Expanded(
                          child: _QuickActionChip(
                            label: 'Quét AI',
                            isSelected: true,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(child: _QuickActionChip(label: 'Lưu')),
                        SizedBox(width: 12),
                        Expanded(child: _QuickActionChip(label: 'Cân bằng')),
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
  final List<_AiMessage> _messages = <_AiMessage>[];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final String text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _messages.add(_AiMessage(text: text, isUser: true));
      _messages.add(
        const _AiMessage(
          text:
              'Cảm ơn bạn đã chia sẻ. Mình gợi ý theo dõi thêm sau bữa ăn 2 giờ và chọn bữa tiếp theo ít đường hơn nhé.',
          isUser: false,
        ),
      );
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasMessages = _messages.isNotEmpty;

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
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: hasMessages
                      ? ListView.builder(
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
                                    message.text,
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
                                  color: const Color(0xFF9ED0E8),
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
                                      child: Text(
                                        message.text,
                                        style: const TextStyle(
                                          color: Color(0xFF22465F),
                                          fontSize: 12,
                                          height: 1.35,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : Column(
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
                        ),
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
                                      onTap: _sendMessage,
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
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
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
                            const SizedBox(width: 6),
                            Container(
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
                            const Spacer(),
                            Container(
                              width: 28,
                              height: 22,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD6E8F1),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Icon(
                                Icons.mic,
                                color: Color(0xFF4C7A9B),
                                size: 14,
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
  const _AiMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}

class _DiaryTab extends StatefulWidget {
  const _DiaryTab();

  @override
  State<_DiaryTab> createState() => _DiaryTabState();
}

class _DiaryTabState extends State<_DiaryTab> {
  int selectedView = 0;
  int selectedFollowMode = 0;
  final List<double> _glucose24hPoints = <double>[];
  final math.Random _random = math.Random();
  Timer? _liveDataTimer;
  double _lastMockValue = 136;

  @override
  void initState() {
    super.initState();
    _startMockLiveData();
  }

  @override
  void dispose() {
    _liveDataTimer?.cancel();
    super.dispose();
  }

  void _startMockLiveData() {
    _liveDataTimer?.cancel();
    _liveDataTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) {
        return;
      }
      final double change = (_random.nextDouble() * 18) - 9;
      final double nextValue = (_lastMockValue + change).clamp(70, 190);
      setState(() {
        _lastMockValue = nextValue;
        _glucose24hPoints.add(nextValue);
        if (_glucose24hPoints.length > 24) {
          _glucose24hPoints.removeAt(0);
        }
      });
    });
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
            border: Border.all(
              color: const Color(0xFF2B8BD7),
              width: 3,
            ),
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
                      child: _Glucose24hGraph(
                        dataPoints: _glucose24hPoints,
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
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
              child: _DiaryMetricTile(
                title: 'Trung bình',
                value: '136',
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _DiaryMetricTile(
                title: 'Dao động',
                value: '30',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Row(
          children: [
            Expanded(
              child: _DiaryMetricTile(
                title: 'TIR',
                value: '80%',
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _DiaryMetricTile(
                title: 'HbA1c',
                value: '1.2%',
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
              padding: EdgeInsets.symmetric(
                horizontal: 2,
                vertical: 2,
              ),
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
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
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
          const _FollowPersonTile(level: 'Nguy hiểm', isDanger: true),
          const SizedBox(height: 10),
          const _FollowPersonTile(level: 'Bình thường'),
          const SizedBox(height: 10),
          const _FollowPersonTile(level: 'Bình thường'),
          const SizedBox(height: 10),
          const _FollowPersonTile(level: 'Bình thường'),
          const SizedBox(height: 10),
          const _FollowPersonTile(level: 'Bình thường'),
          const SizedBox(height: 10),
          const _FollowPersonTile(level: 'Bình thường'),
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
  const _FollowPersonTile({
    required this.level,
    this.isDanger = false,
  });

  final String level;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8ECEF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFD0D7DE),
        ),
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
            child: const Text(
              'A',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nguyễn Văn A',
                  style: TextStyle(
                    color: Color(0xFF202F44),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '165 mmol/L',
                  style: TextStyle(
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
              color: isDanger ? const Color(0xFFFF1F1F) : const Color(0xFF72E26D),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              level,
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

class BlogArticleData {
  const BlogArticleData({
    required this.title,
    required this.publishedInfo,
    required this.summary,
    required this.body,
    this.imageUrl,
  });

  final String title;
  final String publishedInfo;
  final String summary;
  final List<String> body;
  final String? imageUrl;
}

class _BlogTab extends StatelessWidget {
  const _BlogTab({required this.onBackToHome, this.article});

  final VoidCallback onBackToHome;
  final BlogArticleData? article;

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
                  onPressed: onBackToHome,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
              child: _BlogArticleCard(article: article),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlogArticleCard extends StatelessWidget {
  const _BlogArticleCard({this.article});

  final BlogArticleData? article;

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
            color: skeletonColor.withOpacity(0.35),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      );
    }

    if (article == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 190,
              decoration: BoxDecoration(
                color: const Color(0xFF8FC7DF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Icon(
                  Icons.image_outlined,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 14),
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 190,
            decoration: BoxDecoration(
              color: const Color(0xFF8FC7DF),
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: article!.imageUrl == null || article!.imageUrl!.isEmpty
                ? const Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.white,
                      size: 40,
                    ),
                  )
                : Image.network(
                    article!.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 14),
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
          ...article!.body.map(
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
          ),
        ],
      ),
    );
  }
}
