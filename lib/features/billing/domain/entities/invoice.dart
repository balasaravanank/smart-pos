import 'package:equatable/equatable.dart';
import '../../../product/domain/entities/product.dart';
import '../../../billing/domain/entities/cart_item.dart';

class Invoice extends Equatable {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime createdAt;
  final String shopName;

  const Invoice({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    required this.shopName,
  });

  @override
  List<Object?> get props => [id, items, totalAmount, createdAt, shopName];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
      'shopName': shopName,
      'items': items
          .map((item) => {
                'productId': item.product.id,
                'productName': item.product.name,
                'productBarcode': item.product.barcode,
                'productPrice': item.product.price,
                'quantity': item.quantity,
              })
          .toList(),
    };
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List).map((itemJson) {
      final product = Product(
        id: itemJson['productId'] as String,
        name: itemJson['productName'] as String,
        barcode: itemJson['productBarcode'] as String,
        price: (itemJson['productPrice'] as num).toDouble(),
      );
      return CartItem(
        product: product,
        quantity: itemJson['quantity'] as int,
      );
    }).toList();

    return Invoice(
      id: json['id'] as String,
      items: itemsList,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      shopName: json['shopName'] as String,
    );
  }
}
