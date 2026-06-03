import '../../features/songs/models/song_model.dart';

class SearchHelper {
  /// Calculates a relevance score for a song based on a search query.
  /// Returns 0 if there is no match, or a positive integer representing the match strength.
  static int calculateSongMatchScore(SongModel song, String query) {
    final cleanQuery = query.toLowerCase().trim();
    if (cleanQuery.isEmpty) return 0;

    final words = cleanQuery.split(RegExp(r'\s+'));

    final title = song.title.toLowerCase();
    final singer = (song.singerName ?? '').toLowerCase();
    final album = (song.albumName ?? '').toLowerCase();
    final lyrics = song.lyrics.toLowerCase();
    final tags = (song.tags ?? []).map((t) => t.name.toLowerCase()).toList();

    int score = 0;

    // 1. Check exact matches (highest priority)
    if (title == cleanQuery) score += 1000;
    if (singer == cleanQuery) score += 500;
    if (album == cleanQuery) score += 300;

    // 2. Check tag exact matches
    for (final tag in tags) {
      if (tag == cleanQuery) {
        score += 400;
      }
    }

    // 3. Substring matches
    if (title.contains(cleanQuery)) {
      score += 200;
    }
    if (singer.contains(cleanQuery)) {
      score += 100;
    }
    if (album.contains(cleanQuery)) {
      score += 80;
    }
    if (lyrics.contains(cleanQuery)) {
      score += 20;
    }

    // 4. Tag substring matches
    for (final tag in tags) {
      if (tag.contains(cleanQuery)) {
        score += 150;
      }
    }

    // 5. Word-by-word matches (checking if words are present in some fields)
    int matchedWords = 0;
    for (final word in words) {
      bool wordMatched = false;
      if (title.contains(word)) {
        wordMatched = true;
        score += 20;
      }
      if (singer.contains(word)) {
        wordMatched = true;
        score += 15;
      }
      if (album.contains(word)) {
        wordMatched = true;
        score += 10;
      }
      if (lyrics.contains(word)) {
        wordMatched = true;
        score += 2;
      }
      for (final tag in tags) {
        if (tag.contains(word)) {
          wordMatched = true;
          score += 18;
        }
      }
      if (wordMatched) {
        matchedWords++;
      }
    }

    // If none of the words matched, return 0 (no match)
    if (matchedWords == 0) {
      return 0;
    }

    // Add bonus for matching more words
    score += matchedWords * 10;

    // 6. Character sequence matching (fuzzy sequence, e.g. "bhm" matches "Bohemian")
    if (cleanQuery.length >= 2) {
      if (_fuzzySequenceMatch(title, cleanQuery)) score += 30;
      for (final tag in tags) {
        if (_fuzzySequenceMatch(tag, cleanQuery)) score += 25;
      }
    }

    return score;
  }

  static bool _fuzzySequenceMatch(String source, String query) {
    int sourceIndex = 0;
    int queryIndex = 0;
    while (sourceIndex < source.length && queryIndex < query.length) {
      if (source[sourceIndex] == query[queryIndex]) {
        queryIndex++;
      }
      sourceIndex++;
    }
    return queryIndex == query.length;
  }

  /// Splits a source string into highlighted and non-highlighted segments
  /// based on the matching portions of a query string.
  /// Returns a list of MapEntry where the key is the text slice and the value is true if it matches.
  static List<MapEntry<String, bool>> highlightSegments(String source, String query) {
    final cleanQuery = query.toLowerCase().trim();
    if (cleanQuery.isEmpty) {
      return [MapEntry(source, false)];
    }

    final lowerSource = source.toLowerCase();
    final index = lowerSource.indexOf(cleanQuery);

    if (index == -1) {
      // Fuzzy split word by word if no direct substring match
      final words = cleanQuery.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      if (words.isEmpty) return [MapEntry(source, false)];

      // Highlight the first matching word we find
      for (final word in words) {
        final wIndex = lowerSource.indexOf(word);
        if (wIndex != -1) {
          final segments = <MapEntry<String, bool>>[];
          if (wIndex > 0) {
            segments.add(MapEntry(source.substring(0, wIndex), false));
          }
          segments.add(MapEntry(source.substring(wIndex, wIndex + word.length), true));
          if (wIndex + word.length < source.length) {
            segments.add(MapEntry(source.substring(wIndex + word.length), false));
          }
          return segments;
        }
      }

      return [MapEntry(source, false)];
    }

    final segments = <MapEntry<String, bool>>[];
    if (index > 0) {
      segments.add(MapEntry(source.substring(0, index), false));
    }
    segments.add(MapEntry(source.substring(index, index + cleanQuery.length), true));
    if (index + cleanQuery.length < source.length) {
      segments.add(MapEntry(source.substring(index + cleanQuery.length), false));
    }

    return segments;
  }
}
