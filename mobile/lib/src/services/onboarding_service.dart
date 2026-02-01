import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing onboarding state
class OnboardingService {
  static const String _hasCompletedOnboardingKey = 'has_completed_onboarding';

  final SharedPreferences _prefs;

  OnboardingService(this._prefs);

  /// Check if the user has completed the onboarding flow
  bool get hasCompletedOnboarding => _prefs.getBool(_hasCompletedOnboardingKey) ?? false;

  /// Mark onboarding as completed
  Future<void> markAsCompleted() async {
    await _prefs.setBool(_hasCompletedOnboardingKey, true);
  }

  /// Reset onboarding status (useful for testing)
  Future<void> reset() async {
    await _prefs.setBool(_hasCompletedOnboardingKey, false);
  }
}