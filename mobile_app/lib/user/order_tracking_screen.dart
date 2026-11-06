import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/firebase_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  final FirebaseService firebaseService;
  final TransactionRecord order;

  const OrderTrackingScreen({
    super.key,
    required this.firebaseService,
    required this.order,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late TransactionRecord _currentOrder;
  bool _isUpdating = false;

  final List<Map<String, dynamic>> _stages = [
    {
      'title': 'Order Placed',
      'subtitle': 'Order submitted & logged in system',
      'icon': Icons.inventory_2_outlined,
    },
    {
      'title': 'Preparing Food',
      'subtitle': 'Kitchen is preparing your fresh donuts',
      'icon': Icons.restaurant_outlined,
    },
    {
      'title': 'Ready for Delivery',
      'subtitle': 'Order packaged and ready for dispatch',
      'icon': Icons.takeout_dining_outlined,
    },
    {
      'title': 'Out for Delivery',
      'subtitle': 'Order handed over for delivery to your address',
      'icon': Icons.two_wheeler_outlined,
    },
    {
      'title': 'Order Delivered',
      'subtitle': 'Customer has received the order',
      'icon': Icons.handshake_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    widget.firebaseService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    widget.firebaseService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (!mounted) return;
    final updated = widget.firebaseService.transactions.firstWhere(
      (t) => t.id == _currentOrder.id,
      orElse: () => _currentOrder,
    );
    setState(() {
      _currentOrder = updated;
    });
  }

  int _getStageIndex(String status) {
    switch (status.trim().toLowerCase()) {
      case 'order placed':
      case 'placed':
        return 0;
      case 'preparing food':
      case 'prepares food':
      case 'preparing':
        return 1;
      case 'ready for delivery':
      case 'ready':
        return 2;
      case 'out for delivery':
        return 3;
      case 'order delivered':
      case 'delivered':
      case 'completed':
        return 4;
      default:
        return 0;
    }
  }

  Future<void> _updateStage(String newStatus) async {
    if (!widget.firebaseService.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Access Denied: Only administrators can change the order progress stage.'),
          backgroundColor: Color(0xFFDC2626),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() => _isUpdating = true);
    final success = await widget.firebaseService.updateOrderStatus(_currentOrder.id, newStatus);
    if (!mounted) return;
    setState(() => _isUpdating = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to "$newStatus"'),
          backgroundColor: const Color(0xFF15803D),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stageIndex = _getStageIndex(_currentOrder.status);
    final isDelivered = stageIndex == 4;
    final isAdmin = widget.firebaseService.isAdmin;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Order #${_currentOrder.id}'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
        actions: [
          IconButton(
            tooltip: 'Refresh Status',
            icon: const Icon(Icons.refresh),
            onPressed: () => widget.firebaseService.fetchCustomerOrders(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Status Banner inspired by Reference Image
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Current Status',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _stages[stageIndex]['title'] as String,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDelivered ? const Color(0xFFDCFCE7) : const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDelivered ? const Color(0xFF86EFAC) : const Color(0xFFFDBA74),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isDelivered ? Icons.check_circle_rounded : Icons.sync_rounded,
                                    size: 14,
                                    color: isDelivered ? const Color(0xFF15803D) : const Color(0xFFEA580C),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isDelivered ? 'Delivered' : 'Step ${stageIndex + 1} of 5',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDelivered ? const Color(0xFF15803D) : const Color(0xFFEA580C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _stages[stageIndex]['subtitle'] as String,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 2. Visual Progress Timeline (5 Stages)
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Progress Stages',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 18),
                        ...List.generate(_stages.length, (idx) {
                          final isCompleted = idx < stageIndex;
                          final isCurrent = idx == stageIndex;
                          final isPending = idx > stageIndex;
                          final isLast = idx == _stages.length - 1;
                          final stage = _stages[idx];

                          Color iconBgColor;
                          Color iconColor;
                          Color borderColor;

                          if (isCompleted) {
                            iconBgColor = const Color(0xFFEA580C);
                            iconColor = Colors.white;
                            borderColor = const Color(0xFFEA580C);
                          } else if (isCurrent) {
                            iconBgColor = const Color(0xFFFFF7ED);
                            iconColor = const Color(0xFFEA580C);
                            borderColor = const Color(0xFFEA580C);
                          } else {
                            iconBgColor = const Color(0xFFF1F5F9);
                            iconColor = const Color(0xFF94A3B8);
                            borderColor = const Color(0xFFE2E8F0);
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Timeline node & connecting vertical line
                              Column(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: iconBgColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: borderColor, width: isCurrent ? 2 : 1),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        isCompleted ? Icons.check_rounded : (stage['icon'] as IconData),
                                        size: 18,
                                        color: iconColor,
                                      ),
                                    ),
                                  ),
                                  if (!isLast)
                                    Container(
                                      width: 2,
                                      height: 34,
                                      color: isCompleted ? const Color(0xFFEA580C) : const Color(0xFFE2E8F0),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 14),
                              // Stage Title and Subtitle
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            stage['title'] as String,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                              color: isPending ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                                            ),
                                          ),
                                          if (isCurrent) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEA580C),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'ACTIVE',
                                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        stage['subtitle'] as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isPending ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 3. Delivery Confirmation Section (Shown when Delivered)
                if (isDelivered) ...[
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFF86EFAC)),
                    ),
                    color: const Color(0xFFF0FDF4),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.verified_rounded, color: Color(0xFF15803D), size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Delivery Confirmation',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Your order was successfully delivered and received. Thank you for ordering from Daily Dough!',
                            style: TextStyle(fontSize: 13, color: Color(0xFF166534)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Completed on: ${_currentOrder.timestamp}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF15803D), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // 4. Delivery & Order Details Box
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Delivery & Payment Information',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 18, color: Color(0xFF64748B)),
                            const SizedBox(width: 8),
                            Text('Recipient: ${_currentOrder.customerName}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF64748B)),
                            const SizedBox(width: 8),
                            Expanded(child: Text('Address: ${_currentOrder.address}', style: const TextStyle(fontSize: 13))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.payment_outlined, size: 18, color: Color(0xFF64748B)),
                            const SizedBox(width: 8),
                            Text('Payment: ${_currentOrder.paymentMethod}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            if (_currentOrder.paymentMethod == 'GCash') ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'GCash Verified',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const Divider(height: 20),
                        const Text('Ordered Items:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        ..._currentOrder.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  const Icon(Icons.bakery_dining_rounded, size: 15, color: Color(0xFFD97706)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(item, style: const TextStyle(fontSize: 13)),
                                  ),
                                ],
                              ),
                            )),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Amount:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(
                              '₱${_currentOrder.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFDC2626)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 5. Transparent Technical Note (Requirement 5 & 6)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.info_outline, size: 18, color: Color(0xFF64748B)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Note: Live GPS map tracking and rider photo verification are in development and require external Google Maps API and cloud storage services.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 6. Need Help / Customer Assistance Section (Requirement 7)
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.help_outline_rounded, color: Color(0xFF0F172A), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Need Help with this Order?',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          title: const Text('Where is my food?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          children: const [
                            Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Your order is progressing according to the stages shown above. You will see it advance from kitchen preparation to out for delivery.',
                                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ),
                          ],
                        ),
                        ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          title: const Text('Can I change my order?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          children: const [
                            Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Once baking begins in the Preparing Food stage, items cannot be changed.',
                                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ),
                          ],
                        ),
                        ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          title: const Text('Can I cancel my order?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          children: const [
                            Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Cancellations are accepted only while the order remains in the "Order Placed" stage.',
                                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 7. Order Stage Progression Control (Admin Only - Completely Hidden for Customers)
                if (isAdmin) ...[
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.amber.shade300),
                    ),
                    color: Colors.amber.shade50.withValues(alpha: 0.6),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.admin_panel_settings_rounded,
                                size: 18,
                                color: Color(0xFFD97706),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Order Stage Progression',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFFDE68A)),
                                ),
                                child: const Text(
                                  'ADMIN ACCESS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Select a stage below to update this order\'s live progress in Firebase:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF92400E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _stages.map((stg) {
                              final name = stg['title'] as String;
                              final isSel = _currentOrder.status == name;
                              return ChoiceChip(
                                label: Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                    color: isSel ? Colors.white : const Color(0xFF92400E),
                                  ),
                                ),
                                selected: isSel,
                                selectedColor: const Color(0xFFEA580C),
                                backgroundColor: Colors.white,
                                onSelected: _isUpdating
                                    ? null
                                    : (sel) {
                                        if (sel) _updateStage(name);
                                      },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ] else
                  const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

