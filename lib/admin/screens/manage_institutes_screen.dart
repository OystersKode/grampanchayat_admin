import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/institute_model.dart';
import '../services/institute_service.dart';
import '../widgets/admin_drawer.dart';

class ManageInstitutesScreen extends StatefulWidget {
  const ManageInstitutesScreen({super.key});

  @override
  State<ManageInstitutesScreen> createState() => _ManageInstitutesScreenState();
}

class _ManageInstitutesScreenState extends State<ManageInstitutesScreen> {
  final InstituteService _instituteService = InstituteService();
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  
  bool _isUploading = false;
  File? _selectedImage;
  String? _existingImageUrl;

  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _showInstituteDialog({Institute? institute}) {
    if (institute != null) {
      _nameController.text = institute.name;
      _contactController.text = institute.contactNumber;
      _emailController.text = institute.email;
      _websiteController.text = institute.website;
      _existingImageUrl = institute.imageUrl;
      _selectedImage = null;
    } else {
      _nameController.clear();
      _contactController.clear();
      _emailController.clear();
      _websiteController.clear();
      _existingImageUrl = null;
      _selectedImage = null;
    }

    showDialog(
      context: context,
      barrierDismissible: !_isUploading,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(institute == null ? 'Add Institute' : 'Edit Institute'),
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
                                    Text('Select Institute Image', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Institute Name'),
                    validator: (value) => value!.isEmpty ? 'Enter name' : null,
                  ),
                  TextFormField(
                    controller: _contactController,
                    decoration: const InputDecoration(labelText: 'Contact Number'),
                    keyboardType: TextInputType.phone,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email Address'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextFormField(
                    controller: _websiteController,
                    decoration: const InputDecoration(labelText: 'Website URL'),
                    keyboardType: TextInputType.url,
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
                  setDialogState(() => _isUploading = true);
                  setState(() => _isUploading = true);

                  try {
                    String imageUrl = _existingImageUrl ?? '';
                    if (_selectedImage != null) {
                      imageUrl = await _instituteService.uploadImage(_selectedImage!.path);
                    }

                    final newInstitute = Institute(
                      id: institute?.id ?? '',
                      name: _nameController.text,
                      imageUrl: imageUrl,
                      contactNumber: _contactController.text,
                      email: _emailController.text,
                      website: _websiteController.text,
                    );

                    if (institute == null) {
                      await _instituteService.addInstitute(newInstitute);
                    } else {
                      await _instituteService.updateInstitute(newInstitute);
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
        title: const Text('Manage Schools & Colleges'),
        backgroundColor: backgroundColor,
        foregroundColor: primaryMaroon,
        elevation: 0,
      ),
      body: StreamBuilder<List<Institute>>(
        stream: _instituteService.getInstitutes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final institutes = snapshot.data ?? [];

          if (institutes.isEmpty) {
            return const Center(child: Text('No institutes found. Click + to add.'));
          }

          return ListView.builder(
            itemCount: institutes.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final institute = institutes[index];
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
                    child: institute.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(institute.imageUrl, fit: BoxFit.cover),
                          )
                        : const Icon(Icons.school, color: primaryMaroon),
                  ),
                  title: Text(institute.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (institute.contactNumber.isNotEmpty)
                        Row(children: [const Icon(Icons.phone, size: 14), const SizedBox(width: 4), Text(institute.contactNumber)]),
                      if (institute.email.isNotEmpty)
                        Row(children: [const Icon(Icons.email, size: 14), const SizedBox(width: 4), Text(institute.email)]),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showInstituteDialog(institute: institute),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Institute'),
                              content: const Text('Are you sure you want to delete this institute?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await _instituteService.deleteInstitute(institute.id);
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
        onPressed: () => _showInstituteDialog(),
        backgroundColor: primaryMaroon,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
