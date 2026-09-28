import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final AudioPlayer _sfxPlayer = AudioPlayer();
  static final AudioPlayer _bgmPlayer = AudioPlayer();

  static bool isMuted = false;
  static String _currentBgmTrack = '';
  static int _lastClickTimestamp = 0;

  static final Source _clickSource = AssetSource('audio/clickUI.wav');

  static Future<void> initAudio() async {
    try {
      final audioContext = AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: const {AVAudioSessionOptions.mixWithOthers},
        ),
      );

      await AudioPlayer.global.setAudioContext(audioContext);
      await _bgmPlayer.setAudioContext(audioContext);
      await _sfxPlayer.setAudioContext(audioContext);

      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _sfxPlayer.setReleaseMode(ReleaseMode.stop);

      debugPrint("[SOUND_SERVICE] Khởi tạo âm thanh hoàn tất!");
    } catch (e) {
      debugPrint("[SOUND_SERVICE ERROR] initAudio: $e");
    }
  }

  static void toggleMute() {
    isMuted = !isMuted;
    if (isMuted) {
      _bgmPlayer.pause();
    } else {
      if (_currentBgmTrack.isNotEmpty) {
        _bgmPlayer.resume();
      } else {
        playLoginBgm();
      }
    }
  }

  // TIẾNG CLICK: BỎ HOÀN TOÀN .seek() -> TRIỆT TIÊU TIẾNG BỊCH BỊCH
  static void playClick() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastClickTimestamp < 100) return; // Chống spam double-click
    _lastClickTimestamp = now;

    try {
      _sfxPlayer.play(
        _clickSource,
        volume: 0.8,
        mode: PlayerMode.lowLatency,
      );
    } catch (e) {
      debugPrint("Lỗi playClick: $e");
    }
  }

  // PHÁT NHẠC NỀN: Hạ volume trước khi chuyển bài để không nổ màng loa
  static Future<void> _playBgm(String assetPath, double volume) async {
    if (_currentBgmTrack == assetPath &&
        _bgmPlayer.state == PlayerState.playing) {
      return;
    }

    _currentBgmTrack = assetPath;
    if (isMuted) return;

    try {
      // Tắt tiếng bài cũ về 0 để triệt tiêu xung điện DC
      await _bgmPlayer.setVolume(0.0);
      await _bgmPlayer.stop();

      // Nạp bài mới và nâng âm lượng lên
      await _bgmPlayer.setSource(AssetSource(assetPath));
      await _bgmPlayer.setVolume(volume);
      await _bgmPlayer.resume();
      debugPrint(">>> [BGM PLAYING] $assetPath <<<");
    } catch (e) {
      debugPrint("[BGM ERROR] $assetPath: $e");
    }
  }

  static void playLoginBgm() {
    _playBgm('audio/ambience_login.mp3', 0.5);
  }

  static void playStartHorn() {
    _playBgm('audio/CombatSong.mp3', 0.85);
  }

  static void stopCombat() {
    stopBgm();
  }

  static void stopBgm() {
    _currentBgmTrack = '';
    try {
      _bgmPlayer.stop();
    } catch (_) {}
  }

  static void playVictory() {
    _playBgm('audio/victory.mp3', 0.85);
  }

  static void playDefeat() {
    _playBgm('audio/defeat.mp3', 0.85);
  }
}
