import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_compras/datas/cart_product.dart';
import 'package:loja_compras/datas/product_data.dart';
import 'package:loja_compras/moldes/cart_model.dart';

class CartTile extends StatelessWidget {
  final CartProduct cartProduct;

  CartTile(this.cartProduct);

  Widget _buildContent(ProductData productData, BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          width: 120,
          child: productData.images.isNotEmpty
              ? Image.network(
            productData.images[0],
            fit: BoxFit.cover,
          )
              : Placeholder(),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productData.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 17,
                  ),
                ),
                Text(
                  "Tamanho: ${cartProduct.size ?? 'Desconhecido'}",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  "R\$ ${productData.price.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: cartProduct.quantity! > 1
                          ? () {
                        CartModel.of(context).decProduct(cartProduct);
                      }
                          : null,
                      icon: Icon(Icons.remove),
                      color: Theme.of(context).primaryColor,
                    ),
                    Text(cartProduct.quantity.toString()),
                    IconButton(
                      onPressed: () {
                        CartModel.of(context).incProduct(cartProduct);
                      },
                      icon: Icon(Icons.add),
                      color: Theme.of(context).primaryColor,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        CartModel.of(context).removeCartItem(cartProduct);
                      },
                      child: Text(
                        "Remover",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildFutureBuilder() {
    final category = cartProduct.category;
    final pid = cartProduct.pid;

    print('Category: $category');
    print('PID: $pid');

    if (category == null || category.isEmpty || pid == null || pid.isEmpty) {
      return Center(child: Text('Informações do produto estão faltando'));
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection("products")
          .doc(cartProduct.category) // Usar a categoria aqui (ex: "camisetas")
          .collection("items")
          .doc(cartProduct.pid) // Usar o ID do produto aqui
          .get(),
      builder: (context, snapshot) {
        print('Snapshot connectionState: ${snapshot.connectionState}');
        print('PID usado na consulta: ${cartProduct.pid}');
        print('Categoria usada na consulta: ${cartProduct.category}');

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            print('Snapshot data exists: ${snapshot.data!.exists}');
          }
          if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
            final document = snapshot.data!;
            print('Document data: ${document.data()}');
            final productData = ProductData.fromDocument(document);
            return _buildContent(productData, context);
          } else {
            print('Produto não encontrado');
            return Center(child: Text('Produto não encontrado'));
          }
        } else {
          return Container(
            height: 70,
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: cartProduct.productData == null
          ? _buildFutureBuilder()
          : _buildContent(cartProduct.productData!, context),
    );
  }
}
