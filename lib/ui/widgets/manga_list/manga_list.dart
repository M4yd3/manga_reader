import 'package:flutter/material.dart';

import '../../../core/data_models/manga_model.dart';
import '../../views/base_view/base_controller.dart';
import 'manga_list_item.dart';

class MangaList extends StatelessWidget {
  final List<Manga> mangaList;

  const MangaList(this.mangaList);

  @override
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (_, index) => MangaListItem(
        mangaList[index],
        selected: index == BaseController.to.selected,
      ),
      childCount: mangaList.length,
    ));
  }
}
