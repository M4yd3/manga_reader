import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/enums.dart';
import '../../../core/data_models/manga_model.dart';
import '../../shared/text_styles.dart';
import '../../views/base_view/base_controller.dart';
import '../../views/reader_view/reader_view.dart';
import '../neat_slider/neat_slider.dart';

class MangaListItem extends StatelessWidget {
  final Manga manga;
  final bool selected;

  const MangaListItem(this.manga, {this.selected = false});

  BaseController get controller => BaseController.to;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: selected ? const Color(0xff606060) : Theme.of(context).cardColor,
      child: Container(
        padding: const EdgeInsets.all(8),
        height: 160,
        child: Row(
          children: [
            buildThumbnail(),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...buildMetadataWidget(),
                  buildActionButtons(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildThumbnail() {
    final thumbnail = controller.getThumbnail(manga);
    Widget child = const SizedBox();
    if (thumbnail != null && thumbnail.existsSync()) {
      child = Ink.image(
        fit: BoxFit.cover,
        width: 100,
        height: double.infinity,
        image: FileImage(thumbnail),
        child: GestureDetector(
          onTap: () => Get.to(() => ReaderView(manga)),
        ),
      );
    }
    return child;
  }

  List<Widget> buildMetadataWidget() {
    return [
      Text(
        manga.title,
        style: headerStyle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      Text(
        [
          if (manga.author != null && manga.author!.isNotEmpty) manga.author,
          if (manga.series != null && manga.series!.isNotEmpty) manga.series,
        ].join(', '),
        maxLines: 2,
        style: subHeaderStyle,
      ),
      const Spacer(),
      Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          '${manga.pageCount} pages',
          style: subHeaderStyle,
        ),
      ),
      NeatSlider(segments: manga.pageCount, position: manga.currentPage)
    ];
  }

  Widget buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          splashColor: Colors.white,
          splashRadius: 20,
          icon: const Icon(Icons.favorite),
          onPressed: () => controller.toggle(manga, ToggleParam.favorite),
          color: manga.favorite ? Colors.red : Colors.grey,
        ),
        IconButton(
          icon: const Icon(Icons.watch_later_outlined),
          onPressed: () => controller.toggle(manga, ToggleParam.toRead),
          color: manga.toRead ? Colors.lightBlue : Colors.grey,
        ),
        IconButton(
          icon: const Icon(Icons.done_all),
          onPressed: () => controller.toggle(manga, ToggleParam.haveRead),
          color: manga.haveRead ? Colors.green : Colors.grey,
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => controller.editManga(manga),
          color: Colors.grey,
        )
      ],
    );
  }
}
