import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_demo_app/app/models/leave_request.dart';
import 'package:riverpod_demo_app/app/riverpod/providers/leave_provider.dart';
import 'package:riverpod_demo_app/app/states/leave_state.dart';
import 'package:riverpod_demo_app/app/utils/date_formatter.dart';

class LeaveFormPage extends ConsumerStatefulWidget {
  final String employeeName;
  final LeaveRequest? existingLeave; // Null = create, not null = edit

  const LeaveFormPage({
    super.key,
    required this.employeeName,
    this.existingLeave,
  });

  @override
  ConsumerState<LeaveFormPage> createState() => _LeaveFormPageState();
}

class _LeaveFormPageState extends ConsumerState<LeaveFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _substituteController = TextEditingController();
  final _reasonController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  bool get isEditMode => widget.existingLeave != null;

  @override
  void initState() {
    super.initState();

    // Jika edit mode, populate data yang sudah ada
    if (isEditMode) {
      _startDate = widget.existingLeave!.startDate;
      _endDate = widget.existingLeave!.endDate;
      _substituteController.text = widget.existingLeave!.substitute;
      _reasonController.text = widget.existingLeave!.reason;
    }

    // Reset form state saat masuk halaman
    Future.microtask(() {
      ref.read(leaveFormProvider.notifier).resetFormState();
    });
  }

  @override
  void dispose() {
    _substituteController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(leaveFormProvider);

    // Listen perubahan state untuk navigasi
    ref.listen(leaveFormProvider, (previous, next) {
      if (next.isSuccess) {
        Navigator.pop(context, true); // Return true untuk refresh list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? 'Pengajuan berhasil diupdate'
                  : 'Pengajuan cuti berhasil dibuat',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (next.errorMessage != null && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditMode ? 'Edit Pengajuan Cuti' : 'Ajukan Cuti Baru'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade700, Colors.grey.shade50],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: 16),
                    _buildFormCard(formState),
                    const SizedBox(height: 24),
                    _buildSubmitButton(formState),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade700,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.employeeName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEditMode
                        ? 'Edit Pengajuan #${widget.existingLeave!.id}'
                        : 'Pengajuan Baru',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard(LeaveFormState formState) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail Pengajuan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Start Date
            _buildDateField(
              label: 'Tanggal Mulai',
              date: _startDate,
              onTap: () => _selectStartDate(context),
              icon: Icons.calendar_today,
            ),
            const SizedBox(height: 16),

            // End Date
            _buildDateField(
              label: 'Tanggal Selesai',
              date: _endDate,
              onTap: () => _selectEndDate(context),
              icon: Icons.event,
            ),

            // Display total days
            if (_startDate != null && _endDate != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Total: ${_calculateTotalDays()} hari',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormatter.formatRange(_startDate!, _endDate!),
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Substitute
            TextFormField(
              controller: _substituteController,
              decoration: InputDecoration(
                labelText: 'Karyawan Pengganti',
                hintText: 'Masukkan nama pengganti',
                prefixIcon: const Icon(Icons.person_add),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Karyawan pengganti harus diisi';
                }
                return null;
              },
              enabled: !formState.isLoading,
            ),
            const SizedBox(height: 16),

            // Reason
            TextFormField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: 'Alasan',
                hintText: 'Masukkan alasan pengajuan cuti',
                prefixIcon: const Icon(Icons.notes),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Alasan harus diisi';
                }
                if (value.length < 10) {
                  return 'Alasan minimal 10 karakter';
                }
                return null;
              },
              enabled: !formState.isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          date == null ? 'Pilih tanggal' : DateFormatter.formatMedium(date),
          style: TextStyle(color: date == null ? Colors.grey : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(LeaveFormState formState) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: formState.isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.blue.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: formState.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                isEditMode ? 'Update Pengajuan' : 'Ajukan Cuti',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Colors.blue.shade700),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Reset end date jika lebih awal dari start date
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal mulai terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!,
      firstDate: _startDate!,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Colors.blue.shade700),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  int _calculateTotalDays() {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal mulai harus diisi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal selesai harus diisi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final notifier = ref.read(leaveFormProvider.notifier);

    if (isEditMode) {
      await notifier.updateLeaveRequest(
        id: widget.existingLeave!.id,
        startDate: _startDate!,
        endDate: _endDate!,
        substitute: _substituteController.text,
        reason: _reasonController.text,
      );
    } else {
      await notifier.createLeaveRequest(
        employeeName: widget.employeeName,
        startDate: _startDate!,
        endDate: _endDate!,
        substitute: _substituteController.text,
        reason: _reasonController.text,
      );
    }
  }
}
