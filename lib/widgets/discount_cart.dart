import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_compras/moldes/cart_model.dart';

class DiscountCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        title: Text(
          "Cupom de desconto",
          textAlign: TextAlign.start,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        leading: Icon(
          Icons.card_giftcard,
        ),
        trailing: Icon(
          Icons.add,
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: TextFormField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Digite seu Cupom"
              ),
              initialValue: CartModel.of(context).couponCode ?? "",
              onFieldSubmitted: (text) {
                FirebaseFirestore.instance.collection("coupons").doc(text).get()
                    .then((docSnap) {
                  final data = docSnap.data();
                  if (data != null) {
                    CartModel.of(context).setCoupon(text, data["percent"]);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Desconto de ${data["percent"]}% aplicado!"),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    );
                  } else {
                    CartModel.of(context).setCoupon("", 0); // Substituindo null por string vazia
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Cupom não existente"),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
