// ignore_for_file: prefer_mixin

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'directory_list.dart';

class FolderPicker {
  /// Opens a dialog to allow user to pick a directory.
  ///
  /// If [message] is non null then it is rendered when user denies to give
  /// external storage permission. A default message will be used if [message]
  /// is not specified. [rootDirectory] is the initial directory whose
  /// sub directories are shown for picking
  ///
  /// If [allowFolderCreation] is true then user will be allowed to create
  /// new folders directly from the picker. Make sure that you add write
  /// permission to manifest if you want to support folder creationa
  static Future<Directory?> pick(
      {bool allowFolderCreation = false,
      required BuildContext context,
      bool barrierDismissible = true,
      Color? backgroundColor,
      required Directory rootDirectory,
      String? message,
      ShapeBorder? shape}) async {
    if (Platform.isAndroid) {
      final directory = await showDialog<Directory>(
          context: context,
          barrierDismissible: barrierDismissible,
          builder: (context) {
            return DirectoryPickerData(
                allowFolderCreation: allowFolderCreation,
                backgroundColor: backgroundColor,
                message: message,
                rootDirectory: rootDirectory,
                shape: shape,
                child: _DirectoryPickerDialog());
          });

      return directory;
    } else {
      throw UnsupportedError('DirectoryPicker is only supported on android!');
    }
  }

  static String rootPath = '/storage/emulated/0/';
}

class DirectoryPickerData extends InheritedWidget {
  final bool? allowFolderCreation;
  final Color? backgroundColor;
  final String? message;
  final Directory? rootDirectory;
  final ShapeBorder? shape;

  const DirectoryPickerData(
      {required Widget child,
      this.allowFolderCreation,
      this.backgroundColor,
      this.message,
      this.rootDirectory,
      this.shape})
      : super(child: child);

  static DirectoryPickerData? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType(
        aspect: DirectoryPickerData);
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }
}

class _DirectoryPickerDialog extends StatefulWidget {
  @override
  _DirectoryPickerDialogState createState() => _DirectoryPickerDialogState();
}

class _DirectoryPickerDialogState extends State<_DirectoryPickerDialog>
    with WidgetsBindingObserver {
  static const double spacing = 8;

//  static final PermissionGroup requiredPermission = PermissionGroup.storage;

  bool canPrompt = true;
  bool checkingForPermission = false;
  PermissionStatus? status;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero).then((_) => _requestPermission());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _getPermissionStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  /// If silent is true then below function will not try to request permission
  /// if permission is not granter
  Future<void> _getPermissionStatus() async {
    final updatedStatus = await Permission.storage.status;
    final updatedCanPrompt = await Permission.storage.isGranted;
    if (mounted) {
      setState(() {
        canPrompt = updatedCanPrompt;
        status = updatedStatus;
      });
    }
  }

  Future<void> _requestPermission() async {
    status = await Permission.storage.status;
    if (status!.isRestricted) {
      // We didn't ask for permission
      status = await Permission.storage.request();
    }

    if (status!.isDenied) {
      status = await Permission.storage.request();
    }

    if (status!.isPermanentlyDenied) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green,
        content: Text('Please setup Permission from App Permission Settings'),
      ));
    }
  }

  DirectoryPickerData? get data => DirectoryPickerData.of(context);

  String? get message {
    if (data!.message == null) {
      return 'Please setup Permission from App Permission Settings\n\nApp needs read access to your device storage to load directories';
    } else {
      return data!.message;
    }
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);

    // print("status $status");
    if (status == null) {
      return Padding(
          padding: const EdgeInsets.all(spacing * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: const <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: spacing),
              Text('Checking permission', textAlign: TextAlign.center)
            ],
          ));
    } else if (status == PermissionStatus.granted) {
      return DirectoryList();
    } else if (status == PermissionStatus.denied) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(spacing * 2),
          child: Text(
            'App is restricted from accessing your device storage',
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      return Padding(
          padding: const EdgeInsets.all(spacing * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(message!, textAlign: TextAlign.center),
              const SizedBox(height: spacing),
              MaterialButton(
                  color: theme.colorScheme.secondary,
                  onPressed: _requestPermission,
                  child: const Text('Grant Permission'))
            ],
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    _getPermissionStatus();
    return Dialog(
      backgroundColor: data!.backgroundColor,
      shape: data!.shape,
      child: _buildBody(context),
    );
  }
}
