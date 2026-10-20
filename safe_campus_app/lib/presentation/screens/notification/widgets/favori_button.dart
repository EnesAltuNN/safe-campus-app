import 'package:flutter/material.dart';

class FavoriteButton extends StatefulWidget {
  final bool initialIsFavorite; // Başlangıçta favori mi? (Backend'den gelen)
  final Function(bool isFavorite)? onToggle; // Tıklandığında ne olsun? (Opsiyonel)

  const FavoriteButton({
    super.key,
    this.initialIsFavorite = false, // Varsayılan false
    this.onToggle,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialIsFavorite;
  }

  void _toggle() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    if (widget.onToggle != null) {
      widget.onToggle!(_isFavorite);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _toggle,
      constraints: const BoxConstraints(), 
      padding: EdgeInsets.zero,
      icon: Icon(
        _isFavorite ? Icons.star : Icons.star_border,
        color: _isFavorite ? Colors.amber : Colors.grey,
        size: 24,
      ),
    );
  }
}