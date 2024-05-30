import 'dart:convert';
import 'dart:ui' as ui;

// ignore: avoid_web_libraries_in_flutter
// import 'dart:html' as html;

import 'package:file_picker/file_picker.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:particular/particular.dart';

/// Browse files from the user's device.
///
/// This function uses the [FilePicker] library to allow the user to select
/// files. It returns a `Future` that resolves to a list of [PlatformFile]
/// objects. If the user cancels the selection, the function returns an empty
/// list.
///
/// Returns:
/// - A `Future<List<PlatformFile>>`: A list of [PlatformFile] objects
///   representing the selected files.
Future<List<PlatformFile>> browseFiles() async {
  // Use the FilePicker library to allow the user to select files.
  final pickResult = await FilePicker.platform.pickFiles(
    withData: true,
    type: FileType.any,
  );

  // If the user cancels the selection or no file is selected, return an empty
  // list. Otherwise, return the selected files.
  return pickResult?.files ?? [];
}

/// Browse and load an image from the user's device.
///
/// This function uses the [FilePicker] library to allow the user to select an
/// image file. If the user cancels the selection or no image is selected, the
/// function returns a `Future` that resolves to a tuple containing the empty
/// string and `null`. Otherwise, it reads the contents of the selected file,
/// decodes it from bytes and returns a `Future` that resolves to a tuple
/// containing the name of the selected file and the decoded image.
///
/// Returns:
/// - A `Future<(String, ui.Image?)>`: A tuple containing the name of the
///   selected file and the decoded image. If the user cancels the selection or
///   no image is selected, the tuple contains the empty string and `null`.
Future<(String, ui.Image?)> browseImage() async {
  // Use the FilePicker library to allow the user to select an image file.
  final files = await browseFiles();

  if (files.isNotEmpty) {
    PlatformFile file = files.first;
    if (file.bytes != null) {
      var image = await loadUIImage(file.bytes!);
      return (file.name, image);
    }
  }

  return ("", null);
}

/// Browse and load configs from a file with specified extensions.
///
/// The function uses the [FilePicker] library to allow the user to select a file
/// with a specific set of extensions. If the user cancels the selection or no
/// file is selected, the function returns `null`. Otherwise, it reads the
/// contents of the selected file, decodes it from JSON and returns the decoded
/// map.
///
/// Parameters:
/// - [extensions]: A list of file extensions supported by the config file.
///
/// Returns:
/// - A `Future<dynamic>`: A map of configuration data, decoded
///   from JSON, or `null` if no file was selected.
Future<dynamic> browseConfigs(List<String> extensions) async {
  // Use the FilePicker library to allow the user to select a config file.
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    withData: true, // Request file contents.
    type: FileType.custom, // Allow any type of file.
    allowedExtensions:
        extensions, // Only allow files with specified extensions.
  );

  // If no file was selected, return null.
  if (result == null) return null;

  // Get the first selected file.
  PlatformFile file = result.files.first;

  // Decode the JSON contents of the file.
  String json = String.fromCharCodes(file.bytes!);
  return jsonDecode(json);
}

/// Save the provided configs to a file.
///
/// If the app is running on a non-web platform, the function uses the
/// [FilePicker.saveFile] method to open a file picker dialog for the user to
/// select a filename. The configs are encoded to JSON and saved to the
/// selected file with the `.json` extension.
///
/// Parameters:
/// - [configs]: The configs to save.
/// - [filename]: The name of the file to save the configs to. If not
///   provided, the filename will be "configs".
///
/// Returns:
/// - A `Future<void>`: A future that completes when the configs have been
///   saved to a file.
Future<void> saveConfigs({required dynamic configs, String? filename}) async {
  final json = jsonEncode(configs);
  final bytes = utf8.encode(json);

  // if (kIsWeb) {
  //   final blob = html.Blob([bytes]);
  //   final url = html.Url.createObjectUrlFromBlob(blob);
  //   final anchor = html.document.createElement('a') as html.AnchorElement
  //     ..href = url
  //     ..style.display = 'none'
  //     ..download = 'configs.json';
  //   html.document.body!.children.add(anchor);

  //   // Download
  //   anchor.click();

  //   // Cleanup
  //   html.document.body!.children.remove(anchor);
  //   html.Url.revokeObjectUrl(url);
  // } else {
  await FilePicker.platform.saveFile(
    dialogTitle: "Save Particle Configs",
    fileName: "${filename ?? "configs"}.json",
    bytes: bytes,
  );
  // }
}
