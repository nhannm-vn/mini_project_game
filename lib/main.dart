import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:project_mini_game_racing/services/sound_service.dart';
import 'constants/theme.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SoundService.initAudio();
  AudioPlayer().setSource(AssetSource('audio/clickUI.wav'));

  runApp(const ShadowDerbyApp());
}

class ShadowDerbyApp extends StatelessWidget {
  const ShadowDerbyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shadow Derby',
      debugShowCheckedModeBanner: false,
      theme: DarkFantasyTheme.themeData, // Áp dụng font pixel toàn cục
      home: const LoginScreen(),
    );
  }
}
