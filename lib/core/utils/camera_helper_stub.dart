Future<bool> checkCameraConnection() async {
  // Native mobile platforms handle camera checks dynamically or throw exceptions via the plugin.
  return true;
}

Future<String?> capturePhotoFromWebcam() async {
  // Mobile uses the native picker, so return null to fall back to ImagePicker.
  return null;
}
