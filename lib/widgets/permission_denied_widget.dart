import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../theme/app_theme.dart';

class PermissionDeniedWidget extends StatelessWidget {
  const PermissionDeniedWidget({
    super.key,
    required this.permissionName,
    required this.onRequestAgain,
  });

  final String permissionName;
  final VoidCallback onRequestAgain;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.cream,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: AppTheme.orange,
              ),
              const SizedBox(height: 16),
              Text(
                '$permissionName permission required',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onRequestAgain,
                child: const Text('Grant Permission'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PermissionPermanentlyDeniedWidget extends StatelessWidget {
  const PermissionPermanentlyDeniedWidget({
    super.key,
    required this.permissionName,
  });

  final String permissionName;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.cream,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.block_rounded,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                '$permissionName permission permanently denied',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Open app settings and enable access to continue.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: openAppSettings,
                child: const Text('Open Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
