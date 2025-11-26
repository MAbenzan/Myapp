import 'package:flutter/material.dart';
import '../../business/presentation/feed_screen.dart';
import '../../search/presentation/search_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../profile/presentation/business_owner_profile_screen.dart';
import '../../auth/data/auth_service.dart';
import '../../auth/domain/user_model.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  UserModel? _currentUser;
  bool _isLoading = true;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.currentUser;
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isBusiness = _currentUser?.userType == UserType.business;

    final List<Widget> screens = [
      const FeedScreen(),
      const SearchScreen(),
      isBusiness
          ? BusinessOwnerProfileScreen(
              businessId: _currentUser?.businessId ?? '',
            )
          : const ProfileScreen(),
    ];

    final List<NavigationDestination> destinations = [
      const NavigationDestination(
        icon: Icon(Icons.explore_outlined),
        selectedIcon: Icon(Icons.explore),
        label: 'Explorar',
      ),
      const NavigationDestination(
        icon: Icon(Icons.search_outlined),
        selectedIcon: Icon(Icons.search),
        label: 'Buscar',
      ),
      NavigationDestination(
        icon: Icon(isBusiness ? Icons.store_outlined : Icons.person_outline),
        selectedIcon: Icon(isBusiness ? Icons.store : Icons.person),
        label: isBusiness ? 'Mi Negocio' : 'Perfil',
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: destinations,
      ),
    );
  }
}
