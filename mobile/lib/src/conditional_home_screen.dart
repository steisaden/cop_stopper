import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/src/services/onboarding_service.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/screens/navigation_wrapper.dart';

class ConditionalHomeScreen extends StatefulWidget {
  const ConditionalHomeScreen({Key? key}) : super(key: key);

  @override
  State<ConditionalHomeScreen> createState() => _ConditionalHomeScreenState();
}

class _ConditionalHomeScreenState extends State<ConditionalHomeScreen> {
  bool _isLoading = true;
  late OnboardingService _onboardingService;

  @override
  void initState() {
    super.initState();
    _onboardingService = Provider.of<OnboardingService>(context, listen: false);
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Brief delay to allow service to initialize
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Check if onboarding has been completed
    if (!_onboardingService.hasCompletedOnboarding) {
      return const OnboardingScreen();
    }

    // Show main app if onboarding is completed
    return const NavigationWrapper();
  }
}