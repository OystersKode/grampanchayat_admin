import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/advertisement_model.dart';
import '../services/advertisement_service.dart';
import '../widgets/admin_drawer.dart';

class ManageAdvertisementsScreen extends StatefulWidget {
  const ManageAdvertisementsScreen({super.key});

  @override
  State<ManageAdvertisementsScreen> createState() => _ManageAdvertisementsScreenState();
}

class _ManageAdvertisementsScreenState extends State<ManageAdvertisementsScreen> {
  final AdvertisementService _adService = AdvertisementService();
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  
  bool _isUploading = false;
  File? _selectedImage;
  String? _existingImageUrl;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showAdDialog({Advertisement? ad}) {
    if (ad != null) {
      _titleController.text = ad.title;
      _descriptionController.text = ad.description;
      _existingImageUrl = ad.imageUrl;
      _selectedImage = null;
    } else {
      _titleController.clear();
      _descriptionController.clear();
      _existingImageUrl = null;
      _selectedImage = null;
    }

    showDialog(
      context: context,
      barrierDismissible: !_isUploading,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(ad == null ? 'Add Advertisement' : 'Edit Advertisement'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _isUploading ? null : () async {
                      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setDialogState(() {
                          _selectedImage = File(image.path);
                        });
                        setState(() {
                          _selectedImage = File(image.path);
                        });
                      }
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_selectedImage!, fit: BoxFit.cover),
                            )
                          : _existingImageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(_existingImageUrl!, fit: BoxFit.cover),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Select Ad Image', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Ad Title'),
                    validator: (value) => value!.isEmpty ? 'Enter title' : null,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    validator: (value) => value!.isEmpty ? 'Enter description' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isUploading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isUploading ? null : () async {
                if (_formKey.currentState!.validate()) {
                  if (_selectedImage == null && _existingImageUrl == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select an image')),
                    );
                    return;
                  }

                  setDialogState(() => _isUploading = true);
                  setState(() => _isUploading = true);

                  try {
                    String imageUrl = _existingImageUrl ?? '';
                    if (_selectedImage != null) {
                      imageUrl = await _adService.uploadImage(_selectedImage!.path);
                    }

                    final newAd = Advertisement(
                      id: ad?.id ?? '',
                      title: _titleController.text,
                      description: _descriptionController.text,
                      imageUrl: imageUrl,
                    );

                    if (ad == null) {
                      await _adService.addAdvertisement(newAd);
                    } else {
                      await _adService.updateAdvertisement(newAd);
                    }
                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setDialogState(() => _isUploading = false);
                      setState(() => _isUploading = false);
                    }
                  }
                }
              },
              child: _isUploading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryMaroon = Color(0xFF8B0000);
    const Color backgroundColor = Color(0xFFFFF8F7);

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: const AdminDrawer(),
      appBar: AppBar(
        title: const Text('Manage Advertisements'),
        backgroundColor: backgroundColor,
        foregroundColor: primaryMaroon,
        elevation: 0,
      ),
      body: StreamBuilder<List<Advertisement>>(
        stream: _adService.getAdvertisements(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final ads = snapshot.data ?? [];

          if (ads.isEmpty) {
            return const Center(child: Text('No advertisements found. Click + to add.'));
          }

          return ListView.builder(
            itemCount: ads.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final ad = ads[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ad.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(ad.imageUrl, fit: BoxFit.cover),
                          )
                        : const Icon(Icons.ad_units, color: primaryMaroon),
                  ),
                  title: Text(ad.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    ad.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showAdDialog(ad: ad),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Advertisement'),
                              content: const Text('Are you sure you want to delete this ad?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await _adService.deleteAdvertisement(ad.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAdDialog(),
        backgroundColor: primaryMaroon,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
