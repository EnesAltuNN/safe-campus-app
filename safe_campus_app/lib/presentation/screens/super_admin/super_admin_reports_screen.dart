import 'package:flutter/material.dart';
import 'package:safe_campus_app/services/super_admin_service.dart';
import 'package:safe_campus_app/logic/models/super_admin_report.dart';
import 'package:safe_campus_app/logic/models/super_admin_university.dart';
import 'package:safe_campus_app/services/super_admin_report_actions.dart';

// Kategori id-name eşleşmesi (tam liste)
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

class SuperAdminReportsScreen extends StatefulWidget {
  const SuperAdminReportsScreen({super.key});

  @override
  State<SuperAdminReportsScreen> createState() =>
      _SuperAdminReportsScreenState();
}

class _SuperAdminReportsScreenState extends State<SuperAdminReportsScreen> {
  void _showEditDescriptionDialog(SuperAdminReport report) {
    final controller = TextEditingController(text: report.description);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Açıklama Düzenle'),
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
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateReportDescription(report.reportId, controller.text);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateReportDescription(
    int reportId,
    String newDescription,
  ) async {
    try {
      await SuperAdminReportActions.updateReportDescription(
        reportId: reportId,
        description: newDescription,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Açıklama güncellendi'),
            backgroundColor: Colors.green,
          ),
        );
        _loadReports();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<SuperAdminReport> _reports = [];
  List<SuperAdminUniversity> _universities = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int? _selectedUniversityId;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadReports();
    _loadUniversities();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    try {
      final reports = await SuperAdminService.getAllReports();
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadUniversities() async {
    try {
      final universities = await SuperAdminService.getAllUniversities();
      setState(() {
        _universities = universities;
      });
    } catch (e) {
      // Hata gösterilebilir
    }
  }

  List<SuperAdminReport> get _filteredReports {
    return _reports.where((report) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          report.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesUniversity =
          _selectedUniversityId == null ||
          report.universityId == _selectedUniversityId;
      final matchesCategory =
          _selectedCategoryId == null ||
          report.categoryId == _selectedCategoryId;
      return matchesSearch && matchesUniversity && matchesCategory;
    }).toList();
  }

  List<int> get _categoryIds {
    final filtered = _selectedUniversityId == null
        ? _reports
        : _reports.where((r) => r.universityId == _selectedUniversityId);
    return filtered.map((r) => r.categoryId).toSet().toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raporlar (SuperAdmin)'),
        backgroundColor: Colors.deepPurple,
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
                    value: _selectedUniversityId,
                    hint: const Text('Üniversite'),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Tümü'),
                      ),
                      ..._universities.map(
                        (uni) => DropdownMenuItem<int?>(
                          value: uni.universityId,
                          child: Text(uni.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedUniversityId = value;
                        _selectedCategoryId = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
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
                              backgroundColor: Colors.deepPurple,
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
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _confirmDeleteReport(report);
                                } else if (value == 'changeStatus') {
                                  _showChangeStatusDialog(report);
                                } else if (value == 'editDescription') {
                                  _showEditDescriptionDialog(report);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'changeStatus',
                                  child: Row(
                                    children: [
                                      Icon(Icons.swap_horiz, size: 20),
                                      SizedBox(width: 8),
                                      Text('Durum Değiştir'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'editDescription',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text('Açıklama Düzenle'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Sil',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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

  void _confirmDeleteReport(SuperAdminReport report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Raporu Sil'),
        content: Text(
          '${report.title} raporunu silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteReport(report.reportId);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteReport(int reportId) async {
    try {
      await SuperAdminReportActions.deleteReport(reportId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rapor silindi'),
            backgroundColor: Colors.green,
          ),
        );
        _loadReports();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showChangeStatusDialog(SuperAdminReport report) {
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

  Future<void> _updateReportStatus(int reportId, String newStatus) async {
    try {
      await SuperAdminReportActions.updateReportStatus(
        reportId: reportId,
        status: newStatus,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Durum güncellendi'),
            backgroundColor: Colors.green,
          ),
        );
        _loadReports();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
