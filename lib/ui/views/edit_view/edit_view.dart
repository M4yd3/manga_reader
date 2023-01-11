import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'edit_controller.dart';

class EditView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditController>(
      init: EditController(),
      builder: (controller) => Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 32, left: 16, right: 16),
              child: TextFormField(
                controller: controller.titleController,
                // initialValue: controller.titleController.text,
                decoration: const InputDecoration(labelText: 'Title'),
                maxLines: 3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32, left: 16, right: 16),
              child: TextFormField(
                controller: controller.authorController,
                // initialValue: controller.authorController.text,
                decoration: const InputDecoration(labelText: 'Author'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32, left: 16, right: 16),
              child: TextFormField(
                controller: controller.seriesController,
                // initialValue: 'adasd',
                decoration: const InputDecoration(labelText: 'Series'),
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: controller.submitEdit,
          child: const Icon(Icons.done),
        ),
      ),
    );
  }
}
