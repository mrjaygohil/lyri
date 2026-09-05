import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as js_util;

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
    final promise = js.context.callMethod('_captureFromWebcam');
    final result = await js_util.promiseToFuture(promise);
    return result as String?;
  } catch (e) {
    return null;
  }
}
