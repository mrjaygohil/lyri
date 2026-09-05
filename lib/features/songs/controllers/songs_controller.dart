import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/localization/locale_keys.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/logger.dart';
import '../../categories/models/category_model.dart';
import '../../categories/repositories/categories_repository.dart';
import '../../tags/models/tag_model.dart';
import '../../tags/repositories/tags_repository.dart';
import '../../tags/controllers/tags_controller.dart';
import '../../raags/models/raag_model.dart';
import '../../raags/repositories/raags_repository.dart';
import '../../raags/controllers/raags_controller.dart';
import '../models/song_model.dart';
import '../repositories/songs_repository.dart';
import '../../authentication/controllers/auth_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../../core/utils/search_helper.dart';
import '../../../core/utils/error_handler.dart';

class SongsController extends GetxController {
  final SongsRepository _songsRepository = Get.find<SongsRepository>();
  final CategoriesRepository _categoriesRepository = Get.find<CategoriesRepository>();
  final TagsRepository _tagsRepository = Get.find<TagsRepository>();
  final RaagsRepository _raagsRepository = Get.find<RaagsRepository>();
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  final RxList<SongModel> songs = <SongModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<TagModel> tags = <TagModel>[].obs;
  final RxList<RaagModel> raags = <RaagModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;

  // Search & Filter State
  final RxString searchQuery = ''.obs;
  final RxnString selectedCategoryFilter = RxnString();
  final RxnBool selectedStatusFilter = RxnBool();
  final RxList<String> selectedTagFilters = <String>[].obs;
  final RxList<String> selectedRaagFilters = <String>[].obs;
  TextEditingController _searchController = TextEditingController();
  TextEditingController get searchController {
    try {
      _searchController.text;
    } catch (_) {
      _searchController = TextEditingController(text: searchQuery.value);
      _searchController.addListener(() {
        searchQuery.value = _searchController.text;
      });
    }
    return _searchController;
  }

  // Song Image Selection
  final Rxn<Uint8List> selectedImageBytes = Rxn<Uint8List>();
  final RxString selectedImageName = ''.obs;
  final RxString selectedMimeType = 'image/jpeg'.obs;

  @override
  void onInit() {
    super.onInit();
    loadDependencies();
    loadSongs();
    
    _searchController = TextEditingController(text: searchQuery.value);
    _searchController.addListener(() {
      searchQuery.value = _searchController.text;
    });
    
    // Debounce search query by 500ms
    debounce(searchQuery, (_) => loadSongs(), time: const Duration(milliseconds: 500));
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> loadDependencies() async {
    try {
      final results = await Future.wait([
        _categoriesRepository.getCategories(),
        _tagsRepository.getTags(),
        _raagsRepository.getRaags(),
      ]);
      
      // Filter out inactive categories for selection, but keep all for safety
      categories.assignAll(results[0] as List<CategoryModel>);
      tags.assignAll(results[1] as List<TagModel>);
      raags.assignAll(results[2] as List<RaagModel>);
    } catch (e) {
      AppLogger.e('Failed to load dependencies for SongsController: $e');
    }
  }

  Future<void> loadSongs() async {
    try {
      isLoading.value = true;
      final list = await _songsRepository.getSongs(
        categoryId: selectedCategoryFilter.value,
        statusFilter: selectedStatusFilter.value,
      );

      var filteredList = list;
      if (selectedTagFilters.isNotEmpty) {
        filteredList = filteredList.where((song) {
          return song.tags?.any((t) => selectedTagFilters.contains(t.id)) ?? false;
        }).toList();
      }
      if (selectedRaagFilters.isNotEmpty) {
        filteredList = filteredList.where((song) {
          return song.raags?.any((r) => selectedRaagFilters.contains(r.id)) ?? false;
        }).toList();
      }

      final searchVal = searchQuery.value.trim();
      if (searchVal.isNotEmpty) {
        final scoredResults = <MapEntry<SongModel, int>>[];
        for (final song in filteredList) {
          final score = SearchHelper.calculateSongMatchScore(song, searchVal);
          if (score > 0) {
            scoredResults.add(MapEntry(song, score));
          }
        }
        scoredResults.sort((a, b) {
          final scoreCompare = b.value.compareTo(a.value);
          if (scoreCompare != 0) return scoreCompare;
          return a.key.title.compareTo(b.key.title);
        });
        songs.assignAll(scoredResults.map((e) => e.key).toList());
      } else {
        songs.assignAll(filteredList);
      }
    } catch (e) {
      Get.snackbar(
        LocaleKeys.errorOccurred.tr,
        ErrorHandler.formatError(e),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Pick song image
  Future<void> pickSongImage() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.first.bytes != null) {
        selectedImageBytes.value = result.files.first.bytes;
        selectedImageName.value = result.files.first.name;
        
        final ext = result.files.first.extension?.toLowerCase() ?? 'jpg';
        selectedMimeType.value = ext == 'png' ? 'image/png' : 'image/jpeg';
        
        AppLogger.i('Song image picked: ${selectedImageName.value}');
      }
    } catch (e) {
      AppLogger.e('Failed to pick song image: $e');
    }
  }

  void clearSelectedImage() {
    selectedImageBytes.value = null;
    selectedImageName.value = '';
  }

  Future<void> deleteSong(String songId) async {
    try {
      isLoading.value = true;
      await _songsRepository.deleteSong(songId);
      songs.removeWhere((s) => s.id == songId);
      Get.snackbar(LocaleKeys.success.tr, 'Song deleted successfully.',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar(
        LocaleKeys.errorOccurred.tr,
        ErrorHandler.formatError(e),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateApprovalStatus(String songId, String status) async {
    try {
      isLoading.value = true;
      final currentUser = _supabaseService.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User session not found.');
      }
      final updatedSong = await _songsRepository.updateSongApprovalStatus(songId, status, currentUser.id);
      
      final index = songs.indexWhere((s) => s.id == songId);
      if (index != -1) {
        songs[index] = updatedSong;
      }
      final message = status == 'approved' ? 'Song approved successfully.' : 'Song declined successfully.';
      Get.snackbar(LocaleKeys.success.tr, message,
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar(
        LocaleKeys.errorOccurred.tr,
        ErrorHandler.formatError(e),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveSong({
    required String title,
    required String lyrics,
    String? singerName,
    String? albumName,
    String? language,
    String? categoryId,
    required List<String> tagIds,
    required List<String> raagIds,
    required bool status,
    String visibility = 'public',
    SongModel? existingSong,
  }) async {
    if (title.trim().isEmpty || lyrics.trim().isEmpty) {
      Get.snackbar(LocaleKeys.errorOccurred.tr, 'Title and lyrics are required.',
          backgroundColor: Colors.amber.shade900, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      final isEdit = existingSong != null;

      String? imageUrl = isEdit ? existingSong.thumbnail : null;
      if (selectedImageBytes.value != null) {
        isUploading.value = true;
        final String path = 'songs/${DateTime.now().millisecondsSinceEpoch}_${selectedImageName.value}';
        imageUrl = await _supabaseService.uploadImage(
          path: path,
          fileBytes: selectedImageBytes.value!,
          mimeType: selectedMimeType.value,
        );
        isUploading.value = false;
      }

      final currentUser = _supabaseService.client.auth.currentUser;
      // Dynamically determine approval status based on role
      final String userRole = _supabaseService.client.auth.currentSession != null
          ? (Get.isRegistered<AuthController>() 
              ? (Get.find<AuthController>().profile?.role ?? 'user')
              : 'user')
          : 'user';

      final Map<String, dynamic> songData = {
        'title': title.trim(),
        'lyrics': lyrics.trim(),
        'singer_name': singerName?.trim(),
        'album_name': albumName?.trim(),
        'language': language?.trim(),
        'category_id': categoryId,
        'thumbnail': imageUrl,
        'status': status,
        'visibility': visibility,
        'approval_status': isEdit 
            ? existingSong.approvalStatus 
            : (userRole == 'admin' ? 'approved' : 'pending'),
        'created_by': isEdit ? existingSong.createdBy : currentUser?.id,
      };

      if (isEdit) {
        final updated = await _songsRepository.updateSong(existingSong.id, songData, tagIds, raagIds);
        final index = songs.indexWhere((s) => s.id == existingSong.id);
        if (index != -1) {
          songs[index] = updated;
        }
        Get.back(); // return to list view
        Get.snackbar(LocaleKeys.success.tr, 'Song updated successfully.',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        final newSong = await _songsRepository.createSong(songData, tagIds, raagIds);
        songs.insert(0, newSong);
        
        if (Get.isRegistered<HomeController>() && Get.find<HomeController>().tabIndex.value == 2) {
          Get.find<HomeController>().changeTab(4); // Redirect to Profile tab to see uploaded songs
        } else {
          Get.back(); // return to list view
        }
        
        Get.snackbar(LocaleKeys.success.tr, 
            userRole == 'admin' 
                ? 'Song added successfully.' 
                : 'Song submitted successfully and is pending moderator review.',
            backgroundColor: Colors.green, colorText: Colors.white);
      }
      clearSelectedImage();
    } catch (e) {
      Get.snackbar(
        LocaleKeys.errorOccurred.tr,
        ErrorHandler.formatError(e),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isUploading.value = false;
    }
  }

  // Create Tag Action
  Future<TagModel?> addNewTag(String name) async {
    if (name.trim().isEmpty) return null;
    
    final nameTrimmed = name.trim();
    final exists = tags.any((tag) => tag.name.trim().toLowerCase() == nameTrimmed.toLowerCase());
    if (exists) {
      Get.snackbar(
        LocaleKeys.errorOccurred.tr,
        'Tag with this name already exists.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return null;
    }

    try {
      isLoading.value = true;
      final newTag = await _tagsRepository.createTag(nameTrimmed);
      tags.add(newTag);
      tags.sort((a, b) => a.name.compareTo(b.name));
      
      // Update TagsController if registered
      try {
        if (Get.isRegistered<TagsController>()) {
          final tagsController = Get.find<TagsController>();
          tagsController.tags.add(newTag);
          tagsController.tags.sort((a, b) => a.name.compareTo(b.name));
        }
      } catch (_) {}
      
      Get.snackbar(LocaleKeys.success.tr, 'Tag added successfully.',
          backgroundColor: Colors.green, colorText: Colors.white);
      return newTag;
    } catch (e) {
      Get.snackbar(
        LocaleKeys.errorOccurred.tr,
        ErrorHandler.formatError(e),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Create Raag Action
  Future<RaagModel?> addNewRaag(String name) async {
    if (name.trim().isEmpty) return null;
    
    final nameTrimmed = name.trim();
    final exists = raags.any((r) => r.name.trim().toLowerCase() == nameTrimmed.toLowerCase());
    if (exists) {
      Get.snackbar(
        LocaleKeys.errorOccurred.tr,
        'Raag with this name already exists.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return null;
    }

    try {
      isLoading.value = true;
      final newRaag = await _raagsRepository.createRaag(nameTrimmed);
      raags.add(newRaag);
      raags.sort((a, b) => a.name.compareTo(b.name));
      
      // Update RaagsController if registered
      try {
        if (Get.isRegistered<RaagsController>()) {
          final raagsController = Get.find<RaagsController>();
          raagsController.raags.add(newRaag);
          raagsController.raags.sort((a, b) => a.name.compareTo(b.name));
        }
      } catch (_) {}
      
      Get.snackbar(LocaleKeys.success.tr, 'Raag added successfully.',
          backgroundColor: Colors.green, colorText: Colors.white);
      return newRaag;
    } catch (e) {
      Get.snackbar(
        LocaleKeys.errorOccurred.tr,
        ErrorHandler.formatError(e),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Filter setters
  void setCategoryFilter(String? catId) {
    selectedCategoryFilter.value = catId;
    loadSongs();
  }

  void setStatusFilter(bool? status) {
    selectedStatusFilter.value = status;
    loadSongs();
  }

  void resetFilters() {
    searchController.clear();
    selectedCategoryFilter.value = null;
    selectedStatusFilter.value = null;
    selectedTagFilters.clear();
    selectedRaagFilters.clear();
    loadSongs();
  }

  // Bulk Upload Songs from JSON File
  Future<void> bulkUploadSongsFromJson(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        Get.snackbar(
          LocaleKeys.errorOccurred.tr,
          'Could not read JSON file bytes.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      final jsonString = utf8.decode(bytes);
      final dynamic parsedJson = jsonDecode(jsonString);

      List<dynamic> rawItems = [];
      if (parsedJson is List) {
        rawItems = parsedJson;
      } else if (parsedJson is Map<String, dynamic>) {
        if (parsedJson.containsKey('subTodos') && parsedJson['subTodos'] is List) {
          rawItems = parsedJson['subTodos'] as List;
        } else if (parsedJson.containsKey('todos') && parsedJson['todos'] is List) {
          rawItems = parsedJson['todos'] as List;
        } else if (parsedJson.containsKey('songs') && parsedJson['songs'] is List) {
          rawItems = parsedJson['songs'] as List;
        } else if (parsedJson.containsKey('items') && parsedJson['items'] is List) {
          rawItems = parsedJson['items'] as List;
        }
      }

      final List<Map<String, String>> parsedSongs = [];
      for (var item in rawItems) {
        if (item is Map<String, dynamic>) {
          final title = (item['title'] ?? item['name'] ?? '').toString().trim();
          final lyrics = (item['description'] ?? item['lyrics'] ?? item['body'] ?? '').toString().trim();

          if (title.isNotEmpty && lyrics.isNotEmpty) {
            parsedSongs.add({
              'title': title,
              'lyrics': lyrics,
            });
          }
        }
      }

      if (parsedSongs.isEmpty) {
        Get.snackbar(
          LocaleKeys.errorOccurred.tr,
          'No valid song items with title and description/lyrics found in ${file.name}.',
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.white,
        );
        return;
      }

      // Show confirmation dialog with optional Category selection
      String? selectedCategoryId;
      if (!context.mounted) return;
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Bulk Upload Songs (${file.name})'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Found ${parsedSongs.length} valid song(s) to upload.'),
                    const SizedBox(height: 16),
                    const Text(
                      'Assign Category (Optional):',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedCategoryId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        hintText: 'Select Category (Optional)',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('No Category'),
                        ),
                        ...categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat.id,
                            child: Text(cat.name),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setState(() {
                          selectedCategoryId = val;
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(LocaleKeys.cancel.tr),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.cloud_upload),
                    label: Text('Upload ${parsedSongs.length} Songs'),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                  ),
                ],
              );
            },
          );
        },
      );

      if (confirmed == true) {
        isLoading.value = true;
        final String? userId = _supabaseService.client.auth.currentUser?.id;

        final List<Map<String, dynamic>> songsToInsert = parsedSongs.map((song) {
          final Map<String, dynamic> row = {
            'title': song['title'],
            'lyrics': song['lyrics'],
            'status': true,
            'visibility': 'public',
            'approval_status': 'approved',
          };
          if (selectedCategoryId != null) {
            row['category_id'] = selectedCategoryId;
          }
          if (userId != null) {
            row['created_by'] = userId;
          }
          return row;
        }).toList();

        final count = await _songsRepository.bulkCreateSongs(songsToInsert);
        await loadSongs();

        try {
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().fetchHomeData();
          }
        } catch (_) {}


        Get.snackbar(
          LocaleKeys.success.tr,
          'Successfully uploaded $count songs from ${file.name}!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.e('Failed to bulk upload songs from JSON: $e', stackTrace: stackTrace);
      Get.snackbar(
        LocaleKeys.errorOccurred.tr,
        ErrorHandler.formatError(e),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

