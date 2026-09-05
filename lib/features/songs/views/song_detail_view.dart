import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/widgets/app_glass_container.dart';
import '../../../core/widgets/app_animated_button.dart';
import '../../favorites/controllers/favorites_controller.dart';
import '../../playlists/controllers/playlists_controller.dart';
import '../models/song_model.dart';
import 'package:flutter/foundation.dart';
import '../utils/transliteration_helper.dart';

class SongDetailView extends StatefulWidget {
  const SongDetailView({super.key});

  @override
  State<SongDetailView> createState() => _SongDetailViewState();
}

class _SongDetailViewState extends State<SongDetailView> {
  final FavoritesController _favoritesController = Get.put(FavoritesController());
  final PlaylistsController _playlistsController = Get.put(PlaylistsController());
  
  late SongModel _song;
  final RxDouble _lyricsFontSize = 16.0.obs;
  
  final RxString _selectedTranslationCode = 'original'.obs;
  final RxString _selectedRomanizedCode = 'original'.obs;
  final RxString _displayLyrics = ''.obs;
  final RxBool _isTranslating = false.obs;

  static const Map<String, String> _languages = {
    'original': 'Original (Default)',
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'hi': 'Hindi',
    'gu': 'Gujarati',
    'zh-cn': 'Chinese (Simplified)',
    'ja': 'Japanese',
    'ar': 'Arabic',
    'pt': 'Portuguese',
    'ru': 'Russian',
    'it': 'Italian',
    'ko': 'Korean',
    'pa': 'Punjabi',
    'ta': 'Tamil',
    'te': 'Telugu',
    'tr': 'Turkish',
    'vi': 'Vietnamese',
  };

  static const Map<String, String> _romanizedLanguages = {
    'original': 'None (Original Script)',
    'original_romanized': 'Original Lyrics (Romanized)',
    'en': 'English (Romanized)',
    'es': 'Spanish (Romanized)',
    'fr': 'French (Romanized)',
    'de': 'German (Romanized)',
    'hi': 'Hindi (Romanized)',
    'gu': 'Gujarati (Romanized)',
    'zh-cn': 'Chinese (Romanized)',
    'ja': 'Japanese (Romanized)',
    'ar': 'Arabic (Romanized)',
    'pt': 'Portuguese (Romanized)',
    'ru': 'Russian (Romanized)',
    'it': 'Italian (Romanized)',
    'ko': 'Korean (Romanized)',
    'pa': 'Punjabi (Romanized)',
    'ta': 'Tamil (Romanized)',
    'te': 'Telugu (Romanized)',
    'tr': 'Turkish (Romanized)',
    'vi': 'Vietnamese (Romanized)',
  };

  @override
  void initState() {
    super.initState();
    _song = Get.arguments as SongModel;
    _displayLyrics.value = _song.lyrics;
    _incrementViewCount();
  }

  static String? _detectIndicLanguage(String text) {
    for (var i = 0; i < text.length; i++) {
      final codePoint = text.codeUnitAt(i);
      if (codePoint >= 0x0900 && codePoint <= 0x097F) return 'hi';
      if (codePoint >= 0x0980 && codePoint <= 0x09FF) return 'bn';
      if (codePoint >= 0x0A00 && codePoint <= 0x0A7F) return 'pa';
      if (codePoint >= 0x0A80 && codePoint <= 0x0AFF) return 'gu';
      if (codePoint >= 0x0B00 && codePoint <= 0x0B7F) return 'or';
      if (codePoint >= 0x0B80 && codePoint <= 0x0BFF) return 'ta';
      if (codePoint >= 0x0C00 && codePoint <= 0x0C7F) return 'te';
      if (codePoint >= 0x0C80 && codePoint <= 0x0CFF) return 'kn';
      if (codePoint >= 0x0D00 && codePoint <= 0x0D7F) return 'ml';
    }
    return null;
  }

  static bool _isLatinScript(String langCode) {
    const latinCodes = {
      'en', 'es', 'fr', 'de', 'pt', 'it', 'tr', 'vi', 'original_romanized'
    };
    return latinCodes.contains(langCode);
  }

  static String _transliterateIndic(String text, String targetLangCode, String sourceLangCode) {
    final Map<String, int> offsets = {
      'hi': 0x0000, // Devanagari (Hindi)
      'bn': 0x0080, // Bengali
      'pa': 0x0100, // Gurmukhi (Punjabi)
      'gu': 0x0180, // Gujarati
      'or': 0x0200, // Oriya
      'ta': 0x0280, // Tamil
      'te': 0x0300, // Telugu
      'kn': 0x0380, // Kannada
      'ml': 0x0400, // Malayalam
    };

    if (!offsets.containsKey(targetLangCode) || !offsets.containsKey(sourceLangCode)) {
      return text;
    }

    final sourceOffset = offsets[sourceLangCode]!;
    final targetOffset = offsets[targetLangCode]!;
    final diff = targetOffset - sourceOffset;

    final sourceStart = 0x0900 + sourceOffset;
    final sourceEnd = sourceStart + 0x007F;

    final result = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final codePoint = text.codeUnitAt(i);
      if (codePoint >= sourceStart && codePoint <= sourceEnd) {
        result.writeCharCode(codePoint + diff);
      } else {
        result.writeCharCode(codePoint);
      }
    }
    return result.toString();
  }

  Future<String> _getRomanizedText(String text) async {
    try {
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=en&dt=t&dt=rm&dj=1'
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'q': text},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('sentences')) {
          final sentences = data['sentences'];
          if (sentences is List) {
            final List<String> translitSegments = [];
            final List<String> origSegments = [];
            for (var sentence in sentences) {
              if (sentence is Map) {
                final srcTranslit = sentence['src_translit'] as String?;
                final orig = sentence['orig'] as String?;
                if (srcTranslit != null && srcTranslit.trim().isNotEmpty) {
                  translitSegments.add(srcTranslit);
                } else if (orig != null) {
                  origSegments.add(orig);
                }
              }
            }
            if (translitSegments.isNotEmpty) {
              return translitSegments.join('');
            } else if (origSegments.isNotEmpty) {
              return origSegments.join('');
            }
          }
        }
      }
    } catch (e) {
      // Fallback
    }
    return text;
  }

  Future<String> _transliterateWithInputTools(String romanizedText, String targetLang) async {
    String? itc;
    switch (targetLang) {
      case 'hi': itc = 'hi-t-i0-und'; break;
      case 'gu': itc = 'gu-t-i0-und'; break;
      case 'pa': itc = 'pa-t-i0-und'; break;
      case 'ta': itc = 'ta-t-i0-und'; break;
      case 'te': itc = 'te-t-i0-und'; break;
      case 'ru': itc = 'ru-t-i0-und'; break;
      case 'ar': itc = 'ar-t-i0-und'; break;
      case 'ja': itc = 'ja-t-i0-und'; break;
      case 'ko': itc = 'ko-t-i0-und'; break;
      case 'zh-cn': itc = 'zh-t-i0-pinyin'; break;
    }

    if (itc == null) {
      return romanizedText;
    }

    try {
      if (kIsWeb) {
        final webResult = await transliterateWeb(romanizedText, itc);
        if (webResult != null) {
          return webResult;
        }
      }

      final url = Uri.parse('https://inputtools.google.com/request');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'text': romanizedText,
          'itc': itc,
          'num': '1',
          'cp': '0',
          'cs': '1',
          'ie': 'utf-8',
          'oe': 'utf-8',
          'app': 'test'
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty && data[0] == 'SUCCESS') {
          final results = data[1][0][1];
          if (results is List && results.isNotEmpty) {
            return results[0] as String;
          }
        }
      }
    } catch (e) {
      // Fallback to romanized
    }
    return romanizedText;
  }

  Future<void> _translateLyrics(String langCode, {required bool isRomanized}) async {
    if (isRomanized) {
      _selectedRomanizedCode.value = langCode;
      _selectedTranslationCode.value = 'original';
    } else {
      _selectedTranslationCode.value = langCode;
      _selectedRomanizedCode.value = 'original';
    }

    if (langCode == 'original') {
      _displayLyrics.value = _song.lyrics;
      return;
    }

    try {
      _isTranslating.value = true;

      if (isRomanized) {
        final detectedSrc = _detectIndicLanguage(_song.lyrics);
        final isTargetIndic = const {'hi', 'bn', 'pa', 'gu', 'or', 'ta', 'te', 'kn', 'ml'}.contains(langCode);

        if (detectedSrc != null && isTargetIndic) {
          _displayLyrics.value = _transliterateIndic(_song.lyrics, langCode, detectedSrc);
        } else {
          final romanized = await _getRomanizedText(_song.lyrics);
          if (_isLatinScript(langCode)) {
            _displayLyrics.value = romanized;
          } else {
            final transliterated = await _transliterateWithInputTools(romanized, langCode);
            _displayLyrics.value = transliterated;
          }
        }
      } else {
        final translator = GoogleTranslator();
        final translation = await translator.translate(_song.lyrics, to: langCode);
        _displayLyrics.value = translation.text;
      }
    } catch (e) {
      Get.snackbar(
        "Translation Error",
        "Failed to translate lyrics: $e",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      _selectedTranslationCode.value = 'original';
      _selectedRomanizedCode.value = 'original';
      _displayLyrics.value = _song.lyrics;
    } finally {
      _isTranslating.value = false;
    }
  }


  Widget _buildTranslationDropdown() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: _selectedTranslationCode.value,
            dropdownColor: const Color(0xFF1E293B),
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            icon: const Icon(Icons.translate, color: Colors.indigoAccent, size: 16),
            onChanged: (val) {
              if (val != null) {
                _translateLyrics(val, isRomanized: false);
              }
            },
            items: _languages.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    entry.value,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  Widget _buildRomanizedDropdown() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: _selectedRomanizedCode.value,
            dropdownColor: const Color(0xFF1E293B),
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            icon: const Icon(Icons.abc, color: Colors.indigoAccent, size: 20),
            onChanged: (val) {
              if (val != null) {
                _translateLyrics(val, isRomanized: true);
              }
            },
            items: _romanizedLanguages.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    entry.value,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  void _incrementViewCount() async {
    try {
      final client = Supabase.instance.client;
      // Increment views count directly
      await client
          .from('songs')
          .update({'views_count': _song.viewsCount + 1})
          .eq('id', _song.id);
    } catch (e) {
      // Fail silently for views count increment
    }
  }

  void _shareLyrics() {
    final shareContent = '🎶 ${_song.title} - ${_song.singerName ?? "Unknown Artist"}\n'
        '${_song.albumName != null ? "Album: ${_song.albumName}\n" : ""}'
        '------------------------------------\n\n'
        '${_song.lyrics}\n\n'
        'Shared via Lyri App';
    
    Share.share(shareContent, subject: 'Lyrics for ${_song.title}');
  }

  void _showAddToPlaylistBottomSheet(BuildContext context) {
    _playlistsController.fetchPlaylists();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CustomText(
                  'Add to Playlist',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  useOutfit: true,
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: Obx(() {
                if (_playlistsController.playlists.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CustomText('No playlists found.', isSecondary: true),
                        const SizedBox(height: 16),
                        CustomButton(
                          label: 'Create Playlist',
                          width: 160,
                          onPressed: () {
                            Get.back();
                            _showCreatePlaylistDialog(context);
                          },
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: _playlistsController.playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = _playlistsController.playlists[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.playlist_play, color: Colors.indigo),
                      ),
                      title: CustomText(
                        playlist.title,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      subtitle: CustomText(
                        '${playlist.songs.length} songs',
                        fontSize: 12,
                        isSecondary: true,
                      ),
                      onTap: () {
                        _playlistsController.addSongToPlaylist(playlist.id, _song.id);
                        Get.back();
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final titleController = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('New Playlist', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: titleController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Playlist Title',
            labelStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                _playlistsController.createPlaylist(title: titleController.text.trim());
                Get.back();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 750;

    if (isMobile) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: CustomScrollView(
          slivers: [
            // Collapsible Header Banner
            SliverAppBar(
              expandedHeight: 280.0,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF0F172A),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              actions: [
                Obx(() {
                  final isFav = _favoritesController.isFavorite(_song.id);
                  return IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.pink : Colors.white,
                    ),
                    onPressed: () => _favoritesController.toggleFavorite(_song),
                  );
                }),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: _shareLyrics,
                ),
                IconButton(
                  icon: const Icon(Icons.playlist_add, color: Colors.white),
                  onPressed: () => _showAddToPlaylistBottomSheet(context),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image background
                    _song.thumbnail != null && _song.thumbnail!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: _song.thumbnail!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: const Color(0xFF1E293B)),
                            errorWidget: (context, url, error) => Container(color: const Color(0xFF1E293B)),
                          )
                        : Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Icon(Icons.music_note, size: 80, color: Colors.white24),
                          ),
                    
                    // Shade Overlay Gradient
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black87,
                            Colors.transparent,
                            Color(0xFF0F172A),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    
                    // Song details overlay
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_song.category != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.indigo.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: CustomText(
                                _song.category!.name,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo.shade200,
                              ),
                            ),
                          CustomText(
                            _song.title,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            useOutfit: true,
                          ),
                          const SizedBox(height: 4),
                          CustomText(
                            _song.singerName ?? 'Unknown Singer',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[300],
                          ),
                          if (_song.albumName != null && _song.albumName!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            CustomText(
                              'Album: ${_song.albumName}',
                              fontSize: 13,
                              color: Colors.grey[400],
                              isSecondary: true,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Sticky Font Control Panel
            // Sticky Controls Panel (Translation Dropdown & Font Controls)
            SliverToBoxAdapter(
              child: Container(
                color: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildTranslationDropdown()),
                        const SizedBox(width: 8),
                        Expanded(child: _buildRomanizedDropdown()),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CustomText(
                          'Lyrics Size',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.withOpacity(0.1)),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, color: Colors.white, size: 16),
                                onPressed: () {
                                  if (_lyricsFontSize.value > 12.0) {
                                    _lyricsFontSize.value -= 2.0;
                                  }
                                },
                              ),
                              Obx(() => CustomText(
                                    '${_lyricsFontSize.value.toInt()}',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  )),
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.white, size: 16),
                                onPressed: () {
                                  if (_lyricsFontSize.value < 36.0) {
                                    _lyricsFontSize.value += 2.0;
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Lyrics Text Content
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              sliver: SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.withOpacity(0.05)),
                  ),
                  child: Obx(() {
                    if (_isTranslating.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return SelectableText(
                      _displayLyrics.value,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: _lyricsFontSize.value,
                        height: 1.8,
                        color: Colors.grey[200],
                      ),
                    );
                  }),
                ),
              ),
            ),
            
            // Tag chips footer
            if (_song.tags != null && _song.tags!.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        'Tags',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[400],
                        isSecondary: true,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _song.tags!.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.indigo.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.indigo.withOpacity(0.2)),
                            ),
                            child: CustomText(
                              '#${tag.name}',
                              fontSize: 12,
                              color: Colors.indigo.shade300,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

            if (_song.raags != null && _song.raags!.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        'Raags',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[400],
                        isSecondary: true,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _song.raags!.map((raag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.purple.withOpacity(0.2)),
                            ),
                            child: CustomText(
                              '#${raag.name}',
                              fontSize: 12,
                              color: Colors.purple.shade300,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Pane (fixed width)
          Container(
            width: 380,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: Color(0xFF1E293B), width: 1),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      const SizedBox(width: 8),
                      CustomText(
                        'Back',
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Cover Art Card
                  Center(
                    child: AppGlassContainer(
                      borderRadius: 16,
                      padding: EdgeInsets.zero,
                      child: SizedBox(
                        width: 300,
                        height: 300,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _song.thumbnail != null && _song.thumbnail!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: _song.thumbnail!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(color: const Color(0xFF1E293B)),
                                  errorWidget: (context, url, error) => Container(color: const Color(0xFF1E293B)),
                                )
                              : Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Icon(Icons.music_note, size: 100, color: Colors.white24),
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Category Badge
                  if (_song.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.indigo.withOpacity(0.3)),
                      ),
                      child: CustomText(
                        _song.category!.name,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade200,
                      ),
                    ),

                  // Song Title & Singer
                  CustomText(
                    _song.title,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    useOutfit: true,
                  ),
                  const SizedBox(height: 6),
                  CustomText(
                    _song.singerName ?? 'Unknown Singer',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[300],
                  ),
                  if (_song.albumName != null && _song.albumName!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    CustomText(
                      'Album: ${_song.albumName}',
                      fontSize: 13,
                      color: Colors.grey[400],
                      isSecondary: true,
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Action Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Obx(() {
                        final isFav = _favoritesController.isFavorite(_song.id);
                        return IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.pink : Colors.white,
                            size: 28,
                          ),
                          onPressed: () => _favoritesController.toggleFavorite(_song),
                        );
                      }),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.white, size: 26),
                        onPressed: _shareLyrics,
                      ),
                      IconButton(
                        icon: const Icon(Icons.playlist_add, color: Colors.white, size: 28),
                        onPressed: () => _showAddToPlaylistBottomSheet(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tag chips
                  if (_song.tags != null && _song.tags!.isNotEmpty) ...[
                    CustomText(
                      'Tags',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400],
                      isSecondary: true,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _song.tags!.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.indigo.withOpacity(0.2)),
                          ),
                          child: CustomText(
                            '#${tag.name}',
                            fontSize: 12,
                            color: Colors.indigo.shade300,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_song.raags != null && _song.raags!.isNotEmpty) ...[
                    CustomText(
                      'Raags',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400],
                      isSecondary: true,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _song.raags!.map((raag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.purple.withOpacity(0.2)),
                          ),
                          child: CustomText(
                            '#${raag.name}',
                            fontSize: 12,
                            color: Colors.purple.shade300,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),

          // Right Pane (Lyrics panel + pinned controls)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Pinned controls (Translation Dropdown & Font controls)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.05)),
                    ),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            SizedBox(width: 140, child: _buildTranslationDropdown()),
                            SizedBox(width: 140, child: _buildRomanizedDropdown()),
                            const SizedBox(width: 8),
                            const CustomText(
                              'Lyrics Size',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, color: Colors.white, size: 16),
                                onPressed: () {
                                  if (_lyricsFontSize.value > 12.0) {
                                    _lyricsFontSize.value -= 2.0;
                                  }
                                },
                              ),
                              Obx(() => CustomText(
                                    '${_lyricsFontSize.value.toInt()}',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  )),
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.white, size: 16),
                                onPressed: () {
                                  if (_lyricsFontSize.value < 36.0) {
                                    _lyricsFontSize.value += 2.0;
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Lyrics Card Content
                  Expanded(
                    child: AppGlassContainer(
                      borderRadius: 16,
                      padding: const EdgeInsets.all(24),
                      child: SingleChildScrollView(
                          child: Obx(() {
                            if (_isTranslating.value) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return SelectableText(
                              _displayLyrics.value,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: _lyricsFontSize.value,
                                height: 1.8,
                                color: Colors.grey[200],
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
