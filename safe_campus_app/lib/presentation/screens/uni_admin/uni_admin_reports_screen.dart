import 'package:flutter/material.dart';
import 'package:safe_campus_app/services/uni_admin_service.dart';
import 'package:safe_campus_app/logic/models/uni_admin_report.dart';

const Map<int, String> categoryIdNameMap = {
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

class UniAdminReportsScreen extends StatefulWidget {
  const UniAdminReportsScreen({super.key});

  @override
  State<UniAdminReportsScreen> createState() => _UniAdminReportsScreenState();
}

class _UniAdminReportsScreenState extends State<UniAdminReportsScreen> {
  Future<void> _editReportDescription(UniAdminReport report) async {
    final controller = TextEditingController(text: report.description);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Açıklamayı Düzenle'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Açıklama',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    if (result == null || result == report.description) return;
    try {
      await UniAdminService.updateReportDescription(
        reportId: report.reportId,
        description: result,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Açıklama güncellendi'),
          backgroundColor: Colors.green,
        ),
      );
      _loadReports();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Açıklama güncellenemedi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  final List<UniAdminReport> _reports = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _deleteReport(int reportId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Raporı Sil'),
        content: const Text('Bu raporu silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await UniAdminService.deleteReport(reportId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rapor silindi'),
          backgroundColor: Colors.green,
        ),
      );
      _loadReports();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silme hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    try {
      final reports = await UniAdminService.getReports();
      setState(() {
        _reports.clear();
        _reports.addAll(reports);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    }
  }

  List<UniAdminReport> get _filteredReports {
    return _reports.where((report) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          report.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategoryId == null ||
          report.categoryId == _selectedCategoryId;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<int> get _categoryIds {
    return _reports.map((r) => r.categoryId).toSet().toList()..sort();
  }

  Future<void> _updateReportStatus(int reportId, String newStatus) async {
    try {
      await UniAdminService.updateReportStatus(
        reportId: reportId,
        status: newStatus,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Durum güncellendi'),
          backgroundColor: Colors.green,
        ),
      );
      _loadReports();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showChangeStatusDialog(UniAdminReport report) {
    String selectedStatus = report.status;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Durum Değiştir'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Açık'),
                value: 'Acik',
                groupValue: selectedStatus,
                onChanged: (value) => setState(() => selectedStatus = value!),
              ),
              RadioListTile<String>(
                title: const Text('Çözüldü'),
                value: 'Cozuldu',
                groupValue: selectedStatus,
                onChanged: (value) => setState(() => selectedStatus = value!),
              ),
              RadioListTile<String>(
                title: const Text('İnceleniyor'),
                value: 'Inceleniyor',
                groupValue: selectedStatus,
                onChanged: (value) => setState(() => selectedStatus = value!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateReportStatus(report.reportId, selectedStatus);
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raporlar (Üniversite Admin)'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rapor ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<int?>(
                    isExpanded: true,
                    value: _selectedCategoryId,
                    hint: const Text('Kategori'),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Tümü'),
                      ),
                      ..._categoryIds.map(
                        (catId) => DropdownMenuItem<int?>(
                          value: catId,
                          child: Text(
                            categoryIdNameMap[catId] ?? 'Kategori $catId',
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedCategoryId = value);
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
                      itemCount: _filteredReports.length,
                      itemBuilder: (context, index) {
                        final report = _filteredReports[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo,
                              child: const Icon(
                                Icons.report,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(report.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Üniversite: ${report.universityName}'),
                                Text(
                                  'Kategori: ${categoryIdNameMap[report.categoryId] ?? 'Kategori ${report.categoryId}'}',
                                ),
                                Text('Durum: ${report.status}'),
                                if (report.description.isNotEmpty)
                                  Text(
                                    'Açıklama: ${report.description}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Raporu Sil',
                              onPressed: () => _deleteReport(report.reportId),
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(report.title),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Üniversite: ${report.universityName}',
                                      ),
                                      Text(
                                        'Kategori: ${categoryIdNameMap[report.categoryId] ?? 'Kategori ${report.categoryId}'}',
                                      ),
                                      Text('Durum: ${report.status}'),
                                      Text('Açıklama: ${report.description}'),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Kapat'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _editReportDescription(report);
                                      },
                                      child: const Text('Açıklamayı Düzenle'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _showChangeStatusDialog(report);
                                      },
                                      child: const Text('Durum Değiştir'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _deleteReport(report.reportId);
                                      },
                                      child: const Text(
                                        'Sil',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
