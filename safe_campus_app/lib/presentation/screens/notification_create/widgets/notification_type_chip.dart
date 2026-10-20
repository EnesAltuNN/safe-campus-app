import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_campus_app/core/constants/providers/all_providers.dart';
import 'package:safe_campus_app/core/constants/sizes/sizes.dart';

class NotificationTypeChip extends ConsumerWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final int index;

  const NotificationTypeChip(
    this.label,
    this.icon,
    this.isSelected,
    this.index, {
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(AppProviders.notificationFilterProvider.notifier).state = index;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00E676) : Colors.transparent,
          borderRadius: BorderRadius.circular(Sizes.lg),
          border: Border.all(
            color: isSelected ? const Color(0xFF00E676) : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: Sizes.iconSm,
              color: isSelected ? Colors.black : Colors.grey,
            ),
            const SizedBox(width: Sizes.xs),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: Sizes.fontSizeSm,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 