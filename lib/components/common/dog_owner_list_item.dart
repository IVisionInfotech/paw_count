import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:survey_dogapp/model/dogOwner.dart';
import 'package:survey_dogapp/components/theme.dart';

import 'custom_image_shimmer_effect.dart';

class DogOwnerListItem extends StatelessWidget {
  final DogOwner dogOwner;
  final VoidCallback? onEdit;

  const DogOwnerListItem({
    Key? key,
    required this.dogOwner,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.background,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dogOwner.ownerName ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  dogOwner.petName ?? '-',
                  style: const TextStyle(color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('📞 ${dogOwner.ownerContact ?? '-'}', style: const TextStyle(fontSize: 14)),
            Text('🧬 ${dogOwner.dogBreedName ?? '-'}   🎨 ${dogOwner.dogColorName ?? '-'}', style: const TextStyle(fontSize: 14)),
            Text('♂️ ${dogOwner.gender ?? '-'}   🎂 ${dogOwner.age ?? '-'} yrs   🏠 ${dogOwner.currentAddress ?? '-'}', style: const TextStyle(fontSize: 14)),
            if (dogOwner.latLong != null && dogOwner.latLong!.isNotEmpty)
              Text('📍 ${dogOwner.latLong}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (dogOwner.ownerImage != null && dogOwner.ownerImage!.isNotEmpty)
                      ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: dogOwner.ownerImage ?? "N/A",
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) =>
                              CommonShimmer(width: 45, height: 45),
                          errorWidget:
                              (context, url, error) => Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                            child: const Icon(Icons.error, color: Colors.red),
                          ),
                        ),
                      ),
                    const SizedBox(width: 10),
                    if (dogOwner.dogImage != null && dogOwner.dogImage!.isNotEmpty)
                      ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: dogOwner.dogImage ?? "N/A",
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) =>
                              CommonShimmer(width: 45, height: 45),
                          errorWidget:
                              (context, url, error) => Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                            child: const Icon(Icons.error, color: Colors.red),
                          ),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                  onPressed: onEdit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
