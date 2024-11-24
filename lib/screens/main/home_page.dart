import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_store/models/product.dart';
import 'package:mobile_store/screens/main/account_page.dart';

import '../../cubits/cart_state.dart';
import '../../cubits/product_state.dart';
import '../../nav/bottom_nav_bar.dart';
import '../../cubits/auth_cubit.dart';
import '../../cubits/cart_cubit.dart';
import '../../cubits/product_cubit.dart';
import 'cart_page.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isLoading = false;
  final bool _hasMoreItems = true;
  final ScrollController _scrollController = ScrollController();

  // Add filter-related state variables
  String _searchQuery = '';
  RangeValues _priceRange = const RangeValues(0, 2000);
  bool _isFilterVisible = false;

  Product? productSelected;
  bool _isDetailView = false;

  // Add key for RefreshIndicator
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _initializeUserData();
    _setupScrollController();
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!_isLoading && _hasMoreItems) {
          _loadMoreProducts();
        }
      }
    });
  }

  // Add refresh method
  Future<void> _refreshProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Reset filters
      setState(() {
        _searchQuery = '';
        _priceRange = const RangeValues(0, 2000);
      });

      // Refresh products
      await context.read<ProductCubit>().refreshProducts();

      // Refresh cart
      if (!mounted) return;
      await context.read<CartCubit>().loadCart();

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Products refreshed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<ProductCubit>().fetchProducts(loadMore: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _initializeUserData() async {
    final authCubit = context.read<AuthCubit>();
    final userId = authCubit.currentUserId();

    if (userId != null) {
      await context.read<ProductCubit>().fetchProducts();
      if (!mounted) return;
      await context.read<CartCubit>().loadCart();
    }
  }

  void _addToCart(Product product) {
    final cartCubit = context.read<CartCubit>();
    cartCubit.addToCart(product);

    final error = cartCubit.state.error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} added to cart!')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void handleSearch() {
    if (_searchQuery.isEmpty && _priceRange == const RangeValues(0, 2000)) {
      context.read<ProductCubit>().clearSearch();
      return;
    }

    context.read<ProductCubit>().searchProducts(
          name: _searchQuery.isNotEmpty ? _searchQuery : null,
          minPrice: _priceRange.start,
          maxPrice: _priceRange.end,
        );
  }

  Widget _buildFilterPanel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isFilterVisible ? null : 0,
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Search Products',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Price Range',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 2000,
                divisions: 20,
                labels: RangeLabels(
                  '\$${_priceRange.start.round()}',
                  '\$${_priceRange.end.round()}',
                ),
                onChanged: (values) {
                  setState(() {
                    _priceRange = values;
                  });
                },
              ),
              Center(
                  child: FilledButton(
                      onPressed: () => {handleSearch()},
                      child: const Text('Search')))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedIndex == 0 && _isDetailView && productSelected != null) {
      return ProductDetailPage(
        product: productSelected!,
        onOrderNow: () {
          _addToCart(productSelected!);
        },
        onBack: () {
          setState(() {
            _isDetailView = false;
            productSelected = null;
          });
        },
      );
    } else if (_selectedIndex == 1) {
      return CartPage(
        onContinueShopping: () {
          setState(() {
            _selectedIndex = 0;
            if (_isDetailView) {
              return;
            }
            _isDetailView = false;
          });
        },
      );
    } else if (_selectedIndex == 2) {
      return const AccountPage();
    } else {
      return Column(
        children: [
          _buildFilterPanel(),
          Expanded(child: _buildProductList()),
        ],
      );
    }
  }

  Widget _buildProductList() {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state.isLoading && state.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null && state.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${state.error}',
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => context.read<ProductCubit>().fetchProducts(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.products.isEmpty) {
          return const Center(
            child: Text(
              'No products found',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          );
        }

        return RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: () => context.read<ProductCubit>().refreshProducts(),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: state.products.length + 1,
            itemBuilder: (context, index) {
              if (index == state.products.length) {
                if (state.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (!state.hasMoreItems) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No more products to load',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }

              final product = state.products[index];

              return Card(
                color: Colors.white,
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Image.network(
                        product.image,
                        width: 200,
                        height: 200,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const SizedBox(
                            width: 200,
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(
                            width: 200,
                            height: 200,
                            child: Icon(Icons.error_outline, size: 50),
                          );
                        },
                      ),
                      Text(
                        '${product.name} (${product.condition})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '\$${product.price} USD',
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        '${product.quantity} units in stock',
                        style: const TextStyle(fontSize: 20),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                setState(() {
                                  productSelected = product;
                                  _isDetailView = true;
                                });
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              label: const Text(
                                'Details',
                                style: TextStyle(fontSize: 20),
                              ),
                              icon: const Icon(
                                Icons.info,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => _addToCart(product),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              label: const Text(
                                'Order Now',
                                style: TextStyle(fontSize: 20),
                              ),
                              icon: const Icon(
                                Icons.shopping_cart,
                                size: 24,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Mobile Store',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (_selectedIndex == 0 && !_isDetailView) ...[
            if (context.watch<ProductCubit>().state.isSearching)
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.black),
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _priceRange = const RangeValues(0, 2000);
                    _isFilterVisible = false;
                  });
                  context.read<ProductCubit>().clearSearch();
                },
              ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: _refreshProducts,
            ),
            IconButton(
              icon: Icon(
                _isFilterVisible ? Icons.filter_list_off : Icons.filter_list,
                color: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  _isFilterVisible = !_isFilterVisible;
                });
              },
            ),
          ],
        ],
      ),
      body: _buildContent(),
      bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
        builder: (context, cartState) {
          return BottomNavBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
            cartItemCount: cartState.items.fold(
              0,
              (total, item) => total + item.quantity,
            ),
          );
        },
      ),
    );
  }
}
