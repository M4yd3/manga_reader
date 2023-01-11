import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/constants/enums.dart';
import '../../../core/data_models/manga_model.dart';
import '../../../core/extensions.dart';
import '../home_view/home_controller.dart';

class BaseController extends GetxController {
  static BaseController get to => Get.find();

  SortingOrder _currentSortingOrder = SortingOrder.title;

  SortingOrder get currentSortingOrder => _currentSortingOrder;

  set currentSortingOrder(SortingOrder order) {
    _currentSortingOrder = order;
    update();
  }

  int selected = -1;

  ScrollController scrollController = ScrollController();

  TextEditingController searchController = TextEditingController();

  List getSpecifiedContent(BaseScope scope, {bool withSorting = true}) {
    final data = HomeController.to.mangaData;
    List newData;
    switch (scope) {
      case BaseScope.library:
        newData = data;
        break;
      case BaseScope.reading:
        newData = data
            .where((e) => e.currentPage > 1 && !e.haveRead && !e.toRead)
            .toList();
        break;
      case BaseScope.toRead:
        newData = data.where((e) => e.toRead).toList();
        break;
      case BaseScope.haveRead:
        newData = data.where((e) => e.haveRead).toList();
        break;
      case BaseScope.favorite:
        newData = data.where((e) => e.favorite).toList();
        break;
      case BaseScope.haventRead:
        newData = data.where((e) => !e.haveRead).toList();
        break;
      case BaseScope.search:
        final searchQuery = searchController.text.toLowerCase();
        newData = data
            .where((e) =>
                e.path.split('/').last.toLowerCase().contains(searchQuery) ||
                (e.series ?? '').toLowerCase().contains(searchQuery))
            .toList();
        break;
      case BaseScope.authors:
        // ignore: avoid_types_on_closure_parameters
        newData = groupBy(data, (Manga m) {
          return m.author ?? '';
        }).entries.whereNot((element) => element.key.isEmpty).toList();
        break;
      case BaseScope.series:
        // ignore: avoid_types_on_closure_parameters
        newData = groupBy(data, (Manga m) {
          return m.series ?? '';
        }).entries.whereNot((element) => element.key.isEmpty).toList();
        break;
    }
    if (withSorting && !HomeController.to.isGroupScope) {
      sortManga(newData.cast<Manga>());
    } else if (HomeController.to.isGroupScope && scope != BaseScope.search) {
      newData.sortBy<String>((element) => element.key);
    }
    return newData;
  }

  List<Manga> sortManga(List<Manga> data) {
    switch (currentSortingOrder) {
      case SortingOrder.title:
        data.sort((a, b) => a.title.naturalCompareTo(b.title));
        break;
      case SortingOrder.author:
        data.sort((a, b) {
          var compare = (a.author ?? '').naturalCompareTo(b.author ?? '');
          if (compare == 0) compare = a.title.naturalCompareTo(b.title);
          return compare;
        });
        break;
      case SortingOrder.size:
        data.sort((a, b) => a.pageCount.compareTo(b.pageCount));
        break;
    }
    return data;
  }

  String getCountTitle(BaseScope scope) {
    switch (scope) {
      case BaseScope.authors:
        return 'Authors';
      case BaseScope.series:
        return 'Series';
      default:
        return 'Manga';
    }
  }

  File? getThumbnail(Manga manga) {
    final directory = Directory.fromUri(Uri.directory(manga.path)).listSync();
    directory.sort((a, b) => a.path.compareTo(b.path));
    final file = directory.first;
    if (file is File) return file;
    return null;
  }

  void toggle(Manga manga, ToggleParam param) {
    switch (param) {
      case ToggleParam.favorite:
        manga.favorite = !manga.favorite;
        break;
      case ToggleParam.toRead:
        manga.toRead = !manga.toRead;
        manga.haveRead = false;
        break;
      case ToggleParam.haveRead:
        manga.haveRead = !manga.haveRead;
        manga.toRead = false;
        break;
    }
    HomeController.to.updateMangaData();
    update();
  }

  Future<void> editManga(Manga manga) async {
    await Get.toNamed('/edit-view', arguments: manga);
    update();
  }

  void openRandomManga(BaseScope scope) {
    const appBarHeight = 56.0;
    const expansionListHeight = 58.0;
    const mangaListTileHeight = 160.0;
    const mangaListTilePadding = 8.0;
    final listTileHeight = HomeController.to.isGroupScope
        ? expansionListHeight
        : (mangaListTileHeight + mangaListTilePadding);
    final maxTilesOnScreen =
        (Get.height - Get.statusBarHeight) ~/ listTileHeight;

    final list = getSpecifiedContent(scope, withSorting: false);
    if (list.isNotEmpty && list.length != 1) {
      int randomIndex;
      do {
        randomIndex = Random().nextInt(list.length);
      } while (selected == randomIndex);

      final maxTopPadding = Get.height -
          16 -
          mangaListTilePadding -
          maxTilesOnScreen * listTileHeight;
      final minListLength = max(list.length - maxTilesOnScreen, 0);

      final upperLimit = minListLength * listTileHeight +
          minListLength.clamp(0, 1) * (appBarHeight - maxTopPadding);

      double position;
      position = appBarHeight + listTileHeight * randomIndex;
      position = min(position, upperLimit);

      if (scrollController.offset > position) position -= appBarHeight;

      scrollController.animateTo(
        position,
        duration: 500.milliseconds +
            10.milliseconds * ((randomIndex - selected).abs() - 1),
        curve: Curves.easeInOut,
      );

      selected = randomIndex;

      update();
    }
  }
}
