import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/src/services/onboarding_service.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';
import '../app_colors.dart';
import '../components/shadcn_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late OnboardingService _onboardingService;
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      title: 'Your Safety is Our Priority',
      content: 'Cop Stopper helps you stay safe during police interactions with secure recording and real-time monitoring.',
      imagePath: 'assets/images/onboarding1.png', // Placeholder - in a real app, you'd have actual assets
      icon: Icons.shield,
    ),
    _OnboardingPage(
      title: 'Record & Protect',
      content: 'Your interactions are securely recorded with advanced transcription and fact-checking capabilities.',
      imagePath: 'assets/images/onboarding2.png',
      icon: Icons.videocam,
    ),
    _OnboardingPage(
      title: 'Emergency Support',
      content: 'Instant access to legal guidance and emergency contacts when you need them most.',
      imagePath: 'assets/images/onboarding3.png',
      icon: Icons.emergency,
    ),
    _OnboardingPage(
      title: 'Complete Control',
      content: 'All your data remains private and secure, with full control over sharing and storage.',
      imagePath: 'assets/images/onboarding4.png',
      icon: Icons.privacy_tip,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _onboardingService = Provider.of<OnboardingService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () async {
                  // Mark onboarding as completed
                  await _onboardingService.markAsCompleted();
                  // Navigate to main app
                  Navigator.of(context).pushReplacementNamed('/'); // This would be the main screen
                },
                child: Text(
                  'Skip',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
            ),
            
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.lg,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < _pages.length; i++)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _currentPage 
                            ? AppColors.primary 
                            : AppColors.mutedForeground.withOpacity(0.3),
                      ),
                    ),
                ],
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView.builder(
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _buildPage(page);
                },
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: ShadcnButton.outline(
                        text: 'Back',
                        onPressed: () {
                          if (_currentPage > 0) {
                            setState(() {
                              _currentPage--;
                            });
                          }
                        },
                      ),
                    )
                  else
                    const Spacer(),
                  
                  const SizedBox(width: AppSpacing.sm),
                  
                  Expanded(
                    child: ShadcnButton.primary(
                      text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                      onPressed: () async {
                        if (_currentPage < _pages.length - 1) {
                          setState(() {
                            _currentPage++;
                          });
                        } else {
                          // Mark onboarding as completed
                          await _onboardingService.markAsCompleted();
                          // Navigate to main app
                          Navigator.of(context).pushReplacementNamed('/'); // This would be the main screen
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon placeholder (would be an actual image in a real implementation)
          Icon(
            page.icon,
            size: 120,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            page.title,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            page.content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          // In a real app, we would have actual images:
          // Image.asset(
          //   page.imagePath,
          //   height: 200,
          //   fit: BoxFit.contain,
          // ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final String title;
  final String content;
  final String imagePath;
  final IconData icon;

  _OnboardingPage({
    required this.title,
    required this.content,
    required this.imagePath,
    required this.icon,
  });
}