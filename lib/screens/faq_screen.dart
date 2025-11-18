import 'package:flutter/material.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  int? _expandedIndex;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'Comment créer un compte sur SenOffre ?',
      'answer': 'Pour créer un compte, cliquez sur "S\'inscrire" sur la page d\'accueil. Remplissez le formulaire avec vos informations personnelles (nom, email, mot de passe) et validez. Vous recevrez un email de confirmation.',
    },
    {
      'question': 'Comment postuler à une offre d\'emploi ?',
      'answer': 'Pour postuler à une offre, consultez les détails de l\'offre qui vous intéresse, puis cliquez sur le bouton "Postuler". Vous devrez sélectionner ou télécharger votre CV, puis rédiger un message de motivation (minimum 20 caractères).',
    },
    {
      'question': 'Quels formats de CV sont acceptés ?',
      'answer': 'Nous acceptons les formats suivants : PDF, DOC, DOCX, JPG et PNG. La taille maximale du fichier est de 5 MB. Assurez-vous que votre CV est à jour et bien structuré.',
    },
    {
      'question': 'Comment modifier mon profil ?',
      'answer': 'Allez dans l\'onglet "Profil", puis cliquez sur "Modifier Profil". Vous pourrez modifier votre nom, email, numéro de téléphone et pays. N\'oubliez pas de sauvegarder vos modifications.',
    },
    {
      'question': 'Comment consulter l\'historique de mes candidatures ?',
      'answer': 'Dans l\'onglet "Profil", sélectionnez l\'onglet "Historique". Vous y trouverez la liste de toutes vos candidatures avec les détails des postes auxquels vous avez postulé et vos messages de motivation.',
    },
    {
      'question': 'Comment filtrer les offres d\'emploi ?',
      'answer': 'Sur la page d\'accueil ou la page des offres, utilisez les filtres disponibles : Type d\'offre (CDI, CDD, Stage, etc.), Localisation (ville) et Catégorie. Cliquez sur les chips pour ouvrir les options de filtrage.',
    },
    {
      'question': 'Comment ajouter une offre aux favoris ?',
      'answer': 'Sur chaque carte d\'offre, cliquez sur l\'icône cœur en haut à droite. L\'offre sera ajoutée à vos favoris et vous pourrez la retrouver facilement dans l\'onglet "Favoris".',
    },
    {
      'question': 'Puis-je postuler plusieurs fois à la même offre ?',
      'answer': 'Non, vous ne pouvez postuler qu\'une seule fois à chaque offre. Assurez-vous que votre candidature est complète avant de l\'envoyer.',
    },
    {
      'question': 'Comment contacter une entreprise directement ?',
      'answer': 'Dans les détails d\'une offre, vous trouverez les informations de contact de l\'entreprise (email, téléphone, site web). Vous pouvez les contacter directement via ces moyens.',
    },
    {
      'question': 'Que faire si j\'ai oublié mon mot de passe ?',
      'answer': 'Sur la page de connexion, cliquez sur "Mot de passe oublié ?". Entrez votre adresse email et vous recevrez un lien pour réinitialiser votre mot de passe.',
    },
    {
      'question': 'Les offres sont-elles vérifiées ?',
      'answer': 'Oui, toutes les offres publiées sur SenOffre sont vérifiées par notre équipe avant d\'être mises en ligne. Nous nous assurons de la légitimité des entreprises et des postes proposés.',
    },
    {
      'question': 'Comment supprimer mon compte ?',
      'answer': 'Pour supprimer votre compte, contactez notre support à l\'adresse support@senoffre.sn avec votre demande. Nous traiterons votre demande dans les plus brefs délais.',
    },
    {
      'question': 'L\'application est-elle gratuite ?',
      'answer': 'Oui, SenOffre est entièrement gratuit pour les chercheurs d\'emploi. Vous pouvez consulter les offres, postuler et gérer vos candidatures sans aucun frais.',
    },
    {
      'question': 'Comment recevoir des notifications pour les nouvelles offres ?',
      'answer': 'Allez dans "Profil" > "Notifications" pour activer les notifications push. Vous serez alerté dès qu\'une nouvelle offre correspondant à vos critères est publiée.',
    },
    {
      'question': 'Puis-je partager une offre avec un ami ?',
      'answer': 'Oui, dans les détails d\'une offre, cliquez sur le bouton "Partager". Vous pourrez partager l\'offre via WhatsApp, email, SMS ou d\'autres applications.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        title: const Text(
          'FAQ & Support',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Header avec icône
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.help_outline,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Questions Fréquentes',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Trouvez rapidement des réponses à vos questions',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Liste des FAQ
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _faqs.length,
              itemBuilder: (context, index) {
                final faq = _faqs[index];
                final isExpanded = _expandedIndex == index;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isExpanded 
                          ? const Color(0xFF4CAF50) 
                          : Colors.grey[300]!,
                      width: isExpanded ? 2 : 1,
                    ),
                    boxShadow: isExpanded
                        ? [
                            BoxShadow(
                              color: const Color(0xFF4CAF50).withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isExpanded
                              ? const Color(0xFF4CAF50)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isExpanded ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        faq['question']!,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isExpanded 
                              ? const Color(0xFF4CAF50) 
                              : Colors.black87,
                        ),
                      ),
                      trailing: Icon(
                        isExpanded 
                            ? Icons.remove_circle_outline 
                            : Icons.add_circle_outline,
                        color: isExpanded 
                            ? const Color(0xFF4CAF50) 
                            : Colors.grey[600],
                      ),
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _expandedIndex = expanded ? index : null;
                        });
                      },
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            faq['answer']!,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Footer avec contact support
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Vous ne trouvez pas votre réponse ?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildContactButton(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      onTap: () {
                        // TODO: Ouvrir l'email
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('support@senoffre.sn'),
                            backgroundColor: Color(0xFF4CAF50),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildContactButton(
                      icon: Icons.phone_outlined,
                      label: 'Appeler',
                      onTap: () {
                        // TODO: Ouvrir le téléphone
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('+221 77 123 45 67'),
                            backgroundColor: Color(0xFF4CAF50),
                          ),
                        );
                      },
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

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
