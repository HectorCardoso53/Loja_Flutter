import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../tiles/category_tile.dart';

class ProductsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('products').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Nenhum produto encontrado'));
        } else {
          var dividedTiles = ListTile.divideTiles(
            tiles: snapshot.data!.docs.map((doc) {
              return CategoryTile(doc);
            }).toList(),
          color: Colors.grey[500]).toList();
          print('Dados recebidos: ${snapshot.data!.docs}');
          return ListView(
            children:dividedTiles,
          );
        }
      },
    );
  }
}
