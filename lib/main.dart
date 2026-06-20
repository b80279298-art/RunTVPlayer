import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'managers/favorite_manager.dart';
import 'managers/history_manager.dart';
import 'managers/layout_manager.dart';
import 'managers/player_manager.dart';
import 'managers/settings_manager.dart';
import 'managers/stream_manager.dart';
import 'managers/volume_manager.dart';
import 'models/stream_model.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  final settingsManager = SettingsManager();
  await settingsManager.load();

  final favoriteManager = FavoriteManager();
  await favoriteManager.load();

  final historyManager = HistoryManager();
  await historyManager.load();

  final streamManager = StreamManager();
  await streamManager.load();

  final volumeManager = VolumeManager();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsManager),
        ChangeNotifierProvider.value(value: favoriteManager),
        ChangeNotifierProvider.value(value: historyManager),
        ChangeNotifierProvider.value(value: streamManager),
        ChangeNotifierProvider.value(value: volumeManager),
        ChangeNotifierProvider(
          create: (_) => PlayerManager(volumeManager),
        ),
        ChangeNotifierProvider(
          create: (_) => LayoutManager(settingsManager.defaultLayout),
        ),
      ],
      child: const RunTVApp(),
    ),
  );
}

class RunTVApp extends StatelessWidget {
  const RunTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RunTV Player',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/settings': (_) => const Scaffold(
          body: SafeArea(child: SettingsScreen()),
        ),
      },
    );
  }
}
