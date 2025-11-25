import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/presentation/widgets/business_card.dart';
import 'search_provider.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchProvider(),
      child: const _SearchContent(),
    );
  }
}

class _SearchContent extends StatelessWidget {
  const _SearchContent();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SearchProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header de Búsqueda
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Barra de búsqueda
                  TextField(
                    onChanged: provider.search,
                    decoration: InputDecoration(
                      hintText: 'Buscar restaurantes, cafeterías...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: provider.query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                provider.search('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filtros Horizontales
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Chip "Abierto Ahora"
                        FilterChip(
                          label: const Text('Abierto ahora'),
                          selected: provider.onlyOpen,
                          onSelected: (_) => provider.toggleOpenNow(),
                          checkmarkColor: Colors.white,
                          selectedColor: theme.colorScheme.primary,
                          // Corrección para Dark Mode:
                          // Si no está seleccionado, usar onSurface (blanco en dark, negro en light)
                          labelStyle: TextStyle(
                            color: provider.onlyOpen
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                          ),
                          backgroundColor: isDark
                              ? theme.colorScheme.surfaceContainerHighest
                              : null,
                        ),
                        const SizedBox(width: 8),

                        // Chips de Categorías
                        ...provider.categories.map((category) {
                          final isSelected =
                              provider.selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (_) =>
                                  provider.toggleCategory(category),
                              checkmarkColor: Colors.white,
                              selectedColor: theme.colorScheme.primary,
                              // Corrección para Dark Mode
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : theme.colorScheme.onSurface,
                              ),
                              backgroundColor: isDark
                                  ? theme.colorScheme.surfaceContainerHighest
                                  : null,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Resultados
            Expanded(
              child:
                  provider.query.isEmpty &&
                      provider.selectedCategory == null &&
                      !provider.onlyOpen
                  ? _buildEmptyState(context)
                  : _buildResultsList(context, provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Encuentra tu próximo lugar favorito',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, SearchProvider provider) {
    if (provider.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_dissatisfied,
              size: 60,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text('No se encontraron resultados'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: provider.results.length,
      itemBuilder: (context, index) {
        final business = provider.results[index];
        return BusinessCard(
          business: business,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Seleccionaste: ${business.name}')),
            );
          },
        );
      },
    );
  }
}
