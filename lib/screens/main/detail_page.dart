import 'package:flutter/material.dart';
import 'package:mobile_store/models/product.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;
  final VoidCallback onOrderNow;
  final VoidCallback onBack;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.onOrderNow,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Image.network(product.image, width: 200, height: 200)),
              const SizedBox(height: 16),
              Text(
                product.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              const SizedBox(height: 16),
              Text(
                product.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Manufacturer: ${product.manufacturer}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                '${product.quantity} units in stock',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${product.price} USD',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onBack, // Trigger onBack callback
                        style: FilledButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        label: const Text(
                          'Back',
                          style: TextStyle(fontSize: 20),
                        ),
                        icon: const Icon(Icons.arrow_circle_left_sharp),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onOrderNow,
                        style: FilledButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        label: const Text(
                          'Order Now',
                          style: TextStyle(fontSize: 20),
                        ),
                        icon: const Icon(Icons.shopping_cart),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
