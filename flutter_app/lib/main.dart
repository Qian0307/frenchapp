import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'shared/providers/supabase_provider.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

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

    runApp(const ProviderScope(child: FrenchLearningApp()));
  } catch (e, st) {
    // Write crash log so we can debug Windows startup failures
    try {
      final logPath = Platform.isWindows
          ? '${Platform.environment['USERPROFILE']}\\Desktop\\frenchmind_crash.log'
          : '/tmp/frenchmind_crash.log';
      await File(logPath).writeAsString(
        'CRASH at ${DateTime.now()}\n\nError: $e\n\nStackTrace:\n$st\n',
      );
    } catch (_) {}
    rethrow;
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
