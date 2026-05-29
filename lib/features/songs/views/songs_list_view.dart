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
                  final isMobile = size.width < 950;

                  final searchField = TextField(
                    onChanged: (val) => controller.searchQuery.value = val,
                    decoration: InputDecoration(
                      hintText: '${LocaleKeys.search.tr} title or singer...',
                      prefixIcon: const Icon(Icons.search),
                    ),
                  );

                  final categoryFilter = Obx(() {
                    return DropdownButtonFormField<String>(
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

                  final actionButtons = Row(
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
                  );

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
                        actionButtons,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: searchField,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: categoryFilter,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: statusFilter,
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

                  if (controller.songs.isEmpty) {
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
                        label: Text('Created'),
                        size: ColumnSize.M,
                      ),
                      const DataColumn2(
                        label: Text('Actions'),
                        size: ColumnSize.S,
                        numeric: true,
                      ),
                    ],
                    rows: controller.songs.map((song) {
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
                          DataCell(Text(
                            DateFormat('yyyy-MM-dd').format(song.createdAt.toLocal()),
                          )),
                          DataCell(
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility_outlined, color: Colors.green),
                                  onPressed: () => _showLyricsDialog(context, song),
                                  tooltip: 'View Lyrics',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                                  onPressed: () {
                                    controller.clearSelectedImage();
                                    Get.toNamed(AppRoutes.songEditor, arguments: song);
                                  },
                                  tooltip: LocaleKeys.editSong.tr,
                                ),
                                IconButton(
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
