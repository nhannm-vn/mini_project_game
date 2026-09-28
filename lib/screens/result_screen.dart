import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/bet_info.dart';
import '../models/racer.dart';
import '../services/sound_service.dart';
import 'betting_screen.dart';

class ResultScreen extends StatefulWidget {
  final String playerName;
  final int initialBalance;
  final List<Racer> racers;
  final Map<int, BetInfo> bets;
  final Racer winner;

  const ResultScreen({
    super.key,
    required this.playerName,
    required this.initialBalance,
    required this.racers,
    required this.bets,
    required this.winner,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late int totalBetDeducted;
  late int totalWinnings;
  late int finalBalance;
  late int netProfit;

  @override
  void initState() {
    super.initState();
    totalBetDeducted = 0;
    totalWinnings = 0;

    for (var r in widget.racers) {
      final b = widget.bets[r.id];
      if (b != null && b.isSelected) {
        totalBetDeducted += b.amount;
        if (r.id == widget.winner.id) {
          totalWinnings += (b.amount * r.odds).toInt();
        }
      }
    }

    finalBalance = widget.initialBalance + totalWinnings;
    netProfit = totalWinnings - totalBetDeducted;

    // Chờ 150ms để RaceScreen cũ hủy hẳn rồi mới phát nhạc
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      if (netProfit > 0) {
        SoundService.playVictory();
      } else {
        SoundService.playDefeat();
      }
    });
  }

  @override
  void dispose() {
    SoundService.stopBgm(); // Dừng nhạc kết quả khi rời màn hình
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isBankrupt = finalBalance < 50;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/bg_castle.gif',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.none,
            errorBuilder: (c, e, s) =>
                Container(color: const Color(0xFF140D21)),
          ),
          Container(color: Colors.black.withValues(alpha: 0.75)),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 16.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  padding: const EdgeInsets.all(22),
                  decoration: DarkFantasyTheme.gothicBorder(
                    borderColor: netProfit > 0
                        ? DarkFantasyTheme.gold
                        : DarkFantasyTheme.bloodRed,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        netProfit > 0
                            ? "★ THẮNG LỚN (ĐẠI THẮNG) ★"
                            : "☠ THUA CUỘC (LỖ KÈO) ☠",
                        style: TextStyle(
                          color: netProfit > 0
                              ? DarkFantasyTheme.gold
                              : DarkFantasyTheme.bloodRed,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // CHIẾN BINH QUÁN QUÂN
                      Container(
                        width: 80,
                        height: 80,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          border:
                              Border.all(color: widget.winner.color, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  widget.winner.color.withValues(alpha: 0.35),
                              blurRadius: 14,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          widget.winner.assetPath,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.none,
                          errorBuilder: (c, e, s) => const Icon(
                            Icons.military_tech,
                            size: 54,
                            color: DarkFantasyTheme.gold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      const Text(
                        "QUÁN QUÂN",
                        style: TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                            letterSpacing: 2.0),
                      ),
                      Text(
                        widget.winner.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: widget.winner.color,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Divider(color: DarkFantasyTheme.stoneBorder),
                      const SizedBox(height: 8),

                      // CHI TIẾT KÈO
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "CHI TIẾT KÈO CƯỢC:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: DarkFantasyTheme.goldDark,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      ...widget.racers.map((r) {
                        final b = widget.bets[r.id];
                        if (b == null || !b.isSelected) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("- ${r.name}:",
                                    style: const TextStyle(
                                        color: Colors.white60, fontSize: 13)),
                                const Text("Không cược",
                                    style: TextStyle(
                                        color: Colors.white60, fontSize: 13)),
                              ],
                            ),
                          );
                        }

                        final bool isWon = (r.id == widget.winner.id);
                        final payout = isWon ? (b.amount * r.odds).toInt() : 0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "- ${r.name} (cược ${b.amount}):",
                                style: const TextStyle(
                                    color: DarkFantasyTheme.textLight,
                                    fontSize: 13),
                              ),
                              Text(
                                isWon
                                    ? "THẮNG (+${payout})"
                                    : "THUA (-${b.amount})",
                                style: TextStyle(
                                  color: isWon
                                      ? Colors.greenAccent
                                      : DarkFantasyTheme.bloodRed,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 12),
                      const Divider(color: DarkFantasyTheme.stoneBorder),
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Tổng đặt cược:",
                              style: TextStyle(
                                  fontSize: 13, color: Colors.white70)),
                          Text("-$totalBetDeducted",
                              style: const TextStyle(
                                  color: DarkFantasyTheme.bloodRed,
                                  fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Tiền thưởng nhận về:",
                              style: TextStyle(
                                  fontSize: 13, color: Colors.white70)),
                          Text("+$totalWinnings",
                              style: const TextStyle(
                                  color: Colors.greenAccent, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Kết quả vòng đấu:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.white)),
                          Text(
                            netProfit > 0
                                ? "LÃI: +$netProfit VÀNG"
                                : "LỖ: $netProfit VÀNG",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: netProfit > 0
                                  ? Colors.greenAccent
                                  : DarkFantasyTheme.bloodRed,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // KHUNG SỐ VÀNG CÒN LẠI
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          border: Border.all(
                            color: isBankrupt
                                ? DarkFantasyTheme.bloodRed
                                : DarkFantasyTheme.goldDark,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isBankrupt ? "TÌNH TRẠNG:" : "SỐ VÀNG HIỆN TẠI:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isBankrupt
                                    ? DarkFantasyTheme.bloodRed
                                    : DarkFantasyTheme.gold,
                              ),
                            ),
                            Text(
                              isBankrupt
                                  ? "PHÁ SẢN (HẾT VÀNG)"
                                  : "$finalBalance Vàng",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isBankrupt
                                    ? DarkFantasyTheme.bloodRed
                                    : DarkFantasyTheme.gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // NÚT CHƠI TIẾP
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            SoundService.playClick();
                            SoundService.playLoginBgm();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BettingScreen(
                                  playerName: widget.playerName,
                                  balance: isBankrupt
                                      ? 1000
                                      : finalBalance, // Hồi sinh 1000 vàng nếu phá sản
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isBankrupt
                                ? Colors.indigo.shade900
                                : DarkFantasyTheme.crimson,
                            side: const BorderSide(
                                color: DarkFantasyTheme.gold, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: const BeveledRectangleBorder(),
                          ),
                          child: Text(
                            isBankrupt
                                ? "HỒI SINH (NHẬN LẠI VÀNG)"
                                : "TIẾP TỤC ĐẶT CƯỢC",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
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
    );
  }
}
