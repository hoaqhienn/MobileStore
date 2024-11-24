import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_store/utils/shared_prefs_util.dart';
import 'dart:convert';

import '../../cubits/cart_state.dart';
import '../../models/cart_item.dart';
import '../../cubits/cart_cubit.dart';

class CartPage extends StatefulWidget {
  final VoidCallback onContinueShopping;

  const CartPage({
    super.key,
    required this.onContinueShopping,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int _selectedPaymentMethod = 0;
  bool _isLoading = false;

  Future<void> _checkout() async {
    setState(() => _isLoading = true);

    try {
      final token = SharedPrefsUtil().getToken();

      if (!mounted) {
        return;
      }
      final cartState = context.read<CartCubit>().state;
      final items = cartState.items;

      if (items.isEmpty) {
        throw Exception('Cart is empty');
      }

      final total = items.fold(
        0.0,
        (sum, item) => sum + (item.product.price * item.quantity),
      );

      final orderDetails = items
          .map((item) => {
                "productId": item.product.id,
                "quantity": item.quantity,
                "unitPrice": item.product.price,
              })
          .toList();

      final orderData = {
        "total": total,
        "paymentMethod": _selectedPaymentMethod,
        "orderStatus": 1,
        "details": orderDetails,
      };

      final response = await http.post(
        Uri.parse(
            'https://8080-hoaqhienn-mobilestorebe-2hziaz09ts5.ws-us116.gitpod.io/api/v2/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(orderData),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        // Clear cart after successful order
        context.read<CartCubit>().clearCart();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        widget.onContinueShopping(); // Navigate back to shopping
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Account is not authenticated, please login!';
        throw Exception(error);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showCheckoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Checkout'),
          content: DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'Payment Method'),
            value: _selectedPaymentMethod,
            items: const [
              DropdownMenuItem(value: 0, child: Text('MOMO')),
              DropdownMenuItem(value: 1, child: Text('Bank Transfer')),
              DropdownMenuItem(value: 2, child: Text('Cash')),
              DropdownMenuItem(value: 3, child: Text('VISA')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _checkout();
              },
              child: const Text('Place Order'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCartItem(CartItem item) {
    return ListTile(
      leading: SizedBox(
        width: 100,
        child: Image.network(item.product.image),
      ),
      title: Text(
        item.product.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quantity: ${item.quantity}'),
          Text('\$${(item.product.price * item.quantity).toStringAsFixed(2)}'),
        ],
      ),
      trailing: IconButton(
        onPressed: () => context.read<CartCubit>().removeFromCart(item),
        icon: const Icon(Icons.close, color: Colors.red),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 24,
          color: Colors.white,
        ),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        final items = cartState.items;
        final total = context.read<CartCubit>().getTotalPrice();

        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Your cart is empty',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildButton(
                    color: Colors.blue,
                    label: 'Start Shopping',
                    icon: Icons.shopping_cart,
                    onPressed: widget.onContinueShopping,
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => _buildCartItem(items[index]),
          ),
          bottomNavigationBar: BottomAppBar(
            color: Colors.white,
            height: 220,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Total: \$${total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  _buildButton(
                    color: Colors.red,
                    label: 'Clear Cart',
                    icon: Icons.clear_all,
                    onPressed: () => context.read<CartCubit>().clearCart(),
                  ),
                  _buildButton(
                    color: Colors.green,
                    label: 'Check out',
                    icon: Icons.shopping_cart,
                    onPressed: _showCheckoutDialog,
                  ),
                  _buildButton(
                    color: Colors.blue,
                    label: 'Continue Shopping',
                    icon: Icons.arrow_back,
                    onPressed: widget.onContinueShopping,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
