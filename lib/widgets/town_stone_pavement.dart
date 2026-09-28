import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TownStonePavement extends StatefulWidget {
  const TownStonePavement({super.key});

  @override
  State<TownStonePavement> createState() => _TownStonePavementState();
}

class _TownStonePavementState extends State<TownStonePavement> {
  ui.Image? _tileset;

  @override
  void initState() {
    super.initState();
    _loadTileset();
  }

  Future<void> _loadTileset() async {
    try {
      final ByteData data =
          await rootBundle.load('assets/images/Tileset_Stones_32x32.png');
      final ui.Codec codec =
          await ui.instantiateImageCodec(data.buffer.asUint8List());
      final ui.FrameInfo fi = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _tileset = fi.image;
        });
      }
    } catch (e) {
      debugPrint("Lỗi tải Tileset gạch phố: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tileset == null) {
      return Container(color: const Color(0xFF1E1428));
    }
    return CustomPaint(
      painter: _PavementPainter(tileset: _tileset!),
      size: Size.infinite,
    );
  }
}

class _PavementPainter extends CustomPainter {
  final ui.Image tileset;
  _PavementPainter({required this.tileset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..filterQuality = FilterQuality.none
      ..isAntiAlias = false;

    const double srcTile = 32.0;
    const double dstTile = 16.0;

    // Tọa độ cắt viên đá mặt phẳng trong tileset
    final Rect srcRect = const Rect.fromLTWH(32, 0, srcTile, srcTile);

    // Lát các viên đá nhỏ thành vỉa hè
    for (double y = 0; y < size.height; y += dstTile) {
      for (double x = 0; x < size.width; x += dstTile) {
        canvas.drawImageRect(
          tileset,
          srcRect,
          Rect.fromLTWH(x, y, dstTile, dstTile),
          paint,
        );
      }
    }

    // Phủ lớp bóng tối nhẹ để tôn dáng nhà
    final shadow = Paint()..color = Colors.black.withValues(alpha: 0.3);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), shadow);
  }

  @override
  bool shouldRepaint(covariant _PavementPainter oldDelegate) =>
      oldDelegate.tileset != tileset;
}
