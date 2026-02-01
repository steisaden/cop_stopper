import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/src/service_locator.dart'
    if (dart.library.html) 'package:mobile/src/service_locator_web.dart';
import 'package:mobile/src/conditional_home_screen.dart';
import 'package:mobile/src/services/text_size_service.dart';
import 'package:mobile/src/services/onboarding_service.dart';
import 'package:mobile/src/services/offline_service.dart';
import 'package:mobile/src/ui/theme_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/services/settings_service.dart';
import 'package:mobile/src/services/recording_service_interface.dart';
import 'package:mobile/src/services/location_service.dart';
import 'package:mobile/src/services/navigation_service.dart';

import 'package:mobile/src/blocs/navigation/navigation_bloc.dart';
import 'package:mobile/src/blocs/recording/recording_bloc.dart';
import 'package:mobile/src/blocs/transcription/transcription_bloc.dart';
import 'package:mobile/src/blocs/emergency/emergency_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Setup services
  setupLocator(prefs);

  // Register services that need SharedPreferences
  locator.registerSingleton<SharedPreferences>(prefs);
  locator
      .registerLazySingleton<OnboardingService>(() => OnboardingService(prefs));

  locator.registerLazySingleton<OfflineService>(() => OfflineService(prefs));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        Provider(create: (_) => locator<TextSizeService>()),
        Provider(create: (_) => locator<OnboardingService>()),
        Provider(create: (_) => locator<OfflineService>()),
        Provider(create: (_) => locator<SettingsService>()),

        // Global Blocs
        BlocProvider<NavigationBloc>(create: (_) => NavigationBloc()),
        BlocProvider<RecordingBloc>(create: (_) => RecordingBloc()),
        BlocProvider<TranscriptionBloc>(create: (_) => TranscriptionBloc()),
        // EmergencyBloc requires dependencies
        BlocProvider<EmergencyBloc>(
            create: (_) => EmergencyBloc(
                  recordingService: locator<RecordingService>(),
                  locationService: locator<LocationService>(),
                  navigationService: locator<NavigationService>(),
                )),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeManager, TextSizeService>(
      builder: (context, themeManager, textSizeService, child) {
        return MaterialApp(
          title: 'Cop Stopper',
          theme: themeManager.getTheme(context),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: textSizeService.textScaleFactor,
              ),
              child: child!,
            );
          },
          home: const ConditionalHomeScreen(),
        );
      },
    );
  }
}
