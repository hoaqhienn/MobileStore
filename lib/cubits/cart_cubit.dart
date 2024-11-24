import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../utils/shared_prefs_util.dart';
import 'auth_cubit.dart';
import 'cart_state.dart';



class CartCubit extends Cubit<CartState> {
  final SharedPrefsUtil _prefsUtil;
  final AuthCubit _authCubit;

  CartCubit({
    required SharedPrefsUtil prefsUtil,
    required AuthCubit authCubit,
  }) : _prefsUtil = prefsUtil,
        _authCubit = authCubit,
        super(const CartState(items: []));

  Future<void> loadCart() async {
    final userId = _authCubit.currentUserId();
    if (userId == null) {
      emit(state.copyWith(error: 'User not authenticated'));
      return;
    }

    try {
      emit(state.copyWith(isLoading: true));
      final cartData = await _prefsUtil.loadCartFromPreferences(userId);

      final loadedItems = cartData.map((item) {
        final product = Product.fromJson(item['product'] as Map<String, dynamic>);
        return CartItem(
          product: product,
          quantity: item['quantity'] as int,
        );
      }).toList();

      emit(state.copyWith(
        items: loadedItems,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load cart: $e',
      ));
    }
  }

  Future<void> addToCart(Product product) async {
    final userId = _authCubit.currentUserId();
    if (userId == null) {
      emit(state.copyWith(error: 'User not authenticated'));
      return;
    }

    try {
      final existingItemIndex = state.items.indexWhere(
            (item) => item.product.id == product.id,
      );

      List<CartItem> updatedItems;
      if (existingItemIndex != -1) {
        // Update existing item
        updatedItems = List.from(state.items);
        final existingItem = updatedItems[existingItemIndex];
        updatedItems[existingItemIndex] = CartItem(
          product: product,
          quantity: existingItem.quantity + 1,
        );
      } else {
        // Add new item
        updatedItems = [...state.items, CartItem(product: product, quantity: 1)];
      }

      emit(state.copyWith(items: updatedItems));
      await _saveCart(userId);
    } catch (e) {
      emit(state.copyWith(error: 'Failed to add item to cart: $e'));
    }
  }

  Future<void> removeFromCart(CartItem item) async {
    final userId = _authCubit.currentUserId();
    if (userId == null) {
      emit(state.copyWith(error: 'User not authenticated'));
      return;
    }

    try {
      final updatedItems = state.items.where((i) => i != item).toList();
      emit(state.copyWith(items: updatedItems));
      await _saveCart(userId);
    } catch (e) {
      emit(state.copyWith(error: 'Failed to remove item from cart: $e'));
    }
  }

  Future<void> clearCart() async {
    final userId = _authCubit.currentUserId();
    if (userId == null) {
      emit(state.copyWith(error: 'User not authenticated'));
      return;
    }

    try {
      emit(state.copyWith(items: []));
      await _prefsUtil.clearCartPreferences(userId);
    } catch (e) {
      emit(state.copyWith(error: 'Failed to clear cart: $e'));
    }
  }

  Future<void> _saveCart(int userId) async {
    final cartList = state.items.map((item) => {
      'product': item.product.toJson(),
      'quantity': item.quantity,
    }).toList();

    await _prefsUtil.saveCartToPreferences(userId, cartList);
  }

  int getTotalItems() {
    return state.items.fold(0, (total, item) => total + item.quantity);
  }

  double getTotalPrice() {
    return state.items.fold(
      0.0,
          (total, item) => total + (item.product.price * item.quantity),
    );
  }
}