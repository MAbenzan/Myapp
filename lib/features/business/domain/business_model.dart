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
  final List<ServiceItem> services;
  final List<Review> reviews;
  final List<String> gallery; // URLs de imágenes de la galería
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
    this.services = const [],
    this.reviews = const [],
    this.gallery = const [],
    this.isPublished = false,
    this.phoneNumber,
    this.schedule,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      category: json['category'] ?? '',
      address: json['address'] ?? '',
      isOpen: json['isOpen'] ?? false,
      distance: (json['distance'] ?? 0).toDouble(),
      isPublished: json['isPublished'] ?? false,
      phoneNumber: json['phoneNumber'],
      schedule: json['schedule'],
      menu:
          (json['menu'] as List<dynamic>?)
              ?.map((e) => MenuItem.fromJson(e))
              .toList() ??
          [],
      services:
          (json['services'] as List<dynamic>?)
              ?.map((e) => ServiceItem.fromJson(e))
              .toList() ??
          [],
      reviews:
          (json['reviews'] as List<dynamic>?)
              ?.map((e) => Review.fromJson(e))
              .toList() ??
          [],
      gallery:
          (json['gallery'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'category': category,
      'address': address,
      'isOpen': isOpen,
      'distance': distance,
      'isPublished': isPublished,
      'phoneNumber': phoneNumber,
      'schedule': schedule,
      'menu': menu.map((e) => e.toJson()).toList(),
      'services': services.map((e) => e.toJson()).toList(),
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'gallery': gallery,
    };
  }

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

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'],
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
    };
  }
}

class ServiceItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? duration; // e.g., "30 min", "1 hora"

  const ServiceItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.duration,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
    };
  }
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

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      userName: json['userName'] ?? '',
      userImage: json['userImage'],
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'userImage': userImage,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
    };
  }
}
