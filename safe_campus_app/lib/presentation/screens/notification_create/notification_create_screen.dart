import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_campus_app/core/constants/providers/all_providers.dart';
import 'package:safe_campus_app/core/constants/sizes/sizes.dart';
import 'package:safe_campus_app/core/helper/helper_functions.dart';
import 'package:safe_campus_app/presentation/screens/notification_create/widgets/notification_type_chip.dart';
import 'package:safe_campus_app/presentation/screens/notification_create/widgets/photo_box.dart';
import 'package:safe_campus_app/presentation/screens/notification_create/widgets/section_title.dart';
import 'package:safe_campus_app/presentation/screens/notification_create/select_location_on_map.dart';
import 'package:safe_campus_app/services/auth_service.dart';
import 'package:safe_campus_app/services/report_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationCreateScreen extends ConsumerStatefulWidget {
  const NotificationCreateScreen({super.key});

  @override
  ConsumerState<NotificationCreateScreen> createState() =>
      _NotificationCreateScreenState();
}

class _NotificationCreateScreenState
    extends ConsumerState<NotificationCreateScreen> {
  LatLng? selectedLocation;
  bool locationSelected = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _loading = false;
  XFile? _selectedImage;
  List<String> _uploadedImageUrls = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<String?> uploadImageToFirebaseStorage(XFile imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        'notification_images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}',
      );
      await storageRef.putData(await imageFile.readAsBytes());
      final downloadUrl = await storageRef.getDownloadURL();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Firebase başarıyla URL oluşturuldu'),
          backgroundColor: Colors.green,
        ),
      );
      return downloadUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fotoğraf yüklenemedi: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(AppProviders.notificationFilterProvider);

    // Bildirim türleri backend ile uyumlu olacak şekilde güncellendi.
    final List<Map<String, dynamic>> notificationTypes = [
      {"label": "Acil Durum", "id": 1, "icon": Icons.warning_amber_rounded},
      {"label": "Sağlık", "id": 2, "icon": Icons.medical_services_outlined},
      {"label": "Güvenlik", "id": 3, "icon": Icons.security},
      {"label": "Teknik Arıza", "id": 4, "icon": Icons.build_outlined},
      {"label": "Kayıp & Buluntu", "id": 5, "icon": Icons.search},
      {"label": "Temizlik", "id": 6, "icon": Icons.cleaning_services},
      {"label": "Bilişim & İnternet", "id": 7, "icon": Icons.wifi},
      {"label": "Yemekhane", "id": 8, "icon": Icons.restaurant},
      {"label": "Diğer", "id": 9, "icon": Icons.more_horiz},
    ];

    // Yüklenen görsel URL'lerini ekranda göster
    Widget uploadedUrlsWidget = _uploadedImageUrls.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Fotoğraf ekleme başarılı:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ..._uploadedImageUrls.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fotoğraf ${entry.key + 1}: ',
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Expanded(
                        child: SelectableText(
                          entry.value,
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        : const SizedBox.shrink();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Yeni Bildirim Oluştur",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Sizes.fontSizeLg,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Sizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: "BİLDİRİM TÜRÜ"),

            const SizedBox(height: Sizes.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(notificationTypes.length, (index) {
                  final item = notificationTypes[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: Sizes.sm),
                    child: NotificationTypeChip(
                      item['label'],
                      item['icon'],
                      selectedIndex == index,
                      index,
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: Sizes.lg),

            // --- Konu Başlığı ---
            const SectionTitle(title: "KONU BAŞLIĞI"),
            const SizedBox(height: Sizes.sm),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: HelperFunctions.inputDecoration(
                "Örn: Laboratuvar havalandırma arızası",
              ),
            ),

            const SizedBox(height: Sizes.lg),

            // --- Detaylı Açıklama ---
            const SectionTitle(title: "DETAYLI AÇIKLAMA"),
            const SizedBox(height: Sizes.sm),
            TextField(
              controller: _descController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: HelperFunctions.inputDecoration(
                "Lütfen durumu detaylı bir şekilde açıklayınız...",
              ),
            ),

            const SizedBox(height: Sizes.lg),

            // --- Konum Kartı ---
            const SectionTitle(title: "KONUM"),
            const SizedBox(height: Sizes.sm),
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectLocationOnMapScreen(
                      initialLocation: selectedLocation,
                    ),
                  ),
                );
                if (result != null && result is LatLng) {
                  setState(() {
                    selectedLocation = result;
                    locationSelected = true;
                  });
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: selectedLocation == null
                              ? const Text(
                                  "Haritadan konum seç",
                                  style: TextStyle(color: Colors.white70),
                                )
                              : Text(
                                  "Seçilen Konum: ${selectedLocation!.latitude.toStringAsFixed(5)}, ${selectedLocation!.longitude.toStringAsFixed(5)}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                        ),
                        const Icon(Icons.map, color: Colors.green),
                      ],
                    ),
                  ),
                  if (locationSelected && selectedLocation != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                        left: 4.0,
                        right: 4.0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green[700],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Konum başarıyla seçildi',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: Sizes.lg),

            // --- Fotoğraf Ekle ---
            const SectionTitle(title: "FOTOĞRAF EKLE (İSTEĞE BAĞLI)"),
            const SizedBox(height: Sizes.sm),
            Row(
              children: [
                Expanded(
                  child: PhotoBox(
                    icon: Icons.camera_alt,
                    label: "Kamera",
                    onTap: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(
                        source: ImageSource.camera,
                      );
                      if (pickedFile != null) {
                        setState(() {
                          _selectedImage = pickedFile;
                        });
                        final url = await uploadImageToFirebaseStorage(
                          pickedFile,
                        );
                        if (url != null) {
                          setState(() {
                            _uploadedImageUrls.add(url);
                          });
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: Sizes.defaultSpace),
                Expanded(
                  child: PhotoBox(
                    icon: Icons.image,
                    label: "Galeri",
                    onTap: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (pickedFile != null) {
                        setState(() {
                          _selectedImage = pickedFile;
                        });
                        final url = await uploadImageToFirebaseStorage(
                          pickedFile,
                        );
                        if (url != null) {
                          setState(() {
                            _uploadedImageUrls.add(url);
                          });
                        }
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: Sizes.lg),

            // Yüklenen görsel URL'lerini göster
            uploadedUrlsWidget,

            // --- Gönder Butonu ---
            SizedBox(
              width: double.infinity,
              height: Sizes.xxl,
              child: ElevatedButton(
                onPressed: _loading
                    ? null
                    : () async {
                        final title = _titleController.text.trim();
                        final desc = _descController.text.trim();
                        final categoryId =
                            ref.read(AppProviders.notificationFilterProvider) +
                            1;
                        if (title.isEmpty ||
                            desc.isEmpty ||
                            selectedLocation == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Lütfen tüm alanları doldurun ve konum seçin.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        setState(() {
                          _loading = true;
                        });
                        try {
                          final user = AuthService.currentUser;
                          if (user == null || user.universityId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Kullanıcı veya üniversite bilgisi eksik!',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            setState(() {
                              _loading = false;
                            });
                            return;
                          }
                          await ReportService.createReport(
                            universityId: user.universityId!,
                            userId: user.id,
                            title: title,
                            description: desc,
                            categoryId: categoryId,
                            latitude: selectedLocation!.latitude,
                            longitude: selectedLocation!.longitude,
                            images: _uploadedImageUrls,
                          );
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bildirim başarıyla gönderildi.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.of(context).pop();
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Hata: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          if (mounted)
                            setState(() {
                              _loading = false;
                            });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Sizes.buttonRadius),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "BİLDİRİMİ GÖNDER",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Sizes.fontSizeMd,
                            ),
                          ),
                          SizedBox(width: Sizes.sm),
                          Icon(Icons.send, size: Sizes.iconMd),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: Sizes.lg),
          ],
        ),
      ),
    );
  }
}
