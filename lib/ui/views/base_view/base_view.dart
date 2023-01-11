import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/enums.dart';
import '../../../core/data_models/manga_model.dart';
import '../../widgets/group_list.dart';
import '../../widgets/manga_list/manga_list.dart';
import '../home_view/home_controller.dart';
import 'base_controller.dart';

class BaseView extends StatelessWidget {
  final BaseScope scope;

  const BaseView(this.scope);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BaseController>(
      init: BaseController(),
      builder: (controller) {
        final content = controller.getSpecifiedContent(scope);
        return Scrollbar(
          controller: controller.scrollController,
          interactive: true,
          thickness: 10,
          radius: const Radius.circular(10),
          child: CustomScrollView(
            controller: controller.scrollController,
            cacheExtent: 50,
            restorationId: 'MainScrollView',
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: scope != BaseScope.search,
                title: scope == BaseScope.search
                    ? TextFormField(
                        autofocus: true,
                        controller: controller.searchController,
                        decoration:
                            const InputDecoration(hintText: 'Search...'),
                        onChanged: (_) {
                          controller.update();
                        },
                      )
                    : Text(getSpecifiedTitle()),
                floating: true,
                actions: [
                  if (scope != BaseScope.search)
                    IconButton(
                      onPressed: () {
                        Get.to(() => const BaseView(BaseScope.search));
                      },
                      icon: const Icon(Icons.search),
                    )
                  else
                    IconButton(
                      onPressed: () {
                        if (controller.searchController.text != '') {
                          controller.searchController.text = '';
                          controller.update();
                        } else {
                          Get.back();
                        }
                      },
                      icon: const Icon(Icons.clear),
                    ),
                  Visibility(
                    visible: scope != BaseScope.search,
                    child: IconButton(
                      onPressed: () => controller.openRandomManga(scope),
                      icon: const Icon(Icons.shuffle),
                    ),
                  ),
                  IconButton(
                    onPressed: () => showContextMenu(context),
                    icon: const Icon(Icons.sort),
                  ),
                ],
              ),
              if (HomeController.to.isGroupScope && scope != BaseScope.search)
                GroupList(content.cast<MapEntry<String, List<Manga>>>())
              else
                MangaList(content.cast<Manga>()),
            ],
          ),
        );
      },
    );
  }

  DropdownMenuItem buildSortingMenuItem({
    required String title,
    required SortingOrder order,
  }) {
    return DropdownMenuItem(
      onTap: () {
        BaseController.to.currentSortingOrder = order;
      },
      child: Text(title),
    );
  }

  String getSpecifiedTitle() {
    switch (scope) {
      case BaseScope.library:
        return 'Library';
      case BaseScope.reading:
        return 'Reading Now';
      case BaseScope.toRead:
        return 'To Read';
      case BaseScope.haveRead:
        return 'Have Read';
      case BaseScope.favorite:
        return 'Favorite';
      case BaseScope.haventRead:
        return 'Haven\'t Read';
      case BaseScope.search:
        return '';
      case BaseScope.authors:
        return 'Authors';
      case BaseScope.series:
        return 'Series';
    }
  }

  void showContextMenu(context) {
    var items = const [
      PopupMenuItem(
        value: SortingOrder.title,
        child: Text('Title'),
      ),
      PopupMenuItem(
        value: SortingOrder.author,
        child: Text('Author'),
      ),
      PopupMenuItem(
        value: SortingOrder.size,
        child: Text('Size'),
      ),
    ];
    if (HomeController.to.isGroupScope) {
      items = [];
    }
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(400, 10, 10, 400),
      items: [
        ...items,
        PopupMenuItem(
          child: Text('${BaseController.to.getCountTitle(scope)} '
              'count: ${BaseController.to.getSpecifiedContent(scope).length}'),
        ),
      ],
    ).then((value) {
      if (value != null) {
        BaseController.to.currentSortingOrder = value;
        BaseController.to.update();
      }
    });
  }
}
