import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:async';

Future<bool> checkCameraConnection() async {
  try {
    final navigator = html.window.navigator;
    if (navigator.mediaDevices == null) {
      return false;
    }
    final devices = await navigator.mediaDevices!.enumerateDevices();
    for (final device in devices) {
      if (device.kind == 'videoinput') {
        return true;
      }
    }
  } catch (e) {
    return false;
  }
  return false;
}

Future<String?> capturePhotoFromWebcam() async {
  try {
    final completer = Completer<String?>();
    final dynamic promise = js.context.callMethod('_captureFromWebcam');
    if (promise != null && promise is js.JsObject) {
      promise.callMethod('then', [
        (dynamic result) => completer.complete(result as String?),
        (dynamic error) => completer.complete(null),
      ]);
      return await completer.future;
    }
    return null;
  } catch (e) {
    return null;
  }
}


