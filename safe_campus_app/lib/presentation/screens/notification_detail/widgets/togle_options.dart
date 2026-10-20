import 'package:flutter/material.dart';

class TogleOptions extends StatefulWidget {
  final String status;
  // Seçim değiştiğinde dışarıya haber vermek için bu fonksiyonu ekledim
  final Function(String val)? onChanged; 

  const TogleOptions({
    super.key, 
    required this.status, 
    this.onChanged
  });

  @override
  State<TogleOptions> createState() => _TogleOptionsState();
}

class _TogleOptionsState extends State<TogleOptions> {
  late String _currentOption;

  @override
  void initState() {
    super.initState();
    _currentOption = widget.status;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF162620),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildToggleOption("Açık"),
          _buildToggleOption("İnceleniyor"),
          _buildToggleOption("Çözüldü"),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label) {
    bool isSelected = _currentOption == label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentOption = label; // Durumu güncelle
          });
          
          if (widget.onChanged != null) {
            widget.onChanged!(label);
          }
          
          print("Seçilen durum: $label");
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00E676) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}