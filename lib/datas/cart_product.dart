import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loja_compras/datas/product_data.dart';

class CartProduct {
  String? cid;
  String? category;
  String? pid;
  int? quantity;
  String? size;
  double? price;
  ProductData? productData; // Adiciona o campo productData

  CartProduct({
    this.cid,
    this.category,
    this.pid,
    this.quantity,
    this.size,
    this.price,
    this.productData, // Adiciona o campo productData
  });

  CartProduct.fromDocument(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data != null) {
      cid = snapshot.id;
      category = data['category'] as String?;
      pid = data['pid'] as String?;
      quantity = data['quantity'] as int?;
      size = data['size'] as String?;
      price = data['price'] as double?;
    }
  }

  Future<void> loadProductData() async {
    if (pid != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> productDoc = await FirebaseFirestore.instance
            .collection('products')
            .doc(pid)
            .get();

        if (productDoc.exists) {
          productData = ProductData.fromDocument(productDoc); // Define o productData
        }
      } catch (e) {
        print('Error loading product data: $e');
      }
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "category": category,
      "pid": pid,
      "quantity": quantity,
      "size": size,
      "price": price,
      "product": productData!.toResumeMap(),
    };
  }
}
