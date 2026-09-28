import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IslandTrackFloor extends StatefulWidget {
  const IslandTrackFloor({super.key});

  @override
  State<IslandTrackFloor> createState() => _IslandTrackFloorState();
}

class _IslandTrackFloorState extends State<IslandTrackFloor> {
  ui.Image? _tileImage;

  @override
  void initState() {
    super.initState();
    _loadTileset();
  }

  Future<void> _loadTileset() async {
    try {
      final ByteData data =
          await rootBundle.load('assets/images/tilemap_cliff.png');
      final ui.Codec codec =
          await ui.instantiateImageCodec(data.buffer.asUint8List());
      final ui.FrameInfo fi = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _tileImage = fi.image;
        });
      }
    } catch (e) {
      debugPrint("Lỗi nạp tilemap_cliff: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tileImage == null) {
      return Container(color: const Color(0xFF131D18));
    }
    return CustomPaint(
      painter: _IslandPainter(tileImage: _tileImage!),
      size: Size.infinite,
    );
  }
}

class _IslandPainter extends CustomPainter {
  final ui.Image tileImage;
  _IslandPainter({required this.tileImage});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..filterQuality = FilterQuality.none
      ..isAntiAlias = false;

    const double cliffH = 24.0;
    final double grassH = size.height - cliffH;

    // Cắt ruột thảm cỏ (tránh viền lưới tilemap)
    final double grassSrcX = tileImage.width * 0.12;
    final double grassSrcY = tileImage.height * 0.12;
    final double grassSrcSize = tileImage.width * 0.18;
    final Rect srcGrass =
        Rect.fromLTWH(grassSrcX, grassSrcY, grassSrcSize, grassSrcSize);

    const double tileSize = 36.0;
    for (double x = 0; x < size.width; x += tileSize) {
      for (double y = 0; y < grassH; y += tileSize) {
        canvas.drawImageRect(
          tileImage,
          srcGrass,
          Rect.fromLTWH(x, y, tileSize, tileSize),
          paint,
        );
      }
    }

    // Cắt vách đá 2.5D ở góc dưới bên phải
    final double cliffSrcX = tileImage.width * 0.55;
    final double cliffSrcY = tileImage.height * 0.52;
    final double cliffSrcW = tileImage.width * 0.40;
    final double cliffSrcH = tileImage.height * 0.40;
    final Rect srcCliff =
        Rect.fromLTWH(cliffSrcX, cliffSrcY, cliffSrcW, cliffSrcH);

    for (double x = 0; x < size.width; x += 40.0) {
      canvas.drawImageRect(
        tileImage,
        srcCliff,
        Rect.fromLTWH(x, grassH, 40.0, cliffH),
        paint,
      );
    }

    // Bóng tối ngăn làn phía dưới
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    canvas.drawRect(
        Rect.fromLTWH(0, size.height - 3, size.width, 3), shadowPaint);
  }

  @override
  bool shouldRepaint(covariant _IslandPainter oldDelegate) =>
      oldDelegate.tileImage != tileImage;
}
