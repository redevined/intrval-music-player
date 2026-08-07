import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart' as mak;
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/providers.dart';
import 'services/audio_player_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  mak.MpvAudioKit.ensureInitialized();
  final audioHandler = AudioPlayerHandler();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        audioHandlerProvider.overrideWithValue(audioHandler),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const IntrvalApp(),
    ),
  );
}
