import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderTile extends StatelessWidget {
  final String id;

  OrderTile(this.id);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 8,
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .doc(id)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Erro ao carregar pedido'),
              );
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                child: Text('Pedido não encontrado'),
              );
            } else {
              int status = snapshot.data!["status"];
              var data = snapshot.data!.data() as Map<String, dynamic>;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Código do pedido: ${snapshot.data!.id}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    _buildProductsText(data),
                  ),
                  SizedBox(height: 4,),
                  Text(
                    'Status do Pedido: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,// expande o elemento na tela toda
                    children: [
                      _buildCircle("1", "Preparação", status, 1),
                      Container(height: 1,width: 40,color: Colors.grey[500],),
                      _buildCircle("2", "Transporte", status, 2),
                      Container(height: 1,width: 40,color: Colors.grey[500],),
                      _buildCircle("3", "Entrega", status, 3),
                    ],
                  )
                ],
              );
            }
          },
        ),
      ),
    );
  }

  String _buildProductsText(Map<String, dynamic> data) {
    String text = 'Descrição:\n';
    var products = data['products'] as List<dynamic>? ?? [];
    for (var p in products) {
      var product = p as Map<String, dynamic>;
      var productDetails = product['product'] as Map<String, dynamic>;
      text +=
      '${product['quantity']} x ${productDetails['title']} (R\$ ${productDetails['price'].toStringAsFixed(2)})\n';
    }
    text += 'Total: R\$ ${data["totalPrice"]?.toStringAsFixed(2) ?? '0.00'}';
    return text;
  }

  Widget _buildCircle(
      String title, String subtitle, int status, int thisStatus) {
    Color backColor;
    Widget child;

    if (status < thisStatus) {
      backColor = Colors.grey[500]!;
      child = Text(
        title,
        style: TextStyle(
          color: Colors.white,
        ),
      );
    } else if (status == thisStatus) {
      backColor = Colors.blue;
      child = Stack(
        alignment: Alignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          )
        ],
      );
    } else {
      backColor = Colors.green;
      child = Icon(Icons.check);
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: backColor,
          child: child,
        ),
        Text(subtitle),
      ],
    );
  }
}
