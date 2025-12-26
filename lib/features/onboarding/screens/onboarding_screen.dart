import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/project_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = const [
    OnboardingSlide(
      title: 'Welcome to CodeX',
      description: 'Your professional mobile IDE for modern web development.',
      icon: Icons.code_rounded,
    ),
    OnboardingSlide(
      title: 'Projects & Files',
      description: 'Create boilerplates or import existing work. \n\nManage files directly from the Dashboard folder menu.',
      icon: Icons.folder_copy_rounded,
    ),
    OnboardingSlide(
      title: 'Rich File Controls',
      description: '• Tap to Rename\n• Delete with a swipe/tap\n• Import assets seamlessly.',
      icon: Icons.drive_file_rename_outline_rounded,
    ),
    OnboardingSlide(
      title: 'Pro Code Editor',
      description: 'Full-featured editor with tabs, line numbers, word wrap, and specialized keyboard tools.',
      icon: Icons.integration_instructions_rounded,
    ),
    OnboardingSlide(
      title: 'Integrated Workbench',
      description: 'Navigate your codebase, search across all files, and tune your workspace settings.',
      icon: Icons.dashboard_customize_rounded,
    ),
     OnboardingSlide(
      title: 'Instant Preview',
      description: 'See your changes live with a single tap. Built-in console for powerful debugging.',
      icon: Icons.rocket_launch_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E1E1E),
              Color(0xFF121212),
              Color(0xFF000000),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.outfit(
                          color: Colors.white.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (index == 0)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.white.withOpacity(0.05),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'assets/logo.png',
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: CodeXColors.accentBlue.withOpacity(0.1),
                                border: Border.all(
                                  color: CodeXColors.accentBlue.withOpacity(0.2),
                                  width: 2,
                                ),
                              ),
                              child: Icon(slide.icon, size: 80, color: CodeXColors.accentBlue),
                            ),
                          const SizedBox(height: 60),
                          Text(
                            slide.title,
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                            ),
                            child: Text(
                              slide.description,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.7),
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _currentPage == index
                            ? CodeXColors.accentBlue
                            : Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _slides.length - 1) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutQuart,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CodeXColors.accentBlue,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: CodeXColors.accentBlue.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _currentPage == _slides.length - 1 ? 'Start Coding' : 'Continue',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    await ref.read(projectServiceProvider).completeOnboarding();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/'); // Assuming '/' is Dashboard or handled by logic
      // Actually, since we might be pushed FROM Dashboard, pop is better if pushed.
      // But if we want to replace, we can rely on how it's called.
      // If called from initState, we likely need to just pop or replace.
      // Let's assume we pop back to dashboard which will then show normal content.
      // Wait, if it's pushed, pop is enough.
      Navigator.pop(context);
    }
  }
}

class OnboardingSlide {
  final String title;
  final String description;
  final IconData icon;

  const OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
  });
}
