import 'package:get/get.dart';

import 'ui/views/edit_view/edit_view.dart';
import 'ui/views/home_view/home_view.dart';
import 'ui/views/settings_view/settings_view.dart';

List<GetPage> getPages = [
  GetPage(name: '/', page: () => HomeView()),
  GetPage(name: '/settings', page: () => SettingsView()),
  GetPage(name: '/edit-view', page: () => EditView())
];
