import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/invoice_repository_impl.dart';
import '../../domain/entities/invoice.dart';

class InvoiceHistoryPage extends StatefulWidget {
  const InvoiceHistoryPage({super.key});

  @override
  State<InvoiceHistoryPage> createState() => _InvoiceHistoryPageState();
}

class _InvoiceHistoryPageState extends State<InvoiceHistoryPage> {
  final InvoiceRepositoryImpl _repository = InvoiceRepositoryImpl();
  List<Invoice> _invoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    final result = await _repository.getInvoices();
    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading invoices: ${failure.message}'), backgroundColor: Colors.red),
          );
        }
      },
      (invoices) {
        if (mounted) {
          setState(() {
            _invoices = invoices;
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: 28, color: Theme.of(context).primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _invoices.isEmpty
              ? const Center(child: Text('No invoices found.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _invoices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final invoice = _invoices[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(
                          'Invoice #${invoice.id.substring(0, 8)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          DateFormat('dd-MM-yyyy hh:mm a').format(invoice.createdAt),
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        trailing: Text(
                          '₹${invoice.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        onTap: () {
                          // Show details in bottom sheet or dialog
                          _showInvoiceDetails(context, invoice);
                        },
                      ),
                    );
                  },
                ),
    );
  }

  void _showInvoiceDetails(BuildContext context, Invoice invoice) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Invoice #${invoice.id.substring(0, 8)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Date: ${DateFormat('dd-MM-yyyy hh:mm a').format(invoice.createdAt)}', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: invoice.items.length,
                  itemBuilder: (context, index) {
                    final item = invoice.items[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('${item.quantity}x ${item.product.name}', style: const TextStyle(fontSize: 14)),
                      trailing: Text('₹${item.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text('₹${invoice.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
