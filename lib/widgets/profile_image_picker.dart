import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileImagePicker extends StatefulWidget {
  final String? imageUrl;
  final Function(XFile) onImageSelected;
  final double size;
  final bool showEditButton;
  final String? userIdentifier; // Für eindeutige Standard-Avatare

  const ProfileImagePicker({
    super.key,
    this.imageUrl,
    required this.onImageSelected,
    this.size = 120,
    this.showEditButton = true,
    this.userIdentifier,
  });

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        widget.onImageSelected(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Auswählen des Bildes: $e'),
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

  Future<void> _takePhoto() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        widget.onImageSelected(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Aufnehmen des Bildes: $e'),
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

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Profilbild auswählen',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color.fromARGB(255, 26, 169, 48),
              ),
              title: const Text('Aus Galerie auswählen'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: Color.fromARGB(255, 26, 169, 48),
              ),
              title: const Text('Foto aufnehmen'),
              onTap: () {
                Navigator.of(context).pop();
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Profile Image
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[300]!, width: 2),
          ),
          child: ClipOval(child: _buildImage()),
        ),

        // Edit Button
        if (widget.showEditButton)
          GestureDetector(
            onTap: _isLoading ? null : _showImageSourceDialog,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 26, 169, 48),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.camera_alt, color: Colors.white, size: 18),
            ),
          ),
      ],
    );
  }

  Widget _buildImage() {
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      // Prüfe ob es ein Base64-Image ist
      if (widget.imageUrl!.startsWith('data:image/')) {
        return ClipOval(
          child: Image.memory(
            _decodeBase64Image(widget.imageUrl!),
            fit: BoxFit.cover,
            width: widget.size,
            height: widget.size,
          ),
        );
      } else {
        // Normale URL für Firebase Storage oder andere Services
        return CachedNetworkImage(
          imageUrl: widget.imageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => _buildDefaultAvatar(),
        );
      }
    } else {
      return _buildDefaultAvatar();
    }
  }

  /// Decodiert Base64-Image-String zurück zu Bytes
  Uint8List _decodeBase64Image(String base64String) {
    // Entferne "data:image/jpeg;base64," Präfix
    final commaIndex = base64String.indexOf(',');
    final base64Data = commaIndex != -1
        ? base64String.substring(commaIndex + 1)
        : base64String;

    return base64Decode(base64Data);
  }

  Widget _buildDefaultAvatar() {
    // Generiere eindeutige Farbe basierend auf Benutzer-ID
    final colors = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.purple.shade400,
      Colors.orange.shade400,
      Colors.pink.shade400,
      Colors.teal.shade400,
      Colors.indigo.shade400,
      Colors.amber.shade400,
      Colors.cyan.shade400,
      Colors.lime.shade400,
      Colors.red.shade400,
      Colors.brown.shade400,
    ];

    // Verwende Benutzer-ID oder Standardwert
    final userId = widget.userIdentifier ?? 'default';
    final hash = userId.hashCode.abs();
    final colorIndex = hash % colors.length;
    final selectedColor = colors[colorIndex];

    // Verschiedene Icons für mehr Abwechslung
    final icons = [
      Icons.person,
      Icons.account_circle,
      Icons.person_outline,
      Icons.face,
      Icons.manage_accounts,
      Icons.badge,
    ];

    final iconIndex = hash % icons.length;
    final selectedIcon = icons[iconIndex];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [selectedColor, selectedColor.withOpacity(0.8)],
        ),
      ),
      child: Icon(selectedIcon, size: widget.size * 0.6, color: Colors.white),
    );
  }
}
