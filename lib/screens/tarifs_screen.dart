import 'package:flutter/material.dart';

class TarifsScreen extends StatefulWidget {
  const TarifsScreen({super.key});

  @override
  State<TarifsScreen> createState() => _TarifsScreenState();
}

class _TarifsScreenState extends State<TarifsScreen> with TickerProviderStateMixin {
  bool isAnnualSelected = false;
  late AnimationController _floatingController;
  late AnimationController _scaleController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _floatingAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _selectPlan(bool isAnnual) {
    setState(() {
      isAnnualSelected = isAnnual;
    });
    _scaleController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF4CAF50),
              const Color(0xFF45A049),
              const Color(0xFF66BB6A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Abonnement',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Description text
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            "Deux formules, un seul objectif : vous connecter aux meilleures opportunités du Sénégal. Recevez chaque jour tous les appels d'offres et donnez plus de visibilité à vos annonces !",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Illustration animée
                        AnimatedBuilder(
                          animation: _floatingAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _floatingAnimation.value),
                              child: child,
                            );
                          },
                          child: Container(
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Cercles en arrière-plan
                                ...List.generate(3, (index) {
                                  return Opacity(
                                    opacity: (0.3 - (index * 0.1)).clamp(0.0, 1.0),
                                    child: Container(
                                      width: 100 + (index * 40.0),
                                      height: 100 + (index * 40.0),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                // Icônes centrales
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildModernPersonIcon(false, 0),
                                    _buildModernPersonIcon(true, 1),
                                    _buildModernPersonIcon(false, 2),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Offre Annuelle
                        _buildModernPricingCard(
                          isSelected: isAnnualSelected,
                          title: 'Offre Annuelle',
                          price: '20,000',
                          period: '/année',
                          features: [
                            "Jusqu'à 500 annonces",
                            'Accès illimité',
                            'Support prioritaire',
                          ],
                          badge: 'Meilleur Prix',
                          onTap: () => _selectPlan(true),
                          delay: 0,
                        ),
                        const SizedBox(height: 20),
                        // Offre Mensuelle
                        _buildModernPricingCard(
                          isSelected: !isAnnualSelected,
                          title: 'Offre Mensuelle',
                          price: '3,000',
                          period: '/mois',
                          features: [
                            "Jusqu'à 130 annonces",
                            'Accès complet',
                            'Support standard',
                          ],
                          onTap: () => _selectPlan(false),
                          delay: 100,
                        ),
                        const SizedBox(height: 32),
                        // Confirm button
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF4CAF50),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Confirmer cette offre',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: const Color(0xFF4CAF50),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Terms text
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(
                                text: 'En passant cette commande, vous acceptez les ',
                              ),
                              TextSpan(
                                text: 'conditions d\'utilisation',
                                style: TextStyle(
                                  color: Colors.white,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(text: ' et la '),
                              TextSpan(
                                text: 'politique de confidentialité',
                                style: TextStyle(
                                  color: Colors.white,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
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

  Widget _buildModernPersonIcon(bool highlighted, int index) {
    return Container(
      width: 70,
      height: 110,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: highlighted
              ? [Colors.white, Colors.white.withOpacity(0.9)]
              : [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(35),
        boxShadow: highlighted
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            highlighted ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: highlighted ? const Color(0xFF4CAF50) : Colors.white,
            size: 28,
          ),
          const SizedBox(height: 12),
          Icon(
            Icons.person_rounded,
            color: highlighted ? const Color(0xFF4CAF50) : Colors.white,
            size: 36,
          ),
        ],
      ),
    );
  }

  Widget _buildModernPricingCard({
    required bool isSelected,
    required String title,
    required String price,
    required String period,
    required List<String> features,
    String? badge,
    required VoidCallback onTap,
    required int delay,
  }) {
    return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0.95),
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
              width: isSelected ? 3 : 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF4CAF50) : Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF4CAF50),
                            const Color(0xFF66BB6A),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF4CAF50) : Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'FCFA',
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF4CAF50).withOpacity(0.7)
                            : Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                period,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF4CAF50).withOpacity(0.8)
                      : Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              ...features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: isSelected
                              ? const Color(0xFF4CAF50)
                              : Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF4CAF50).withOpacity(0.9)
                                  : Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
    );
  }
}
