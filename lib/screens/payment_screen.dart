import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/wave_payment_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentScreen extends StatefulWidget {
  final bool isAnnual;
  final String planTitle;
  final String price;
  final String period;

  const PaymentScreen({
    super.key,
    required this.isAnnual,
    required this.planTitle,
    required this.price,
    required this.period,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPaymentMethod = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Moyen de paiement',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Résumé de la commande
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Icône de l'abonnement
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              widget.isAnnual 
                                  ? 'assets/images/subscription_12_months.png'
                                  : 'assets/images/subscription_1_month.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback si l'image n'est pas trouvée
                                return Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.isAnnual ? '12' : '1',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Mois',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Résumé de la commande',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.planTitle,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Quantité : 1',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Montant total
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Montant total',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${widget.price} Fcfa',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Cartes de crédit et de débit
                  const Text(
                    'Cartes de crédit et de débit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildPaymentOption(
                          icon: Icons.credit_card,
                          title: 'Afrika Bank',
                          subtitle: '**** **** **** 6246',
                          value: 'visa',
                          iconColor: Colors.blue,
                        ),
                        const Divider(height: 1),
                        _buildAddCardOption(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Mobile Money
                  const Text(
                    'Mobile Money',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildPaymentOptionWithLogo(
                          logoPath: 'assets/images/wave_logo.png',
                          title: 'Wave',
                          subtitle: '',
                          value: 'wave',
                          fallbackIcon: Icons.waves,
                          fallbackColor: Colors.blue,
                        ),
                        const Divider(height: 1),
                        _buildPaymentOptionWithLogo(
                          logoPath: 'assets/images/orange_money_logo.png',
                          title: 'Orange Money',
                          subtitle: '',
                          value: 'orange',
                          fallbackIcon: Icons.phone_android,
                          fallbackColor: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom section avec prix et bouton
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.price} Fcfa',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Afficher la facture détaillée
                          },
                          child: const Text(
                            'Voir facture détaillée',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: selectedPaymentMethod.isNotEmpty
                          ? () {
                              // Traiter le paiement
                              _processPayment();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Payer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required Color iconColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            )
          : null,
      trailing: Radio<String>(
        value: value,
        groupValue: selectedPaymentMethod,
        onChanged: (String? newValue) {
          setState(() {
            selectedPaymentMethod = newValue ?? '';
          });
        },
        activeColor: const Color(0xFF4CAF50),
      ),
      onTap: () {
        setState(() {
          selectedPaymentMethod = value;
        });
      },
    );
  }

  Widget _buildPaymentOptionWithLogo({
    required String logoPath,
    required String title,
    required String subtitle,
    required String value,
    required IconData fallbackIcon,
    required Color fallbackColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            logoPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback vers l'icône si l'image n'est pas trouvée
              return Container(
                decoration: BoxDecoration(
                  color: fallbackColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  fallbackIcon,
                  color: fallbackColor,
                  size: 24,
                ),
              );
            },
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            )
          : null,
      trailing: Radio<String>(
        value: value,
        groupValue: selectedPaymentMethod,
        onChanged: (String? newValue) {
          setState(() {
            selectedPaymentMethod = newValue ?? '';
          });
        },
        activeColor: const Color(0xFF4CAF50),
      ),
      onTap: () {
        setState(() {
          selectedPaymentMethod = value;
        });
      },
    );
  }

  Widget _buildAddCardOption() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.green,
          size: 24,
        ),
      ),
      title: const Text(
        'Ajouter une nouvelle carte',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.green,
        ),
      ),
      onTap: () {
        _showAddCardDialog();
      },
    );
  }

  void _showAddCardDialog() {
    final TextEditingController cardNumberController = TextEditingController();
    final TextEditingController cardHolderController = TextEditingController();
    final TextEditingController cvvController = TextEditingController();
    String selectedMonth = 'Mois';
    String selectedYear = 'Année';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header avec titre et bouton fermer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ajouter une carte',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.black54,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Numéro de carte
                    const Text(
                      'Numéro de carte',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: cardNumberController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Entrez le numéro à 12 chiffres',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Date d'expiration et CVV
                    Row(
                      children: [
                        // Valable jusqu'à fin
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Valable jusqu\'à fin',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  // Mois
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: selectedMonth,
                                          hint: const Text('Mois'),
                                          isExpanded: true,
                                          items: ['Mois', '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12']
                                              .map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setDialogState(() {
                                              selectedMonth = newValue!;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Année
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: selectedYear,
                                          hint: const Text('Année'),
                                          isExpanded: true,
                                          items: ['Année', '2024', '2025', '2026', '2027', '2028', '2029', '2030']
                                              .map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setDialogState(() {
                                              selectedYear = newValue!;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // CVV
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CVV',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: cvvController,
                                keyboardType: TextInputType.number,
                                maxLength: 3,
                                decoration: InputDecoration(
                                  hintText: 'CVV',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  counterText: '',
                                  suffixIcon: const Icon(
                                    Icons.help_outline,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Nom du titulaire
                    const Text(
                      'Nom du titulaire de la carte',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: cardHolderController,
                      decoration: InputDecoration(
                        hintText: 'Nom sur la carte',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Bouton Enregistrer
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Enregistrer la carte
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Carte ajoutée avec succès'),
                              backgroundColor: Color(0xFF4CAF50),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Enregistrer la carte',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _processPayment() async {
    if (selectedPaymentMethod.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un moyen de paiement'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Afficher le dialog de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Initialisation du paiement...'),
          ],
        ),
      ),
    );

    try {
      if (selectedPaymentMethod == 'wave') {
        await _processWavePayment();
      } else if (selectedPaymentMethod == 'orange') {
        await _processOrangeMoneyPayment();
      } else {
        await _processCreditCardPayment();
      }
    } catch (e) {
      Navigator.of(context).pop(); // Fermer le dialog de chargement
      _showErrorDialog('Erreur lors du paiement: $e');
    }
  }

  Future<void> _processWavePayment() async {
    // Générer une référence unique
    final reference = 'SENOFFRE_${DateTime.now().millisecondsSinceEpoch}';
    final amount = double.parse(widget.price.replaceAll(',', ''));
    final description = 'Paiement ${widget.planTitle} - SenOffre';

    final result = await WavePaymentService.initiatePayment(
      amount: amount,
      reference: reference,
      description: description,
    );

    Navigator.of(context).pop(); // Fermer le dialog de chargement

    if (result['success']) {
      final data = result['data'];
      if (data['success'] == true) {
        final waveUrl = data['data']['wave_launch_url'];
        final checkoutId = data['data']['checkout_id'];
        
        // Ouvrir l'URL Wave
        if (await canLaunchUrl(Uri.parse(waveUrl))) {
          await launchUrl(
            Uri.parse(waveUrl),
            mode: LaunchMode.externalApplication,
          );
          
          // Surveiller le statut du paiement
          _monitorPaymentStatus(checkoutId);
        } else {
          _showErrorDialog('Impossible d\'ouvrir l\'application Wave');
        }
      } else {
        _showErrorDialog(data['message'] ?? 'Erreur lors de l\'initialisation du paiement Wave');
      }
    } else {
      _showErrorDialog(result['error']);
    }
  }

  Future<void> _processOrangeMoneyPayment() async {
    // TODO: Implémenter Orange Money
    _showErrorDialog('Orange Money sera bientôt disponible');
  }

  Future<void> _processCreditCardPayment() async {
    // TODO: Implémenter le paiement par carte
    _showErrorDialog('Paiement par carte sera bientôt disponible');
  }

  void _monitorPaymentStatus(String checkoutId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Paiement en cours'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Veuillez compléter le paiement dans l\'application Wave'),
            SizedBox(height: 8),
            Text(
              'Cette fenêtre se fermera automatiquement une fois le paiement confirmé.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Retour à l'écran précédent
            },
            child: const Text('Annuler'),
          ),
        ],
      ),
    );

    // Vérifier le statut toutes les 3 secondes
    _checkPaymentStatusPeriodically(checkoutId);
  }

  void _checkPaymentStatusPeriodically(String checkoutId) async {
    int attempts = 0;
    const maxAttempts = 40; // 2 minutes maximum (40 * 3 secondes)

    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 3));
      attempts++;

      try {
        final result = await WavePaymentService.checkPaymentStatus(
          checkoutId: checkoutId,
        );

        if (result['success']) {
          final status = result['data']['status'];
          
          if (status == 'completed') {
            Navigator.of(context).pop(); // Fermer le dialog de monitoring
            _showSuccessDialog();
            return;
          } else if (status == 'failed' || status == 'cancelled') {
            Navigator.of(context).pop(); // Fermer le dialog de monitoring
            _showErrorDialog('Le paiement a été annulé ou a échoué');
            return;
          }
        }
      } catch (e) {
        // Continuer à vérifier même en cas d'erreur
        print('Erreur lors de la vérification du statut: $e');
      }
    }

    // Timeout atteint
    Navigator.of(context).pop(); // Fermer le dialog de monitoring
    _showErrorDialog('Délai d\'attente dépassé. Veuillez vérifier votre paiement.');
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Paiement réussi'),
          ],
        ),
        content: Text('Votre abonnement ${widget.planTitle} a été activé avec succès !'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fermer le dialog
              Navigator.of(context).pop(); // Retour à l'écran précédent
            },
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Erreur'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
