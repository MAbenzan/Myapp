import 'package:flutter/material.dart';
import '../../../business/data/business_service.dart';
import '../../../business/domain/business_model.dart';

class MenuManagerTab extends StatelessWidget {
  final String businessId;
  final BusinessService _businessService = BusinessService();

  MenuManagerTab({super.key, required this.businessId});

  void _showItemDialog(BuildContext context, {MenuItem? item}) {
    final nameController = TextEditingController(text: item?.name);
    final descriptionController = TextEditingController(
      text: item?.description,
    );
    final priceController = TextEditingController(text: item?.price.toString());

    // Simple category selector for now
    final categories = ['Entradas', 'Platos Fuertes', 'Bebidas', 'Postres'];
    String selectedCategory = item?.category ?? categories[1];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(item == null ? 'Nuevo Producto' : 'Editar Producto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 2,
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Precio',
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedCategory = value!);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                final newItem = MenuItem(
                  id:
                      item?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  description: descriptionController.text,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  category: selectedCategory,
                  imageUrl: item?.imageUrl,
                );

                try {
                  if (item == null) {
                    await _businessService.addMenuItem(businessId, newItem);
                  } else {
                    await _businessService.updateMenuItem(
                      businessId,
                      item,
                      newItem,
                    );
                  }
                  navigator.pop();
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showItemDialog(context),
        label: const Text('Agregar Producto'),
        icon: const Icon(Icons.add),
      ),
      body: StreamBuilder<BusinessModel>(
        stream: _businessService.getBusinessStream(businessId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final menu = snapshot.data!.menu;

          if (menu.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tu menú está vacío',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  const Text('Agrega productos para que tus clientes los vean'),
                ],
              ),
            );
          }

          // Group by category
          final groupedMenu = <String, List<MenuItem>>{};
          for (var item in menu) {
            if (!groupedMenu.containsKey(item.category)) {
              groupedMenu[item.category] = [];
            }
            groupedMenu[item.category]!.add(item);
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80), // Space for FAB
            itemCount: groupedMenu.length,
            itemBuilder: (context, index) {
              final category = groupedMenu.keys.elementAt(index);
              final items = groupedMenu[category]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text(
                      category,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  ...items.map(
                    (item) => ListTile(
                      leading: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          image:
                              item.imageUrl != null && item.imageUrl!.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(item.imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: item.imageUrl == null || item.imageUrl!.isEmpty
                            ? const Icon(Icons.fastfood, color: Colors.grey)
                            : null,
                      ),
                      title: Text(item.name),
                      subtitle: Text(
                        '${item.description}\n\$${item.price.toStringAsFixed(2)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      isThreeLine: true,
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Eliminar',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showItemDialog(context, item: item);
                          } else if (value == 'delete') {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('¿Eliminar producto?'),
                                content: Text(
                                  '¿Estás seguro de eliminar "${item.name}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await _businessService.deleteMenuItem(
                                        businessId,
                                        item,
                                      );
                                    },
                                    child: const Text(
                                      'Eliminar',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
