import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';
import 'products_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final FirebaseService firebaseService;
  final TreatItem item;

  const ProductDetailScreen({
    super.key,
    required this.firebaseService,
    required this.item,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isAdding = false;
  bool _justAdded = false;

  @override
  void initState() {
    super.initState();
    // Default quantity is existing cart quantity if already in cart, else 1
    final cartQty = widget.firebaseService.getProductQuantity(widget.item.name);
    _quantity = cartQty > 0 ? cartQty : 1;
  }

  Future<void> _handleAddToCart() async {
    setState(() => _isAdding = true);

    final prod = Product(
      id: 'treat_${widget.item.name.toLowerCase().replaceAll(' ', '_')}',
      name: widget.item.name,
      price: widget.item.price,
      details: widget.item.description,
      imageUrl: widget.item.assetPath,
    );

    await widget.firebaseService.setProductQuantity(prod, _quantity);

    if (!mounted) return;

    setState(() {
      _isAdding = false;
      _justAdded = true;
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Added ${widget.item.name} (x$_quantity) to cart',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF16A34A),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF6F0),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Top Section: Back Button and Large Product Image
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back Arrow Icon in upper-left corner
                            Material(
                              color: Colors.white,
                              shape: const CircleBorder(),
                              elevation: 2,
                              shadowColor: Colors.black12,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => Navigator.of(context).pop(),
                                child: const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Icon(
                                    Icons.arrow_back_rounded,
                                    size: 22,
                                    color: Color(0xFF291B15),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 44),
                          ],
                        ),
                      ),

                      // Large prominent product image
                      Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 340, maxHeight: 290),
                          padding: const EdgeInsets.all(12),
                          child: Hero(
                            tag: 'treat_${item.name}',
                            child: item.assetPath.startsWith('http://') || item.assetPath.startsWith('https://')
                                ? Image.network(
                                    item.assetPath,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => const Icon(
                                      Icons.bakery_dining_rounded,
                                      size: 140,
                                      color: Color(0xFFD97706),
                                    ),
                                  )
                                : Image.asset(
                                    item.assetPath,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => const Icon(
                                      Icons.bakery_dining_rounded,
                                      size: 140,
                                      color: Color(0xFFD97706),
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 2. Bottom Section: Product Name, Price, Description, Controls
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFFDFBF8),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x08000000),
                                offset: Offset(0, -4),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Product Name
                              Text(
                                item.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF291B15),
                                  height: 1.2,
                                  letterSpacing: -0.3,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Product Price
                              Text(
                                '₱${item.price.toInt()}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFD95B1E),
                                ),
                              ),

                              // Product Description (if available)
                              if (item.description.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Text(
                                    item.description,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF64748B),
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 28),

                              // Quantity Selector with Minus and Plus icons
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3ECE4),
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Minus button
                                    Material(
                                      color: const Color(0xFFE8DED3),
                                      shape: const CircleBorder(),
                                      child: InkWell(
                                        customBorder: const CircleBorder(),
                                        onTap: _quantity > 1
                                            ? () {
                                                setState(() {
                                                  _quantity--;
                                                  _justAdded = false;
                                                });
                                              }
                                            : null,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.remove_rounded,
                                            size: 20,
                                            color: _quantity > 1
                                                ? const Color(0xFF291B15)
                                                : Colors.grey.shade400,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                      child: Text(
                                        '$_quantity',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF291B15),
                                        ),
                                      ),
                                    ),
                                    // Plus button
                                    Material(
                                      color: const Color(0xFFE8DED3),
                                      shape: const CircleBorder(),
                                      child: InkWell(
                                        customBorder: const CircleBorder(),
                                        onTap: () {
                                          setState(() {
                                            _quantity++;
                                            _justAdded = false;
                                          });
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.add_rounded,
                                            size: 20,
                                            color: Color(0xFF291B15),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Add to Cart Button
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: _isAdding ? null : _handleAddToCart,
                                  icon: _isAdding
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.shopping_cart_outlined, size: 20),
                                  label: Text(
                                    _isAdding ? 'Adding...' : 'Add to Cart',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD95B1E),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(26),
                                    ),
                                  ),
                                ),
                              ),

                              // Green confirmation message when product is added
                              if (_justAdded) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFF86EFAC)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF15803D)),
                                      SizedBox(width: 6),
                                      Text(
                                        'Added to cart',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF15803D),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

