import 'package:flutter/material.dart';
import 'package:safe_campus_app/logic/models/report.dart';
import 'package:safe_campus_app/services/admin_service.dart';

class ReportsManagementScreen extends StatefulWidget {
  const ReportsManagementScreen({super.key});

  @override
  State<ReportsManagementScreen> createState() =>
      _ReportsManagementScreenState();
}

class _ReportsManagementScreenState extends State<ReportsManagementScreen> {
  // Kategori eşlemesi (ID -> İsim)
  static const Map<int, String> categoryMap = {
    1: 'Acil Durum',
    2: 'Sağlık',
    3: 'Güvenlik',
    4: 'Teknik Arıza',
    5: 'Kayıp & Buluntu',
    6: 'Temizlik',
    7: 'Bilişim & İnternet',
    8: 'Yemekhane',
    9: 'Diğer',
  };
  int? _filterCategoryId;
  List<Report> _reports = [];
  bool _isLoading = true;
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    try {
      final reports = await AdminService.getAllReports();
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } on AdminException catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<Report> get _filteredReports {
    Iterable<Report> filtered = _reports;
    if (_filterStatus != null && _filterStatus != 'Tümü') {
      filtered = filtered.where((report) => report.status == _filterStatus);
    }
    if (_filterCategoryId != null) {
      filtered = filtered.where(
        (report) => report.categoryId == _filterCategoryId,
      );
    }
    return filtered.toList();
  }

  @override
  Widget build(BuildContext context) {
    // Kategoriler ve renkler
    final statusOptions = [
      {'value': null, 'label': 'Tümü', 'color': Colors.grey},
      {'value': 'Acik', 'label': 'Açık', 'color': Colors.orange},
      {'value': 'Cozuldu', 'label': 'Çözüldü', 'color': Colors.green},
      {'value': 'Reddedildi', 'label': 'Reddedildi', 'color': Colors.red},
    ];
    final categoryOptions = [
      {'value': null, 'label': 'Tümü'},
      ...categoryMap.entries.map((e) => {'value': e.key, 'label': e.value}),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapor Yönetimi'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                // Durum filtresi
                const Text(
                  'Durum:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String?>(
                    isExpanded: true,
                    value: _filterStatus,
                    items: statusOptions
                        .map(
                          (opt) => DropdownMenuItem<String?>(
                            value: opt['value'] as String?,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: opt['color'] as Color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Text(opt['label'] as String),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _filterStatus = value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Kategori filtresi
                const Text(
                  'Kategori:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<int?>(
                    isExpanded: true,
                    value: _filterCategoryId,
                    items: categoryOptions
                        .map(
                          (opt) => DropdownMenuItem<int?>(
                            value: opt['value'] as int?,
                            child: Text(opt['label'] as String),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _filterCategoryId = value);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredReports.isEmpty
                ? const Center(child: Text('Rapor bulunamadı'))
                : RefreshIndicator(
                    onRefresh: _loadReports,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredReports.length,
                      itemBuilder: (context, index) {
                        final report = _filteredReports[index];
                        return _buildReportCard(report);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Report report) {
    Color statusColor;
    IconData statusIcon;
    switch (report.status) {
      case 'Acik':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'Cozuldu':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Reddedildi':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text(
          report.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (report.universityName != null) ...[
              const SizedBox(height: 4),
              Text('🏫 ${report.universityName}'),
            ],
            const SizedBox(height: 4),
            Text(
              'Kategori: ${report.categoryId != null && categoryMap[report.categoryId!] != null ? categoryMap[report.categoryId!] : (report.categoryName.isNotEmpty ? report.categoryName : 'Kategori yok')}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              '📅 ${_formatDate(report.createdAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getStatusText(report.status),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kategori:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  report.categoryId != null &&
                          categoryMap[report.categoryId!] != null
                      ? categoryMap[report.categoryId!]!
                      : (report.categoryName.isNotEmpty
                            ? report.categoryName
                            : 'Kategori yok'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Açıklama:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  (report.description != null &&
                          report.description!.trim().isNotEmpty)
                      ? report.description!
                      : 'Açıklama yok',
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        _showReportDetailDialog(report, statusColor);
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text('Detay'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDetailDialog(Report report, Color statusColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.description, color: statusColor),
            const SizedBox(width: 8),
            Expanded(child: Text(report.title)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusText(report.status),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (report.universityName != null) ...[
                Text('Üniversite: ${report.universityName!}'),
                const SizedBox(height: 8),
              ],
              Text(
                'Kategori: ${report.categoryId != null && categoryMap[report.categoryId!] != null ? categoryMap[report.categoryId!] : (report.categoryName.isNotEmpty ? report.categoryName : 'Kategori yok')}',
              ),
              const SizedBox(height: 8),
              Text('Oluşturulma: ${_formatDate(report.createdAt)}'),
              const SizedBox(height: 8),
              const Text(
                'Açıklama:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                (report.description != null &&
                        report.description!.trim().isNotEmpty)
                    ? report.description!
                    : 'Açıklama yok',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'Acik':
        return 'Açık';
      case 'Cozuldu':
        return 'Çözüldü';
      case 'Reddedildi':
        return 'Reddedildi';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
