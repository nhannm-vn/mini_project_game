import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/bet_info.dart';
import '../models/racer.dart';
import '../services/sound_service.dart';
import '../widgets/island_track_floor.dart';
import '../widgets/warrior_spectator.dart';
import 'betting_screen.dart';
import 'result_screen.dart';
import '../widgets/controllable_gif_racer.dart';

class RaceScreen extends StatefulWidget {
  final String playerName;
  final int balance;
  final List<Racer> racers;
  final Map<int, BetInfo> bets;

  const RaceScreen({
    super.key,
    required this.playerName,
    required this.balance,
    required this.racers,
    required this.bets,
  });

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen>
    with SingleTickerProviderStateMixin {
  late List<double> _positions;
  bool _isRacing = false;
  bool _isFinished = false;
  Timer? _raceTimer;
  final Random _random = Random();
  late AnimationController _bounceController;

  // NGƯỠNG DỪNG XE: Chạy vọt qua vạch đích một đoạn ngắn rồi mới dừng lại hẳn (0.98)
  static const double _finishLinePosition = 0.98;

  @override
  void initState() {
    super.initState();
    _positions = List.filled(widget.racers.length, 0.0);
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _raceTimer?.cancel();
    _bounceController.dispose();
    super.dispose();
  }

  void _startRace() {
    if (_isRacing || _isFinished) return;

    SoundService.playClick();
    SoundService.playStartHorn();

    setState(() {
      _isRacing = true;
    });

    _raceTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      bool someoneWon = false;
      int winnerIndex = -1;

      setState(() {
        for (int i = 0; i < widget.racers.length; i++) {
          // Tốc độ chạy mượt mà, hồi hộp kéo dài 5-6 giây
          final double step = _random.nextDouble() * 0.007 + 0.0035;
          _positions[i] += step;

          // Nhân vật chạy vượt qua vạch đích một đoạn (đạt 0.98) mới phân định chiến thắng
          if (_positions[i] >= _finishLinePosition) {
            _positions[i] = _finishLinePosition;
            someoneWon = true;
            winnerIndex = i;
            break;
          }
        }
      });

      if (someoneWon) {
        timer.cancel();
        _isRacing = false;
        _isFinished = true;
        _onRaceFinish(widget.racers[winnerIndex]);
      }
    });
  }

  void _onRaceFinish(Racer winner) {
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      SoundService.stopCombat();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            playerName: widget.playerName,
            winner: winner,
            racers: widget.racers,
            bets: widget.bets,
            initialBalance: widget.balance,
          ),
        ),
      );
    });
  }

  void _onBackToBetting() {
    SoundService.playClick();
    SoundService.stopCombat();
    _raceTimer?.cancel();

    int refundTotal = 0;
    for (var b in widget.bets.values) {
      if (b.isSelected) refundTotal += b.amount;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BettingScreen(
          playerName: widget.playerName,
          balance: widget.balance + refundTotal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0814),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Column(
            children: [
              // 1. THANH TIÊU ĐỀ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _isRacing ? null : _onBackToBetting,
                    tooltip: "Hủy cược & Quay lại",
                    icon: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(color: DarkFantasyTheme.gold),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: DarkFantasyTheme.gold,
                        size: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      border: Border.all(color: DarkFantasyTheme.goldDark),
                    ),
                    child: const Text(
                      "ĐẤU TRƯỜNG HUYẾT LỆ",
                      style: TextStyle(
                        color: DarkFantasyTheme.gold,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 8),

              // 2. THANH TRẠNG THÁI CUỘC ĐUA
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF160E22),
                  border: Border.all(color: DarkFantasyTheme.goldDark),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.local_fire_department,
                            color: Colors.orangeAccent, size: 18),
                        SizedBox(width: 4),
                        Text(
                          "XUẤT PHÁT",
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(
                      _isRacing
                          ? "TRANH ĐẤU NẢY LỬA!"
                          : (_isFinished ? "KẾT THÚC!" : "CHUẨN BỊ"),
                      style: TextStyle(
                        color: _isRacing
                            ? Colors.greenAccent
                            : DarkFantasyTheme.gold,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Row(
                      children: [
                        Text(
                          "VẠCH ĐÍCH",
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.flag, color: Colors.redAccent, size: 18),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // 3. 3 LÀN ĐUA ĐẢO NỔI VÁCH ĐÁ RÊU 2.5D
              Expanded(
                child: Column(
                  children: List.generate(widget.racers.length, (i) {
                    final racer = widget.racers[i];
                    final progress = _positions[i];
                    final bet = widget.bets[racer.id];
                    final bool hasBet =
                        bet != null && bet.isSelected && bet.amount > 0;

                    // Tiến độ phần trăm chuẩn
                    final int percent = ((progress / _finishLinePosition) * 100)
                        .clamp(0, 100)
                        .toInt();

                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: hasBet
                                ? racer.color
                                : DarkFantasyTheme.stoneBorder,
                            width: hasBet ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.6),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // NỀN VÁCH ĐÁ & CỎ RÊU 2.5D
                            const Positioned.fill(
                              child: IslandTrackFloor(),
                            ),

                            // KHÁN GIẢ CHIẾN BINH WARRIOR
                            Positioned(
                              top: 2,
                              left: 65,
                              right:
                                  90, // Thu gọn khán giả để chừa vạch đích thoáng mắt
                              child: AnimatedBuilder(
                                animation: _bounceController,
                                builder: (context, child) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: List.generate(3, (specIdx) {
                                      final double jump = _isRacing
                                          ? (sin((_bounceController.value *
                                                          pi) +
                                                      (specIdx * 1.2))
                                                  .abs() *
                                              3.0)
                                          : 0.0;

                                      return Transform.translate(
                                        offset: Offset(0, -jump),
                                        child: WarriorSpectator(
                                          size: 38.0,
                                          flipX: specIdx % 2 == 1,
                                        ),
                                      );
                                    }),
                                  );
                                },
                              ),
                            ),

                            // TÊN ĐẤU SĨ & % TIẾN ĐỘ
                            Positioned(
                              left: 8,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                color: Colors.black87,
                                child: Text(
                                  "${racer.name} - $percent%",
                                  style: TextStyle(
                                    color: racer.color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            // VẠCH KẺ ĐÍCH SỌC ĐỎ - VÀNG CÁCH MÉP PHẢI 1 KHOẢNG (right: 75)
                            Positioned(
                              right: 75,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                width: 3,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.redAccent,
                                      DarkFantasyTheme.gold,
                                      Colors.redAccent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.redAccent
                                          .withValues(alpha: 0.6),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // CỜ VẠCH ĐÍCH (GARGOYLE) ĐẶT NGAY TRÊN VẠCH KẺ ĐÍCH
                            Positioned(
                              right: 62,
                              top: 10,
                              bottom: 14,
                              child: Image.asset(
                                'assets/images/fan_gargoyle.png',
                                width: 30,
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) => const Icon(
                                  Icons.sports_score,
                                  color: DarkFantasyTheme.gold,
                                  size: 26,
                                ),
                              ),
                            ),

                            // ĐẤU SĨ: CHẠY QUA CỜ (right: 62) VÀ LAO THẲNG VỀ GÓC PHẢI
                            Align(
                              alignment: FractionalOffset(progress, 0.62),
                              child: SizedBox(
                                width: 56,
                                height: 56,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: [
                                    // Bóng đổ elip dẹt sát chân
                                    Positioned(
                                      bottom: 2,
                                      child: Container(
                                        width: 32,
                                        height: 9,
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withValues(alpha: 0.65),
                                          borderRadius: const BorderRadius.all(
                                            Radius.elliptical(32, 9),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Sprite nhân vật
                                    Positioned(
                                      bottom: 6,
                                      child: ControllableGifRacer(
                                        assetPath: racer.assetPath,
                                        isRacing: _isRacing,
                                        size: 44.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),

              // 4. NÚT BẮT ĐẦU ĐUA (START)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isRacing || _isFinished ? null : _startRace,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isRacing ? Colors.grey[800] : DarkFantasyTheme.crimson,
                    side: const BorderSide(
                        color: DarkFantasyTheme.gold, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const BeveledRectangleBorder(),
                  ),
                  child: Text(
                    _isRacing
                        ? "CUỘC ĐUA ĐANG DIỄN RA..."
                        : "START (XUẤT PHÁT)",
                    style: const TextStyle(
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
    );
  }
}
