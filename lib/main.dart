import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/providers.dart';
import 'services/audio_player_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.redevined.intrval.channel.audio',
      androidNotificationChannelName: 'intrval playback',
      androidNotificationOngoing: true,
    ),
  );

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
