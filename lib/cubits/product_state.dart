import '../models/product.dart';

class ProductState {
  final List<Product> products;
  final int currentPage;
  final bool hasMoreItems;
  final bool isLoading;
  final bool refreshing;
  final String? error;
  final bool isSearching;

  ProductState({
    required this.products,
    required this.currentPage,
    required this.hasMoreItems,
    required this.isLoading,
    required this.refreshing,
    this.error,
    this.isSearching = false,
  });

  factory ProductState.initial() => ProductState(
        products: [],
        currentPage: 1,
        hasMoreItems: true,
        isLoading: false,
        refreshing: false,
        isSearching: false,
      );

  ProductState copyWith({
    List<Product>? products,
    int? currentPage,
    bool? hasMoreItems,
    bool? isLoading,
    bool? refreshing,
    String? error,
    bool? isSearching,
  }) {
    return ProductState(
      products: products ?? this.products,
      currentPage: currentPage ?? this.currentPage,
      hasMoreItems: hasMoreItems ?? this.hasMoreItems,
      isLoading: isLoading ?? this.isLoading,
      refreshing: refreshing ?? this.refreshing,
      error: error,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}
