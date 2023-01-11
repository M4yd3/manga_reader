import 'dart:io';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/constants/enums.dart';
import '../../../core/data_models/manga_model.dart';
import '../base_view/base_controller.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find();

  RxList<Manga> mangaData = <Manga>[].obs;

  BaseScope _scope = BaseScope.library;

  set scope(BaseScope value) {
    _scope = value;
    BaseController.to.scrollController.jumpTo(0);
    BaseController.to.selected = -1;
    Get.back();
    update();
  }

  BaseScope get scope => _scope;

  bool get isGroupScope =>
      _scope == BaseScope.authors || _scope == BaseScope.series;

  static GetStorage box = GetStorage();

  RxString? mainDirectory;

  @override
  void onInit() {
    final storedManga = box.read<List>('manga_data');

    if (storedManga != null) {
      mangaData = storedManga.map((e) => Manga.fromJson(e)).toList().obs;
    }

    mainDirectory = RxString(box.read('main_directory') ?? '');
    super.onInit();
  }

  void updateMainDirectory({replace = true}) {
    Get.log('mainDirectory updated');
    box.write('main_directory', mainDirectory!.value);
    final mainDir = Directory.fromUri(Uri.directory(mainDirectory!.value));
    final temp = <Directory>[];
    Get.log('$mainDir');
    Get.log('${mainDir.listSync()}');
    for (final entity in mainDir.listSync(recursive: true)) {
      if (entity is Directory) {
        var hasFiles = false;
        for (final file in entity.listSync()) {
          if (file is File) {
            hasFiles = true;
            break;
          }
        }
        if (hasFiles) temp.add(entity);
      }
    }
    final newManga = convertList(temp).obs;
    if (replace) {
      mangaData = newManga;
    } else {
      final paths = mangaData.map((element) => element.path);
      for (final data in newManga) {
        if (!paths.contains(data.path)) mangaData.add(data);
      }
    }
    updateMangaData();
    Get.log('mangaData: $mangaData');
    update();
  }

  Future<bool> updateMangaData([updateView = true]) async {
    Get.log('mangaData updated');
    await box.write('manga_data', mangaData.toList());
    if (updateView) update();
    return true;
  }

  List<Manga> convertList(List<Directory> list) {
    final mangas = <Manga>[];
    for (final directory in list) {
      final manga = _getManga(directory);
      if (manga != null) mangas.add(manga);
    }
    return mangas;
  }

  Manga? _getManga(Directory directory) {
    final name = directory.path.split('/').last;
    try {
      final manga = Manga(
        path: directory.path,
        title: name.substring(name.indexOf(']')).trim(),
        author: name.substring(name.indexOf('['), name.lastIndexOf(']')),
        pageCount: directory.listSync().length,
      );
      return manga;
    } catch (error) {
      Get.log(error.toString());
    }
    return null; // Get.log(man
  }
}
