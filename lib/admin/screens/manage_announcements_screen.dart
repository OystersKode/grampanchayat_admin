import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/announcement_service.dart';
import '../widgets/admin_drawer.dart';

class ManageAnnouncementsScreen extends StatefulWidget {
  const ManageAnnouncementsScreen({super.key});

  @override
  State<ManageAnnouncementsScreen> createState() => _ManageAnnouncementsScreenState();
}

class _ManageAnnouncementsScreenState extends State<ManageAnnouncementsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  bool _isSubmitting = false;
  String? _editingId;
  List<Map<String, dynamic>> _allNews = [];
  List<Map<String, dynamic>> _filteredNews = [];

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    try {
      final news = await AnnouncementService.instance.fetchAnnouncements();
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
      _descriptionController.text = news['content'] ?? '';
      _categoryController.text = news['category'] ?? '';
    });
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
        await AnnouncementService.instance.deleteAnnouncement(id);
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
      if (_editingId != null) {
        await AnnouncementService.instance.updateAnnouncement(
          id: _editingId!,
          title: _titleController.text.trim(),
          content: _descriptionController.text.trim(),
          category: _categoryController.text.trim(),
        );
      } else {
        await AnnouncementService.instance.createAnnouncement(
          title: _titleController.text.trim(),
          content: _descriptionController.text.trim(),
          category: _categoryController.text.trim(),
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
    _descriptionController.clear();
    _categoryController.clear();
    setState(() {
      _editingId = null;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryMaroon = Color(0xFF8B0000);
    const Color backgroundColor = Color(0xFFFFF8F7);

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: const AdminDrawer(),
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text(
          'Manage Announcements',
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
                      'POST NEW ANNOUNCEMENT',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFB09491)),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Title'),
                    TextFormField(
                      controller: _titleController,
                      decoration: _buildInputDecoration('Enter announcement title'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Category'),
                    TextFormField(
                      controller: _categoryController,
                      decoration: _buildInputDecoration('e.g. Health, Agriculture, General'),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Description'),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: _buildInputDecoration('Enter announcement description'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
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
                            : Text(_editingId != null ? 'UPDATE ANNOUNCEMENT' : 'POST ANNOUNCEMENT'),
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
                'EXISTING ANNOUNCEMENTS',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFB09491)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: _filterNews,
                decoration: _buildInputDecoration('Search announcements...').copyWith(
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
                      title: Text(news['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(news['content'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
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
