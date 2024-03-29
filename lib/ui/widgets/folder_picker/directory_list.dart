import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import 'folder_picker.dart';

// Internal widget used for rendering directory list
class DirectoryList extends StatefulWidget {
  @override
  _DirectoryListState createState() => _DirectoryListState();
}

class _DirectoryListState extends State<DirectoryList> {
  static const double spacing = 8;

  Directory? rootDirectory;
  Directory? currentDirectory;
  List<Directory?>? directoryList;

  @override
  void initState() {
    super.initState();

    // To make context available when init runs
    Future.delayed(Duration.zero).then((_) => _init());
  }

  Widget _buildBackNav(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(Icons.folder, color: theme.colorScheme.secondary),
      title: const Text('..'),
      onTap: () => _setDirectory(currentDirectory!.parent),
    );
  }

  List<Widget> _buildDirectories(BuildContext context) {
    final theme = Theme.of(context);

    if (directoryList == null) {
      return [
        const Expanded(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        )
      ];
    } else if (directoryList!.isEmpty) {
      return [
        _buildBackNav(context),
        const Expanded(
          child: Center(
              child: Text('Directory is empty!', textAlign: TextAlign.center)),
        )
      ];
    } else {
      return [
        Expanded(
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [_buildBackNav(context), ...directoryList!.map((directory) {
                return ListTile(
                  leading: Icon(Icons.folder, color: theme.colorScheme.secondary),
                  title: Text(_getDirectoryName(directory!)),
                  onTap: () => _setDirectory(directory),
                );
              })]
              ,
          ),
        )
      ];
    }
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final path = (currentDirectory != null)
        ? currentDirectory?.path.replaceAll(FolderPicker.rootPath, '') ?? ''
        : '';

    return Container(
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: theme.colorScheme.secondary, width: 2))),
      padding: const EdgeInsets.all(spacing),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Selected directory', style: theme.textTheme.subtitle2),
                const SizedBox(height: spacing / 2),
                Text(path, style: theme.textTheme.caption)
              ],
            ),
          ),
          if (data!.allowFolderCreation!) Padding(
                  padding: const EdgeInsets.only(left: spacing / 2),
                  child: IconButton(
                      color: theme.colorScheme.secondary,
                      icon: const Icon(Icons.create_new_folder),
                      onPressed: _createNewFolder)) else const SizedBox(height: 0, width: 0),
          Padding(
            padding: const EdgeInsets.only(left: spacing / 2),
            child: IconButton(
                color: theme.colorScheme.secondary,
                icon: const Icon(Icons.check),
                onPressed: () => Navigator.pop(context, currentDirectory)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        _buildHeader(context),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: _buildDirectories(context),
          ),
        ),
      ],
    );
  }

  Future<void> _init() async {
    rootDirectory = data!.rootDirectory;
    await _setDirectory(rootDirectory);
  }

  Future<void> _createNewFolder() async {
    final newDirectory = await showDialog<Directory>(
        builder: (_) => _NewFolderDialog(data: data, parent: currentDirectory),
        context: context);

    if (newDirectory != null) {
      await _setDirectory(newDirectory);
    }
  }

  Future<void> _setDirectory(Directory? directory) async {
    setState(() {
      try {
        directoryList = directory!
            .listSync()
            .map<Directory?>((fse) => (fse is Directory ? fse : null))
            .toList()
              ..removeWhere((fse) => fse == null);
        currentDirectory = directory;
      } catch (e) {
        // Ignore when tried navigating to directory that does not exist
        // or to which user does not have permission to read
        log(e.toString());
      }
    });
  }

  String _getDirectoryName(Directory directory) {
    return directory.path.split('/').last;
  }

  DirectoryPickerData? get data => DirectoryPickerData.of(context);
}

class _NewFolderDialog extends StatefulWidget {
  final DirectoryPickerData? data;
  final Directory? parent;

  const _NewFolderDialog({this.data, this.parent});

  @override
  _NewFolderDialogState createState() => _NewFolderDialogState();
}

class _NewFolderDialogState extends State<_NewFolderDialog> {
  String? name;
  bool isSubmitting = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _createDirectory() async {
    if (name == null || name!.trim() == '') {
      setState(() => errorMessage = 'Enter a valid folder name');
      return;
    }

    try {
      setState(() => isSubmitting = true);
      final newDirectory =
          await Directory(path.join(widget.parent!.path, name)).create();
      if (mounted) Navigator.pop(context, newDirectory);
    } catch (e) {
      setState(() => errorMessage = 'Failed to create folder');
    }
    setState(() => isSubmitting = false);
  }

  void _onNameChanged(String value) {
    setState(() {
      name = value;
      errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.data!.backgroundColor,
      content: TextField(
        autofocus: true,
        decoration: InputDecoration(errorText: errorMessage),
        onChanged: _onNameChanged,
      ),
      actions: <Widget>[
        MaterialButton(
            onPressed: isSubmitting ? null : () => Navigator.pop(context),
            child: const Text('Cancel')),
        MaterialButton(
          onPressed: isSubmitting ? null : _createDirectory,
          child: const Text('Create Folder'),
        )
      ],
      shape: widget.data!.shape,
      title: const Text('Create New Folder'),
    );
  }
}
