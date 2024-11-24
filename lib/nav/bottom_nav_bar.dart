import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final int cartItemCount;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.cartItemCount,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      fixedColor: Colors.blue,
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: CartIcon(itemCount: cartItemCount),
          label: 'Cart',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Account',
        ),
      ],
    );
  }
}

class CartIcon extends StatelessWidget {
  final int itemCount;

  const CartIcon({super.key, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Icon(Icons.shopping_cart, size: 30), // Main icon
        if (itemCount > 0) // Show badge only if there's an item count
          Positioned(
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              constraints: const BoxConstraints(
                maxWidth: 20,
                maxHeight: 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                itemCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}