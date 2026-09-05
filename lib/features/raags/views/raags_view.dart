import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/locale_keys.dart';
import '../../../core/widgets/app_animated_button.dart';
import '../../../core/widgets/app_glass_container.dart';
import '../../../core/widgets/app_glass_icon_button.dart';
import '../../../routes/app_routes.dart';
import '../../dashboard/widgets/dashboard_layout.dart';
import '../controllers/raags_controller.dart';
import '../models/raag_model.dart';

class RaagsView extends GetView<RaagsController> {
  const RaagsView({super.key});

  void _showRaagDialog(BuildContext context, {RaagModel? raag}) {
    final textController = TextEditingController(text: raag?.name);
    final isEdit = raag != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? LocaleKeys.editRaag.tr : LocaleKeys.addRaag.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: LocaleKeys.name.tr,
                  hintText: 'e.g. Bhairav, Yaman, Kalyan',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(LocaleKeys.cancel.tr),
            ),
            ElevatedButton(
              onPressed: () {
                final name = textController.text.trim();
                if (name.isNotEmpty) {
                  if (isEdit) {
                    controller.editRaag(raag.id, name);
                  } else {
                    controller.addRaag(name);
                  }
                }
              },
              child: Text(LocaleKeys.save.tr),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, RaagModel raag) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(LocaleKeys.deleteRaag.tr),
          content: Text('Are you sure you want to delete the raag "${raag.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(LocaleKeys.cancel.tr),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                controller.deleteRaag(raag.id);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final RxString searchQuery = ''.obs;

    return DashboardLayout(
      currentRoute: AppRoutes.raags,
      child: AppGlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header actions (Responsive)
            Builder(
              builder: (context) {
                final isMobile = MediaQuery.of(context).size.width < 600;
                final searchField = TextField(
                  onChanged: (val) => searchQuery.value = val,
                  decoration: InputDecoration(
                    hintText: '${LocaleKeys.search.tr} raags...',
                    prefixIcon: const Icon(Icons.search),
                  ),
                );
                final seedBtn = AppAnimatedButton(
                  onTap: () => controller.seedInitialRaags(),
                  child: OutlinedButton.icon(
                    onPressed: () => controller.seedInitialRaags(),
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text('Seed Default Raags'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.purple,
                    ),
                  ),
                );
                final addBtn = AppAnimatedButton(
                  onTap: () => _showRaagDialog(context),
                  child: ElevatedButton.icon(
                    onPressed: () => _showRaagDialog(context),
                    icon: const Icon(Icons.add),
                    label: Text(LocaleKeys.addRaag.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                );

                  if (isMobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        searchField,
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.end,
                          children: [
                            seedBtn,
                            addBtn,
                          ],
                        ),
                      ],
                    );
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: searchField,
                        ),
                      ),
                      Row(
                        children: [
                          seedBtn,
                          const SizedBox(width: 12),
                          addBtn,
                        ],
                      ),
                    ],
                  );

                },
              ),
              const SizedBox(height: 24),

              // Data Table Area
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Local filter based on search query
                  final filteredRaags = controller.raags.where((raag) {
                    return raag.name.toLowerCase().contains(searchQuery.value.toLowerCase());
                  }).toList();

                  if (filteredRaags.isEmpty) {
                    return const Center(
                      child: Text('No raags found.'),
                    );
                  }

                  return DataTable2(
                    dataRowColor: WidgetStateProperty.all(Colors.transparent),
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 600,
                    columns: [
                      DataColumn2(
                        label: Text(LocaleKeys.name.tr),
                        size: ColumnSize.L,
                      ),
                      DataColumn2(
                        label: const Text('Created At'),
                        size: ColumnSize.M,
                      ),
                      const DataColumn2(
                        label: Text('Actions'),
                        size: ColumnSize.S,
                        numeric: true,
                      ),
                    ],
                    rows: filteredRaags.map((raag) {
                      return DataRow(
                        cells: [
                          DataCell(Text(
                            raag.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          )),
                          DataCell(Text(
                            DateFormat('yyyy-MM-dd HH:mm').format(raag.createdAt.toLocal()),
                          )),
                          DataCell(
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AppGlassIconButton(
                                  icon: Icons.edit_outlined,
                                  color: Colors.purpleAccent,
                                  onPressed: () => _showRaagDialog(context, raag: raag),
                                  tooltip: LocaleKeys.editRaag.tr,
                                ),
                                const SizedBox(width: 8),
                                AppGlassIconButton(
                                  icon: Icons.delete_outline,
                                  color: Colors.redAccent,
                                  onPressed: () => _confirmDelete(context, raag),
                                  tooltip: LocaleKeys.deleteRaag.tr,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  );
                }),
              ),
            ],
          ),
        ),
      );
  }
}
