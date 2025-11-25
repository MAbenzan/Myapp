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
  final bool isPublished; // Si el negocio está completo y visible en el feed
  final String? phoneNumber;
  final String? schedule; // Horarios como String (ej: "Lun-Dom 8:00-22:00")

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
    this.isPublished = false,
    this.phoneNumber,
    this.schedule,
  });

  // Valida si el perfil está completo para ser publicado
  bool isProfileComplete() {
    return name.isNotEmpty &&
        address.isNotEmpty &&
        imageUrl.isNotEmpty &&
        (schedule != null && schedule!.isNotEmpty);
  }

  // Calcula el porcentaje de completitud del perfil
  int get profileCompleteness {
    int completed = 0;
    const int totalFields = 4;

    if (name.isNotEmpty) completed++;
    if (address.isNotEmpty) completed++;
    if (imageUrl.isNotEmpty) completed++;
    if (schedule != null && schedule!.isNotEmpty) completed++;

    return ((completed / totalFields) * 100).round();
  }
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
