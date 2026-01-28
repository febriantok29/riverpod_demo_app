/// Model untuk dokumen yang harus di-approve oleh user
class ApprovalDocument {
  final String id;
  final String title;
  final String description;
  final List<DocumentSection> sections;

  const ApprovalDocument({
    required this.id,
    required this.title,
    required this.description,
    required this.sections,
  });
}

/// Section dalam dokumen approval
class DocumentSection {
  final String title;
  final String content;

  const DocumentSection({required this.title, required this.content});
}

/// Constants: Daftar semua dokumen yang harus di-approve
class ApprovalDocuments {
  ApprovalDocuments._();

  /// Dokumen untuk Admin: General Terms & Conditions
  static const adminTerms = ApprovalDocument(
    id: 'admin_terms',
    title: 'Syarat dan Ketentuan Admin',
    description: 'Persetujuan akses administrator dan tanggung jawabnya',
    sections: [
      DocumentSection(
        title: '1. Ketentuan Umum',
        content:
            'Administrator memiliki akses penuh terhadap sistem dan bertanggung jawab untuk menjaga keamanan dan integritas data.',
      ),
      DocumentSection(
        title: '2. Tanggung Jawab Administrator',
        content:
            'Administrator bertanggung jawab untuk mengelola pengguna, hak akses, dan memastikan sistem berjalan dengan baik.',
      ),
      DocumentSection(
        title: '3. Kebijakan Keamanan',
        content:
            'Administrator wajib mengikuti kebijakan keamanan perusahaan dan melaporkan setiap insiden keamanan.',
      ),
      DocumentSection(
        title: '4. Kebijakan Privasi',
        content:
            'Administrator wajib menjaga privasi data pengguna dan tidak menyalahgunakan akses yang diberikan.',
      ),
      DocumentSection(
        title: '5. Sanksi',
        content:
            'Pelanggaran terhadap ketentuan ini dapat mengakibatkan pencabutan hak akses dan sanksi sesuai peraturan perusahaan.',
      ),
    ],
  );

  /// Dokumen 1 untuk Member: Pacta Integritas
  static const integrityPact = ApprovalDocument(
    id: 'pacta_integritas',
    title: 'Pacta Integritas',
    description:
        'Pernyataan komitmen untuk menjaga integritas dan etika dalam bekerja',
    sections: [
      DocumentSection(
        title: '1. Komitmen Integritas',
        content:
            'Saya berkomitmen untuk menjalankan tugas dengan jujur, bertanggung jawab, dan menjunjung tinggi nilai-nilai integritas dalam setiap keputusan dan tindakan yang saya lakukan.',
      ),
      DocumentSection(
        title: '2. Anti Korupsi',
        content:
            'Saya tidak akan terlibat dalam segala bentuk tindakan korupsi, kolusi, dan nepotisme (KKN). Saya akan menolak dan melaporkan setiap bentuk gratifikasi yang dapat mempengaruhi objektivitas dalam melaksanakan tugas.',
      ),
      DocumentSection(
        title: '3. Benturan Kepentingan',
        content:
            'Saya akan menghindari situasi yang dapat menimbulkan benturan kepentingan antara kepentingan pribadi dengan kepentingan perusahaan, serta akan melaporkan jika terjadi potensi benturan kepentingan.',
      ),
      DocumentSection(
        title: '4. Kerahasiaan',
        content:
            'Saya akan menjaga kerahasiaan informasi perusahaan dan tidak akan menggunakan informasi tersebut untuk kepentingan pribadi atau pihak lain.',
      ),
      DocumentSection(
        title: '5. Sanksi',
        content:
            'Saya memahami bahwa pelanggaran terhadap Pacta Integritas ini dapat mengakibatkan sanksi sesuai dengan peraturan yang berlaku, termasuk pemutusan hubungan kerja.',
      ),
    ],
  );

  /// Dokumen 2: Perlindungan Data Pribadi
  static const personalDataProtection = ApprovalDocument(
    id: 'perlindungan_data_pribadi',
    title: 'Perlindungan Data Pribadi',
    description:
        'Persetujuan pengumpulan, pengolahan, dan perlindungan data pribadi',
    sections: [
      DocumentSection(
        title: '1. Pengumpulan Data',
        content:
            'Saya menyetujui bahwa perusahaan dapat mengumpulkan data pribadi saya termasuk namun tidak terbatas pada: nama, alamat, nomor telepon, email, data biometrik, dan data terkait pekerjaan untuk keperluan administrasi dan operasional.',
      ),
      DocumentSection(
        title: '2. Penggunaan Data',
        content:
            'Data pribadi saya akan digunakan untuk keperluan: administrasi kepegawaian, penggajian, pelatihan, evaluasi kinerja, dan keperluan operasional lainnya yang berkaitan dengan hubungan kerja.',
      ),
      DocumentSection(
        title: '3. Perlindungan Data',
        content:
            'Perusahaan berkomitmen untuk melindungi data pribadi saya dengan menerapkan standar keamanan yang sesuai untuk mencegah akses tidak sah, pengungkapan, atau penyalahgunaan data.',
      ),
      DocumentSection(
        title: '4. Hak Individu',
        content:
            'Saya memiliki hak untuk mengakses, memperbaiki, atau meminta penghapusan data pribadi saya sesuai dengan peraturan perundang-undangan yang berlaku. Saya dapat menghubungi bagian HRD untuk melaksanakan hak-hak tersebut.',
      ),
      DocumentSection(
        title: '5. Perubahan Kebijakan',
        content:
            'Saya memahami bahwa kebijakan perlindungan data pribadi ini dapat berubah sewaktu-waktu dan saya akan diberitahu mengenai perubahan tersebut.',
      ),
    ],
  );

  /// Dokumen 3: Persetujuan K3 (Keselamatan dan Kesehatan Kerja)
  static const hsse = ApprovalDocument(
    id: 'persetujuan_k3',
    title: 'Persetujuan K3',
    description:
        'Persetujuan untuk mematuhi standar Keselamatan dan Kesehatan Kerja',
    sections: [
      DocumentSection(
        title: '1. Komitmen Keselamatan',
        content:
            'Saya berkomitmen untuk selalu memprioritaskan keselamatan dan kesehatan kerja dalam setiap aktivitas yang saya lakukan. Saya akan mematuhi semua prosedur dan standar K3 yang ditetapkan perusahaan.',
      ),
      DocumentSection(
        title: '2. Penggunaan APD',
        content:
            'Saya akan menggunakan Alat Pelindung Diri (APD) yang telah disediakan sesuai dengan standar dan prosedur yang berlaku. Saya memahami bahwa APD adalah perlindungan terakhir terhadap bahaya di tempat kerja.',
      ),
      DocumentSection(
        title: '3. Pelaporan Bahaya',
        content:
            'Saya akan segera melaporkan setiap kondisi atau tindakan tidak aman yang saya temukan kepada atasan atau tim K3. Saya tidak akan melakukan pekerjaan yang saya anggap tidak aman tanpa konsultasi terlebih dahulu.',
      ),
      DocumentSection(
        title: '4. Keadaan Darurat',
        content:
            'Saya telah memahami prosedur tanggap darurat termasuk jalur evakuasi, titik kumpul, dan nomor kontak darurat. Saya akan mengikuti instruksi petugas K3 dalam situasi darurat.',
      ),
      DocumentSection(
        title: '5. Konsekuensi',
        content:
            'Saya memahami bahwa pelanggaran terhadap prosedur K3 dapat membahayakan diri sendiri dan orang lain, serta dapat mengakibatkan sanksi sesuai peraturan perusahaan.',
      ),
    ],
  );

  /// Get dokumen berdasarkan ID
  static ApprovalDocument? getById(String id) {
    // Check in admin documents
    if (id == adminTerms.id) return adminTerms;

    // Check in member documents
    try {
      return memberDocuments.firstWhere((doc) => doc.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Dokumen untuk member (3 dokumen)
  static const List<ApprovalDocument> memberDocuments = [
    integrityPact,
    personalDataProtection,
    hsse,
  ];

  /// Dokumen untuk admin (1 dokumen)
  static const List<ApprovalDocument> adminDocuments = [adminTerms];

  /// Get list dokumen berdasarkan user type
  static List<ApprovalDocument> getDocumentsForUser(String username) {
    if (username.toLowerCase().contains('admin')) {
      return adminDocuments;
    } else if (username.toLowerCase().contains('member')) {
      return memberDocuments;
    }
    return []; // User biasa tidak perlu approval
  }
}
