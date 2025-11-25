import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/data/auth_provider.dart';
import '../../../core/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.user;
    final theme = Theme.of(context);

    // Helpers para datos seguros
    final userEmail = user?.email ?? '';
    final userInitial = userEmail.isNotEmpty
        ? userEmail.substring(0, 1).toUpperCase()
        : 'U';
    final userName = user?.displayName ?? 'Usuario';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                      theme.colorScheme.surface,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: theme.colorScheme.surface,
                      child: Text(
                        userInitial,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userEmail,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Estadísticas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(context, '0', 'Reseñas'),
                      _buildStatItem(context, '0', 'Fotos'),
                      _buildStatItem(context, '0', 'Favoritos'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Opciones
                  _buildSectionTitle(context, 'Cuenta'),
                  _buildListTile(
                    context,
                    icon: Icons.store_mall_directory_outlined,
                    title: 'Mi Negocio',
                    subtitle: 'Gestiona tu perfil de negocio',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Próximamente: Gestión de Negocio'),
                        ),
                      );
                    },
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notificaciones',
                    onTap: () {},
                  ),

                  const SizedBox(height: 16),
                  _buildSectionTitle(context, 'Configuración'),
                  SwitchListTile(
                    secondary: Icon(
                      themeProvider.themeMode == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('Modo Oscuro'),
                    value: themeProvider.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.help_outline,
                    title: 'Ayuda y Soporte',
                    onTap: () {},
                  ),

                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () async {
                      await authProvider.signOut();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right, size: 16),
      onTap: onTap,
    );
  }
}
