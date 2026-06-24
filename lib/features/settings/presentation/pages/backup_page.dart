import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/data/hive_database.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../shop/data/models/shop_model.dart';
import '../../../product/data/models/product_model.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  bool _isExporting = false;

  Future<void> _exportData() async {
    setState(() => _isExporting = true);

    try {
      final productBox = HiveDatabase.productBox;
      final shopBox = HiveDatabase.shopBox;

      // Basic serialization for products
      final productsList = productBox.values.map((p) => {
        'id': p.id,
        'name': p.name,
        'barcode': p.barcode,
        'price': p.price,
        'stock': p.stock,
      }).toList();

      final shopData = shopBox.get('shop_details');
      Map<String, dynamic>? shopJson;
      if (shopData != null) {
        shopJson = {
          'name': shopData.name,
          'addressLine1': shopData.addressLine1,
          'addressLine2': shopData.addressLine2,
          'phoneNumber': shopData.phoneNumber,
          'upiId': shopData.upiId,
          'footerText': shopData.footerText,
        };
      }

      final exportData = {
        'timestamp': DateTime.now().toIso8601String(),
        'products': productsList,
        'shop': shopJson,
      };

      final jsonString = jsonEncode(exportData);

      // Save to temp file
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/smart_pos_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);

      // Share it
      await Share.shareXFiles([XFile(file.path)], text: 'Smart POS Backup File');

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: 28, color: Theme.of(context).primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.cloud_upload_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'Keep your data safe',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Export your products and shop details to a JSON file. You can save it to Google Drive or share it via email.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 48),
            PrimaryButton(
              onPressed: _isExporting ? () {} : _exportData,
              icon: Icons.share,
              label: 'Export Data File',
              isLoading: _isExporting,
            ),
            const SizedBox(height: 16),
            const Text(
              'Note: Invoices are not currently included in backups.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
            )
          ],
        ),
      ),
    );
  }
}
