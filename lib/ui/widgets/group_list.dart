import 'package:flutter/material.dart';

import '../../core/data_models/manga_model.dart';
import '../views/base_view/base_controller.dart';
import 'manga_list/manga_list_item.dart';

class GroupList extends StatelessWidget {
  final List<MapEntry<String, List<Manga>>> mangaList;

  const GroupList(this.mangaList);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, groupIndex) {
          final color = BaseController.to.selected == groupIndex
              ? const Color(0xff606060)
              : const Color(0xff303030);
          return Container(
            color: color,
            child: ExpansionTile(
              collapsedBackgroundColor: Colors.transparent,
              backgroundColor: const Color(0xff303030),
              childrenPadding: const EdgeInsets.only(top: 4),
              title: Text(mangaList[groupIndex].key),
              children: List.generate(
                mangaList[groupIndex].value.length,
                (mangaIndex) => MangaListItem(
                  mangaList[groupIndex].value[mangaIndex],
                ),
              ),
            ),
          );
        },
        childCount: mangaList.length,
      ),
    );
  }
}
