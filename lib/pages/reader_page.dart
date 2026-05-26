import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/book_model.dart';
import '../services/reading_history_service.dart';

/// Halaman reader: membuka preview Google Books via browser/webview
class ReaderPage extends StatefulWidget {
  final BookModel book;

  const ReaderPage({super.key, required this.book});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  bool _isOpening = false;

  @override
  void initState() {
    super.initState();
    // Auto-launch reader setelah frame pertama
    WidgetsBinding.instance.addPostFrameCallback((_) => _launchReader());
  }

  String get _readerUrl {
    final book = widget.book;
    if (book.hasWebReader) return book.webReaderLink!;
    if (book.hasPreview) return book.previewLink;
    return book.infoLink;
  }

  Future<void> _launchReader() async {
    if (_isOpening) return;
    setState(() => _isOpening = true);

    final url = _readerUrl;
    if (url.isEmpty) {
      setState(() => _isOpening = false);
      return;
    }

    try {
      debugPrint('[ReaderPage] 🌐 Attempting to launch: $url');
      final uri = Uri.parse(url);
      
      // Try to launch in-app browser first for better UX
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
      );

      // Fallback to external application if in-app fails
      if (!launched) {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }

      if (!launched && mounted) {
        _showCannotOpenDialog();
      }
    } catch (e) {
      debugPrint('[ReaderPage] ❌ Launch error: $e');
      if (mounted) _showCannotOpenDialog();
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }

    // Update progress ke minimal (menandai sudah dibuka)
    try {
      final history = await ReadingHistoryService.getBookHistory(widget.book.id);
      if (history != null && history.progress == 0.0) {
        await ReadingHistoryService.updateProgress(
          widget.book.id,
          progress: 0.05,
          lastPage: 1,
        );
      }
    } catch (e) {
      debugPrint('[ReaderPage] ⚠️ Error updating history: $e');
    }
  }

  void _showCannotOpenDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tidak Dapat Membuka'),
        content: const Text(
          'Browser tidak dapat membuka halaman ini. Pastikan Anda memiliki browser yang terinstal.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF2D5A41))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111111) : const Color(0xFFF8FBF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3D2C),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              book.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              book.authorsDisplay,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser_rounded),
            tooltip: 'Buka di Browser',
            onPressed: _launchReader,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ikon buku animasi
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D5A41).withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: _isOpening
                    ? const SizedBox(
                        width: 56,
                        height: 56,
                        child: CircularProgressIndicator(
                          color: Color(0xFF2D5A41),
                          strokeWidth: 3,
                        ),
                      )
                    : const Icon(
                        Icons.menu_book_rounded,
                        size: 56,
                        color: Color(0xFF2D5A41),
                      ),
              ),
              const SizedBox(height: 24),
              Text(
                _isOpening ? 'Membuka buku...' : 'Baca di Browser',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _isOpening
                    ? 'Harap tunggu sebentar'
                    : 'Buku akan dibuka di Google Books melalui browser Anda.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Info strips
              _InfoStrip(
                icon: Icons.preview_rounded,
                label: 'Preview tersedia',
                visible: book.hasPreview,
              ),
              _InfoStrip(
                icon: Icons.web_rounded,
                label: 'Web reader tersedia',
                visible: book.hasWebReader,
              ),
              _InfoStrip(
                icon: Icons.picture_as_pdf_rounded,
                label: 'PDF tersedia',
                visible: book.pdfDownloadLink != null,
              ),

              const SizedBox(height: 32),

              if (!_isOpening) ...[
                FilledButton.icon(
                  onPressed: _launchReader,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Buka Buku'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2D5A41),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                  child: const Text('Kembali'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoStrip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool visible;

  const _InfoStrip({
    required this.icon,
    required this.label,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2D5A41)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF2D5A41),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
