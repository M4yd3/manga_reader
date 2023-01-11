import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

import '../../../core/data_models/manga_model.dart';
import '../../shared/text_styles.dart';
import '../../widgets/neat_slider/neat_slider.dart';
import 'reader_controller.dart';

class ReaderView extends StatelessWidget {
  final Manga manga;

  const ReaderView(this.manga);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReaderController>(
      init: ReaderController(manga),
      builder: (controller) => SafeArea(
        child: GestureDetector(
          onTap: () => controller.toggleControls(),
          onHorizontalDragStart: controller.controlsVisible
              ? (_) {
                  controller.controlsVisible = false;
                  controller.update();
                }
              : null,
          child: Stack(
            children: [
              PageView.builder(
                controller: controller.pageViewController,
                onPageChanged: controller.pageChanged,
                physics: controller.scaleState == PhotoViewScaleState.initial
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                itemCount: manga.pageCount,
                itemBuilder: (context, index) => PhotoView(
                  scaleStateChangedCallback: (state) {
                    controller.scaleState = state;
                    controller.update();
                  },
                  imageProvider: FileImage(controller.pages[index]),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: 1.0,
                  filterQuality: FilterQuality.low,
                ),
              ),
              Visibility(
                visible: controller.controlsVisible,
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  backgroundColor: Colors.transparent,
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        color: const Color(0xff393939),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                manga.title,
                                // maxLines: 2,
                                style: headerStyle,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                manga.author ?? '',
                                // maxLines: 2,
                                style: subHeaderStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        color: const Color(0xff393939),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                controller.pageViewController.previousPage(
                                  duration: 300.milliseconds,
                                  curve: Curves.linearToEaseOut,
                                );
                              },
                              icon: const Icon(Icons.arrow_back_ios),
                            ),
                            OutlinedButton(
                              onPressed: controller.showJumpDialog,
                              child: Text(
                                '${manga.currentPage} of ${manga.pageCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                controller.pageViewController.nextPage(
                                  duration: 300.milliseconds,
                                  curve: Curves.linearToEaseOut,
                                );
                              },
                              icon: const Icon(Icons.arrow_forward_ios),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.all(8),
                child: NeatSlider(
                  segments: controller.manga.pageCount,
                  position: controller.manga.currentPage,
                  color: const Color(0xff505050),
                  padding: const EdgeInsets.symmetric(vertical: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
