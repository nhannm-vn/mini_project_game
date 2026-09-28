import 'package:flutter/material.dart';

class WarriorSpectator extends StatelessWidget {
  final double size;
  final bool flipX;

  const WarriorSpectator({
    super.key,
    this.size = 28.0,
    this.flipX = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = SizedBox(
      width: size,
      height: size,
      child: ClipRect(
        child: OverflowBox(
          maxWidth: size * 8, // Tấm ảnh gồm 8 frame ngang
          maxHeight: size,
          alignment: Alignment.centerLeft, // Cắt frame đầu tiên
          child: Image.asset(
            'assets/images/warrior_idle.png',
            fit: BoxFit.fill,
            filterQuality: FilterQuality.none,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/images/Warrior_Idle.png',
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
              errorBuilder: (c, e, s) => const Icon(
                Icons.shield,
                color: Colors.amberAccent,
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );

    if (flipX) {
      return Transform.flip(flipX: true, child: content);
    }
    return content;
  }
}
