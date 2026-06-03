// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;


int _callbackId = 0;

Future<String?> transliterateWebImpl(String text, String itc) async {
  final completer = Completer<String?>();
  final callbackName = '__google_input_tools_cb_${_callbackId++}';

  js.context[callbackName] = (dynamic data) {
    try {
      if (data is List && data.isNotEmpty && data[0] == 'SUCCESS') {
        final results = data[1][0][1];
        if (results is List && results.isNotEmpty) {
          completer.complete(results[0] as String);
          return;
        }
      }
    } catch (e) {
      // ignore
    }
    completer.complete(null);
  };

  final script = html.ScriptElement()
    ..src = 'https://inputtools.google.com/request?text=${Uri.encodeComponent(text)}&itc=$itc&num=1&cp=0&cs=1&ie=utf-8&oe=utf-8&app=test&cb=$callbackName'
    ..onError.listen((_) {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    });

  html.document.head?.append(script);

  final result = await completer.future;

  script.remove();
  js.context[callbackName] = null;

  return result;
}
