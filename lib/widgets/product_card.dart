import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final Color? borderColor;

  const ProductCard({
    required this.product,
    this.onTap,
    this.onDelete,
    this.onEdit,
    this.borderColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      // Use a shape with rounded corners for a modern look
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: borderColor != null
            ? BorderSide(color: borderColor!, width: 2)
            : BorderSide.none,
      ),
      // Clip the content inside to match the card's rounded corners
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- IMAGE SECTION ---
            // Use AspectRatio to ensure all images have a consistent shape
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildImage(context),
            ),

            // --- TEXT CONTENT SECTION ---
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Title with improved styling
                  Text(
                    product.title,
                    style: textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Product Description with subtle styling
                  Text(
                    product.description,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // --- ACTION BUTTONS SECTION ---
            // Only show the row if there are actions
            if (onEdit != null || onDelete != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 8, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      IconButton(
                        icon: Icon(Icons.edit_outlined,
                            color: colorScheme.secondary),
                        onPressed: onEdit,
                        tooltip: 'Edit',
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: colorScheme.error),
                        onPressed: onDelete,
                        tooltip: 'Delete',
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build the image or a placeholder
  Widget _buildImage(BuildContext context) {
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return Image.network(
        product.imageUrl!,
        fit: BoxFit.cover,
        // Add a loading builder for a better user experience
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        // Add an error builder to handle failed image loads
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderIcon(context);
        },
      );
    } else {
      // Show a styled placeholder if no image is available
      return _buildPlaceholderIcon(context);
    }
  }

  // Helper widget for the placeholder icon
  Widget _buildPlaceholderIcon(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          product.category == "book" ? Icons.menu_book : Icons.edit_note,
          size: 60,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}
