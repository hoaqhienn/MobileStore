import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_store/cubits/product_state.dart';
import '../models/product.dart';
import 'dart:convert';

import '../services/store_service.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit() : super(ProductState.initial());
  final StoreService storeService = StoreService();
  final int _itemsPerPage = 5;

  Future<void> fetchProducts({bool loadMore = false}) async {
    if (state.isLoading) return;

    try {
      emit(state.copyWith(isLoading: true));

      final currentPage = loadMore ? state.currentPage : 1;

      final response = await storeService.fetchProducts(
          currentPage: currentPage, itemsPerPage: _itemsPerPage);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Product> newProducts = (data['content'] as List)
            .map((item) => Product.fromJson(item))
            .toList();

        final List<Product> updatedProducts =
            loadMore ? [...state.products, ...newProducts] : newProducts;

        emit(state.copyWith(
          products: updatedProducts,
          currentPage: currentPage + 1,
          hasMoreItems: newProducts.length == _itemsPerPage,
          isLoading: false,
          error: null,
        ));
      } else {
        throw HttpException('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
        // Keep existing products on error during load more
        products: loadMore ? state.products : [],
      ));
    }
  }

  Future<void> searchProducts({
    String? name,
    num? minPrice,
    num? maxPrice,
  }) async {
    if (state.isLoading) return;

    try {
      emit(state.copyWith(isLoading: true, isSearching: true));

      final response = await storeService.searchProducts(
        name: name,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (kDebugMode) {
          print('Response data: $data');
        }

        final List<Product> searchResults = data.map<Product>((item) {
          try {
            return Product.fromJson(item as Map<String, dynamic>);
          } catch (e) {
            if (kDebugMode) {
              print('Error parsing product: $e');
              print('Problematic item: $item');
            }
            rethrow;
          }
        }).toList();

        if (kDebugMode) {
          print('Parsed search results: $searchResults');
        }

        emit(state.copyWith(
          products: searchResults,
          currentPage: 1,
          hasMoreItems: false, // Disable pagination for search results
          isLoading: false,
          error: null,
        ));
      } else {
        throw HttpException('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Search error: $e');
      }
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
        products: [], // Clear products on error
      ));
    }
  }

  void clearSearch() {
    emit(state.copyWith(isSearching: false));
    refreshProducts();
  }

  Future<void> refreshProducts() async {
    if (state.isLoading) return;

    emit(state.copyWith(refreshing: true));

    try {
      final response = await storeService.fetchProducts(
          currentPage: 1, itemsPerPage: _itemsPerPage);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Product> products = (data['content'] as List)
            .map((item) => Product.fromJson(item))
            .toList();

        emit(ProductState(
          products: products,
          currentPage: 2,
          hasMoreItems: products.length == _itemsPerPage,
          isLoading: false,
          refreshing: false,
          error: null,
        ));
      } else {
        throw HttpException(
            'Failed to refresh products: ${response.statusCode}');
      }
    } catch (e) {
      emit(state.copyWith(
        refreshing: false,
        error: e.toString(),
      ));
    }
  }

  bool get canLoadMore =>
      !state.isLoading && state.hasMoreItems && !state.refreshing;
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);

  @override
  String toString() => message;
}
