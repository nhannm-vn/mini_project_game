import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ControllableGifRacer extends StatefulWidget {
  final String assetPath;
  final bool isRacing;
  final double size;

  const ControllableGifRacer({
    super.key,
    required this.assetPath,
    required this.isRacing,
    this.size = 44.0,
  });

  @override
  State<ControllableGifRacer> createState() => _ControllableGifRacerState();
}

class _ControllableGifRacerState extends State<ControllableGifRacer> {
  ui.Image? _firstFrame;
  ImageStream? _imageStream;
  ImageStreamListener? _streamListener;

  @override
  void initState() {
    super.initState();
    _loadFirstFrame();
  }

  void _loadFirstFrame() {
    final ImageProvider provider = AssetImage(widget.assetPath);
    _imageStream = provider.resolve(const ImageConfiguration());
    _streamListener = ImageStreamListener((ImageInfo info, bool _) {
      if (mounted && _firstFrame == null) {
        setState(() {
          _firstFrame = info.image.clone();
        });
        // Sau khi đã tóm được frame đầu tiên làm ảnh tĩnh, ngắt stream ngay để không bị chạy tiếp
        if (_imageStream != null && _streamListener != null) {
          _imageStream!.removeListener(_streamListener!);
        }
      }
    });
    _imageStream!.addListener(_streamListener!);
  }

  @override
  void dispose() {
    if (_imageStream != null && _streamListener != null) {
      _imageStream!.removeListener(_streamListener!);
    }
    _firstFrame?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: widget.isRacing
          // 1. Khi đang đua: Hiển thị GIF động chạy bình thường
          ? Image.asset(
              widget.assetPath,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
            )
          // 2. Khi CHƯA đua: Vẽ đúng frame tĩnh đầu tiên (nhân vật đứng yên 100%)
          : (_firstFrame != null
              ? RawImage(
                  image: _firstFrame,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                )
              : Image.asset(
                  widget.assetPath,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                )),
    );
  }
}
