import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/navigation/navigation_bloc.dart';
import '../../blocs/navigation/navigation_event.dart';
import '../../blocs/navigation/navigation_state.dart';
import '../../blocs/emergency/emergency_bloc.dart';
import '../../blocs/emergency/emergency_state.dart';
import '../../blocs/recording/recording_bloc.dart';
import '../../blocs/transcription/transcription_bloc.dart';
import '../../services/navigation_service.dart';
import '../../services/recording_service_interface.dart';
import '../../services/storage_service.dart';
import '../../services/location_service.dart';
import '../../service_locator.dart'
    if (dart.library.html) '../../service_locator_web.dart';
import '../widgets/bottom_navigation_component.dart';
import '../widgets/glass_bottom_nav.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/emergency_mode_interface.dart';
import '../widgets/emergency_stop_confirmation_dialog.dart';
import '../widgets/emergency_button.dart';
import '../widgets/global_emergency_button.dart';
import '../widgets/global_recording_indicator.dart';
import '../app_colors.dart';
// Glass screens - new glassmorphism design
import 'glass_home_screen.dart';
import 'glass_monitor_screen.dart';
import 'glass_officer_search_screen.dart';
import 'glass_documents_screen.dart';
import 'glass_history_screen.dart';
import 'glass_settings_screen.dart';

/// Main navigation wrapper that manages tab switching and screen display
class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({Key? key}) : super(key: key);

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  late final NavigationService _navigationService;

  @override
  void initState() {
    super.initState();
    // Initialize NavigationService with the global NavigationBloc
    _navigationService = locator<NavigationService>();
    // We need to access the global bloc here.
    // Since initState cannot access context.read easily without a delayed callback or didChangeDependencies,
    // we will do it in didChangeDependencies or just assume it's linked if NavigationService handles it.
    // However, the original code linked them: _navigationService.initialize(_navigationBloc);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigationService.initialize(context.read<NavigationBloc>());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Get the screen widget for the given tab
  Widget _getScreenForTab(NavigationTab tab) {
    switch (tab) {
      case NavigationTab.record:
        return const GlassHomeScreen(); // New glassmorphism design
      case NavigationTab.monitor:
        return const GlassMonitorScreen();
      case NavigationTab.officers:
        return const GlassOfficerSearchScreen();
      case NavigationTab.documents:
        return const GlassDocumentsScreen();
      case NavigationTab.history:
        return const GlassHistoryScreen();
      case NavigationTab.settings:
        return const GlassSettingsScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return EmergencyStopConfirmationHandler(
      child: BlocBuilder<NavigationBloc, NavigationState>(
        builder: (context, state) {
          return EmergencyModeOverlay(
            child: Scaffold(
              body: Stack(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _getScreenForTab(state.activeTab),
                  ),
                  // Global recording indicator - appears when recording is active
                  const GlobalRecordingIndicator(),
                  // Global floating emergency button removed
                  // const GlobalEmergencyButton(),
                  // Emergency status indicator at top
                  const EmergencyStatusIndicator(),
                ],
              ),
              bottomNavigationBar: const BottomNavigationComponent(),
            ),
          );
        },
      ),
    );
  }
}
