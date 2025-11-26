import 'package:flutter/material.dart';
import '../../../business/data/business_service.dart';
import '../../../business/domain/business_model.dart';

class ServicesManagerTab extends StatelessWidget {
  final String businessId;
  final BusinessService _businessService = BusinessService();

  ServicesManagerTab({super.key, required this.businessId});

  void _showItemDialog(BuildContext context, {ServiceItem? item}) {
    final nameController = TextEditingController(text: item?.name);
    final descriptionController = TextEditingController(
      text: item?.description,
    );
    final priceController = TextEditingController(text: item?.price.toString());
    final durationController = TextEditingController(text: item?.duration);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(item == null ? 'Nuevo Servicio' : 'Editar Servicio'),
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
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duración (ej. 30 min)',
                  ),
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

                final newItem = ServiceItem(
                  id:
                      item?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  description: descriptionController.text,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  duration: durationController.text,
                );

                try {
                  // Implement addServiceItem and updateServiceItem in BusinessService
                  // For now we will just log it or fail
                  // await _businessService.addServiceItem(businessId, newItem);

                  // Since we haven't implemented these methods in BusinessService yet,
                  // I will add them in the next step.
                  if (item == null) {
                    await _businessService.addServiceItem(businessId, newItem);
                  } else {
                    await _businessService.updateServiceItem(
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
        label: const Text('Agregar Servicio'),
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

          final services = snapshot.data!.services;

          if (services.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.spa, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes servicios',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  const Text('Agrega servicios que ofreces'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final item = services[index];
              return ListTile(
                leading: CircleAvatar(child: Text(item.name[0].toUpperCase())),
                title: Text(item.name),
                subtitle: Text(
                  '${item.description}\n\$${item.price.toStringAsFixed(2)} • ${item.duration ?? ""}',
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
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
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
                          title: const Text('¿Eliminar servicio?'),
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
                                await _businessService.deleteServiceItem(
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
              );
            },
          );
        },
      ),
    );
  }
}
