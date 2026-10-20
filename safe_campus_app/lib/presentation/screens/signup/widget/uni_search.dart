import 'package:flutter/material.dart';
import 'package:safe_campus_app/core/constants/sizes/sizes.dart';
import 'package:safe_campus_app/core/constants/texts/app_texts.dart';

class UniSearch extends StatefulWidget {
  const UniSearch({super.key});

  @override
  State<UniSearch> createState() => _UniSearchState();
}

class _UniSearchState extends State<UniSearch> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      builder: (BuildContext context, SearchController controller) {
        return SearchBar(
          hintText: "Üniversite Adı",
          controller: controller,
     /*            padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ), */
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                Sizes.inputFieldRadius,
              ), // Bu sayıyı artırırsan daha yuvarlak olur
            ),
          ),
          onTap: () {
            controller.openView();
          },
          onChanged: (_) {
            controller.openView();
          },
          leading: const Icon(Icons.search),
        );
      },
      viewShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          Sizes.inputFieldRadius,
        ), // Yumuşaklık miktarını buradan ayarla
      ),
      
      suggestionsBuilder:
          (BuildContext context, SearchController controller) {
            final String keyword = controller.text.toLowerCase();
            final unilistesi = Texts.universiyNamesList;
    
            final List<String> filteredItems = unilistesi.where((item) {
              return item.toLowerCase().contains(keyword);
            }).toList();
    
            return filteredItems.map((item) {
              return ListTile(
                title: Text(item),
                onTap: () {
                  setState(() {
                    controller.closeView(
                      item,
                    ); // Seçileni arama çubuğuna yazar ve kapatır
                    FocusScope.of(context).unfocus();
                  });
                },
              );
            }).toList();
          },
      isFullScreen: false,
      viewConstraints: const BoxConstraints(
        maxHeight:
            300, // Açılan listenin yüksekliği en fazla 300 piksel olsun
        //  maxWidth: 340, // Genişliği de sınırlayabilirsin (opsiyonel)
      ),
      viewHintText: "Üniversite Adı",
    );
  }
}
