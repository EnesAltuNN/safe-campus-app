import 'package:flutter/material.dart';
import 'package:safe_campus_app/core/constants/sizes/sizes.dart';

class SelectOnMap extends StatelessWidget {
  const SelectOnMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(Sizes.inputFieldRadius),
      clipBehavior:
          Clip.hardEdge, // BU ÇOK ÖNEMLİ: Efektin dışa taşmasını engeller
      child: InkWell(
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF162620),
            borderRadius: BorderRadius.circular(Sizes.inputFieldRadius),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(Sizes.md),
                child: Row(
                  children: [
                    // Harita İkonu
                    Container(
                      width: Sizes.xxl,
                      height: Sizes.xxl,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          Sizes.inputFieldRadius,
                        ),
                        color: Colors.grey[800],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: Sizes.md),
                    // Konum Bilgisi
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "OTOMATİK KONUM",
                            style: TextStyle(
                              color: Color(0xFF00E676),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: Sizes.xs),
                          const Text(
                            "Mühendislik Fakültesi",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            "C Blok, Zemin Kat, Koridor 2",
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Düzenle Butonu
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.white10),
              // Haritadan Seç
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(Sizes.buttonRadius),
                    bottomRight: Radius.circular(Sizes.buttonRadius),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: Sizes.iconMd, color: Colors.grey),
                    SizedBox(width: Sizes.sm),
                    Text(
                      "Haritadan Seç",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        /*  */
      ),
    );
  }
}
