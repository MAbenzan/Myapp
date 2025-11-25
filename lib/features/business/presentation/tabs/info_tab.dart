import 'package:flutter/material.dart';
import '../../domain/business_model.dart';

class InfoTab extends StatelessWidget {
  final BusinessModel business;

  const InfoTab({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoRow(
          context,
          Icons.location_on,
          'Dirección',
          business.address,
        ),
        const Divider(),
        _buildInfoRow(
          context,
          Icons.access_time,
          'Horario',
          'Lunes a Domingo: 8:00 AM - 10:00 PM',
        ),
        const Divider(),
        _buildInfoRow(context, Icons.phone, 'Teléfono', '+1 (809) 555-0123'),
        const SizedBox(height: 24),
        // Mapa estático simulado
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, size: 40, color: Colors.grey),
                SizedBox(height: 8),
                Text('Mapa Próximamente'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String title,
    String content,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
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
