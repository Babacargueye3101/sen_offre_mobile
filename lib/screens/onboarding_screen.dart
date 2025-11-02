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
      icon: Icons.handshake_outlined,
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFF4CAF50)
                              : Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Buttons
                  Row(
                    children: [
                      if (_currentPage < _pages.length - 1)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _skipToLast,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(
                                color: Colors.grey.withOpacity(0.3),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Passer',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      if (_currentPage < _pages.length - 1) const SizedBox(width: 16),
                      Expanded(
                        flex: _currentPage == _pages.length - 1 ? 1 : 1,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _currentPage == _pages.length - 1 ? 'Commencer' : 'Suivant',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
          const SizedBox(height: 20),
          // Illustration
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                // Background pattern
                Positioned.fill(
                  child: page.backgroundImagePath != null
                      ? Image.asset(
                          page.backgroundImagePath!,
                          fit: BoxFit.contain,
                        )
                      : CustomPaint(
                          painter: PatternPainter(color: page.backgroundColor),
                        ),
                ),
                // Main image (no circular container)
                if (page.imagePath != null)
                  Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Image.asset(
                              page.imagePath!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                // Icon for pages without custom image
                if (page.imagePath == null && page.icon != null)
                  Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: [
                                BoxShadow(
                                  color: page.backgroundColor.withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              page.icon!,
                              size: 100,
                              color: page.backgroundColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Text(
                  page.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 16),
                Text(
                  page.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 32),
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
