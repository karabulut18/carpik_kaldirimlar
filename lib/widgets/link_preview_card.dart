import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';

class LinkPreviewCard extends StatelessWidget {
  final String url;

  const LinkPreviewCard({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: AnyLinkPreview(
        link: url,
        displayDirection: UIDirection.uiDirectionHorizontal,
        showMultimedia: true,
        bodyMaxLines: 3,
        bodyTextOverflow: TextOverflow.ellipsis,
        titleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
        bodyStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
        errorBody: 'Önizleme yüklenemedi',
        errorTitle: 'Hata',
        errorWidget: Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.link_off),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bağlantı önizlemesi yüklenemedi: $url',
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        errorImage: "https://google.com/error", // Placeholder, usually not shown if errorWidget is used
        cache: const Duration(days: 7),
        backgroundColor: Theme.of(context).colorScheme.surface,
        borderRadius: 12,
        removeElevation: false,
        boxShadow: [
          BoxShadow(
            blurRadius: 3,
            color: Colors.grey.withOpacity(0.2),
            offset: const Offset(0, 1),
          )
        ],
        onTap: () {}, // Handled by default usually, but we can override if needed
      ),
    );
  }
}
