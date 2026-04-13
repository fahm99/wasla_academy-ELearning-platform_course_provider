import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/main_repository.dart';
import '../../data/models/certificate/certificate.dart';
import 'package:intl/intl.dart';

class AllCertificatesScreen extends StatefulWidget {
  const AllCertificatesScreen({super.key});

  @override
  State<AllCertificatesScreen> createState() => _AllCertificatesScreenState();
}

class _AllCertificatesScreenState extends State<AllCertificatesScreen> {
  List<Certificate> _certificates = [];
  bool _isLoading = true;
  String _selectedFilter = 'الكل';

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    setState(() => _isLoading = true);

    try {
      final repository = context.read<MainRepository>();
      final user = await repository.getUser();

      if (user != null) {
        final certificates = await repository.getProviderCertificates(user.id);
        setState(() {
          _certificates = certificates;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل الشهادات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Certificate> get _filteredCertificates {
    if (_selectedFilter == 'الكل') {
      return _certificates;
    } else if (_selectedFilter == 'صادرة') {
      return _certificates
          .where((c) => c.status == CertificateStatus.issued)
          .toList();
    } else if (_selectedFilter == 'ملغاة') {
      return _certificates
          .where((c) => c.status == CertificateStatus.revoked)
          .toList();
    }
    return _certificates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: RefreshIndicator(
        onRefresh: _loadCertificates,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsCard(),
                    const SizedBox(height: 16),
                    _buildFilterButtons(),
                    const SizedBox(height: 16),
                    _buildCertificatesList(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final issuedCount =
        _certificates.where((c) => c.status == CertificateStatus.issued).length;
    final revokedCount = _certificates
        .where((c) => c.status == CertificateStatus.revoked)
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1445),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C1445).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: AppTheme.yellow,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'الشهادات',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppTheme.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child:
                    _buildStatItem('إجمالي', _certificates.length.toString()),
              ),
              Expanded(
                child: _buildStatItem('صادرة', issuedCount.toString()),
              ),
              Expanded(
                child: _buildStatItem('ملغاة', revokedCount.toString()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('الكل', _certificates.length),
          const SizedBox(width: 8),
          _buildFilterChip(
            'صادرة',
            _certificates
                .where((c) => c.status == CertificateStatus.issued)
                .length,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'ملغاة',
            _certificates
                .where((c) => c.status == CertificateStatus.revoked)
                .length,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      backgroundColor: AppTheme.white,
      selectedColor: AppTheme.darkBlue,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.white : AppTheme.darkBlue,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildCertificatesList() {
    final filtered = _filteredCertificates;

    if (filtered.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Icon(
              Icons.workspace_premium,
              size: 64,
              color: AppTheme.mediumGray,
            ),
            SizedBox(height: 16),
            Text(
              'لا توجد شهادات',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.darkGray,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'قائمة الشهادات',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkBlue,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            return _buildCertificateCard(filtered[index]);
          },
        ),
      ],
    );
  }

  Widget _buildCertificateCard(Certificate certificate) {
    final isIssued = certificate.status == CertificateStatus.issued;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isIssued ? Icons.check_circle : Icons.pending,
                  color: isIssued ? AppTheme.green : AppTheme.yellow,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        certificate.studentName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        certificate.courseName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isIssued ? AppTheme.green : AppTheme.yellow)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isIssued ? AppTheme.green : AppTheme.yellow,
                    ),
                  ),
                  child: Text(
                    isIssued ? 'صادرة' : 'معلقة',
                    style: TextStyle(
                      fontSize: 12,
                      color: isIssued ? AppTheme.green : AppTheme.yellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 14, color: AppTheme.darkGray),
                const SizedBox(width: 4),
                Text(
                  'تاريخ الإصدار: ${DateFormat('yyyy-MM-dd').format(certificate.issueDate)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.darkGray,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
