import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_dogapp/components/City/Model/LocationModel.dart';
import 'package:survey_dogapp/components/Filter/filter_download_screen.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/cotroller/chart_cotroller.dart';
import 'package:survey_dogapp/generated/FontHelper.dart';
import 'package:survey_dogapp/generated/assets.dart';
import 'package:survey_dogapp/model/report_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:lottie/lottie.dart';

class Homepage extends StatelessWidget {
  final ChartController controller = Get.put(ChartController());


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Obx(
              () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdowns(controller),
              const SizedBox(height: 20),
              Text(
                "${controller.selectedState.value?.locationName ?? 'No State Selected'} > "
                    "${controller.selectedCity.value?.locationName ?? 'No City Selected'} - Dog Category Summary",
                style: FontHelper.bold(fontSize: 18, color: Colors.black),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              controller.isLoading.value
                  ? Expanded(
                child: Center(
                  child: Lottie.asset(Assets.imagesLoader),
                ),
              )
                  : controller.selectedCategoryData.isEmpty
                  ? const Expanded(child: Center(child: Text("No data available")))
                  : Expanded(
                child: ListView(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        key: ValueKey(controller.selectedWard.value),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 400,
                            child: SfCircularChart(
                              legend: Legend(
                                isVisible: true,
                                position: LegendPosition.top,
                                iconHeight: 10,
                                iconWidth: 10,
                                textStyle: const TextStyle(fontSize: 12, color: Colors.black),
                                overflowMode: LegendItemOverflowMode.wrap,
                              ),
                              series: <CircularSeries>[
                                PieSeries<DogCatchDataModel, String>(
                                  dataSource: controller.selectedCategoryData,
                                  xValueMapper: (d, _) => d.name,
                                  yValueMapper: (d, _) => d.dogCount,
                                  dataLabelSettings: const DataLabelSettings(
                                    isVisible: true,
                                    textStyle: TextStyle(fontSize: 12, color: Colors.white),
                                  ),
                                  pointColorMapper: (d, index) {
                                    return Assets.dogTypeColors[index % Assets.dogTypeColors.length];
                                  },
                                  animationDuration: 1000,
                                  explode: true,
                                  explodeIndex: 0,
                                ),
                              ],
                              backgroundColor: Colors.white,
                              tooltipBehavior: TooltipBehavior(
                                enable: true,
                                header: 'Dog Category',
                                format: 'point.x : point.y',
                                textStyle: const TextStyle(fontSize: 12, color: Colors.white),
                              ),
                              borderColor: Colors.grey[300]!,
                              borderWidth: 1,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // You can add extra content here if needed
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if(controller.selectedCategoryData.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.to(() => FilterDownloadScreen());
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Download PDF"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                ),
              ),
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildDropdowns(ChartController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _dropdown(
            hint: "Select State",
            value: controller.selectedState.value,
            items: controller.states,
            onChanged: controller.updateState,
          ),
          _dropdown(
            hint: "Select City",
            value: controller.selectedCity.value,
            items: controller.cities,
            onChanged: controller.updateCity,
          ),
          _dropdown(
            hint: "Select Zone",
            value: controller.selectedZone.value,
            items: controller.zones,
            onChanged: controller.updateZone,
          ),
          _dropdown(
            hint: "Select Ward",
            value: controller.selectedWard.value,
            items: controller.wards,
            onChanged: controller.updateWard,
          ),
          _dropdown(
            hint: "Select Area",
            value: controller.selectedArea.value,
            items: controller.areas,
            onChanged: controller.updateArea,
          ),
        ],
      ),
    );
  }

  Widget _dropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required void Function(T) onChanged,
  }) {
    return Obx(
      () => Container(
        width: 160,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: DropdownButton<T>(
          isExpanded: true,
          hint: Text(hint),
          value: value,
          items:
              items.map((item) {
                final name = (item as LocationModel).locationName ?? 'N/A';
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(name, style: FontHelper.regular(fontSize: 14)),
                );
              }).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }
}
