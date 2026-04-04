import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown_quill/markdown_quill.dart';
import '../services/wishes_service.dart';
import '../services/news_service.dart';
import '../widgets/admin_drawer.dart';

class CreateWishesScreen extends StatefulWidget {
  const CreateWishesScreen({super.key});

  @override
  State<CreateWishesScreen> createState() => _CreateWishesScreenState();
}

class _CreateWishesScreenState extends State<CreateWishesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final QuillController _controller = QuillController.basic();
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  bool _showPreview = false;
  String? _editingId;
  List<Map<String, dynamic>> _allWishes = [];
  List<Map<String, dynamic>> _filteredWishes = [];

  @override
  void initState() {
    super.initState();
    _fetchWishes();
  }

  Future<void> _fetchWishes() async {
    try {
      final wishes = await WishesService.instance.fetchWishes();
      setState(() {
        _allWishes = wishes;
        _filteredWishes = wishes;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load wishes: $e')),
        );
      }
    }
  }

  void _filterWishes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredWishes = _allWishes;
      } else {
        _filteredWishes = _allWishes
            .where((wish) => (wish['title'] ?? '').toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _editWish(Map<String, dynamic> wish) {
    setState(() {
      _editingId = wish['id'].toString();
      _titleController.text = wish['title'] ?? '';
      _tagController.text = wish['tag'] ?? '';
      _selectedImage = null;
      final String content = wish['content'] ?? '';
      _controller.document = Document()..insert(0, content);
    });
  }

  Future<void> _deleteWish(String id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this wish?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await WishesService.instance.deleteWish(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Wish deleted successfully')),
          );
          _fetchWishes();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
        }
      }
    }
  }

  Future<void> _submitWish() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_controller.document.isEmpty()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description')),
      );
      return;
    }

    final mdEncoder = DeltaToMarkdown();
    final String markdownContent = mdEncoder.convert(_controller.document.toDelta());

    setState(() {
      _isSubmitting = true;
    });

    try {
      String imageUrl = '';
      if (_selectedImage != null) {
        final List<int> bytes = await _selectedImage!.readAsBytes();
        final String mimeType = _guessMimeType(_selectedImage!.name);
        final String base64Image = base64Encode(bytes);
        final String dataUri = 'data:$mimeType;base64,$base64Image';
        imageUrl = await NewsService.instance.uploadImageBase64(dataUri);
      }

      if (_editingId != null) {
        await WishesService.instance.updateWish(
          id: _editingId!,
          title: _titleController.text.trim(),
          content: markdownContent,
          headerImageUrl: imageUrl,
          tag: _tagController.text.trim(),
        );
      } else {
        await WishesService.instance.createWish(
          title: _titleController.text.trim(),
          content: markdownContent,
          headerImageUrl: imageUrl,
          tag: _tagController.text.trim(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_editingId != null ? 'Wish updated successfully!' : 'Wish created successfully!')),
        );
        _clearForm();
        _fetchWishes();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save wish: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _clearForm() {
    _titleController.clear();
    _tagController.clear();
    _controller.clear();
    setState(() {
      _selectedImage = null;
      _editingId = null;
    });
  }

  String _guessMimeType(String fileName) {
    final String lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagController.dispose();
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryMaroon = Color(0xFF8B0000);
    const Color backgroundColor = Color(0xFFFFF8F7);
    const Color borderColor = Color(0xFF8B0000);

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: const AdminDrawer(),
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Create Wishes',
          style: TextStyle(
            color: primaryMaroon,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: primaryMaroon),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'WISHES & EVENTS DETAILS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: Color(0xFFB09491),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        _buildLabel('Title'),
                        TextFormField(
                          controller: _titleController,
                          decoration: _buildInputDecoration('Enter event or wish title'),
                          validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
                        ),
                        const SizedBox(height: 24),

                        _buildLabel('Tag'),
                        TextFormField(
                          controller: _tagController,
                          decoration: _buildInputDecoration('e.g. Birthday, Achievement, Festival'),
                        ),
                        const SizedBox(height: 24),

                        _buildLabel('Upload Image'),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE3BEB8)),
                            ),
                            child: _selectedImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: kIsWeb
                                        ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                                        : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_outlined, size: 48, color: primaryMaroon.withOpacity(0.5)),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Tap to upload image',
                                        style: TextStyle(color: Color(0xFF8E706B), fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        _buildLabel('Description'),
                        Row(
                          children: [
                            ChoiceChip(
                              label: const Text('Edit'),
                              selected: !_showPreview,
                              onSelected: (val) => setState(() => _showPreview = false),
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('Preview'),
                              selected: _showPreview,
                              onSelected: (val) => setState(() => _showPreview = true),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_showPreview)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor, width: 1.5),
                            ),
                            child: MarkdownBody(
                              data: DeltaToMarkdown().convert(_controller.document.toDelta()),
                              selectable: true,
                            ),
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor, width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                QuillSimpleToolbar(
                                  controller: _controller,
                                  config: const QuillSimpleToolbarConfig(
                                    showFontFamily: false,
                                    showFontSize: false,
                                    showColorButton: false,
                                    showBackgroundColorButton: false,
                                    showListBullets: true,
                                    showListNumbers: true,
                                    showQuote: true,
                                    showIndent: false,
                                    showLink: true,
                                    showSearchButton: false,
                                    showSubscript: false,
                                    showSuperscript: false,
                                    showHeaderStyle: true,
                                    showBoldButton: true,
                                    showItalicButton: true,
                                    showUnderLineButton: true,
                                    showStrikeThrough: false,
                                    showInlineCode: true,
                                    showCodeBlock: true,
                                    showAlignmentButtons: false,
                                    showDirection: false,
                                    multiRowsDisplay: false,
                                  ),
                                ),
                                const Divider(height: 1, color: borderColor),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  constraints: const BoxConstraints(minHeight: 150),
                                  child: QuillEditor.basic(
                                    controller: _controller,
                                    config: const QuillEditorConfig(
                                      placeholder: 'Enter details about the wish or event...',
                                      autoFocus: false,
                                      expands: false,
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 40),
                        const Text(
                          'RECENTLY ADDED',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: Color(0xFFB09491),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _searchController,
                          onChanged: _filterWishes,
                          decoration: _buildInputDecoration('Search wishes...').copyWith(
                            prefixIcon: const Icon(Icons.search, color: Color(0xFFB09491)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_filteredWishes.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(32),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE3BEB8)),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.auto_awesome, size: 48, color: Color(0xFFD6A2A2)),
                                SizedBox(height: 12),
                                Text(
                                  'No wishes found',
                                  style: TextStyle(color: Color(0xFF8E706B)),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filteredWishes.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final wish = _filteredWishes[index];
                              final String title = wish['title'] ?? '';
                              final String content = wish['content'] ?? '';
                              final String? imageUrl = wish['header_image_url'];
                              final String id = wish['id'].toString();

                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE3BEB8)),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: imageUrl != null && imageUrl.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            imageUrl,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              width: 60,
                                              height: 60,
                                              color: Colors.grey[200],
                                              child: const Icon(Icons.image_not_supported),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.auto_awesome, color: Colors.grey),
                                        ),
                                  title: Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                        onPressed: () => _editWish(wish),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () => _deleteWish(id),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitWish,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryMaroon,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: primaryMaroon.withOpacity(0.3),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    _editingId != null ? 'UPDATE WISH' : 'POST WISH',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF5A403C),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: const Color(0xFF5A403C).withOpacity(0.3)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE3BEB8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE3BEB8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF8B0000), width: 1.5),
      ),
    );
  }
}
