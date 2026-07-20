import 'dart:io';

import 'package:flutter/material.dart';

class DocumentUploadTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final File? file;
  final IconData icon;
  final VoidCallback onTap;

  const DocumentUploadTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.file,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.pink.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: file == null ? Colors.pink.shade200 : Colors.green.shade400,
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: file == null
                  ? Icon(icon, color: Colors.pink.shade400, size: 30)
                  : _FilePreview(file: file!),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    file == null
                        ? subtitle
                        : 'Selected. Tap to retake or replace.',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(
              file == null ? Icons.add_a_photo_outlined : Icons.check_circle,
              color: file == null ? Colors.pink : Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilePreview extends StatelessWidget {
  final File file;

  const _FilePreview({required this.file});

  @override
  Widget build(BuildContext context) {
    if (file.path.toLowerCase().endsWith('.pdf')) {
      return const Icon(Icons.picture_as_pdf, color: Colors.red, size: 34);
    }
    return Image.file(file, fit: BoxFit.cover);
  }
}
