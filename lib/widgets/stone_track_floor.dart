import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StoneTrackFloor extends StatefulWidget {
  const StoneTrackFloor({super.key});

  @override
  State<StoneTrackFloor> createState() => _StoneTrackFloorState();
}

class _StoneTrackFloorState extends State<StoneTrackFloor> {
  ui.Image? _tilesetImage;

  @override
  void initState() {
    super.initState();
    _loadTileset();
  }

  Future<void> _loadTileset() async {
    final ByteData data =
        await rootBundle.load('assets/images/Tileset_Stones_32x32.png');
    final ui.Codec codec =
        await ui.instantiateImageCodec(data.buffer.asUint8List());
    final ui.FrameInfo fi = await codec.getNextFrame();
    if (mounted) {
      setState(() {
        _tilesetImage = fi.image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tilesetImage == null) {
      return Container(
          color: const Color(0xFF1F1426)); // Màu nền tạm khi đang load
    }
    return CustomPaint(
      painter: _StoneTilesetPainter(tileset: _tilesetImage!),
      size: Size.infinite,
    );
  }
}

class _StoneTilesetPainter extends CustomPainter {
  final ui.Image tileset;
  _StoneTilesetPainter({required this.tileset});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Tô nền tối làm đất ngầm
    final bgPaint = Paint()..color = const Color(0xFF140D1B);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final paint = Paint()
      ..filterQuality = FilterQuality.none // Giữ chất pixel sắc nét
      ..isAntiAlias = false;

    // Tỉ lệ kích thước: Tấm 32x32 có chiều cao khoảng 96px, rộng khoảng 288px
    // Ta lấy ô gạch đá ở góc trên bên trái: x: 0..32, y: 0..32
    const double srcTileSize = 32.0;
    const double dstTileSize = 32.0; // Kích thước hiển thị trên màn hình

    final Rect srcRect = Rect.fromLTWH(0, 0, srcTileSize, srcTileSize);

    // 2. Lát gạch đá trải dài khắp bề ngang và dọc của làn chạy
    for (double y = 8; y < size.height; y += dstTileSize) {
      for (double x = 0; x < size.width; x += dstTileSize) {
        final Rect dstRect = Rect.fromLTWH(x, y, dstTileSize, dstTileSize);
        canvas.drawImageRect(tileset, srcRect, dstRect, paint);
      }
    }

    // 3. Phủ một lớp bóng tối nhẹ để quái vật chạy phía trên nổi bật hơn
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.35);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), shadowPaint);

    // 4. Vẽ cỏ rêu mọc viền mép trên của đường đá
    final mossPaint = Paint()..color = const Color(0xFF2E7D32);
    final lightGrassPaint = Paint()..color = const Color(0xFF81C784);

    for (double x = 0; x < size.width; x += 12) {
      // Chân rêu
      canvas.drawRect(Rect.fromLTWH(x, 6, 8, 3), mossPaint);
      // Ngọn cỏ nhú lên dạng pixel
      if ((x ~/ 12) % 2 == 0) {
        canvas.drawRect(Rect.fromLTWH(x + 2, 3, 2, 4), lightGrassPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StoneTilesetPainter oldDelegate) =>
      oldDelegate.tileset != tileset;
}
