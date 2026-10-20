import 'package:flutter/material.dart';
import 'package:safe_campus_app/core/constants/app_route/app_routes.dart';
import 'package:safe_campus_app/logic/models/notification.dart';
import 'package:safe_campus_app/presentation/screens/map/campus_polygon_screen.dart';
import 'package:safe_campus_app/presentation/screens/notification/widgets/notification_card.dart';
import 'package:safe_campus_app/services/report_service.dart';
import 'package:safe_campus_app/services/auth_service.dart';
import 'package:safe_campus_app/services/report_follow_service.dart';
import 'package:safe_campus_app/presentation/screens/notification/widgets/favori_button.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:safe_campus_app/services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Otomatik güncelleme için timer
  Timer? _refreshTimer;
  // Takip edilen rapor ID'leri
  final Set<int> _followedReportIds = {};
  String _searchText = "";
  final TextEditingController _searchController = TextEditingController();

  // Seçilen kategori ve arama metnine göre bildirimleri filtrele
  List<NotificationClass> _filteredNotifications() {
    final selectedCategoryId = _kategoriler[_secilenKategoriIndex]["id"];
    List<NotificationClass> filtered = selectedCategoryId == null
        ? notifications
        : notifications
              .where((n) => n.categoryId == selectedCategoryId)
              .toList();
    if (_searchText.isNotEmpty) {
      filtered = filtered
          .where(
            (n) =>
                n.title.toLowerCase().contains(_searchText.toLowerCase()) ||
                n.description.toLowerCase().contains(_searchText.toLowerCase()),
          )
          .toList();
    }
    return filtered;
  }

  // --- STATE DEĞİŞKENLERİ ---
  final ScrollController _scrollController = ScrollController();
  int _secilenKategoriIndex = 0;

  // Kategori adı ve ID eşlemesi
  final List<Map<String, dynamic>> _kategoriler = [
    {"ad": "Tümü", "id": null},
    {"ad": "Acil Durum", "id": 1},
    {"ad": "Sağlık", "id": 2},
    {"ad": "Güvenlik", "id": 3},
    {"ad": "Teknik Arıza", "id": 4},
    {"ad": "Kayıp & Buluntu", "id": 5},
    {"ad": "Temizlik", "id": 6},
    {"ad": "Bilişim & İnternet", "id": 7},
    {"ad": "Yemekhane", "id": 8},
    {"ad": "Diğer", "id": 9},
  ];

  List<NotificationClass> notifications = [];
  bool _loading = true;
  String? _error;

  @override
  @override
  void initState() {
    super.initState();
    _initializeFollowedReportsAndNotifications();
    // Her 30 saniyede bir otomatik güncelleme
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchNotifications();
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // Sonsuz kaydırma için backend'den daha fazla veri çekme işlemi burada eklenebilir.
      }
    });
  }

  Future<void> _initializeFollowedReportsAndNotifications() async {
    try {
      final followedIds = await ReportFollowService.getFollowedReportIds();
      setState(() {
        _followedReportIds.clear();
        _followedReportIds.addAll(followedIds);
      });
    } catch (e) {
      // Hata durumunda sessizce geç
    }
    await _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    // TODO: Takip edilen raporlar backend'den alınacaksa burada çekilebilir.
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = AuthService.currentUser;
      if (user == null || user.universityId == null) {
        setState(() {
          _error = 'Kullanıcı veya üniversite bilgisi bulunamadı.';
          _loading = false;
        });
        return;
      }
      final allReports = await ReportService.getAllReports();
      // Sadece kullanıcının üniversitesine ait olanlar filtreleniyor
      final newNotifications = allReports
          .where((r) => r.universityId == user.universityId)
          .map(
            (r) => NotificationClass(
              id: r.reportId,
              reportId: r.reportId,
              universityId: r.universityId,
              userId: r.userId,
              categoryId: r.categoryId,
              title: r.title,
              description: r.description,
              latitude: r.latitude ?? 0.0,
              longitude: r.longitude ?? 0.0,
              status: r.status,
              createdAt: r.createdAt,
            ),
          )
          .toList();

      // Takip edilen raporlardan güncellenen var mı kontrol et
      final updatedFollowed = newNotifications.where(
        (n) =>
            _followedReportIds.contains(n.id) &&
            notifications.any(
              (old) => old.id == n.id && old.status != n.status,
            ),
      );
      if (updatedFollowed.isNotEmpty) {
        for (final notif in updatedFollowed) {
          NotificationService.showNotification(
            title: 'Takip ettiğiniz rapor güncellendi',
            body: notif.title,
            reportId: notif.id,
          );
        }
      }
      notifications = newNotifications;
      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Bildirimler alınamadı: $e';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          "Bildirimler",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.map_outlined, color: Colors.white),
              onPressed: () {
                final user = AuthService.currentUser;
                if (user?.universityId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CampusPolygonScreen(
                        universityId: user!.universityId!,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Üniversite bilgisi bulunamadı'),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        suffixIcon: Icon(Icons.tune, color: Color(0xFF00E676)),
                        hintText: "Bildirimlerde ara...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchText = value.trim();
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _kategoriler.length,
                    itemBuilder: (context, index) {
                      final bool isSelected = _secilenKategoriIndex == index;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _secilenKategoriIndex = index),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF00E676)
                                : const Color(0xFF2C2C2E),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _kategoriler[index]["ad"],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey[400],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: RefreshIndicator(
                    color: const Color(0xFF00E676),
                    backgroundColor: const Color(0xFF2C2C2E),
                    onRefresh: _fetchNotifications,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: _filteredNotifications().length,
                      itemBuilder: (context, index) {
                        final notification = _filteredNotifications()[index];
                        // Görsel linklerini çekmek için endpoint çağrısı yapılacak (örnek async kullanım için placeholder)
                        // Burada NotificationCard'a iletilecek görsel URL'lerinden '/uploads/' önekini kaldırıyoruz
                        return FutureBuilder<List<String>>(
                          future: ReportService.getReportImages(
                            notification.id,
                          ),
                          builder: (context, snapshot) {
                            List<String> images = [];
                            if (snapshot.hasData) {
                              images = snapshot.data!
                                  .map(
                                    (url) => url.startsWith('/uploads/')
                                        ? url.substring('/uploads/'.length)
                                        : url,
                                  )
                                  .toList();
                            }
                            return Column(
                              children: [
                                NotificationCard(
                                  notification: notification,
                                  images: images,
                                  favoriteButton: FavoriteButton(
                                    initialIsFavorite: _followedReportIds
                                        .contains(notification.id),
                                    onToggle: (isFavorite) async {
                                      try {
                                        if (isFavorite) {
                                          await ReportFollowService.followReport(
                                            notification.id,
                                          );
                                          if (mounted) {
                                            setState(() {
                                              _followedReportIds.add(
                                                notification.id,
                                              );
                                            });
                                          }
                                        } else {
                                          await ReportFollowService.unfollowReport(
                                            notification.id,
                                          );
                                          if (mounted) {
                                            setState(() {
                                              _followedReportIds.remove(
                                                notification.id,
                                              );
                                            });
                                          }
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Takip işlemi başarısız: $e',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                // ...existing code...
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, Routes.notificationCreateScreen);
        },
        backgroundColor: const Color(0xFF00E676),
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          "Bildir",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
