import 'package:flutter/material.dart';
import '../../auth/data/auth_service.dart';
import '../../business/domain/business_model.dart';
import '../../business/data/business_service.dart';
import 'widgets/profile_completion_banner.dart';
import 'tabs/menu_manager_tab.dart';
import 'tabs/services_manager_tab.dart';
import 'tabs/gallery_manager_tab.dart';
import 'tabs/reviews_manager_tab.dart';

class BusinessOwnerProfileScreen extends StatefulWidget {
  final String businessId;

  const BusinessOwnerProfileScreen({super.key, required this.businessId});

  @override
  State<BusinessOwnerProfileScreen> createState() =>
      _BusinessOwnerProfileScreenState();
}

class _BusinessOwnerProfileScreenState
    extends State<BusinessOwnerProfileScreen> {
  final BusinessService _businessService = BusinessService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BusinessModel>(
      stream: _businessService.getBusinessStream(widget.businessId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final business = snapshot.data!;
        final isProfileComplete = business.isProfileComplete();
        final completeness = business.profileCompleteness;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              business.name.isNotEmpty ? business.name : 'Mi Negocio',
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  AuthService().signOut();
                },
              ),
            ],
          ),
          body: Column(
            children: [
              if (!isProfileComplete)
                ProfileCompletionBanner(
                  completionPercentage: completeness,
                  onCompleteProfile: () {
                    // Navigate to edit profile form
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Próximamente: Editar Perfil'),
                      ),
                    );
                  },
                ),
              Expanded(
                child: DefaultTabController(
                  length: 4,
                  child: Column(
                    children: [
                      const TabBar(
                        isScrollable: true,
                        tabs: [
                          Tab(text: 'Menú'),
                          Tab(text: 'Servicios'),
                          Tab(text: 'Galería'),
                          Tab(text: 'Reseñas'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            MenuManagerTab(businessId: business.id),
                            ServicesManagerTab(businessId: business.id),
                            GalleryManagerTab(businessId: business.id),
                            ReviewsManagerTab(businessId: business.id),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
