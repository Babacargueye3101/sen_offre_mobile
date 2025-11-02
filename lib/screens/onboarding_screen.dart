import 'package:flutter/material.dart';
import '../main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Bienvenue sur SenOffre !',
      description:
          "SenOffre est votre accès privilégié aux appels d'offres et demandes de prix au Sénégal. Simple, clair et efficace, l'expérience commence ici.",
      imagePath: 'assets/images/ACCEUIL Slider 1.png',
      backgroundImagePath: 'assets/images/SenOffre White Background.png',
      backgroundColor: const Color(0xFF4CAF50),
    ),
    OnboardingPage(
      title: '1 clic, 1 offre, 1 opportunité',
      description:
          "Trouvez rapidement les appels d'offres qui vous correspondent. Filtrez, consultez, sauvegardez et restez toujours en avance sur vos concurrents.",
      imagePath: 'assets/images/ACCEUIL Slider 2.png',
      backgroundImagePath: 'assets/images/SenOffre Green Background.png',
      backgroundColor: const Color(0xFF4CAF50),
    ),
    OnboardingPage(
      title: 'Rejoignez-nous !',
      description:
          "Avec SenOffre, chaque opportunité compte. Développez votre activité et profitez d'un accès illimité au marché dès maintenant.",
      imagePath: 'assets/images/ACCEUIL Slider 3.png',
      backgroundImagePath: 'assets/images/SenOffre White Background.png',
      backgroundColor: const Color(0xFF4CAF50),
      isLast: true,
    ),
  ];

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToHome();
    }
  }

  void _skipToLast() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 32.0),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: _currentPage == index ? 40 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFF4CAF50)
                              : Colors.grey.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Buttons
                  Row(
                    children: [
                      if (_currentPage < _pages.length - 1)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _skipToLast,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              side: BorderSide(
                                color: Colors.grey.withOpacity(0.25),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Passer',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      if (_currentPage < _pages.length - 1) const SizedBox(width: 16),
                      Expanded(
                        flex: _currentPage == _pages.length - 1 ? 1 : 1,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4CAF50).withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 0,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              _currentPage == _pages.length - 1 ? 'Commencer' : 'Suivant',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Illustration with elegant frame
          Expanded(
            flex: 3,
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 380,
                        maxHeight: 380,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withOpacity(0.15),
                            blurRadius: 40,
                            spreadRadius: 0,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Stack(
                          children: [
                            // Background pattern
                            if (page.backgroundImagePath != null)
                              Positioned.fill(
                                child: Image.asset(
                                  page.backgroundImagePath!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            // Main image with padding
                            if (page.imagePath != null)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: Image.asset(
                                    page.imagePath!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            // Icon for pages without custom image
                            if (page.imagePath == null && page.icon != null)
                              Center(
                                child: Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    color: page.backgroundColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(80),
                                  ),
                                  child: Icon(
                                    page.icon!,
                                    size: 80,
                                    color: page.backgroundColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 48),
          // Content with better spacing
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Text(
                  page.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  page.description,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.6,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData? icon;
  final String? imagePath;
  final String? backgroundImagePath;
  final Color backgroundColor;
  final bool isLast;

  OnboardingPage({
    required this.title,
    required this.description,
    this.icon,
    this.imagePath,
    this.backgroundImagePath,
    required this.backgroundColor,
    this.isLast = false,
  });
}

class PatternPainter extends CustomPainter {
  final Color color;

  PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'SENOFFRE ',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: color.withOpacity(0.15),
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    for (double y = -50; y < size.height + 50; y += 40) {
      for (double x = -100; x < size.width + 100; x += 150) {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(-0.2);
        textPainter.paint(canvas, Offset.zero);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
