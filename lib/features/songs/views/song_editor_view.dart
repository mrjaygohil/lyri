import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import '../../../core/localization/locale_keys.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/camera_helper.dart';
import '../controllers/songs_controller.dart';
import '../models/song_model.dart';

class SongEditorView extends StatefulWidget {
  final SongModel? song;

  const SongEditorView({super.key, this.song});

  @override
  State<SongEditorView> createState() => _SongEditorViewState();
}

class _SongEditorViewState extends State<SongEditorView> {
  final _formKey = GlobalKey<FormState>();
  final SongsController _controller = Get.find<SongsController>();

  late TextEditingController _titleController;
  late TextEditingController _lyricsController;
  late TextEditingController _singerController;
  late TextEditingController _albumController;
  late TextEditingController _languageController;

  String? _selectedCategoryId;
  final RxList<String> _selectedTagIds = <String>[].obs;
  final RxList<String> _selectedRaagIds = <String>[].obs;
  final RxBool _status = true.obs;
  final RxString _visibility = 'public'.obs;

  SongModel? _song;
  bool get _isEdit => _song != null;
  bool _isOcrLoading = false;

  @override
  void initState() {
    super.initState();
    _song = widget.song ?? (Get.arguments is SongModel ? Get.arguments as SongModel : null);
    final song = _song;
    _titleController = TextEditingController(text: song?.title);
    _lyricsController = TextEditingController(text: song?.lyrics);
    _singerController = TextEditingController(text: song?.singerName);
    _albumController = TextEditingController(text: song?.albumName);
    _languageController = TextEditingController(text: song?.language);

    _selectedCategoryId = song?.categoryId;
    _status.value = song?.status ?? true;
    _visibility.value = song?.visibility ?? 'public';

    // Load existing tags
    final existingTags = song?.tags;
    if (existingTags != null) {
      _selectedTagIds.assignAll(existingTags.map((t) => t.id));
    }

    final existingRaags = song?.raags;
    if (existingRaags != null) {
      _selectedRaagIds.assignAll(existingRaags.map((r) => r.id));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _lyricsController.dispose();
    _singerController.dispose();
    _albumController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  // Insert a lyrics tag at current cursor position
  void _insertLyricsTag(String tagText) {
    final text = _lyricsController.text;
    final selection = _lyricsController.selection;
    
    if (selection.start >= 0) {
      final newText = text.replaceRange(selection.start, selection.end, '$tagText\n');
      _lyricsController.text = newText;
      _lyricsController.selection = TextSelection.collapsed(
        offset: selection.start + tagText.length + 1,
      );
    } else {
      _lyricsController.text = '$text\n$tagText\n';
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _controller.saveSong(
        title: _titleController.text.trim(),
        lyrics: _lyricsController.text.trim(),
        singerName: _singerController.text.isNotEmpty ? _singerController.text : null,
        albumName: _albumController.text.isNotEmpty ? _albumController.text : null,
        language: _languageController.text.isNotEmpty ? _languageController.text : null,
        categoryId: _selectedCategoryId,
        tagIds: _selectedTagIds,
        raagIds: _selectedRaagIds,
        status: _status.value,
        visibility: _visibility.value,
        existingSong: _song,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 750;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? LocaleKeys.editSong.tr : LocaleKeys.addSong.tr),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Get.back(),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Form(
          key: _formKey,
          child: Builder(
            builder: (context) {
              final metadataCard = Card(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Song Metadata',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Song Title
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: '${LocaleKeys.title.tr} *',
                          hintText: 'e.g. Bohemian Rhapsody',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Song title is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Singer & Album
                      if (isMobile) ...[
                        TextFormField(
                          controller: _singerController,
                          decoration: InputDecoration(
                            labelText: LocaleKeys.singerName.tr,
                            hintText: 'e.g. Queen',
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _albumController,
                          decoration: InputDecoration(
                            labelText: LocaleKeys.albumName.tr,
                            hintText: 'e.g. A Night at the Opera',
                          ),
                        ),
                      ] else
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _singerController,
                                decoration: InputDecoration(
                                  labelText: LocaleKeys.singerName.tr,
                                  hintText: 'e.g. Queen',
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _albumController,
                                decoration: InputDecoration(
                                  labelText: LocaleKeys.albumName.tr,
                                  hintText: 'e.g. A Night at the Opera',
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),

                      // Language & Category
                      if (isMobile) ...[
                        TextFormField(
                          controller: _languageController,
                          decoration: InputDecoration(
                            labelText: LocaleKeys.language.tr,
                            hintText: 'e.g. English',
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(() {
                          return DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: _selectedCategoryId,
                            decoration: InputDecoration(
                              labelText: LocaleKeys.selectCategory.tr,
                            ),
                            items: _controller.categories.map((cat) {
                              return DropdownMenuItem(
                                value: cat.id,
                                child: Text(cat.name),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedCategoryId = val;
                              });
                            },
                          );
                        }),
                      ] else
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _languageController,
                                decoration: InputDecoration(
                                  labelText: LocaleKeys.language.tr,
                                  hintText: 'e.g. English',
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Obx(() {
                                return DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: _selectedCategoryId,
                                  decoration: InputDecoration(
                                    labelText: LocaleKeys.selectCategory.tr,
                                  ),
                                  items: _controller.categories.map((cat) {
                                    return DropdownMenuItem(
                                      value: cat.id,
                                      child: Text(cat.name),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedCategoryId = val;
                                    });
                                  },
                                );
                              }),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );

              final lyricsCard = Card(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            LocaleKeys.lyrics.tr,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            '* Required',
                            style: TextStyle(color: Colors.redAccent, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Quick Lyrics Formatting Toolbar (Wrapped for mobile responsiveness)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkBg : Colors.grey.withOpacity(0.05),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          border: Border.all(
                            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                          ),
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                           
                            if (_isOcrLoading)
                              const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () => _performOcr(ImageSource.camera),
                                    icon: const Icon(Icons.camera_alt_outlined, size: 16),
                                    label: const Text('Camera OCR', style: TextStyle(fontSize: 12)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () => _performOcr(ImageSource.gallery),
                                    icon: const Icon(Icons.image_outlined, size: 16),
                                    label: const Text('Gallery OCR', style: TextStyle(fontSize: 12)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                      // Main Lyrics Input Field
                      TextFormField(
                        controller: _lyricsController,
                        maxLines: 15,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter song lyrics here...',
                          fillColor: Colors.transparent,
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                            borderSide: BorderSide(
                              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                            borderSide: BorderSide(
                              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                            ),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Lyrics are required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              );

              final controlsCard = Card(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        return SwitchListTile(
                          title: Text(LocaleKeys.status.tr),
                          subtitle: Text(_status.value ? LocaleKeys.active.tr : LocaleKeys.inactive.tr),
                          value: _status.value,
                          onChanged: (val) => _status.value = val,
                          contentPadding: EdgeInsets.zero,
                        );
                      }),
                      const SizedBox(height: 16),
                      Obx(() => DropdownButtonFormField<String>(
                            isExpanded: true,
                            dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                            value: _visibility.value,
                            decoration: const InputDecoration(
                              labelText: 'Visibility',
                            ),
                            items: const [
                              DropdownMenuItem(value: 'public', child: Text('Public')),
                              DropdownMenuItem(value: 'private', child: Text('Private')),
                            ],
                            onChanged: (val) {
                              if (val != null) _visibility.value = val;
                            },
                          )),
                      const SizedBox(height: 24),
                      Obx(() {
                        final isSaving = _controller.isLoading.value || _controller.isUploading.value;
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isSaving ? null : _submit,
                            child: isSaving
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(LocaleKeys.save.tr.toUpperCase()),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );

              final thumbnailCard = Card(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.thumbnail.tr,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(() {
                        final hasLocalImage = _controller.selectedImageBytes.value != null;
                        final hasExistingImage = _song?.thumbnail != null;

                        return Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 1.6,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: hasLocalImage
                                    ? Image.memory(
                                        _controller.selectedImageBytes.value!,
                                        fit: BoxFit.cover,
                                      )
                                    : hasExistingImage
                                        ? Image.network(
                                            _song!.thumbnail!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                          )
                                        : Container(
                                            color: Colors.grey.withOpacity(0.2),
                                            child: const Icon(Icons.image, size: 40, color: Colors.grey),
                                          ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton.icon(
                                  onPressed: _controller.pickSongImage,
                                  icon: const Icon(Icons.upload),
                                  label: const Text('Pick Image'),
                                ),
                                if (hasLocalImage)
                                  TextButton.icon(
                                    onPressed: _controller.clearSelectedImage,
                                    icon: const Icon(Icons.clear, color: Colors.red),
                                    label: const Text('Clear', style: TextStyle(color: Colors.red)),
                                  ),
                              ],
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              );

              final tagsCard = Card(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            LocaleKeys.tags.tr,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _showAddTagDialog(context),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Tag'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Obx(() {
                        if (_controller.tags.isEmpty) {
                          return const Text('No tags available. Add tags in the tags tab first.');
                        }
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _controller.tags.map((tag) {
                            final isSelected = _selectedTagIds.contains(tag.id);
                            return FilterChip(
                              label: Text(tag.name),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  _selectedTagIds.add(tag.id);
                                } else {
                                  _selectedTagIds.remove(tag.id);
                                }
                              },
                            );
                          }).toList(),
                        );
                      }),
                    ],
                  ),
                ),
              );

              final raagsCard = Card(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            LocaleKeys.raags.tr,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _showAddRaagDialog(context),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Raag'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.purpleAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Obx(() {
                        if (_controller.raags.isEmpty) {
                          return const Text('No raags available. Add raags in the raags tab first.');
                        }
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _controller.raags.map((raag) {
                            final isSelected = _selectedRaagIds.contains(raag.id);
                            return FilterChip(
                              label: Text(raag.name),
                              selected: isSelected,
                              selectedColor: Colors.purple.withOpacity(0.2),
                              checkmarkColor: Colors.purple,
                              onSelected: (selected) {
                                if (selected) {
                                  _selectedRaagIds.add(raag.id);
                                } else {
                                  _selectedRaagIds.remove(raag.id);
                                }
                              },
                            );
                          }).toList(),
                        );
                      }),
                    ],
                  ),
                ),
              );

              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    metadataCard,
                    const SizedBox(height: 16),
                    lyricsCard,
                    const SizedBox(height: 16),
                    controlsCard,
                    const SizedBox(height: 16),
                    thumbnailCard,
                    const SizedBox(height: 16),
                    tagsCard,
                    const SizedBox(height: 16),
                    raagsCard,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        metadataCard,
                        const SizedBox(height: 24),
                        lyricsCard,
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        controlsCard,
                        const SizedBox(height: 24),
                        thumbnailCard,
                        const SizedBox(height: 24),
                        tagsCard,
                        const SizedBox(height: 24),
                        raagsCard,
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarButton({required String label, required String tooltip}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Tooltip(
        message: tooltip,
        child: OutlinedButton(
          onPressed: () => _insertLyricsTag(label),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Future<String?> _showLanguageSelectionDialog() async {
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Select Lyrics Language',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please select the language of the lyrics in the image for accurate OCR extraction.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.language, color: Colors.blueAccent),
                title: const Text('Gujarati', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, 'guj'),
              ),
              ListTile(
                leading: const Icon(Icons.language, color: Colors.orangeAccent),
                title: const Text('Hindi', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, 'hin'),
              ),
              ListTile(
                leading: const Icon(Icons.language, color: Colors.greenAccent),
                title: const Text('English', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, 'eng'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performOcr(ImageSource source) async {
    try {
      String? imagePath;

      if (source == ImageSource.camera && kIsWeb) {
        final result = await capturePhotoFromWebcam();
        if (result == "NO_CAMERA") {
          Get.snackbar(
            'No Camera Connected',
            'You do not have a camera connected to this device.',
            backgroundColor: Colors.orangeAccent,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        if (result == "CANCELLED" || result == null) {
          return; // User cancelled
        }
        imagePath = result; // base64 data URL
      } else {
        if (source == ImageSource.camera) {
          final hasCamera = await checkCameraConnection();
          if (!hasCamera) {
            Get.snackbar(
              'No Camera Connected',
              'You do not have a camera connected to this device.',
              backgroundColor: Colors.orangeAccent,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
            return;
          }
        }

        final picker = ImagePicker();
        final XFile? imageFile = await picker.pickImage(
          source: source,
          maxWidth: 600,
          maxHeight: 800,
        );

        if (imageFile == null) return;
        imagePath = imageFile.path;
      }

      final chosenLang = await _showLanguageSelectionDialog();
      if (chosenLang == null) return; // User cancelled
      final String ocrLang = chosenLang;

      setState(() {
        _isOcrLoading = true;
      });

      // Call FlutterTesseractOcr to extract text asynchronously
      debugPrint('OCR starting. Image path: $imagePath');
      debugPrint('OCR selected language: $ocrLang');

      final String extractedText = await FlutterTesseractOcr.extractText(
        imagePath,
        language: ocrLang,
      );

      setState(() {
        _isOcrLoading = false;
      });

      if (extractedText.trim().isNotEmpty) {
        // Format lyrics to clean up redundant carriage returns or double linebreaks
        final formattedText = extractedText
            .replaceAll('\r\n', '\n')
            .replaceAll(RegExp(r'\n{3,}'), '\n\n')
            .trim();

        setState(() {
          _lyricsController.text = formattedText;
          if (ocrLang == 'guj') _languageController.text = 'Gujarati';
          if (ocrLang == 'hin') _languageController.text = 'Hindi';
          if (ocrLang == 'eng') _languageController.text = 'English';
        });

        Get.snackbar(
          'Success',
          'Lyrics extracted successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'No Text Found',
          'Could not find any text in the image. Please make sure the image is clear and contains text.',
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      setState(() {
        _isOcrLoading = false;
      });
      Get.snackbar(
        'OCR Error',
        'Failed to extract text: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showAddTagDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add New Tag', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: textController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Tag Name',
              labelStyle: const TextStyle(color: Colors.grey),
              hintText: 'e.g. Rock, Pop, Devotional',
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = textController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.pop(context);
                  final newTag = await _controller.addNewTag(name);
                  if (newTag != null) {
                    _selectedTagIds.add(newTag.id);
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showAddRaagDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add New Raag', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: textController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Raag Name',
              labelStyle: const TextStyle(color: Colors.grey),
              hintText: 'e.g. Bhairav, Yaman, Kalyan',
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = textController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.pop(context);
                  final newRaag = await _controller.addNewRaag(name);
                  if (newRaag != null) {
                    _selectedRaagIds.add(newRaag.id);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
