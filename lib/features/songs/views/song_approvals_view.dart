import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/locale_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_animated_button.dart';
import '../../../core/widgets/app_glass_container.dart';
import '../../../core/widgets/app_glass_icon_button.dart';
import '../../../routes/app_routes.dart';
import '../../dashboard/widgets/dashboard_layout.dart';
import '../controllers/songs_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../models/song_model.dart';

class SongApprovalsView extends GetView<SongsController> {
  const SongApprovalsView({super.key});



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
      currentRoute: AppRoutes.songApprovals,
      child: AppGlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // Search field (Responsive)
              Builder(
                builder: (context) {
                  final size = MediaQuery.of(context).size;
                  final isMobile = size.width < 600;

                  final searchField = TextField(
                    controller: controller.searchController,
                    onChanged: (val) => controller.searchQuery.value = val,
                    decoration: const InputDecoration(
                      hintText: 'Search pending songs...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  );

                  if (isMobile) {
                    return searchField;
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: searchField,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Pending Songs Datatable
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && !controller.isUploading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Local filter for pending songs
                  final pendingSongs = controller.songs.where((song) {
                    final isPending = song.approvalStatus == 'pending';
                    if (!isPending) return false;
                    final query = controller.searchQuery.value.toLowerCase();
                    if (query.isEmpty) return true;
                    return song.title.toLowerCase().contains(query) ||
                        (song.singerName?.toLowerCase().contains(query) ?? false);
                  }).toList();

                  if (pendingSongs.isEmpty) {
                    return const Center(child: Text('No pending songs found.'));
                  }

                  return DataTable2(
                    dataRowColor: WidgetStateProperty.all(Colors.transparent),
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 800,
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
                      const DataColumn2(
                        label: Text('Created'),
                        size: ColumnSize.M,
                      ),
                      const DataColumn2(
                        label: Text('Actions'),
                        fixedWidth: 150,
                        numeric: true,
                      ),
                    ],
                    rows: pendingSongs.map((song) {
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
                          DataCell(Text(
                            DateFormat('yyyy-MM-dd').format(song.createdAt.toLocal()),
                          )),
                          DataCell(
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AppGlassIconButton(
                                  icon: Icons.check_circle_outline,
                                  color: Colors.green,
                                  onPressed: () => controller.updateApprovalStatus(song.id, 'approved'),
                                  tooltip: 'Approve Song',
                                ),
                                const SizedBox(width: 6),
                                AppGlassIconButton(
                                  icon: Icons.cancel_outlined,
                                  color: Colors.redAccent,
                                  onPressed: () => controller.updateApprovalStatus(song.id, 'rejected'),
                                  tooltip: 'Decline Song',
                                ),
                                const SizedBox(width: 6),
                                AppGlassIconButton(
                                  icon: Icons.visibility_outlined,
                                  color: Colors.cyanAccent,
                                  onPressed: () => _showLyricsDialog(context, song),
                                  tooltip: 'View Lyrics',
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
