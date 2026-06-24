import 'package:hive/hive.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/cart_item.dart';
import '../../../product/domain/entities/product.dart';

part 'invoice_model.g.dart';

@HiveType(typeId: 2)
class InvoiceModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final List<Map<String, dynamic>> itemsData;

  @HiveField(2)
  final double totalAmount;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final String shopName;

  InvoiceModel({
    required this.id,
    required this.itemsData,
    required this.totalAmount,
    required this.createdAt,
    required this.shopName,
  });

  factory InvoiceModel.fromEntity(Invoice invoice) {
    return InvoiceModel(
      id: invoice.id,
      itemsData: invoice.items
          .map((item) => <String, dynamic>{
                'productId': item.product.id,
                'productName': item.product.name,
                'productBarcode': item.product.barcode,
                'productPrice': item.product.price,
                'quantity': item.quantity,
              })
          .toList(),
      totalAmount: invoice.totalAmount,
      createdAt: invoice.createdAt,
      shopName: invoice.shopName,
    );
  }

  Invoice toEntity() {
    final items = itemsData.map((data) {
      final product = Product(
        id: data['productId'] as String,
        name: data['productName'] as String,
        barcode: data['productBarcode'] as String,
        price: (data['productPrice'] as num).toDouble(),
      );
      return CartItem(
        product: product,
        quantity: data['quantity'] as int,
      );
    }).toList();

    return Invoice(
      id: id,
      items: items,
      totalAmount: totalAmount,
      createdAt: createdAt,
      shopName: shopName,
    );
  }
}
