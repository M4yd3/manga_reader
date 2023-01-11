import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home_view/home_controller.dart';
import 'settings_controller.dart';

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(
      init: SettingsController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: const Text('Folders'),
        ),
        body: ListView(
          children: [
            ListTile(
              title: const Text('Main Directory'),
              subtitle: Text(HomeController.to.mainDirectory?.value ?? 'None'),
              onTap: () => controller.pickNewFolder(context),
            )
          ],
        ),
      ),
    );
  }
}
