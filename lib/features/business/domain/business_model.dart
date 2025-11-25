class BusinessModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String category;
  final String address;
  final bool isOpen;
  final double distance; // Distancia simulada en km
  final List<MenuItem> menu;
  final List<Review> reviews;

  const BusinessModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.category,
    required this.address,
    required this.isOpen,
    required this.distance,
    this.menu = const [],
    this.reviews = const [],
  });
}

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String category; // Entradas, Platos Fuertes, Bebidas

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.category,
  });
}

class Review {
  final String id;
  final String userName;
  final String? userImage;
  final double rating;
  final String comment;
  final DateTime date;

  const Review({
    required this.id,
    required this.userName,
    this.userImage,
    required this.rating,
    required this.comment,
    required this.date,
  });
}
