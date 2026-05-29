import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/locale_keys.dart';
import '../../../routes/app_routes.dart';
import '../../dashboard/widgets/dashboard_layout.dart';
import '../controllers/categories_controller.dart';
import '../models/category_model.dart';

class CategoriesView extends GetView<CategoriesController> {
  const CategoriesView({super.key});

  void _showCategoryDialog(BuildContext context, {CategoryModel? category}) {
    controller.clearSelectedImage();
    final nameController = TextEditingController(text: category?.name);
    final RxBool isCategoryActive = (category?.status ?? true).obs;
    final theme = Theme.of(context);
    final isEdit = category != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? LocaleKeys.editCategory.tr : LocaleKeys.addCategory.tr),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Name
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: LocaleKeys.name.tr,
                      hintText: 'e.g. Pop, Jazz, Gospel',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Image Selection
                  const Text(
                    'Category Thumbnail Image',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final hasLocalImage = controller.selectedImageBytes.value != null;
                    final hasExistingImage = category?.image != null;

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          if (hasLocalImage)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                controller.selectedImageBytes.value!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                          else if (hasExistingImage)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                category!.image!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                              ),
                            )
                          else
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.image, color: Colors.grey),
                            ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hasLocalImage 
                                      ? controller.selectedImageName.value 
                                      : (hasExistingImage ? 'Using saved image' : 'No image selected'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    TextButton(
                                      onPressed: controller.pickCategoryImage,
                                      child: const Text('Pick Image'),
                                    ),
                                    if (hasLocalImage)
                                      TextButton(
                                        onPressed: controller.clearSelectedImage,
                                        child: const Text('Clear', style: TextStyle(color: Colors.red)),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

                  // Category Status
                  Obx(() {
                    return SwitchListTile(
                      title: Text(LocaleKeys.status.tr),
                      subtitle: Text(isCategoryActive.value ? LocaleKeys.active.tr : LocaleKeys.inactive.tr),
                      value: isCategoryActive.value,
                      onChanged: (val) => isCategoryActive.value = val,
                      contentPadding: EdgeInsets.zero,
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(LocaleKeys.cancel.tr),
            ),
            Obx(() {
              final isSubmitting = controller.isLoading.value || controller.isUploading.value;
              return ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () {
                        final name = nameController.text.trim();
                        if (name.isNotEmpty) {
                          if (isEdit) {
                            controller.editCategory(
                              id: category.id,
                              name: name,
                              status: isCategoryActive.value,
                              existingImageUrl: category.image,
                            );
                          } else {
                            controller.addCategory(
                              name,
                              isCategoryActive.value,
                            );
                          }
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(LocaleKeys.save.tr),
              );
            }),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(LocaleKeys.deleteCategory.tr),
          content: Text('Are you sure you want to delete the category "${category.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(LocaleKeys.cancel.tr),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                controller.deleteCategory(category.id);
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
      currentRoute: AppRoutes.categories,
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
                      hintText: '${LocaleKeys.search.tr} categories...',
                      prefixIcon: const Icon(Icons.search),
                    ),
                  );
                  final addBtn = ElevatedButton.icon(
                    onPressed: () => _showCategoryDialog(context),
                    icon: const Icon(Icons.add),
                    label: Text(LocaleKeys.addCategory.tr),
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
                  if (controller.isLoading.value && !controller.isUploading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Local filter based on search query
                  final filteredCategories = controller.categories.where((cat) {
                    return cat.name.toLowerCase().contains(searchQuery.value.toLowerCase());
                  }).toList();

                  if (filteredCategories.isEmpty) {
                    return const Center(
                      child: Text('No categories found.'),
                    );
                  }

                  return DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 700,
                    columns: [
                      const DataColumn2(
                        label: Text('Image'),
                        size: ColumnSize.S,
                      ),
                      DataColumn2(
                        label: Text(LocaleKeys.name.tr),
                        size: ColumnSize.L,
                      ),
                      DataColumn2(
                        label: Text(LocaleKeys.status.tr),
                        size: ColumnSize.S,
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
                    rows: filteredCategories.map((cat) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: cat.image != null
                                    ? Image.network(
                                        cat.image!,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 20),
                                      )
                                    : Container(
                                        width: 40,
                                        height: 40,
                                        color: Colors.grey.withOpacity(0.2),
                                        child: const Icon(Icons.image, size: 20, color: Colors.grey),
                                      ),
                              ),
                            ),
                          ),
                          DataCell(Text(
                            cat.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          )),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: cat.status
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                cat.status ? LocaleKeys.active.tr : LocaleKeys.inactive.tr,
                                style: TextStyle(
                                  color: cat.status ? Colors.green : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(
                            DateFormat('yyyy-MM-dd').format(cat.createdAt.toLocal()),
                          )),
                          DataCell(
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                                  onPressed: () => _showCategoryDialog(context, category: cat),
                                  tooltip: LocaleKeys.editCategory.tr,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => _confirmDelete(context, cat),
                                  tooltip: LocaleKeys.deleteCategory.tr,
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
