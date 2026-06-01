import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../services/permission_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/image_grid_item.dart';
import '../widgets/permission_denied_widget.dart';
import 'photo_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _picker = ImagePicker();
  final _permissionService = PermissionService();
  final _storageService = StorageService();

  List<String> _imagePaths = [];
  bool _isLoading = false;
  bool _selectionMode = false;
  final Set<int> _selectedIndices = {};
  PermissionStatus? _lastDeniedStatus;
  String? _lastDeniedPermissionName;
  VoidCallback? _retryDeniedPermission;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      final paths = await _storageService.loadPathsList();
      if (!mounted) return;
      setState(() {
        _imagePaths = paths;
      });
      await _storageService.savePathsList(paths);
    } catch (error) {
      _showSnackBar('Failed to load photos: $error');
    }
  }

  Future<void> _savePathsList() async {
    await _storageService.savePathsList(_imagePaths);
  }

  Future<XFile?> _cropImage(XFile image) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Photo',
          toolbarColor: Colors.black,
          statusBarLight: false,
          navBarLight: false,
          toolbarWidgetColor: Colors.white,
          backgroundColor: AppTheme.cream,
          activeControlsWidgetColor: AppTheme.orange,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Crop Photo'),
      ],
    );
    return croppedFile != null ? XFile(croppedFile.path) : null;
  }

  Future<void> _pickImageFromCamera() async {
    await _pickImage(
      source: ImageSource.camera,
      permissionName: 'Camera',
      requestPermission: _permissionService.requestCameraPermission,
    );
  }

  Future<void> _pickImageFromGallery() async {
    await _pickImage(
      source: ImageSource.gallery,
      permissionName: 'Gallery',
      requestPermission: _permissionService.requestGalleryPermission,
    );
  }

  Future<void> _pickImage({
    required ImageSource source,
    required String permissionName,
    required Future<PermissionStatus> Function() requestPermission,
  }) async {
    setState(() {
      _isLoading = true;
      _lastDeniedStatus = null;
      _lastDeniedPermissionName = null;
      _retryDeniedPermission = null;
    });

    try {
      final status = await requestPermission();
      if (!status.isGranted) {
        _handlePermissionDenied(
          status: status,
          permissionName: permissionName,
          retry: source == ImageSource.camera
              ? _pickImageFromCamera
              : _pickImageFromGallery,
        );
        return;
      }

      final image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image == null) return;

      if (!await File(image.path).exists()) {
        throw Exception('Selected image file does not exist');
      }

      final cropped = await _cropImage(image);
      if (cropped == null) return;

      final savedPath = await _storageService.saveImage(cropped);
      setState(() {
        _imagePaths.add(savedPath);
      });
      await _savePathsList();
      _showSnackBar('Photo saved!');
    } catch (error) {
      _showSnackBar('Failed to add photo: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handlePermissionDenied({
    required PermissionStatus status,
    required String permissionName,
    required VoidCallback retry,
  }) {
    setState(() {
      _lastDeniedStatus = status;
      _lastDeniedPermissionName = permissionName;
      _retryDeniedPermission = retry;
    });
    final message = status.isPermanentlyDenied
        ? '$permissionName permission permanently denied'
        : '$permissionName permission denied';
    _showSnackBar(message);
  }

  Future<void> _showImageSourceBottomSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.cream,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              Container(
                width: double.infinity,
                color: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Text(
                  'ADD PHOTO',
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.black),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.black),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.black),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openFullScreen(String path, int index) async {
    if (!await File(path).exists()) {
      _showSnackBar('Photo file is missing');
      await _loadImages();
      return;
    }

    if (!mounted) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoDetailScreen(
          imagePath: path,
          index: index,
          onDelete: () => _deletePhoto(index),
        ),
      ),
    );
  }

  Future<void> _deletePhoto(int index) async {
    try {
      if (index < 0 || index >= _imagePaths.length) return;
      final path = _imagePaths[index];
      if (await File(path).exists()) {
        await _storageService.deleteImage(path);
      }
      setState(() {
        _imagePaths.removeAt(index);
      });
      await _savePathsList();
      _showSnackBar('Photo deleted');
    } catch (error) {
      _showSnackBar('Failed to delete photo: $error');
    }
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
      if (_selectedIndices.isEmpty) {
        _selectionMode = false;
      }
    });
  }

  void _enterSelectionMode(int index) {
    setState(() {
      _selectionMode = true;
      _selectedIndices.add(index);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedIndices.clear();
    });
  }

  Future<void> _confirmDeleteSelected() async {
    if (_selectedIndices.isEmpty) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Photos?'),
          content: Text(
            '${_selectedIndices.length} selected photos will be removed.',
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteSelected();
    }
  }

  Future<void> _deleteSelected() async {
    try {
      final selected = _selectedIndices.toList()
        ..sort((a, b) => b.compareTo(a));
      final pathsToDelete = selected
          .where((index) => index >= 0 && index < _imagePaths.length)
          .map((index) => _imagePaths[index])
          .toList();

      await Future.wait(
        pathsToDelete.map((path) async {
          if (await File(path).exists()) {
            await _storageService.deleteImage(path);
          }
        }),
      );

      setState(() {
        for (final index in selected) {
          if (index >= 0 && index < _imagePaths.length) {
            _imagePaths.removeAt(index);
          }
        }
      });
      _exitSelectionMode();
      await _savePathsList();
      _showSnackBar('${pathsToDelete.length} photos deleted');
    } catch (error) {
      _showSnackBar('Failed to delete selected photos: $error');
    }
  }

  Future<void> _shareSelected() async {
    try {
      final files = <XFile>[];
      for (final index in _selectedIndices) {
        if (index >= 0 && index < _imagePaths.length) {
          final path = _imagePaths[index];
          if (await File(path).exists()) {
            files.add(XFile(path));
          }
        }
      }
      if (files.isEmpty) {
        _showSnackBar('No selected photos to share');
        return;
      }
      await Share.shareXFiles(files);
    } catch (error) {
      _showSnackBar('Failed to share photos: $error');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: _imagePaths.length,
      itemBuilder: (context, index) => ImageGridItem(
        imagePath: _imagePaths[index],
        index: index,
        isSelected: _selectedIndices.contains(index),
        selectionMode: _selectionMode,
        onTap: _selectionMode
            ? () => _toggleSelection(index)
            : () => _openFullScreen(_imagePaths[index], index),
        onLongPress: () => _enterSelectionMode(index),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    if (_selectionMode) {
      return AppBar(
        title: Text('${_selectedIndices.length} SELECTED'),
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close),
          onPressed: _exitSelectionMode,
        ),
        actions: [
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share_rounded),
            onPressed: _shareSelected,
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_rounded),
            onPressed: _confirmDeleteSelected,
          ),
        ],
      );
    }

    return AppBar(
      title: const Text('MY PHOTOS'),
      actions: [
        IconButton(
          tooltip: 'Add photo',
          icon: const Icon(Icons.add_a_photo),
          onPressed: _showImageSourceBottomSheet,
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.orange),
      );
    }

    if (_lastDeniedStatus != null && _lastDeniedPermissionName != null) {
      if (_lastDeniedStatus!.isPermanentlyDenied) {
        return PermissionPermanentlyDeniedWidget(
          permissionName: _lastDeniedPermissionName!,
        );
      }
      return PermissionDeniedWidget(
        permissionName: _lastDeniedPermissionName!,
        onRequestAgain: _retryDeniedPermission ?? _showImageSourceBottomSheet,
      );
    }

    if (_imagePaths.isEmpty) {
      return EmptyStateWidget(onAddPhoto: _showImageSourceBottomSheet);
    }

    return _buildGridView();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_selectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectionMode) {
          _exitSelectionMode();
        }
      },
      child: Scaffold(appBar: _buildAppBar(), body: _buildBody()),
    );
  }
}
