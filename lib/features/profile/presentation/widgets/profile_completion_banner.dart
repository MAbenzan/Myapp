import 'package:flutter/material.dart';

class ProfileCompletionBanner extends StatelessWidget {
  final int completionPercentage;
  final VoidCallback onCompleteProfile;

  const ProfileCompletionBanner({
    super.key,
    required this.completionPercentage,
    required this.onCompleteProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircularProgressIndicator(
            value: completionPercentage / 100,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Completa tu perfil ($completionPercentage%)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Tu negocio no será visible hasta que completes la información básica.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onCompleteProfile,
            child: const Text('Completar'),
          ),
        ],
      ),
    );
  }
}
