import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_compras/moldes/user_model.dart';

import '../screens/login_screen.dart';
import '../tiles/order_tile.dart';

class OrdersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Acesso ao UserModel
    final userModel = UserModel.of(context);

    // Verifica se o usuário está logado
    if (userModel.isLoggedIn()) {
      // Retorna o conteúdo desejado quando o usuário está logado
      String uid = userModel.firebaseUser!.uid;
      return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid)
            .collection('orders').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Exibe um indicador de progresso enquanto os dados estão sendo carregados
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // Exibe um erro, se houver
            return Center(
              child: Text("Erro ao carregar pedidos"),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // Exibe uma mensagem quando não há pedidos
            return Center(
              child: Text("Você ainda não tem pedidos."),
            );
          } else {
            // Exibe a lista de pedidos
            return ListView(
              children: snapshot.data!.docs.map((doc) => OrderTile(doc.id)).toList(),
            );
          }
        },
      );
    } else {
      // Retorna o conteúdo quando o usuário não está logado
      return Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 16),
            Text(
              "Faça o login para acompanhar",
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
    }
  }
}
