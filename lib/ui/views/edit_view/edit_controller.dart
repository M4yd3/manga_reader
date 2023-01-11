import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/data_models/manga_model.dart';
import '../home_view/home_controller.dart';

class EditController extends GetxController {
  late final Manga manga;

  late TextEditingController titleController;
  late TextEditingController authorController;
  late TextEditingController seriesController;

  @override
  void onInit() {
    manga = Get.arguments;
    Get.log('manga');
    titleController = TextEditingController(text: manga.title);
    authorController = TextEditingController(text: manga.author ?? '');
    seriesController = TextEditingController(text: manga.series ?? '');
    update();
    super.onInit();
  }

  void submitEdit() {
    final title = titleController.text.trim();
    if (title != manga.title && title.isNotEmpty) {
      manga.title = title;
    }
    final author = authorController.text.trim();
    manga.author = author;
    final series = seriesController.text.trim();
    manga.series = series;
    HomeController.to.updateMangaData();
    Get.back();
  }
}
