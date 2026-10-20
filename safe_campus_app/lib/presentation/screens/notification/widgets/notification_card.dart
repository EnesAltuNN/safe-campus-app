import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_campus_app/core/constants/app_route/app_routes.dart';
import 'package:safe_campus_app/core/constants/sizes/sizes.dart';
import 'package:safe_campus_app/logic/models/notification.dart';
import 'package:safe_campus_app/presentation/screens/notification/function/get_color.dart';
import 'package:safe_campus_app/presentation/screens/notification/function/get_icon.dart';
import 'package:safe_campus_app/presentation/screens/notification/widgets/favori_button.dart';

class NotificationCard extends ConsumerWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.favoriteButton,
    this.images,
  });
  final NotificationClass notification;
  final Widget favoriteButton;
  final List<String>? images;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color themColor = getColor(notification.status);
    IconData icon = getIcon(notification.categoryId);
    return Material(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(Sizes.inputFieldRadius),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            Routes.notificationDetailScreen,
            arguments: notification,
          );
        },
        splashColor: Colors.white.withOpacity(0.1),
        child: SizedBox(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 6, color: themColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: themColor.withAlpha(30),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(icon, color: themColor, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (images != null && images!.isNotEmpty)
                                      SizedBox(
                                        height: 90,
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: images!.length,
                                          separatorBuilder: (context, i) =>
                                              const SizedBox(width: 8),
                                          itemBuilder: (context, i) =>
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  images![i],
                                                  width: 90,
                                                  height: 90,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => Container(
                                                        color: Colors.grey[800],
                                                        width: 90,
                                                        height: 90,
                                                        child: const Icon(
                                                          Icons.broken_image,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                        ),
                                      ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: themColor.withAlpha(30),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        notification.status,
                                        style: TextStyle(
                                          color: themColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      notification.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              favoriteButton,
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            notification.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                notification.createdAt.toString(),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(width: 4),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
