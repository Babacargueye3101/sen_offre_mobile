import 'package:flutter/material.dart';
import 'payment_screen.dart';

class TarifsScreen extends StatefulWidget {
  const TarifsScreen({super.key});

  @override
  State<TarifsScreen> createState() => _TarifsScreenState();
}

class _TarifsScreenState extends State<TarifsScreen> {
  int selectedPlanIndex = 0; // Offre Annuelle par défaut

  final List<Map<String, dynamic>> plans = [
    {
      'title': 'Mensuel',
      'price': '3 000',
      'period': 'FCFA',
      'periodLabel': '/mois',
      'maxAnnonces': '120',
      'features': [
        'Publiez et recevez jusqu\'à 120 annonces par mois',
        'Accès aux appels d\'offres par Email uniquement',
        '1 utilisateur',
        'Conserver les annonces en ligne pendant 30 jours',
      ],
      'badge': null,
      'isPopular': false,
    },
    {
      'title': 'Essential',
      'price': '25 000',
      'period': 'FCFA',
      'periodLabel': '/année',
      'maxAnnonces': '1200',
      'features': [
        'Publiez et recevez jusqu\'à 1200 annonces par année',
        'Accès aux appels d\'offres par Email uniquement',
        '1 utilisateur',
        'Idéal pour les entrepreneurs individuels',
        'Conserver les annonces en ligne pendant 365 jours',
      ],
      'badge': 'PLUS POPULAIRE',
      'isPopular': true,
    },
    {
      'title': 'Standard',
      'price': '30 000',
      'period': 'FCFA',
      'periodLabel': '/année',
      'maxAnnonces': '1500',
      'features': [
        'Publiez et recevez jusqu\'à 1500 annonces par année',
        'Appels d\'offres par Email + SMS',
        'Alertes quotidiennes rapides',
        'Jusqu\'à 2 utilisateurs',
        'Formule la plus équilibrée',
        'Conserver les annonces en ligne pendant 365 jours',
      ],
      'badge': null,
      'isPopular': false,
    },
    {
      'title': 'Premium',
      'price': '100 000',
      'period': 'FCFA',
      'periodLabel': '/année',
      'maxAnnonces': '2500',
      'features': [
        'Publiez et recevez jusqu\'à 2500 annonces par année',
        'Appels d\'offres par Email + SMS + WhatsApp',
        'Support prioritaire (réponse rapide)',
        'Utilisateurs illimités',
        'Pour les PME & grandes structures',
        'Conserver les annonces en ligne pendant 365 jours',
      ],
      'badge': null,
      'isPopular': false,
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
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    final isSelected = selectedPlanIndex == index;
                    final isPopular = plan['isPopular'] == true;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPlanIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
                        decoration: BoxDecoration(
                          color: isPopular ? const Color(0xFF4CAF50) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected 
                                ? (isPopular ? Colors.white : const Color(0xFF4CAF50))
                                : (isPopular ? Colors.white.withOpacity(0.3) : Colors.grey[300]!),
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isPopular 
                                  ? const Color(0xFF4CAF50).withOpacity(0.3)
                                  : Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badge PLUS POPULAIRE
                            if (plan['badge'] != null)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFA726),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.star, color: Colors.white, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      plan['badge'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Titre
                                  Text(
                                    plan['title'],
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: isPopular ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Prix
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        plan['price'],
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: isPopular ? Colors.white : const Color(0xFF4CAF50),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              plan['period'],
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isPopular ? Colors.white.withOpacity(0.9) : Colors.grey[600],
                                              ),
                                            ),
                                            Text(
                                              plan['periodLabel'],
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isPopular ? Colors.white.withOpacity(0.9) : Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Features
                                  ...List<Widget>.from(
                                    (plan['features'] as List<String>).map((feature) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: isPopular ? Colors.white : const Color(0xFF4CAF50),
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                feature,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: isPopular ? Colors.white.withOpacity(0.95) : Colors.grey[700],
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
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
    );
  }
}
