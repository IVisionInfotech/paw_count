import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:survey_dogapp/components/common/custom_image_shimmer_effect.dart';
import 'package:survey_dogapp/model/dog_type_model.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/generated/FontHelper.dart';
import 'package:flutter/cupertino.dart';

class ListCardView extends StatelessWidget {
  final DogTypeModel dog;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ListCardView({
    Key? key,
    required this.dog,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        leading:
            dog.imagePath != null && dog.imagePath!.isNotEmpty
                ? Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400, width: 2),
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: dog.imagePath ?? "N/A",
                      width: 46,
                      height: 46,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) =>
                              CommonShimmer(width: 50, height: 50),
                      errorWidget:
                          (context, url, error) => Container(
                            width: 46,
                            height: 46,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                            child: const Icon(Icons.error, color: Colors.red),
                          ),
                    ),
                  ),
                )
                : Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400, width: 2),
                  ),
                  child: const Icon(Icons.pets, size: 30),
                ),

        title: Text(dog.name ?? "N/A", style: FontHelper.bold(fontSize: 16)),
        subtitle: Text(
          dog.description ?? "N/A",
          style: FontHelper.regular(fontSize: 14),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
