import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isLoading = false;
  String _selectedCountry = 'SN'; // Par défaut Sénégal
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _hasChanges = false; // Pour suivre si des modifications ont été faites

  // Liste des pays disponibles
  final Map<String, String> _countries = {
    'SN': '🇸🇳 Sénégal (+221)',
    'FR': '🇫🇷 France (+33)',
    'CI': '🇨🇮 Côte d\'Ivoire (+225)',
    'ML': '🇲🇱 Mali (+223)',
    'BF': '🇧🇫 Burkina Faso (+226)',
    'BJ': '🇧🇯 Bénin (+229)',
    'TG': '🇹🇬 Togo (+228)',
    'NE': '🇳🇪 Niger (+227)',
    'GN': '🇬🇳 Guinée (+224)',
    'MR': '🇲🇷 Mauritanie (+222)',
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: UserService.userName);
    _emailController = TextEditingController(text: UserService.userEmail);
    _phoneController = TextEditingController(text: UserService.userPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      // Afficher un dialog pour choisir entre caméra et galerie
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Choisir une source'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Color(0xFF4CAF50)),
                  title: const Text('Caméra'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Color(0xFF4CAF50)),
                  title: const Text('Galerie'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          );
        },
      );

      if (source != null) {
        // Demander les permissions
        bool permissionGranted = false;
        
        if (source == ImageSource.camera) {
          final status = await Permission.camera.request();
          permissionGranted = status.isGranted;
          
          if (status.isPermanentlyDenied) {
            if (mounted) {
              _showPermissionDialog('Caméra');
            }
            return;
          }
        } else {
          // Pour la galerie, demander la permission photos
          PermissionStatus status;
          if (Platform.isAndroid) {
            // Android 13+ utilise photos, versions antérieures utilisent storage
            if (await Permission.photos.isGranted) {
              permissionGranted = true;
            } else {
              status = await Permission.photos.request();
              if (status.isDenied) {
                status = await Permission.storage.request();
              }
              permissionGranted = status.isGranted;
            }
          } else {
            status = await Permission.photos.request();
            permissionGranted = status.isGranted;
          }
          
          if (!permissionGranted && mounted) {
            _showPermissionDialog('Galerie');
            return;
          }
        }
        
        if (!permissionGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permission refusée'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        final XFile? image = await _picker.pickImage(
          source: source,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 85,
        );

        if (image != null) {
          setState(() {
            _selectedImage = File(image.path);
          });

          // Upload immédiatement la photo
          await _uploadPhoto();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de l\'image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPermissionDialog(String permissionName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission requise'),
          content: Text(
            'L\'accès à $permissionName est nécessaire pour cette fonctionnalité. '
            'Veuillez activer la permission dans les paramètres de l\'application.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text('Paramètres'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadPhoto() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await UserService.uploadProfilePhoto(_selectedImage!);

      if (mounted) {
        setState(() {
          _hasChanges = true; // Marquer qu'il y a eu des modifications
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo de profil mise à jour avec succès !'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'upload: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Nettoyer le numéro de téléphone (enlever espaces, tirets, parenthèses)
      String cleanPhone = _phoneController.text.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
      
      // Si le numéro commence par +, on l'enlève car l'API gère l'indicatif séparément
      if (cleanPhone.startsWith('+')) {
        cleanPhone = cleanPhone.substring(1);
        // Si c'est un numéro sénégalais avec +221, enlever le 221
        if (cleanPhone.startsWith('221') && _selectedCountry == 'SN') {
          cleanPhone = cleanPhone.substring(3);
        }
      }
      
      await UserService.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: cleanPhone.isEmpty ? null : cleanPhone,
        phoneCountry: _selectedCountry,
      );

      if (mounted) {
        setState(() {
          _hasChanges = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès !'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        Navigator.pop(context, true); // Retourner true pour indiquer la mise à jour
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        title: const Text(
          'Modifier le profil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, _hasChanges),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF4CAF50),
                          width: 3,
                        ),
                        image: _selectedImage != null
                            ? DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              )
                            : (UserService.userPhotoUrl.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(UserService.userPhotoUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null),
                      ),
                      child: (_selectedImage == null && UserService.userPhotoUrl.isEmpty)
                          ? Center(
                              child: Text(
                                UserService.userName.isNotEmpty
                                    ? UserService.userName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Nom
            const Text(
              'Nom complet',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Entrez votre nom',
                prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF4CAF50)),
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
                  borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            // Email
            const Text(
              'Email',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Entrez votre email',
                prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF4CAF50)),
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
                  borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'L\'email est requis';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Email invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            // Pays
            const Text(
              'Pays',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.flag, color: Color(0xFF4CAF50)),
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
                  borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: _countries.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCountry = value;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            
            // Téléphone
            const Text(
              'Téléphone',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Ex: 771234567 ou +221771234567',
                helperText: 'Format: 9 chiffres ou avec indicatif (+221...)',
                helperStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
                prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF4CAF50)),
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
                  borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return null; // Le téléphone est optionnel
                }
                
                // Nettoyer le numéro (enlever espaces, tirets, etc.)
                final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
                
                // Vérifier le format
                // Accepter: +221XXXXXXXXX (12-13 chiffres) ou XXXXXXXXX (9 chiffres)
                if (!RegExp(r'^\+?\d{9,13}$').hasMatch(cleanPhone)) {
                  return 'Format invalide. Ex: 771234567 ou +221771234567';
                }
                
                return null;
              },
            ),
            const SizedBox(height: 32),
            
            // Bouton Enregistrer
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Enregistrer les modifications',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
