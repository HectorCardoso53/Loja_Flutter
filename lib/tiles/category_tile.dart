import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_compras/screens/category_screen.dart';

class CategoryTile extends StatelessWidget {
  final DocumentSnapshot snapshot;

  CategoryTile(this.snapshot);

  @override
  Widget build(BuildContext context) {
    final data = snapshot.data() as Map<String, dynamic>?;

    if (data == null) {
      return ListTile(title: Text('Dados inválidos'));
    }

    final icon = data['icon'] ?? '';
    final title = data['title'] ?? '';

    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.transparent,
        backgroundImage: NetworkImage(icon),
      ),
      title: Text(title),
      trailing: Icon(Icons.keyboard_arrow_right),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CategoryScreen(snapshot),
          ),
        );
      },
    );
  }
}
