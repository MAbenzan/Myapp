import 'package:flutter/material.dart';
import '../../domain/business_model.dart';

class MenuTab extends StatelessWidget {
  final List<MenuItem> menu;

  const MenuTab({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    if (menu.isEmpty) {
      return const Center(child: Text('No hay menú disponible'));
    }

    // Agrupar por categoría
    final Map<String, List<MenuItem>> groupedMenu = {};
    for (var item in menu) {
      if (!groupedMenu.containsKey(item.category)) {
        groupedMenu[item.category] = [];
      }
      groupedMenu[item.category]!.add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedMenu.length,
      itemBuilder: (context, index) {
        final category = groupedMenu.keys.elementAt(index);
        final items = groupedMenu[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                category,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            ...items.map((item) => _buildMenuItem(context, item)),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen (Placeholder si no hay)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              image: item.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(item.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: item.imageUrl == null
                ? const Icon(Icons.fastfood, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
