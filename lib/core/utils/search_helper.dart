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
    final raags = (song.raags ?? []).map((r) => r.name.toLowerCase()).toList();

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

    // 2.2 Check raag exact matches
    for (final raag in raags) {
      if (raag == cleanQuery) {
        score += 400;
      }
    }

    // 2.5 Fuzzy whole-field matching (typo tolerance for entire search query)
    if (cleanQuery.length >= 4) {
      final titleDist = _levenshtein(cleanQuery, title);
      final titleMaxAllowed = cleanQuery.length > 5 ? 2 : 1;
      if (titleDist <= titleMaxAllowed) {
        score += (titleMaxAllowed - titleDist + 1) * 150;
      }

      final singerDist = _levenshtein(cleanQuery, singer);
      final singerMaxAllowed = cleanQuery.length > 5 ? 2 : 1;
      if (singerDist <= singerMaxAllowed) {
        score += (singerMaxAllowed - singerDist + 1) * 100;
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

    // 4.2 Raag substring matches
    for (final raag in raags) {
      if (raag.contains(cleanQuery)) {
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
      for (final raag in raags) {
        if (raag.contains(word)) {
          wordMatched = true;
          score += 18;
        }
      }

      // Fuzzy fallback for typos on a word level using Levenshtein distance
      if (!wordMatched && word.length >= 3) {
        final maxAllowed = word.length > 5 ? 2 : 1;

        // Try matching title words fuzzily
        final titleWords = title.split(RegExp(r'[\s\-\,\.\(\)\/\\]+')).where((w) => w.length >= 3);
        for (final tw in titleWords) {
          final dist = _levenshtein(word, tw);
          if (dist <= maxAllowed) {
            wordMatched = true;
            score += (maxAllowed - dist + 1) * 15;
          }
        }

        // Try matching singer words fuzzily
        final singerWords = singer.split(RegExp(r'[\s\-\,\.\(\)\/\\]+')).where((w) => w.length >= 3);
        for (final sw in singerWords) {
          final dist = _levenshtein(word, sw);
          if (dist <= maxAllowed) {
            wordMatched = true;
            score += (maxAllowed - dist + 1) * 12;
          }
        }

        // Try matching album words fuzzily
        final albumWords = album.split(RegExp(r'[\s\-\,\.\(\)\/\\]+')).where((w) => w.length >= 3);
        for (final aw in albumWords) {
          final dist = _levenshtein(word, aw);
          if (dist <= maxAllowed) {
            wordMatched = true;
            score += (maxAllowed - dist + 1) * 8;
          }
        }

        // Try matching tag words fuzzily
        for (final tag in tags) {
          final tagWords = tag.split(RegExp(r'[\s\-\,\.\(\)\/\\]+')).where((w) => w.length >= 3);
          for (final tg in tagWords) {
            final dist = _levenshtein(word, tg);
            if (dist <= maxAllowed) {
              wordMatched = true;
              score += (maxAllowed - dist + 1) * 13;
            }
          }
        }

        // Try matching raag words fuzzily
        for (final raag in raags) {
          final raagWords = raag.split(RegExp(r'[\s\-\,\.\(\)\/\\]+')).where((w) => w.length >= 3);
          for (final rg in raagWords) {
            final dist = _levenshtein(word, rg);
            if (dist <= maxAllowed) {
              wordMatched = true;
              score += (maxAllowed - dist + 1) * 13;
            }
          }
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
      for (final raag in raags) {
        if (_fuzzySequenceMatch(raag, cleanQuery)) score += 25;
      }
    }

    return score;
  }

  static int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.generate(t.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = _min3(v1[j] + 1, v0[j + 1] + 1, v0[j] + cost);
      }

      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }

    return v0[t.length];
  }

  static int _min3(int a, int b, int c) {
    int min = a;
    if (b < min) min = b;
    if (c < min) min = c;
    return min;
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
