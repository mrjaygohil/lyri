import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/locale_keys.dart';
import '../../../routes/app_routes.dart';
import '../../dashboard/widgets/dashboard_layout.dart';
import '../controllers/tags_controller.dart';
import '../models/tag_model.dart';

class TagsView extends GetView<TagsController> {
  const TagsView({super.key});

  void _showTagDialog(BuildContext context, {TagModel? tag}) {
    final textController = TextEditingController(text: tag?.name);
    final isEdit = tag != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? LocaleKeys.editTag.tr : LocaleKeys.addTag.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: LocaleKeys.name.tr,
                  hintText: 'e.g. Rock, Pop, Devotional',
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
                    controller.editTag(tag.id, name);
                  } else {
                    controller.addTag(name);
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

  void _confirmDelete(BuildContext context, TagModel tag) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(LocaleKeys.deleteTag.tr),
          content: Text('Are you sure you want to delete the tag "${tag.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(LocaleKeys.cancel.tr),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                controller.deleteTag(tag.id);
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
      currentRoute: AppRoutes.tags,
      child: Card(
        child: Padding(
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
                      hintText: '${LocaleKeys.search.tr} tags...',
                      prefixIcon: const Icon(Icons.search),
                    ),
                  );
                  final addBtn = ElevatedButton.icon(
                    onPressed: () => _showTagDialog(context),
                    icon: const Icon(Icons.add),
                    label: Text(LocaleKeys.addTag.tr),
                  );

                  if (isMobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        searchField,
                        const SizedBox(height: 12),
                        addBtn,
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
                      addBtn,
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
                  final filteredTags = controller.tags.where((tag) {
                    return tag.name.toLowerCase().contains(searchQuery.value.toLowerCase());
                  }).toList();

                  if (filteredTags.isEmpty) {
                    return const Center(
                      child: Text('No tags found.'),
                    );
                  }

                  return DataTable2(
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
                    rows: filteredTags.map((tag) {
                      return DataRow(
                        cells: [
                          DataCell(Text(
                            tag.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          )),
                          DataCell(Text(
                            DateFormat('yyyy-MM-dd HH:mm').format(tag.createdAt.toLocal()),
                          )),
                          DataCell(
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                                  onPressed: () => _showTagDialog(context, tag: tag),
                                  tooltip: LocaleKeys.editTag.tr,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => _confirmDelete(context, tag),
                                  tooltip: LocaleKeys.deleteTag.tr,
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
      ),
    );
  }
}
