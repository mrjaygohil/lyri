import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../songs/models/song_model.dart';
import '../controllers/playlists_controller.dart';
import '../models/playlist_model.dart';

class PlaylistLyricsView extends StatefulWidget {
  const PlaylistLyricsView({super.key});

  @override
  State<PlaylistLyricsView> createState() => _PlaylistLyricsViewState();
}

class _PlaylistLyricsViewState extends State<PlaylistLyricsView> {
  late final PlaylistModel initialPlaylist;
  late final PlaylistsController controller;

  // Initial Theme state: White Background, Black Text
  bool isDarkMode = false;

  // Font size adjustment state (Initial: 18.0)
  double lyricsFontSize = 18.0;

  // Track expanded song IDs (Initially empty so all titles display collapsed)
  final Set<String> expandedSongIds = <String>{};

  @override
  void initState() {
    super.initState();
    controller = Get.find<PlaylistsController>();

    if (Get.arguments is Map && (Get.arguments as Map).containsKey('playlist')) {
      initialPlaylist = (Get.arguments as Map)['playlist'] as PlaylistModel;
    } else if (Get.arguments is PlaylistModel) {
      initialPlaylist = Get.arguments as PlaylistModel;
    }
  }

  void _toggleExpanded(String songId) {
    setState(() {
      if (expandedSongIds.contains(songId)) {
        expandedSongIds.remove(songId);
      } else {
        expandedSongIds.add(songId);
      }
    });
  }

  void _toggleExpandAll(List<SongModel> songs) {
    setState(() {
      if (expandedSongIds.length == songs.length) {
        expandedSongIds.clear();
      } else {
        expandedSongIds.addAll(songs.map((s) => s.id));
      }
    });
  }

  // Helper to trim and collapse excessive blank line breaks
  String _cleanLyricsText(String raw) {
    if (raw.trim().isEmpty) return 'No lyrics available.';
    String text = raw.replaceAll(RegExp(r'\r\n'), '\n');
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return text.trim();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? const Color(0xFF090D16) : const Color(0xFFF8FAFC);
    final cardBgColor = isDarkMode ? const Color(0xFF151C2C) : Colors.white;
    final textColor = isDarkMode ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final secondaryTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final appBarBgColor = isDarkMode ? const Color(0xFF0F172A) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: Colors.black12,
        iconTheme: IconThemeData(color: textColor),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              initialPlaylist.title,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
              ),
            ),
            Obx(() {
              final playlist = controller.playlists.firstWhere(
                (p) => p.id == initialPlaylist.id,
                orElse: () => initialPlaylist,
              );
              return Text(
                '${playlist.songs.length} Songs • Performance Mode',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 11,
                  fontFamily: 'Inter',
                ),
              );
            }),
          ],
        ),
        actions: [
          // Theme Switch Pill Button (White <-> Black)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: InkWell(
              onTap: () => setState(() => isDarkMode = !isDarkMode),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      size: 16,
                      color: isDarkMode ? const Color(0xFFFACC15) : const Color(0xFF6366F1),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isDarkMode ? 'Light' : 'Dark',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Font Controls Pill
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: lyricsFontSize > 12.0
                      ? () => setState(() => lyricsFontSize -= 2.0)
                      : null,
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.remove,
                      size: 16,
                      color: lyricsFontSize > 12.0 ? textColor : secondaryTextColor,
                    ),
                  ),
                ),
                Text(
                  '${lyricsFontSize.toInt()}px',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: lyricsFontSize < 40.0
                      ? () => setState(() => lyricsFontSize += 2.0)
                      : null,
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.add,
                      size: 16,
                      color: lyricsFontSize < 40.0 ? textColor : secondaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Expand / Collapse All Button
          Obx(() {
            final playlist = controller.playlists.firstWhere(
              (p) => p.id == initialPlaylist.id,
              orElse: () => initialPlaylist,
            );
            final allExpanded = expandedSongIds.length == playlist.songs.length && playlist.songs.isNotEmpty;

            return IconButton(
              icon: Icon(
                allExpanded ? Icons.unfold_less : Icons.unfold_more,
                color: const Color(0xFF6366F1),
                size: 22,
              ),
              tooltip: allExpanded ? 'Collapse All' : 'Expand All',
              onPressed: () => _toggleExpandAll(playlist.songs),
            );
          }),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        final playlist = controller.playlists.firstWhere(
          (p) => p.id == initialPlaylist.id,
          orElse: () => initialPlaylist,
        );

        if (playlist.songs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.music_off_outlined, size: 48, color: Color(0xFF6366F1)),
                ),
                const SizedBox(height: 16),
                Text(
                  'No songs added to this playlist yet',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          );
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: playlist.songs.length,
              itemBuilder: (context, index) {
                final song = playlist.songs[index];
                final isExpanded = expandedSongIds.contains(song.id);
                final lyricsContent = _cleanLyricsText(song.lyrics);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isExpanded ? const Color(0xFF6366F1).withValues(alpha: 0.5) : borderColor,
                      width: isExpanded ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Song Title Header Tile
                      InkWell(
                        onTap: () => _toggleExpanded(song.id),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              // Numbered Badge Circle with Gradient
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  gradient: isExpanded
                                      ? const LinearGradient(
                                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: !isExpanded
                                      ? (isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0))
                                      : null,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: isExpanded
                                          ? Colors.white
                                          : (isDarkMode ? const Color(0xFF818CF8) : const Color(0xFF475569)),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Title & Singer Name
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      song.title,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Outfit',
                                      ),
                                    ),
                                    if (song.singerName != null && song.singerName!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.mic_none,
                                              size: 13,
                                              color: secondaryTextColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                song.singerName!,
                                                style: TextStyle(
                                                  color: secondaryTextColor,
                                                  fontSize: 12,
                                                  fontFamily: 'Inter',
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // Expand / Collapse Chevron Container
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isExpanded
                                      ? const Color(0xFF6366F1).withValues(alpha: 0.15)
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: isExpanded ? const Color(0xFF6366F1) : secondaryTextColor,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Expanded Lyrics Body
                      if (isExpanded) ...[
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF0F172A).withValues(alpha: 0.5)
                                : const Color(0xFFFAFAFA),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: SelectionArea(
                            child: Text(
                              lyricsContent,
                              style: TextStyle(
                                color: textColor,
                                fontSize: lyricsFontSize,
                                height: 1.45,
                                fontFamily: 'Inter',
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
