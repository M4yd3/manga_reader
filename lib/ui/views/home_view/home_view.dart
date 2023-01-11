import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/enums.dart';
import '../../shared/text_styles.dart';
import '../base_view/base_view.dart';
import 'home_controller.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) => SafeArea(
        child: Scaffold(
          body: BaseView(controller.scope),
          drawer: Drawer(
            child: ListView(
              children: [
                SizedBox(
                  height: 40 + 16 * 2,
                  child: DrawerHeader(
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset('assets/icon/icon.png'),
                        const SizedBox(width: 30),
                        const Text('Manga Reader', style: overHeaderStyle)
                      ],
                    ),
                  ),
                ),
                buildBaseTile(
                  title: 'Reading Now',
                  icon: Icons.repeat,
                  scope: BaseScope.reading,
                ),
                buildBaseTile(
                  title: 'Library',
                  icon: Icons.library_books,
                  scope: BaseScope.library,
                ),
                buildBaseTile(
                  title: 'To Read',
                  icon: Icons.watch_later_outlined,
                  scope: BaseScope.toRead,
                ),
                buildBaseTile(
                  title: 'Have Read',
                  icon: Icons.done_all,
                  scope: BaseScope.haveRead,
                ),
                buildBaseTile(
                  title: 'Favorites',
                  icon: Icons.favorite,
                  scope: BaseScope.favorite,
                ),
                buildBaseTile(
                  title: 'Haven\'t Read',
                  icon: Icons.fiber_new,
                  scope: BaseScope.haventRead,
                ),
                const Divider(),
                buildBaseTile(
                    title: 'Authors',
                    icon: Icons.person,
                    scope: BaseScope.authors),
                buildBaseTile(
                    title: 'Series',
                    icon: Icons.local_offer,
                    scope: BaseScope.series),
                const Divider(),
                ListTile(
                  title: const Text('Settings'),
                  leading: const Icon(Icons.settings),
                  onTap: () => Get.toNamed('/settings'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBaseTile(
      {required String title,
      required IconData icon,
      required BaseScope scope}) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      onTap: () => HomeController.to.scope = scope,
    );
  }
}
