import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_dogapp/components/theme.dart';
import '../../cotroller/manageController.dart';

class ManagePage extends StatefulWidget {
  const ManagePage({Key? key}) : super(key: key);

  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  final ManageController controller = Get.put(ManageController());

  @override
  void initState() {
    super.initState();
    controller.fetchCountById();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Obx(
            () => GridView.count(
          crossAxisCount: isTablet ? 3 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: controller.manageItems.map((item) {
            return GestureDetector(
              onTap: () => Get.to(item['screen'])!.then((value) {
                controller.fetchCountById();
              },),
              child: Card(
                color: AppColors.background,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    if (item.containsKey('count'))
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item['count'].toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(item['icon'], size: 40, color: Colors.blueGrey),
                            const SizedBox(height: 12),
                            Text(
                              item['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
