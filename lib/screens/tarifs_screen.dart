import 'package:flutter/material.dart';
import 'payment_screen.dart';

class TarifsScreen extends StatefulWidget {
  const TarifsScreen({super.key});

  @override
  State<TarifsScreen> createState() => _TarifsScreenState();
}

class _TarifsScreenState extends State<TarifsScreen> {
  int selectedPlanIndex = 1; // Offre Mensuelle sélectionnée par défaut (comme la maquette)

  final List<Map<String, dynamic>> plans = [
    {
      'title': 'Offre Annuelle',
      'subtitle': 'Jusqu\'à 500 annonces - 20,000 FCFA/année',
      'price': '20 000',
      'periodLabel': '/année',
      'badge': 'Meilleur Prix',
    },
    {
      'title': 'Offre Mensuelle',
      'subtitle': 'Jusqu\'à 130 annonces - 3,000 FCFA/mois',
      'price': '3 000',
      'periodLabel': '/mois',
      'badge': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4CAF50),
              Color(0xFF45A049),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Abonnement',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              
              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Deux formules, un seul objectif : vous connecter aux meilleures opportunités du Sénégal. Recevez chaque jour tous les appels d\'offres et donnez plus de visibilité à vos annonces !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Illustration
              Image.asset(
                'assets/images/tarif.png',
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.people_outline,
                      size: 100,
                      color: Colors.white70,
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              // Plans
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: List.generate(plans.length, (index) {
                    final plan = plans[index];
                    final isSelected = selectedPlanIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPlanIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3FA34A),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white,
                            width: isSelected ? 2.5 : 0.8,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    plan['title'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    plan['subtitle'],
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.95),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (plan['badge'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D34),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  plan['badge'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),
              
              // Bouton Confirmer
              Container(
                padding: const EdgeInsets.all(24),
                child: ElevatedButton(
                  onPressed: () {
                    final selectedPlan = plans[selectedPlanIndex];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentScreen(
                          isAnnual: selectedPlan['periodLabel'] == '/année',
                          planTitle: selectedPlan['title'],
                          price: selectedPlan['price'],
                          period: selectedPlan['periodLabel'],
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: const Size(double.infinity, 56),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Confirmer cette offre',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              // Conditions
              Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    children: const [
                      TextSpan(text: 'En passant cette commande, vous acceptez les '),
                      TextSpan(
                        text: 'conditions d\'utilisation',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: ' et la '),
                      TextSpan(
                        text: 'politique de confidentialité',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}
