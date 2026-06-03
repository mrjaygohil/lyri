import 'transliteration_helper_stub.dart'
    if (dart.library.html) 'transliteration_helper_web.dart'
    if (dart.library.io) 'transliteration_helper_native.dart';

Future<String?> transliterateWeb(String text, String itc) async {
  return transliterateWebImpl(text, itc);
}
