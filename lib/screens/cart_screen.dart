import 'package:flutter/material.dart';
import 'package:loja_compras/moldes/cart_model.dart';
import 'package:loja_compras/moldes/user_model.dart';
import 'package:loja_compras/screens/login_screen.dart';
import 'package:loja_compras/screens/order_screen.dart';
import 'package:loja_compras/widgets/cart_price.dart';
import 'package:loja_compras/widgets/discount_cart.dart';
import 'package:loja_compras/widgets/ship_card.dart';
import 'package:scoped_model/scoped_model.dart';

import '../tiles/Cart_tile.dart';

class CartScreen extends StatefulWidget {
  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meu Carrinho"),
        actions: [
          Container(
            padding: EdgeInsets.only(right: 8),
            child: ScopedModelDescendant<CartModel>(
              builder: (context, child, model) {
                int p = model.products.length;
                return Text(
                  "${p ?? 0} ${p == 1 ? "ITEM" : "ITENS"}",
                  style: TextStyle(
                    fontSize: 17,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: ScopedModelDescendant<CartModel>(
        builder: (context, child, model) {
          if (model.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (!UserModel.of(context).isLoggedIn()) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.remove_shopping_cart,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Faça o login para Adicionar o produto",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      "Entrar",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (model.products == null || model.products.isEmpty) {
            return Center(
              child: Text(
                "Nenhum Produto no carrinho!!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            );
          } else {
            return ListView(
              children: [
                Column(
                  children: model.products.map(
                        (product) {
                      return CartTile(product);
                    },
                  ).toList(),
                ),
                DiscountCart(),
                ShipCard(),
                CartPrice(() async {
                  final scaffoldContext = context;  // Salva o BuildContext atual

                  try {
                    String? orderId = await model.finishOrder();

                    if (mounted && orderId != null && orderId.isNotEmpty) {
                      Navigator.of(scaffoldContext).push(
                        MaterialPageRoute(
                          builder: (context) => OrderScreen(orderId: orderId),
                        ),
                      );
                    } else if (mounted) {
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        SnackBar(content: Text('Erro ao finalizar pedido.')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        SnackBar(content: Text('Erro ao finalizar pedido: ${e.toString()}')),
                      );
                    }
                  }
                }),
              ],
            );
          }
        },
      ),
    );
  }
}
