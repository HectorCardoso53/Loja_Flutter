import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_compras/datas/cart_product.dart';
import 'package:loja_compras/moldes/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

class CartModel extends Model {
  UserModel user;
  List<CartProduct> products = [];

  String? couponCode;
  int discountPercentage = 0;

  bool isLoading = false;

  CartModel(this.user) {
    if (user.isLoggedIn()) _loadCartItems();
  }

  static CartModel of(BuildContext context) => ScopedModel.of<CartModel>(context);

  void addCartItem(CartProduct cartProduct) {
    if (user.firebaseUser == null) {
      print('Erro: Usuário não autenticado');
      return;
    }

    products.add(cartProduct);

    FirebaseFirestore.instance
        .collection("users")
        .doc(user.firebaseUser!.uid)
        .collection("cart")
        .add(cartProduct.toMap())
        .then((doc) {
      cartProduct.cid = doc.id;
    });
    notifyListeners();
  }

  void removeCartItem(CartProduct cartProduct) {
    if (user.firebaseUser == null) {
      print('Erro: Usuário não autenticado');
      return;
    }

    FirebaseFirestore.instance
        .collection("users")
        .doc(user.firebaseUser!.uid)
        .collection("cart")
        .doc(cartProduct.cid)
        .delete();

    products.remove(cartProduct);
    notifyListeners();
  }

  void decProduct(CartProduct cartProduct) {
    if (cartProduct.quantity != null && cartProduct.quantity! > 0) {
      cartProduct.quantity = cartProduct.quantity! - 1;
      FirebaseFirestore.instance
          .collection("users")
          .doc(user.firebaseUser!.uid)
          .collection("cart")
          .doc(cartProduct.cid)
          .update(cartProduct.toMap());
      notifyListeners();
    }
  }

  void incProduct(CartProduct cartProduct) {
    if (cartProduct.quantity != null) {
      cartProduct.quantity = cartProduct.quantity! + 1;
      FirebaseFirestore.instance
          .collection("users")
          .doc(user.firebaseUser!.uid)
          .collection("cart")
          .doc(cartProduct.cid)
          .update(cartProduct.toMap());
      notifyListeners();
    }
  }

  void setCoupon(String couponCode, int discountPercentage) {
    this.couponCode = couponCode;
    this.discountPercentage = discountPercentage;
    notifyListeners(); // Notifica para atualizar a UI após a aplicação do cupom
  }

  Future<void> loadProductData() async {
    for (CartProduct product in products) {
      await product.loadProductData();
    }
  }

  double calculateSubtotal() {
    double subtotal = 0.0;
    for (CartProduct product in products) {
      if (product.price != null) {
        subtotal += product.price! * (product.quantity ?? 1);
      }
    }
    return subtotal;
  }

  double getDiscount() {
    return calculateSubtotal() * discountPercentage / 100;
  }

  double getShipPrice() {
    return 9.99;
  }
  Future<String?> finishOrder() async {
    // Verificar se a lista de produtos está vazia
    if (products == null || products.isEmpty) {
      print("A lista de produtos está vazia.");
      return null;
    }

    // Verificar se o usuário está autenticado
    if (user.firebaseUser == null) {
      print("Usuário não está autenticado.");
      return null;
    }

    print("Verificando o estado do FirebaseUser...");
    print("FirebaseUser: ${user.firebaseUser}");
    print("FirebaseUser UID: ${user.firebaseUser?.uid}");

    isLoading = true;
    notifyListeners();
    print("Carregando...");

    double productsPrice = calculateSubtotal();
    double shipPrice = getShipPrice();
    double discount = getDiscount();

    try {
      Map<String, dynamic> orderData = {
        "clientId": user.firebaseUser!.uid,
        "products": products.map((cartProduct) {
          var productMap = cartProduct.toMap();
          print("Produto convertido em mapa: $productMap");
          return productMap;
        }).toList(),
        "shipPrice": shipPrice,
        "productsPrice": productsPrice,
        "discount": discount,
        "totalPrice": productsPrice - discount + shipPrice,
        "status": 1,
      };

      print("Dados do pedido a serem enviados: $orderData");

      // Adicionar pedido ao Firestore
      DocumentReference refOrder = await FirebaseFirestore.instance.collection("orders").add(orderData);
      print("Pedido criado com ID: ${refOrder.id}");

      // Adicionar o pedido à coleção de pedidos do usuário
      await FirebaseFirestore.instance.collection("users").doc(user.firebaseUser!.uid)
          .collection("orders").doc(refOrder.id).set({
        "orderId": refOrder.id,
      });
      print("Pedido adicionado à coleção de pedidos do usuário.");

      // Deletar itens do carrinho
      QuerySnapshot query = await FirebaseFirestore.instance.collection("users").doc(user.firebaseUser!.uid)
          .collection("cart").get();

      for (DocumentSnapshot doc in query.docs) {
        print("Deletando item do carrinho com ID: ${doc.id}");
        await doc.reference.delete();
      }
      print("Itens do carrinho deletados.");

      // Limpar o carrinho e atualizar o estado
      products.clear();
      couponCode = null;
      discountPercentage = 0;

      isLoading = false;
      notifyListeners();
      print("Pedido finalizado com sucesso. ID do pedido: ${refOrder.id}");
      return refOrder.id;
    } catch (e) {
      print("Erro ao finalizar o pedido: $e");
      isLoading = false;
      notifyListeners();
      rethrow; // Re-lançar a exceção para ser tratada na interface do usuário
    }
  }






  void _loadCartItems() async {
    QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.firebaseUser!.uid)
        .collection("cart")
        .get();

    products = query.docs.map((doc) => CartProduct.fromDocument(doc)).toList();
    print('Produtos carregados: ${products.length}');
    notifyListeners();
  }
}
