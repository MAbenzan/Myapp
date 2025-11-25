import 'package:flutter/material.dart';
import '../../business/data/business_data.dart';
import '../../business/domain/business_model.dart';

class SearchProvider extends ChangeNotifier {
  String _query = '';
  String? _selectedCategory;
  bool _onlyOpen = false;

  List<BusinessModel> _results = [];

  String get query => _query;
  String? get selectedCategory => _selectedCategory;
  bool get onlyOpen => _onlyOpen;
  List<BusinessModel> get results => _results;

  // Categorías disponibles (extraídas de los datos dummy)
  List<String> get categories =>
      BusinessData.dummyBusinesses.map((b) => b.category).toSet().toList();

  void search(String query) {
    _query = query;
    _applyFilters();
  }

  void toggleCategory(String category) {
    if (_selectedCategory == category) {
      _selectedCategory = null;
    } else {
      _selectedCategory = category;
    }
    _applyFilters();
  }

  void toggleOpenNow() {
    _onlyOpen = !_onlyOpen;
    _applyFilters();
  }

  void _applyFilters() {
    _results = BusinessData.dummyBusinesses.where((business) {
      // Filtro de texto
      final matchesQuery =
          business.name.toLowerCase().contains(_query.toLowerCase()) ||
          business.description.toLowerCase().contains(_query.toLowerCase());

      // Filtro de categoría
      final matchesCategory =
          _selectedCategory == null || business.category == _selectedCategory;

      // Filtro de abierto
      final matchesOpen = !_onlyOpen || business.isOpen;

      return matchesQuery && matchesCategory && matchesOpen;
    }).toList();

    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _selectedCategory = null;
    _onlyOpen = false;
    _results = [];
    notifyListeners();
  }
}
