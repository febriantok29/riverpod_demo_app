import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_demo_app/app/pages/home_page.dart';
import 'package:riverpod_demo_app/app/pages/login_page.dart';
import 'package:riverpod_demo_app/app/riverpod/providers/auth_provider.dart';

/// Halaman approval untuk admin sebelum masuk ke aplikasi
/// Menampilkan dokumen persetujuan (mock PDF) dan checkbox untuk menyetujui
class ApprovalPage extends ConsumerStatefulWidget {
  const ApprovalPage({super.key});

  @override
  ConsumerState<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends ConsumerState<ApprovalPage> {
  bool _isAgreed = false;
  bool _isSubmitting = false;
  bool _isLoggingOut = false;

  /// Handle logout - jika user tidak setuju
  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text(
          'Anda harus menyetujui dokumen untuk menggunakan aplikasi. Apakah Anda yakin ingin logout?',
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

    // Logout
    await ref.read(AuthProviders.notifier.notifier).logout();

    if (!mounted) return;

    // Navigate to login page
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  /// Handle back button press
  Future<bool> _onWillPop() async {
    // Show confirmation dialog
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Aplikasi?'),
        content: const Text(
          'Anda harus menyetujui dokumen untuk menggunakan aplikasi. Apakah Anda yakin ingin keluar?',
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

    return shouldExit ?? false;
  }

  Future<void> _handleSubmit() async {
    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus menyetujui dokumen terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Save approval status
    await ref.read(AuthProviders.notifier.notifier).saveApproval();

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    // Navigate to home page
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(AuthProviders.notifier);

    return PopScope(
      canPop: false, // Disable default back behavior
      onPopInvoked: (didPop) async {
        if (didPop) return;

        // Show confirmation dialog
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Persetujuan Dokumen'),
          centerTitle: true,
          automaticallyImplyLeading: false, // Disable default back button
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            // Logout button
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _isLoggingOut || _isSubmitting ? null : _handleLogout,
              tooltip: 'Logout',
            ),
          ],
        ),
        body: Column(
          children: [
            // Info banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Selamat datang, ${authState.username ?? 'Admin'}!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sebelum menggunakan aplikasi, Anda harus membaca dan menyetujui dokumen berikut.',
                    style: TextStyle(fontSize: 14, color: Colors.blue.shade900),
                  ),
                ],
              ),
            ),

            // PDF Mock Content (scrollable)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      // PDF Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              color: Colors.red.shade700,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dokumen Persetujuan Admin',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Versi 1.0 - 23 Januari 2026',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // PDF Content Mock
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PERSETUJUAN PENGGUNAAN SISTEM',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            _buildSection(
                              '1. Ketentuan Umum',
                              'Dengan menyetujui dokumen ini, Anda sebagai Administrator menyatakan telah membaca, memahami, dan menyetujui seluruh ketentuan yang berlaku dalam penggunaan sistem aplikasi ini.',
                            ),
                            _buildSection(
                              '2. Tanggung Jawab Administrator',
                              'Administrator bertanggung jawab penuh atas:\n'
                                  '• Keamanan akun dan kredensial login\n'
                                  '• Penggunaan fitur sesuai dengan kewenangan yang diberikan\n'
                                  '• Kerahasiaan data yang diakses melalui sistem\n'
                                  '• Backup data secara berkala',
                            ),
                            _buildSection(
                              '3. Kebijakan Keamanan',
                              'Administrator wajib:\n'
                                  '• Menggunakan password yang kuat dan unik\n'
                                  '• Tidak membagikan akun kepada pihak lain\n'
                                  '• Melaporkan jika terjadi aktivitas mencurigakan\n'
                                  '• Logout setelah selesai menggunakan sistem',
                            ),
                            _buildSection(
                              '4. Privasi Data',
                              'Semua data yang diakses melalui sistem ini bersifat rahasia dan tidak boleh disebarluaskan kepada pihak yang tidak berwenang tanpa izin tertulis dari perusahaan.',
                            ),
                            _buildSection(
                              '5. Sanksi',
                              'Pelanggaran terhadap ketentuan ini dapat mengakibatkan:\n'
                                  '• Pencabutan akses ke sistem\n'
                                  '• Tindakan disipliner sesuai kebijakan perusahaan\n'
                                  '• Tindakan hukum jika diperlukan',
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                border: Border.all(
                                  color: Colors.amber.shade200,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.amber.shade700,
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'Dokumen ini mengikat secara hukum. Pastikan Anda membaca dengan teliti sebelum menyetujui.',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Checkbox and Submit Button
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Checkbox
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isAgreed = !_isAgreed;
                      });
                    },
                    child: Row(
                      children: [
                        Checkbox(
                          value: _isAgreed,
                          onChanged: (value) {
                            setState(() {
                              _isAgreed = value ?? false;
                            });
                          },
                          activeColor: Colors.blue,
                        ),
                        const Expanded(
                          child: Text(
                            'Saya telah membaca dan menyetujui seluruh ketentuan di atas',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: (_isSubmitting || _isLoggingOut || !_isAgreed)
                          ? null
                          : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ), // End PopScope
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
