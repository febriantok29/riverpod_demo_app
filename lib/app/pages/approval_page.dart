import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_demo_app/app/models/approval_document.dart';
import 'package:riverpod_demo_app/app/pages/home_page.dart';
import 'package:riverpod_demo_app/app/pages/login_page.dart';
import 'package:riverpod_demo_app/app/riverpod/providers/auth_provider.dart';

/// Halaman approval yang generic - bisa digunakan untuk berbagai dokumen
/// Menerima ApprovalDocument sebagai parameter
/// Self-contained: handle navigation sendiri setelah approve
class ApprovalPage extends ConsumerStatefulWidget {
  final ApprovalDocument document;

  const ApprovalPage({super.key, required this.document});

  @override
  ConsumerState<ApprovalPage> createState() => _MultiApprovalPageState();
}

class _MultiApprovalPageState extends ConsumerState<ApprovalPage> {
  bool _isAgreed = false;
  bool _isSubmitting = false;
  bool _isLoggingOut = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Handle submit approval
  Future<void> _handleSubmit() async {
    if (!_isAgreed) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Save approval ke service
      await ref
          .read(AuthProviders.notifier.notifier)
          .approveDocument(widget.document.id);

      if (!mounted) return;

      // Check dokumen berikutnya
      final pendingDocs = ref
          .read(AuthProviders.notifier.notifier)
          .getPendingDocuments();

      if (pendingDocs.isEmpty) {
        // Semua dokumen sudah approved → navigate ke home
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } else {
        // Masih ada dokumen yang belum approved → navigate ke dokumen berikutnya
        final nextDoc = ApprovalDocuments.getById(pendingDocs.first);
        if (nextDoc != null && mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ApprovalPage(document: nextDoc),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// Handle logout
  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text(
          'Anda harus menyetujui semua dokumen untuk menggunakan aplikasi. Apakah Anda yakin ingin logout?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      // Logout dan navigate ke login
      await ref.read(AuthProviders.notifier.notifier).logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  /// Handle back button
  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text(
          'Anda harus menyetujui dokumen ini untuk melanjutkan. Keluar akan logout. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      _handleLogout();
    }

    return false; // Always prevent default back
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await _onWillPop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.document.title),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _isSubmitting || _isLoggingOut ? null : _handleLogout,
              tooltip: 'Logout',
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress indicator jika ada
            if (_isSubmitting || _isLoggingOut) const LinearProgressIndicator(),

            // Document description
            Container(
              width: double.infinity,
              color: Colors.blue.shade50,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.document.description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Silakan baca dokumen di bawah ini dengan seksama.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),

            // Document content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Render sections
                    ...widget.document.sections.map((section) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              section.content,
                              style: const TextStyle(fontSize: 14, height: 1.5),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Agreement checkbox and submit button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: Text(
                      'Saya telah membaca dan menyetujui ${widget.document.title}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    value: _isAgreed,
                    onChanged: _isSubmitting || _isLoggingOut
                        ? null
                        : (value) {
                            setState(() {
                              _isAgreed = value ?? false;
                            });
                          },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: !_isAgreed || _isSubmitting || _isLoggingOut
                          ? null
                          : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Setuju dan Lanjutkan',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
