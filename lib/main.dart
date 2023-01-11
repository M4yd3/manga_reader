import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';

import 'pages.dart';
import 'ui/shared/theme.dart';

Future main() async {
  runApp(await _myApp());
  await requestStoragePermissions();
}

Future<Widget> _myApp() async {
  await GetStorage.init();
  return GetMaterialApp(
    title: 'Manga Reader',
    theme: theme,
    getPages: getPages,
    initialRoute: '/',
  );
}

Future requestStoragePermissions() async {
  final status = await Permission.storage.request();
  Get.log('Storage permission status: $status');
}
