import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/locale_keys.dart';
import '../../../routes/app_routes.dart';
import '../../dashboard/widgets/dashboard_layout.dart';
import '../controllers/songs_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../models/song_model.dart';

class SongsListView extends GetView<SongsController> {
  const SongsListView({super.key});

  void _confirmDelete(BuildContext context, SongModel song) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(LocaleKeys.deleteSong.tr),
          content: Text('Are you sure you want to delete "${song.title}"? This will remove all associated database records.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(LocaleKeys.cancel.tr),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                controller.deleteSong(song.id);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showLyricsDialog(BuildContext context, SongModel song) {
    showDialog(
      context: context,
      builder: (context) {
        double currentFontSize = 16.0;
        return StatefulBuilder(
          builder: (context, setState) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          song.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        if (song.singerName != null)
                          Text(
                            song.singerName!,
                            style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.zoom_out),
                        tooltip: 'Zoom Out',
                        onPressed: currentFontSize > 10.0
                            ? () {
                                setState(() {
                                  currentFontSize -= 2.0;
                                });
                              }
                            : null,
                      ),
                      Text(
                        '${currentFontSize.toInt()}px',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.zoom_in),
                        tooltip: 'Zoom In',
                        onPressed: currentFontSize < 40.0
                            ? () {
                                setState(() {
                                  currentFontSize += 2.0;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
              content: Container(
                width: 600,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkBg : Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  ),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    song.lyrics,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: currentFontSize,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMultiSelectDialog({
    required BuildContext context,
    required String title,
    required List<dynamic> items,
    required RxList<String> selectedIds,
    required Function() onApply,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        final searchController = TextEditingController();
        final RxList<String> tempSelected = RxList<String>.from(selectedIds);
        final RxString query = ''.obs;

        searchController.addListener(() {
          query.value = searchController.text.trim();
        });

        return AlertDialog(
          title: Text(title),
          content: Container(
            width: 400,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Obx(() {
                    final filteredItems = items.where((item) {
                      final name = item.name.toString().toLowerCase();
                      return name.contains(query.value.toLowerCase());
                    }).toList();

                    if (filteredItems.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No matches found.'),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final id = item.id as String;
                        final name = item.name as String;
                        
                        return Obx(() {
                          final isChecked = tempSelected.contains(id);
                          return CheckboxListTile(
                            title: Text(name),
                            value: isChecked,
                            onChanged: (bool? checked) {
                              if (checked == true) {
                                tempSelected.add(id);
                              } else {
                                tempSelected.remove(id);
                              }
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          );
                        });
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                tempSelected.clear();
              },
              child: const Text('Clear All'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(LocaleKeys.cancel.tr),
            ),
            ElevatedButton(
              onPressed: () {
                selectedIds.clear();
                selectedIds.addAll(tempSelected);
                onApply();
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      currentRoute: AppRoutes.songs,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Toolbar (Responsive Row/Column)
              Builder(
                builder: (context) {
                  final size = MediaQuery.of(context).size;
                  final isMobile = size.width < 1250;

                  final searchField = TextField(
                    controller: controller.searchController,
                    decoration: InputDecoration(
                      hintText: '${LocaleKeys.search.tr} title or singer...',
                      prefixIcon: const Icon(Icons.search),
                    ),
                  );

                  final categoryFilter = Obx(() {
                    return DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: controller.selectedCategoryFilter.value,
                      decoration: InputDecoration(
                        hintText: LocaleKeys.selectCategory.tr,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Categories'),
                        ),
                        ...controller.categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat.id,
                            child: Text(cat.name),
                          );
                        }),
                      ],
                      onChanged: controller.setCategoryFilter,
                    );
                  });

                  final statusFilter = Obx(() {
                    return DropdownButtonFormField<bool>(
                      isExpanded: true,
                      value: controller.selectedStatusFilter.value,
                      decoration: const InputDecoration(
                        hintText: 'Status',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Status'),
                        ),
                        DropdownMenuItem(
                          value: true,
                          child: Text(LocaleKeys.active.tr),
                        ),
                        DropdownMenuItem(
                          value: false,
                          child: Text(LocaleKeys.inactive.tr),
                        ),
                      ],
                      onChanged: controller.setStatusFilter,
                    );
                  });

                  final tagFilter = Obx(() {
                    final selectedCount = controller.selectedTagFilters.length;
                    String label = 'All Tags';
                    if (selectedCount == 1) {
                      final tagId = controller.selectedTagFilters.first;
                      final matchIndex = controller.tags.indexWhere((t) => t.id == tagId);
                      label = matchIndex != -1 ? controller.tags[matchIndex].name : 'Unknown';
                    } else if (selectedCount > 1) {
                      label = 'Tags ($selectedCount selected)';
                    }

                    return InkWell(
                      onTap: () {
                        _showMultiSelectDialog(
                          context: context,
                          title: 'Select Tags',
                          items: controller.tags,
                          selectedIds: controller.selectedTagFilters,
                          onApply: controller.loadSongs,
                        );
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          hintText: 'Tag',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: selectedCount > 0 ? null : Colors.grey.shade600,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    );
                  });

                  final raagFilter = Obx(() {
                    final selectedCount = controller.selectedRaagFilters.length;
                    String label = 'All Raags';
                    if (selectedCount == 1) {
                      final raagId = controller.selectedRaagFilters.first;
                      final matchIndex = controller.raags.indexWhere((r) => r.id == raagId);
                      label = matchIndex != -1 ? controller.raags[matchIndex].name : 'Unknown';
                    } else if (selectedCount > 1) {
                      label = 'Raags ($selectedCount selected)';
                    }

                    return InkWell(
                      onTap: () {
                        _showMultiSelectDialog(
                          context: context,
                          title: 'Select Raags',
                          items: controller.raags,
                          selectedIds: controller.selectedRaagFilters,
                          onApply: controller.loadSongs,
                        );
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          hintText: 'Raag',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: selectedCount > 0 ? null : Colors.grey.shade600,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    );
                  });

                  if (isMobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        searchField,
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: categoryFilter),
                            const SizedBox(width: 12),
                            Expanded(child: statusFilter),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: tagFilter),
                            const SizedBox(width: 12),
                            Expanded(child: raagFilter),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.filter_alt_off_outlined),
                              tooltip: 'Reset Filters',
                              onPressed: controller.resetFilters,
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: () {
                                controller.clearSelectedImage();
                                Get.toNamed(AppRoutes.songEditor);
                              },
                              icon: const Icon(Icons.add),
                              label: Text(LocaleKeys.addSong.tr),
                            ),
                          ],
                        ),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: searchField,
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.filter_alt_off_outlined),
                            tooltip: 'Reset Filters',
                            onPressed: controller.resetFilters,
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              controller.clearSelectedImage();
                              Get.toNamed(AppRoutes.songEditor);
                            },
                            icon: const Icon(Icons.add),
                            label: Text(LocaleKeys.addSong.tr),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: categoryFilter),
                          const SizedBox(width: 16),
                          Expanded(child: statusFilter),
                          const SizedBox(width: 16),
                          Expanded(child: tagFilter),
                          const SizedBox(width: 16),
                          Expanded(child: raagFilter),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Songs Datatable
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && !controller.isUploading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final approvedSongs = controller.songs
                      .where((song) => song.approvalStatus == 'approved')
                      .toList();

                  if (approvedSongs.isEmpty) {
                    return const Center(child: Text('No songs found.'));
                  }

                  return DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 900,
                    columns: [
                      const DataColumn2(
                        label: Text('Thumb'),
                        size: ColumnSize.S,
                      ),
                      DataColumn2(
                        label: Text(LocaleKeys.title.tr),
                        size: ColumnSize.L,
                      ),
                      DataColumn2(
                        label: Text(LocaleKeys.singerName.tr),
                        size: ColumnSize.M,
                      ),
                      const DataColumn2(
                        label: Text('Category'),
                        size: ColumnSize.M,
                      ),
                      DataColumn2(
                        label: Text(LocaleKeys.status.tr),
                        size: ColumnSize.S,
                      ),
                      const DataColumn2(
                        label: Text('Approval'),
                        size: ColumnSize.S,
                      ),
                      const DataColumn2(
                        label: Text('Created'),
                        size: ColumnSize.M,
                      ),
                      const DataColumn2(
                        label: Text('Actions'),
                        fixedWidth: 200,
                        numeric: true,
                      ),
                    ],
                    rows: approvedSongs.map((song) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: song.thumbnail != null
                                    ? Image.network(
                                        song.thumbnail!,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.music_video, size: 20),
                                      )
                                    : Container(
                                        width: 40,
                                        height: 40,
                                        color: Colors.grey.withOpacity(0.2),
                                        child: const Icon(Icons.music_note, size: 20, color: Colors.grey),
                                      ),
                              ),
                            ),
                          ),
                          DataCell(Text(
                            song.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          )),
                          DataCell(Text(song.singerName ?? '-')),
                          DataCell(Text(song.category?.name ?? '-')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: song.status
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                song.status ? LocaleKeys.active.tr : LocaleKeys.inactive.tr,
                                style: TextStyle(
                                  color: song.status ? Colors.green : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: song.approvalStatus == 'approved'
                                    ? Colors.blue.withOpacity(0.1)
                                    : song.approvalStatus == 'rejected'
                                        ? Colors.red.withOpacity(0.1)
                                        : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                song.approvalStatus.capitalizeFirst!,
                                style: TextStyle(
                                  color: song.approvalStatus == 'approved'
                                      ? Colors.blue
                                      : song.approvalStatus == 'rejected'
                                          ? Colors.red
                                          : Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(
                            DateFormat('yyyy-MM-dd').format(song.createdAt.toLocal()),
                          )),
                          DataCell(
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (song.approvalStatus == 'pending') ...[
                                  IconButton(
                                    iconSize: 20,
                                    padding: const EdgeInsets.all(8),
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                                    onPressed: () => controller.updateApprovalStatus(song.id, 'approved'),
                                    tooltip: 'Approve Song',
                                  ),
                                  IconButton(
                                    iconSize: 20,
                                    padding: const EdgeInsets.all(8),
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                                    onPressed: () => controller.updateApprovalStatus(song.id, 'rejected'),
                                    tooltip: 'Decline Song',
                                  ),
                                ],
                                IconButton(
                                  iconSize: 20,
                                  padding: const EdgeInsets.all(8),
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.visibility_outlined, color: Colors.green),
                                  onPressed: () => _showLyricsDialog(context, song),
                                  tooltip: 'View Lyrics',
                                ),
                                IconButton(
                                  iconSize: 20,
                                  padding: const EdgeInsets.all(8),
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                                  onPressed: () {
                                    controller.clearSelectedImage();
                                    Get.toNamed(AppRoutes.songEditor, arguments: song);
                                  },
                                  tooltip: LocaleKeys.editSong.tr,
                                ),
                                IconButton(
                                  iconSize: 20,
                                  padding: const EdgeInsets.all(8),
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => _confirmDelete(context, song),
                                  tooltip: LocaleKeys.deleteSong.tr,
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
