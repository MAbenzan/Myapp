import '../domain/business_model.dart';

class BusinessData {
  static final List<BusinessModel> dummyBusinesses = [
    BusinessModel(
      id: '1',
      name: 'Café Aroma',
      description:
          'El mejor café de especialidad en la ciudad con ambiente relajado.',
      imageUrl:
          'https://images.unsplash.com/photo-1509042239860-f550ce710b93?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      rating: 4.8,
      reviewCount: 124,
      category: 'Cafetería',
      address: 'Av. Principal 123',
      isOpen: true,
      distance: 0.5,
      menu: [
        const MenuItem(
          id: '1',
          name: 'Cappuccino Artesanal',
          description: 'Espresso doble con leche texturizada y arte latte.',
          price: 180.00,
          category: 'Bebidas Calientes',
        ),
        const MenuItem(
          id: '2',
          name: 'Croissant de Almendras',
          description: 'Hojaldre francés relleno de crema de almendras.',
          price: 220.00,
          category: 'Panadería',
        ),
        const MenuItem(
          id: '3',
          name: 'Tostada de Aguacate',
          description:
              'Pan de masa madre, aguacate fresco, huevo pochado y semillas.',
          price: 350.00,
          category: 'Desayunos',
        ),
      ],
      reviews: [
        Review(
          id: '1',
          userName: 'Ana García',
          rating: 5.0,
          comment:
              '¡El mejor café de la zona! El ambiente es perfecto para trabajar.',
          date: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Review(
          id: '2',
          userName: 'Carlos Diaz',
          rating: 4.0,
          comment: 'Muy bueno, pero un poco caro.',
          date: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ],
    ),
    BusinessModel(
      id: '2',
      name: 'Burger House',
      description:
          'Hamburguesas artesanales con ingredientes locales y frescos.',
      imageUrl:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      rating: 4.5,
      reviewCount: 89,
      category: 'Restaurante',
      address: 'Calle 5ta, Zona Norte',
      isOpen: true,
      distance: 1.2,
      menu: [
        const MenuItem(
          id: '4',
          name: 'Classic Burger',
          description:
              'Carne angus 8oz, queso cheddar, lechuga, tomate y salsa especial.',
          price: 450.00,
          category: 'Hamburguesas',
        ),
        const MenuItem(
          id: '5',
          name: 'Bacon Lovers',
          description:
              'Doble carne, doble tocino, cebolla caramelizada y salsa BBQ.',
          price: 580.00,
          category: 'Hamburguesas',
        ),
        const MenuItem(
          id: '6',
          name: 'Papas Trufadas',
          description: 'Papas fritas con aceite de trufa y queso parmesano.',
          price: 250.00,
          category: 'Acompañamientos',
        ),
      ],
    ),
    const BusinessModel(
      id: '3',
      name: 'FitGym Elite',
      description:
          'Gimnasio completo con entrenadores personales y clases grupales.',
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      rating: 4.9,
      reviewCount: 210,
      category: 'Salud',
      address: 'Plaza Central, Local 4',
      isOpen: true,
      distance: 2.5,
    ),
    const BusinessModel(
      id: '4',
      name: 'Librería El Quijote',
      description: 'Libros nuevos y usados, café y espacios de lectura.',
      imageUrl:
          'https://images.unsplash.com/photo-1507842217121-9e9f09e31b70?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      rating: 4.7,
      reviewCount: 56,
      category: 'Librería',
      address: 'Calle de las Letras 45',
      isOpen: false,
      distance: 3.0,
    ),
    const BusinessModel(
      id: '5',
      name: 'Sushi Zen',
      description: 'Auténtica comida japonesa y fusión en un ambiente moderno.',
      imageUrl:
          'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      rating: 4.6,
      reviewCount: 150,
      category: 'Restaurante',
      address: 'Boulevard Gastronómico',
      isOpen: true,
      distance: 4.2,
    ),
  ];
}
