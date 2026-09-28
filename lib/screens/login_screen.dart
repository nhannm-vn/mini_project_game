import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../services/sound_service.dart';
import 'betting_screen.dart';

enum GameDifficulty { easy, hard, asian }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: "Hunter_01");

  // Mặc định chọn chế độ Dễ (1,000 Vàng)
  GameDifficulty _selectedDifficulty = GameDifficulty.easy;

  // Lấy số vàng ban đầu tương ứng với chế độ
  int get _startingBalance {
    switch (_selectedDifficulty) {
      case GameDifficulty.easy:
        return 1000;
      case GameDifficulty.hard:
        return 600;
      case GameDifficulty.asian:
        return 100;
    }
  }

  // Tên hiển thị của chế độ
  String get _difficultyLabel {
    switch (_selectedDifficulty) {
      case GameDifficulty.easy:
        return "DỄ";
      case GameDifficulty.hard:
        return "KHÓ";
      case GameDifficulty.asian:
        return "CHÂU Á (EMOTIONAL DAMAGE)";
    }
  }

  Color get _difficultyColor {
    switch (_selectedDifficulty) {
      case GameDifficulty.easy:
        return Colors.greenAccent;
      case GameDifficulty.hard:
        return Colors.orangeAccent;
      case GameDifficulty.asian:
        return DarkFantasyTheme.bloodRed;
    }
  }

  @override
  void initState() {
    super.initState();
    SoundService.playLoginBgm();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onEnterGame() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập danh xưng thợ săn!"),
          backgroundColor: DarkFantasyTheme.crimson,
        ),
      );
      return;
    }

    SoundService.playClick();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BettingScreen(
          playerName: name,
          balance: _startingBalance, // Truyền số vàng dựa theo chế độ
        ),
      ),
    );
  }

  // Widget hiển thị từng nút chọn độ khó
  Widget _buildDifficultyButton({
    required GameDifficulty difficulty,
    required String title,
    required String goldAmount,
    required Color color,
  }) {
    final isSelected = _selectedDifficulty == difficulty;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          SoundService.playClick();
          setState(() {
            _selectedDifficulty = difficulty;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.2) : Colors.black45,
            border: Border.all(
              color: isSelected ? color : DarkFantasyTheme.stoneBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                goldAmount,
                style: TextStyle(
                  color: isSelected ? DarkFantasyTheme.gold : Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DarkFantasyTheme.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background lâu đài ánh trăng u ám
          Image.asset(
            'assets/images/bg_castle.gif',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.none,
            errorBuilder: (c, e, s) => Image.asset(
              'assets/images/bg_castle.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none,
              errorBuilder: (c2, e2, s2) =>
                  Container(color: const Color(0xFF140D21)),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.65)),

          SafeArea(
            child: Stack(
              children: [
                // NÚT BẬT / TẮT ÂM THANH Ở GÓC TRÊN BÊN PHẢI
                Positioned(
                  top: 10,
                  right: 16,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        SoundService.toggleMute();
                      });
                    },
                    tooltip:
                        SoundService.isMuted ? "Bật âm thanh" : "Tắt âm thanh",
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(
                          color: SoundService.isMuted
                              ? DarkFantasyTheme.stoneBorder
                              : DarkFantasyTheme.gold,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        SoundService.isMuted
                            ? Icons.volume_off
                            : Icons.volume_up,
                        color: SoundService.isMuted
                            ? Colors.grey
                            : DarkFantasyTheme.gold,
                        size: 22,
                      ),
                    ),
                  ),
                ),

                // KHUNG LOGIN ĐẦY ĐỦ CHI TIẾT
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 420),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 22.0),
                      decoration: DarkFantasyTheme.gothicBorder(
                        borderColor: DarkFantasyTheme.goldDark,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 1. ẢNH THÁP HẦM NGỤC (dungeon_tower.png)
                          SizedBox(
                            width: 96,
                            height: 96,
                            child: Image.asset(
                              'assets/images/dungeon_tower.png',
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.none,
                              errorBuilder: (c, e, s) => const Icon(
                                Icons.fort,
                                size: 70,
                                color: DarkFantasyTheme.gold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // 2. TIÊU ĐỀ SHADOW DERBY
                          const Text(
                            "SHADOW DERBY",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: DarkFantasyTheme.gold,
                              letterSpacing: 3.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "— CỔNG VÀO ĐẤU TRƯỜNG NGẦM —",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 3. Ô NHẬP DANH XƯNG (NICKNAME)
                          TextField(
                            controller: _nameController,
                            style: const TextStyle(
                              color: DarkFantasyTheme.gold,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                            decoration: InputDecoration(
                              labelText: "DANH XƯNG THỢ SĂN (NICKNAME)",
                              labelStyle: const TextStyle(
                                color: DarkFantasyTheme.goldDark,
                                fontSize: 11,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.bold,
                              ),
                              prefixIcon: const Icon(
                                Icons.account_circle,
                                color: DarkFantasyTheme.gold,
                                size: 22,
                              ),
                              filled: true,
                              fillColor: Colors.black45,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: DarkFantasyTheme.stoneBorder),
                                borderRadius: BorderRadius.zero,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: DarkFantasyTheme.gold, width: 1.5),
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // 4. CHỌN CHẾ ĐỘ ĐỘ KHÓ (DỄ - KHÓ - CHÂU Á)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "CHẾ ĐỘ THỬ THÁCH: [$_difficultyLabel]",
                              style: TextStyle(
                                color: _difficultyColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _buildDifficultyButton(
                                difficulty: GameDifficulty.easy,
                                title: "DỄ",
                                goldAmount: "1,000 Vàng",
                                color: Colors.greenAccent,
                              ),
                              const SizedBox(width: 8),
                              _buildDifficultyButton(
                                difficulty: GameDifficulty.hard,
                                title: "KHÓ",
                                goldAmount: "600 Vàng",
                                color: Colors.orangeAccent,
                              ),
                              const SizedBox(width: 8),
                              _buildDifficultyButton(
                                difficulty: GameDifficulty.asian,
                                title: "CHÂU Á",
                                goldAmount: "100 Vàng",
                                color: DarkFantasyTheme.bloodRed,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // 5. KHUNG HÀNH TRANG TIỀN KHỞI ĐIỂM
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              border: Border.all(
                                  color: DarkFantasyTheme.stoneBorder),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.monetization_on,
                                  color: DarkFantasyTheme.gold,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Hành trang: $_startingBalance Vàng Hắc Ám",
                                    style: TextStyle(
                                      color: _difficultyColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // 6. NÚT BẮT ĐẦU VÀO ĐẤU TRƯỜNG
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _onEnterGame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DarkFantasyTheme.crimson,
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                    color: DarkFantasyTheme.gold, width: 2),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: const BeveledRectangleBorder(),
                              ),
                              child: const Text(
                                "BƯỚC VÀO ĐẤU TRƯỜNG",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
