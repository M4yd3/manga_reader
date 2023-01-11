import 'dart:io';

import 'package:get/get.dart';

import '../../widgets/folder_picker/folder_picker.dart';
import '../home_view/home_controller.dart';

class SettingsController extends GetxController {
  Future<void> pickNewFolder(context) async {
    final root = Directory.fromUri(Uri.directory('/storage/'));
    final newDirectory =
        await FolderPicker.pick(context: context, rootDirectory: root);
    if (newDirectory != null) {
      HomeController.to.mainDirectory = newDirectory.path.obs;
      HomeController.to.updateMainDirectory(replace: false);
    }
    update();
  }
}
