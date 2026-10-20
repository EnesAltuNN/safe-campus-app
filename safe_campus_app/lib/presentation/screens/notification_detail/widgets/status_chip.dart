import 'package:flutter/material.dart';
import 'package:safe_campus_app/core/helper/helper_functions.dart';

class StatusChip extends StatefulWidget {
  // status değeri
  // statuse göre renk var icon yok
  const StatusChip({super.key, required this.status});
  final String status;

  @override
  State<StatusChip> createState() => _StatusChipState();
}

class _StatusChipState extends State<StatusChip> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: HelperFunctions.getColorWithStatus(widget.status).withAlpha(155),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: HelperFunctions.getColorWithStatus(
            widget.status,
          ).withAlpha(200),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            HelperFunctions.getIconStatus(widget.status),
            color: HelperFunctions.getColorWithStatus(
              widget.status,
            ).withAlpha(255),
            size: 16,
          ),
          const SizedBox(width: 6),

          Text(
            widget.status,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
