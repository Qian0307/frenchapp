import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Fail fast if Supabase credentials are missing
    AppConstants.validateCredentials();

    // Windows 視窗設定（確保視窗正確顯示在螢幕上）
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      await windowManager.ensureInitialized();
      const windowOptions = WindowOptions(
        size: Size(1100, 750),
        minimumSize: Size(800, 600),
        center: true,
        title: 'FrenchMind',
        skipTaskbar: false,
      );
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }

    // Supabase
    await Supabase.initialize(
      url:       AppConstants.supabaseUrl,
      anonKey:   AppConstants.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );

    // Local offline cache
    await Hive.initFlutter();
    await Hive.openBox<dynamic>('vocab_cache');
    await Hive.openBox<dynamic>('article_cache');

    // Notifications
    await NotificationService.instance.initialize();

    if (!kIsWeb) {
      // Windows URL scheme 自動註冊 (frenchmind://)
      if (Platform.isWindows) {
        await _registerWindowsUrlScheme();
      }

      // Deep link 處理（email 驗證回調）
      final appLinks = AppLinks();
      final initialUri = await appLinks.getInitialLink();
      if (initialUri != null) {
        await Supabase.instance.client.auth.getSessionFromUrl(initialUri);
      }
      appLinks.uriLinkStream.listen((uri) async {
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
      });
    }

    runApp(const ProviderScope(child: FrenchLearningApp()));
  } catch (e, st) {
    // Write crash log so we can debug Windows startup failures
    try {
      final logPath = Platform.isWindows
          ? '${Platform.environment['LOCALAPPDATA']}\\frenchmind_crash.log'
          : '/tmp/frenchmind_crash.log';
      await File(logPath).writeAsString(
        'CRASH at ${DateTime.now()}\n\nError: $e\n\nStackTrace:\n$st\n',
      );
    } catch (_) {}
    rethrow;
  }
}

/// 將 frenchmind:// 協議寫入 HKCU，不需要管理員權限
Future<void> _registerWindowsUrlScheme() async {
  final exe = Platform.resolvedExecutable;
  final entries = [
    [r'HKCU\Software\Classes\frenchmind', '/ve', '/d', 'URL:FrenchMind Protocol'],
    [r'HKCU\Software\Classes\frenchmind', '/v', 'URL Protocol', '/d', ''],
    [r'HKCU\Software\Classes\frenchmind\shell\open\command', '/ve', '/d', '"$exe" "%1"'],
  ];
  for (final args in entries) {
    await Process.run('reg', ['add', args[0], ...args.sublist(1), '/f']);
  }
}

class FrenchLearningApp extends ConsumerWidget {
  const FrenchLearningApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title:            'French Learning',
      debugShowCheckedModeBanner: false,
      theme:            AppTheme.lightTheme,
      darkTheme:        AppTheme.darkTheme,
      themeMode:        ThemeMode.system,
      routerConfig:     router,
    );
  }
}
