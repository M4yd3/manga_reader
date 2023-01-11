import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

import '../../../core/data_models/manga_model.dart';
import '../../../core/extensions.dart';
import '../home_view/home_controller.dart';

class ReaderController extends GetxController {
  final Manga manga;

  PhotoViewScaleState scaleState = PhotoViewScaleState.initial;

  bool controlsVisible = false;

  ReaderController(this.manga);

  static ReaderController get to => Get.find();

  late PageController pageViewController;

  late List<File> pages;

  @override
  void onInit() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    sortPages();
    super.onInit();
  }

  @override
  InternalFinalCallback<void> get onDelete {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    HomeController.to.updateMangaData();
    return super.onDelete;
  }

  void sortPages() {
    pageViewController =
        PageController(initialPage: max(manga.currentPage - 1, 0));
    pages =
        List.castFrom(Directory.fromUri(Uri.directory(manga.path)).listSync());
    pages.sort((a, b) => a.path.naturalCompareTo(b.path));
  }

  void toggleControls() {
    controlsVisible = !controlsVisible;
    update();
  }

  void pageChanged(int value) {
    manga.currentPage = value + 1;
    update();
  }

  Future showJumpDialog() async {
    final textController = TextEditingController(text: '${manga.currentPage}');
    final focusNode = FocusNode();
    final result = await Get.dialog(Center(
      child: Card(
        child: Container(
          width: 270,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black38),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      iconSize: 30,
                      onPressed: () {
                        focusNode.unfocus();
                        final page = int.tryParse(textController.text) ?? 0;
                        textController.text =
                            '${(page - 1).clamp(1, manga.pageCount)}';
                      },
                    ),
                    const VerticalDivider(thickness: 0.1, width: 1),
                    Expanded(
                      child: TextField(
                        controller: textController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          isCollapsed: true,
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ClampFormatter(1, manga.pageCount),
                        ],
                      ),
                    ),
                    const VerticalDivider(thickness: 0.1, width: 1),
                    IconButton(
                      icon: const Icon(Icons.add),
                      iconSize: 30,
                      onPressed: () {
                        focusNode.unfocus();
                        final page = int.tryParse(textController.text) ?? 0;
                        textController.text =
                            '${(page + 1).clamp(1, manga.pageCount)}';
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Page ${manga.currentPage} of ${manga.pageCount}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back(result: int.parse(textController.text));
                },
                child: Container(
                  width: double.infinity,
                  height: 40,
                  alignment: Alignment.center,
                  child: const Text('Jump'),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
    if (result != manga.currentPage) pageViewController.jumpToPage(result - 1);
  }
}

class ClampFormatter extends TextInputFormatter {
  final int lowerLimit;
  final int upperLimit;

  ClampFormatter(this.lowerLimit, this.upperLimit);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isNotEmpty) {
      final page = int.parse(newValue.text);
      return newValue.copyWith(text: '${page.clamp(lowerLimit, upperLimit)}');
    }
    return newValue;
  }
}
