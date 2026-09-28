import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/bet_info.dart';
import '../models/racer.dart';
import '../services/sound_service.dart';
import 'login_screen.dart';
import 'race_screen.dart';

class BettingScreen extends StatefulWidget {
  final String playerName;
  final int balance;

  const BettingScreen({
    super.key,
    required this.playerName,
    required this.balance,
  });

  @override
  State<BettingScreen> createState() => _BettingScreenState();
}

class _BettingScreenState extends State<BettingScreen> {
  late int _currentBalance;

  final List<Racer> _racers = [
    Racer(
      id: 1,
      name: "Quái Nham Thạch",
      color: Colors.orangeAccent,
      odds: 2.0,
      assetPath: 'assets/images/racer_1.gif',
    ),
    Racer(
      id: 2,
      name: "Minh Vương Hắc Ám",
      color: const Color(0xFFE1BEE7),
      odds: 3.5,
      assetPath: 'assets/images/racer_2.gif',
    ),
    Racer(
      id: 3,
      name: "Hiệp Sĩ Đầm Lầy",
      color: const Color(0xFF69F0AE),
      odds: 1.8,
      assetPath: 'assets/images/racer_3.gif',
    ),
  ];

  final Map<int, BetInfo> _bets = {};

  @override
  void initState() {
    super.initState();
    _currentBalance = widget.balance;
    for (var r in _racers) {
      _bets[r.id] = BetInfo(amount: 0, isSelected: false);
    }
  }

  int get _totalBetPlaced {
    int total = 0;
    for (var b in _bets.values) {
      if (b.isSelected) total += b.amount;
    }
    return total;
  }

  void _adjustBet(int racerId, int delta) {
    SoundService.playClick();
    final bet = _bets[racerId]!;
    if (!bet.isSelected && delta > 0) {
      bet.isSelected = true;
    }

    if (delta > 0) {
      if (_currentBalance >= delta) {
        setState(() {
          bet.amount += delta;
          _currentBalance -= delta;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Không đủ Vàng Hắc Ám để cược thêm!"),
            backgroundColor: DarkFantasyTheme.crimson,
            duration: Duration(milliseconds: 1200),
          ),
        );
      }
    } else {
      if (bet.amount + delta >= 0) {
        setState(() {
          bet.amount += delta;
          _currentBalance -= delta;
          if (bet.amount == 0) bet.isSelected = false;
        });
      }
    }
  }

  void _onBackToLogin() {
    SoundService.playClick();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _onGoToRace() {
    if (_totalBetPlaced == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ngươi phải đặt cược ít nhất cho một đấu sĩ!"),
          backgroundColor: DarkFantasyTheme.crimson,
          duration: Duration(milliseconds: 1500),
        ),
      );
      return;
    }

    SoundService.playClick();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RaceScreen(
          playerName: widget.playerName,
          balance: _currentBalance,
          racers: _racers,
          bets: _bets,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0B18),
      body: Stack(
        children: [
          // 1. BỨC TRANH NỀN LÂU ĐÀI & HOA TÍM HÙNG VĨ
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_betting.png', // Hoặc .jpg tùy đuôi file của bạn
              fit: BoxFit.cover,
              alignment: Alignment.center,
              filterQuality: FilterQuality.none,
              errorBuilder: (c, e, s) => Container(
                color: const Color(0xFF160E22),
              ),
            ),
          ),

          // 2. MÀNG PHỦ ĐÊM TỐI GRADIENT (Vừa thấy cảnh lung linh vừa đọc chữ cực rõ)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.70),
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // 3. TOÀN BỘ GIAO DIỆN SẢNH CƯỢC THOÁNG ĐÃNG
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                children: [
                  // THANH ĐIỀU HƯỚNG
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _onBackToLogin,
                        tooltip: "Quay lại Cổng vào",
                        icon: ClipRRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                border:
                                    Border.all(color: DarkFantasyTheme.gold),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: DarkFantasyTheme.gold,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ClipRRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              border: Border.all(
                                  color: DarkFantasyTheme.gold, width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: const Text(
                              "SẢNH CƯỢC HẮC ÁM",
                              style: TextStyle(
                                color: DarkFantasyTheme.gold,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // BẢNG THÔNG TIN SỐ DƯ & THỢ SĂN (KÍNH MỜ GOTHIC)
                  ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          border: Border.all(
                              color: DarkFantasyTheme.goldDark, width: 1.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.shield,
                                    color: DarkFantasyTheme.gold, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  "THỢ SĂN: ${widget.playerName.toUpperCase()}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.monetization_on,
                                  color: DarkFantasyTheme.gold,
                                  size: 19,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "$_currentBalance Vàng",
                                  style: const TextStyle(
                                    color: DarkFantasyTheme.gold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // DANH SÁCH 3 THẺ CƯỢC ĐẤU SĨ (THIẾT KẾ KÍNH TRONG SUỐT NỔI BẬT)
                  Column(
                    children: List.generate(_racers.length, (index) {
                      final racer = _racers[index];
                      final bet = _bets[racer.id]!;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        child: ClipRRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14.0, vertical: 12.0),
                              decoration: BoxDecoration(
                                color: bet.isSelected
                                    ? racer.color.withValues(alpha: 0.25)
                                    : Colors.black.withValues(alpha: 0.58),
                                border: Border.all(
                                  color: bet.isSelected
                                      ? racer.color
                                      : DarkFantasyTheme.stoneBorder,
                                  width: bet.isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Avatar đấu sĩ
                                  SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: Image.asset(
                                      racer.assetPath,
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.none,
                                      errorBuilder: (c, e, s) => Icon(
                                        Icons.flash_on,
                                        color: racer.color,
                                        size: 34,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Tên & tỉ lệ cược
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          racer.name,
                                          style: TextStyle(
                                            color: racer.color,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            shadows: const [
                                              Shadow(
                                                  color: Colors.black,
                                                  blurRadius: 4),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          "Tỷ lệ: x${racer.odds.toStringAsFixed(1)}",
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Nút tăng / giảm cược
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () =>
                                            _adjustBet(racer.id, -50),
                                        icon: const Icon(
                                          Icons.remove_circle,
                                          color: Colors.redAccent,
                                          size: 26,
                                        ),
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(4),
                                      ),
                                      Container(
                                        width: 56,
                                        alignment: Alignment.center,
                                        child: Text(
                                          "${bet.amount}",
                                          style: const TextStyle(
                                            color: DarkFantasyTheme.gold,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            shadows: [
                                              Shadow(
                                                  color: Colors.black,
                                                  blurRadius: 4),
                                            ],
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _adjustBet(racer.id, 50),
                                        icon: const Icon(
                                          Icons.add_circle,
                                          color: Colors.greenAccent,
                                          size: 26,
                                        ),
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(4),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const Spacer(flex: 1),

                  // TỔNG TIỀN ĐÃ CƯỢC
                  ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          border: Border.all(
                              color:
                                  Colors.orangeAccent.withValues(alpha: 0.6)),
                        ),
                        child: Text(
                          "ĐÃ CƯỢC: $_totalBetPlaced VÀNG",
                          style: const TextStyle(
                            color: Colors.orangeAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // NÚT BẮT ĐẦU TRANH ĐẤU
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onGoToRace,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DarkFantasyTheme.crimson,
                        side: const BorderSide(
                            color: DarkFantasyTheme.gold, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const BeveledRectangleBorder(),
                        elevation: 8,
                      ),
                      child: const Text(
                        "VÀO ĐẤU TRƯỜNG TRANH ĐẤU",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
