import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';

class AdminProductsScreen extends StatefulWidget {
  final FirebaseService firebaseService;
  final bool showAppBar;

  const AdminProductsScreen({
    super.key,
    required this.firebaseService,
    this.showAppBar = true,
  });

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  @override
  void initState() {
    super.initState();
    widget.firebaseService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    widget.firebaseService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  // --- Dialog: Add New Product ---
  void _showAddProductDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final detailsCtrl = TextEditingController();
    final imageCtrl = TextEditingController();
    String? errorMsg;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: const [
                Icon(Icons.add_circle_outline, color: Color(0xFFD97706)),
                SizedBox(width: 8),
                Text('Add New Product'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (errorMsg != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(errorMsg!, style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Product Name *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Price (₱) *',
                      prefixText: '₱ ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: imageCtrl,
                    onChanged: (_) => setDialogState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Product Photo URL (PNG, JPG) *',
                      hintText: 'https://.../photo.png',
                      prefixIcon: const Icon(Icons.image_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  if (imageCtrl.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageCtrl.text.trim(),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Text('Invalid image preview', style: TextStyle(fontSize: 11, color: Colors.red)),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: detailsCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Details / Description',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final priceText = priceCtrl.text.trim();
                  final price = double.tryParse(priceText);
                  final imageUrl = imageCtrl.text.trim();

                  if (name.isEmpty) {
                    setDialogState(() => errorMsg = 'Product name cannot be empty.');
                    return;
                  }
                  if (price == null || price <= 0) {
                    setDialogState(() => errorMsg = 'Please enter a valid positive price.');
                    return;
                  }
                  if (imageUrl.isEmpty) {
                    setDialogState(() => errorMsg = 'Product photo is required (PNG, JPG, etc.).');
                    return;
                  }

                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(ctx);
                  await widget.firebaseService.addProduct(
                    name: name,
                    price: price,
                    details: detailsCtrl.text.trim(),
                    imageUrl: imageUrl,
                  );

                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Product "$name" added to Firebase!'),
                      backgroundColor: const Color(0xFF059669),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save Product'),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Dialog: Edit Product ---
  void _showEditProductDialog(Product product) {
    final nameCtrl = TextEditingController(text: product.name);
    final priceCtrl = TextEditingController(text: product.price.toStringAsFixed(0));
    final detailsCtrl = TextEditingController(text: product.details);
    final imageCtrl = TextEditingController(text: product.imageUrl);
    String? errorMsg;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: const [
                Icon(Icons.edit_note_rounded, color: Color(0xFFD97706), size: 28),
                SizedBox(width: 8),
                Text('Edit Product'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (errorMsg != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(errorMsg!, style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Product Name *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Price (₱) *',
                      prefixText: '₱ ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: imageCtrl,
                    onChanged: (_) => setDialogState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Product Photo URL (PNG, JPG) *',
                      hintText: 'https://.../photo.png',
                      prefixIcon: const Icon(Icons.image_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  if (imageCtrl.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageCtrl.text.trim(),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Text('Invalid image preview', style: TextStyle(fontSize: 11, color: Colors.red)),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: detailsCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Details / Description',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final priceText = priceCtrl.text.trim();
                  final price = double.tryParse(priceText);
                  final imageUrl = imageCtrl.text.trim();

                  if (name.isEmpty) {
                    setDialogState(() => errorMsg = 'Product name cannot be empty.');
                    return;
                  }
                  if (price == null || price <= 0) {
                    setDialogState(() => errorMsg = 'Please enter a valid positive price.');
                    return;
                  }
                  if (imageUrl.isEmpty) {
                    setDialogState(() => errorMsg = 'Product photo is required (PNG, JPG, etc.).');
                    return;
                  }

                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(ctx);
                  await widget.firebaseService.updateProduct(
                    id: product.id,
                    name: name,
                    price: price,
                    details: detailsCtrl.text.trim(),
                    imageUrl: imageUrl,
                  );

                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Product "$name" updated in Firebase!'),
                      backgroundColor: const Color(0xFF059669),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Update Product'),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Confirm Delete ---
  void _confirmDeleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to remove "${product.name}" from Firebase Realtime Database?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.firebaseService.deleteProduct(product.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product "${product.name}" deleted from Firebase.'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Role-based Access Control Guard: Only Admin can access
    if (!widget.firebaseService.isAdmin) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Admin Management'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F172A),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.admin_panel_settings_outlined, size: 56, color: Color(0xFFDC2626)),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Access Denied',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFB91C1C)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'User "${widget.firebaseService.currentUsername}" is not an Administrator.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Lenie has shopping privileges only (Add to Cart & Checkout). Admin privileges are required to Add, Edit, or Delete products.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Return to Store'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final products = widget.firebaseService.products;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Product Setting'),
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F172A),
              elevation: 0.5,
              actions: [
                IconButton(
                  tooltip: 'Refresh from Firebase',
                  icon: const Icon(Icons.refresh),
                  onPressed: () => widget.firebaseService.fetchProducts(),
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFEFF6FF),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: Color(0xFF1D4ED8), size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Admin Mode: Full CRUD Active',
                    style: TextStyle(color: Color(0xFF1E40AF), fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  'Total: ${products.length}',
                  style: const TextStyle(color: Color(0xFF1E40AF), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 54, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text('No products available. Click below to add one!'),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _showAddProductDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Product'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: product.imageUrl.isNotEmpty
                                  ? Image.network(
                                      product.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => CircleAvatar(
                                        backgroundColor: Colors.amber.shade50,
                                        child: const Icon(Icons.broken_image, color: Color(0xFFD97706), size: 20),
                                      ),
                                    )
                                  : CircleAvatar(
                                      backgroundColor: Colors.amber.shade50,
                                      child: const Icon(Icons.inventory, color: Color(0xFFD97706), size: 20),
                                    ),
                            ),
                          ),
                          title: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 2),
                              Text(
                                '₱${product.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Color(0xFFD97706),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              if (product.details.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  product.details,
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Edit Product',
                                icon: const Icon(Icons.edit_outlined, color: Color(0xFF2563EB)),
                                onPressed: () => _showEditProductDialog(product),
                              ),
                              IconButton(
                                tooltip: 'Delete Product',
                                icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
                                onPressed: () => _confirmDeleteProduct(product),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddProductDialog,
        backgroundColor: const Color(0xFFD97706),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
