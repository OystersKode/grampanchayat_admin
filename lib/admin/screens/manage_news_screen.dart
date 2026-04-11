import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:markdown_quill/markdown_quill.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/news_service.dart';
import '../widgets/admin_drawer.dart';

class ManageNewsScreen extends StatefulWidget {
  const ManageNewsScreen({super.key});

  @override
  State<ManageNewsScreen> createState() => _ManageNewsScreenState();
}

class _ManageNewsScreenState extends State<ManageNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final QuillController _controller = QuillController.basic();
  
  XFile? _coverImage;
  List<XFile> _relatedImages = [];
  final ImagePicker _picker = ImagePicker();
  
  bool _isSubmitting = false;
  bool _showPreview = false;
  String? _editingId;
  DateTime? _scheduledAt;
  List<Map<String, dynamic>> _allNews = [];
  List<Map<String, dynamic>> _filteredNews = [];

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    try {
      final news = await NewsService.instance.fetchNews();
      setState(() {
        _allNews = news;
        _filteredNews = news;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load news: $e')),
        );
      }
    }
  }

  void _filterNews(String query) {
    setState(() {
      _filteredNews = _allNews.where((news) {
        final bool matchesSearch = (news['title'] ?? '').toString().toLowerCase().contains(query.toLowerCase());
        return matchesSearch;
      }).toList();
    });
  }

  void _editNews(Map<String, dynamic> news) {
    setState(() {
      _editingId = news['id'].toString();
      _titleController.text = news['title'] ?? '';
      _categoryController.text = news['category'] ?? '';
      _locationController.text = news['location'] ?? '';
      _coverImage = null;
      _relatedImages = [];
      _scheduledAt = news['scheduled_at'] != null ? (news['scheduled_at'] as Timestamp).toDate() : null;
      final String content = news['content'] ?? '';
      _controller.document = Document()..insert(0, content);
    });
  }

  Future<void> _pickCoverImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _coverImage = pickedFile;
      });
    }
  }

  Future<void> _pickRelatedImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _relatedImages.addAll(pickedFiles);
      });
    }
  }

  Future<void> _deleteNews(String id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this news item?'),
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
        await NewsService.instance.deleteNews(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('News deleted successfully')),
          );
          _fetchNews();
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

  Future<void> _submitNews() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      String? coverImageUrl;
      if (_coverImage != null) {
        coverImageUrl = await NewsService.instance.uploadImage(_coverImage!.path);
      }

      List<String> relatedImageUrls = [];
      for (var file in _relatedImages) {
        final url = await NewsService.instance.uploadImage(file.path);
        relatedImageUrls.add(url);
      }

      final mdEncoder = DeltaToMarkdown();
      final String markdownContent = mdEncoder.convert(_controller.document.toDelta());

      if (_editingId != null) {
        await NewsService.instance.updateNews(
          id: _editingId!,
          title: _titleController.text.trim(),
          content: markdownContent,
          category: _categoryController.text.trim(),
          location: _locationController.text.trim(),
          coverImageUrl: coverImageUrl,
          relatedImages: relatedImageUrls.isNotEmpty ? relatedImageUrls : null,
          scheduledAt: _scheduledAt,
        );
      } else {
        await NewsService.instance.createNews(
          title: _titleController.text.trim(),
          content: markdownContent,
          category: _categoryController.text.trim(),
          location: _locationController.text.trim(),
          coverImageUrl: coverImageUrl,
          relatedImages: relatedImageUrls,
          scheduledAt: _scheduledAt,
        );
      }

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_editingId != null ? 'News updated successfully!' : 'News created successfully!')),
      );
      _clearForm();
      _fetchNews();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save news: $error')),
      );
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
    _categoryController.clear();
    _locationController.clear();
    _controller.clear();
    setState(() {
      _editingId = null;
      _coverImage = null;
      _relatedImages = [];
      _scheduledAt = null;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
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
        title: const Text(
          'Manage News',
          style: TextStyle(color: primaryMaroon, fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: primaryMaroon),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'POST NEW NEWS',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFB09491)),
                    ),
                    const SizedBox(height: 24),
                    _buildLabel('Title'),
                    TextFormField(
                      controller: _titleController,
                      decoration: _buildInputDecoration('Enter news title'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Category'),
                    TextFormField(
                      controller: _categoryController,
                      decoration: _buildInputDecoration('e.g. Health, Agriculture, General'),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Location'),
                    TextFormField(
                      controller: _locationController,
                      decoration: _buildInputDecoration('Enter location (e.g. Village Name, Ward No)'),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildLabel('Cover Image'),
                    GestureDetector(
                      onTap: _pickCoverImage,
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE3BEB8)),
                        ),
                        child: _coverImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: kIsWeb
                                    ? Image.network(_coverImage!.path, fit: BoxFit.cover)
                                    : Image.file(File(_coverImage!.path), fit: BoxFit.cover),
                              )
                            : const Icon(Icons.add_a_photo, color: primaryMaroon, size: 40),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Related Images'),
                    ElevatedButton.icon(
                      onPressed: _pickRelatedImages,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Add Related Images'),
                    ),
                    if (_relatedImages.isNotEmpty)
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _relatedImages.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.file(File(_relatedImages[index].path), width: 80, height: 80, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    
                    _buildLabel('Schedule News (Optional)'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE3BEB8)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _scheduledAt == null
                                  ? 'Post immediately'
                                  : 'Scheduled for: ${_scheduledAt!.day}/${_scheduledAt!.month}/${_scheduledAt!.year} ${_scheduledAt!.hour}:${_scheduledAt!.minute}',
                              style: TextStyle(
                                color: _scheduledAt == null ? Colors.grey : Colors.black,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _scheduledAt ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(_scheduledAt ?? DateTime.now()),
                                );
                                if (time != null) {
                                  setState(() {
                                    _scheduledAt = DateTime(
                                      date.year,
                                      date.month,
                                      date.day,
                                      time.hour,
                                      time.minute,
                                    );
                                  });
                                }
                              }
                            },
                            child: const Text('Schedule'),
                          ),
                          if (_scheduledAt != null)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.red),
                              onPressed: () => setState(() => _scheduledAt = null),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildLabel('Description (Rich Text)'),
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
                    const SizedBox(height: 12),
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
                          children: [
                            QuillSimpleToolbar(
                              controller: _controller,
                              config: const QuillSimpleToolbarConfig(
                                multiRowsDisplay: false,
                                showFontFamily: false,
                                showFontSize: false,
                                showColorButton: false,
                                showBackgroundColorButton: false,
                                showClearFormat: false,
                              ),
                            ),
                            const Divider(height: 1),
                            Container(
                              padding: const EdgeInsets.all(16),
                              constraints: const BoxConstraints(minHeight: 200),
                              child: QuillEditor.basic(
                                controller: _controller,
                                config: const QuillEditorConfig(
                                  placeholder: 'Enter news content...',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitNews,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryMaroon,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(_editingId != null ? 'UPDATE NEWS' : 'POST NEWS'),
                      ),
                    ),
                    if (_editingId != null)
                      TextButton(
                        onPressed: _clearForm,
                        child: const Center(child: Text('Cancel Edit', style: TextStyle(color: Colors.red))),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 24),
              const Text(
                'EXISTING NEWS',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFB09491)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: _filterNews,
                decoration: _buildInputDecoration('Search news...').copyWith(
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredNews.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final news = _filteredNews[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: news['cover_image_url'] != null
                          ? Image.network(news['cover_image_url'], width: 50, height: 50, fit: BoxFit.cover)
                          : const Icon(Icons.newspaper),
                      title: Text(news['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(news['category'] ?? 'General'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _editNews(news)),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteNews(news['id'])),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF5A403C))),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE3BEB8))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE3BEB8))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF8B0000), width: 1.5)),
    );
  }
}
