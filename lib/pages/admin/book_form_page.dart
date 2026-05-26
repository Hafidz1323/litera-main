import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/book_model.dart';
import '../../services/admin_service.dart';

class BookFormPage extends StatefulWidget {
  final BookModel? book;
  const BookFormPage({super.key, this.book});

  @override
  State<BookFormPage> createState() => _BookFormPageState();
}

class _BookFormPageState extends State<BookFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _categoryController;
  late TextEditingController _thumbnailController;
  late TextEditingController _epubController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book?.title ?? '');
    _authorController = TextEditingController(text: widget.book?.authorsDisplay ?? '');
    _categoryController = TextEditingController(text: widget.book?.categoryDisplay ?? '');
    _thumbnailController = TextEditingController(text: widget.book?.thumbnail ?? '');
    _epubController = TextEditingController(text: widget.book?.epubDownloadLink ?? '');
    _descriptionController = TextEditingController(text: widget.book?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _categoryController.dispose();
    _thumbnailController.dispose();
    _epubController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authors = _authorController.text.split(',').map((e) => e.trim()).toList();
    final categories = _categoryController.text.split(',').map((e) => e.trim()).toList();

    final bookData = BookModel(
      id: widget.book?.id ?? '',
      title: _titleController.text.trim(),
      authors: authors,
      categories: categories,
      thumbnail: _thumbnailController.text.trim(),
      epubDownloadLink: _epubController.text.trim(),
      description: _descriptionController.text.trim(),
      // Maintain other fields if editing
      subtitle: widget.book?.subtitle ?? '',
      publisher: widget.book?.publisher ?? '',
      publishedDate: widget.book?.publishedDate ?? '',
      pageCount: widget.book?.pageCount ?? 0,
      language: widget.book?.language ?? 'id',
      previewLink: widget.book?.previewLink ?? '',
      infoLink: widget.book?.infoLink ?? '',
      isEbook: true,
    );

    try {
      if (widget.book == null) {
        await AdminService.addBook(bookData);
      } else {
        await AdminService.updateBook(bookData);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Book ${widget.book == null ? 'added' : 'updated'} successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(widget.book == null ? 'Add New Book' : 'Edit Book'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _titleController,
                      label: 'Title',
                      icon: Icons.title,
                      validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _authorController,
                      label: 'Authors (comma separated)',
                      icon: Icons.person,
                      validator: (v) => v == null || v.isEmpty ? 'Author is required' : null,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _categoryController,
                      label: 'Categories (comma separated)',
                      icon: Icons.category,
                      validator: (v) => v == null || v.isEmpty ? 'Category is required' : null,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _thumbnailController,
                      label: 'Thumbnail URL',
                      icon: Icons.image,
                      onChanged: (v) => setState(() {}),
                      validator: (v) => v == null || v.isEmpty ? 'Thumbnail URL is required' : null,
                    ),
                    if (_thumbnailController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _thumbnailController.text,
                            height: 150,
                            errorBuilder: (_, __, ___) => const Text('Invalid image URL'),
                          ),
                        ),
                      ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _epubController,
                      label: 'EPUB / PDF URL',
                      icon: Icons.link,
                      validator: (v) => v == null || v.isEmpty ? 'Download URL is required' : null,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      icon: Icons.description,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveBook,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          widget.book == null ? 'ADD BOOK' : 'UPDATE BOOK',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: isDark ? AppColors.cardDark : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? AppColors.primary.withOpacity(0.2) : AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
