import 'package:flutter/material.dart';
import '../../business/data/business_service.dart';
import '../../business/domain/business_model.dart';
import '../../business/presentation/widgets/business_card.dart';
import '../data/favorites_service.dart';

class FavoritesScreen extends StatelessWidget {
  final String userId;
  final FavoritesService _favoritesService = FavoritesService();
  final BusinessService _businessService = BusinessService();

  FavoritesScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Favoritos')),
      body: StreamBuilder<List<String>>(
        stream: _favoritesService.getUserFavoritesStream(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final favoriteIds = snapshot.data!;

          if (favoriteIds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes favoritos aún',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  const Text('Guarda los lugares que te encantan'),
                ],
              ),
            );
          }

          return StreamBuilder<List<BusinessModel>>(
            stream: _businessService.getFavoriteBusinesses(favoriteIds),
            builder: (context, businessSnapshot) {
              if (businessSnapshot.hasError) {
                return Center(child: Text('Error: ${businessSnapshot.error}'));
              }
              if (!businessSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final businesses = businessSnapshot.data!;

              if (businesses.isEmpty) {
                // This might happen if favorites exist but businesses were deleted
                return const Center(
                  child: Text('No se encontraron los negocios'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: businesses.length,
                itemBuilder: (context, index) {
                  return BusinessCard(business: businesses[index]);
                },
              );
            },
          );
        },
      ),
    );
  }
}
