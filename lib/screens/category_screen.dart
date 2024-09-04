import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_compras/datas/product_data.dart';

import '../tiles/product_tile.dart';

class CategoryScreen extends StatelessWidget {
  final DocumentSnapshot snapshot;

  CategoryScreen(this.snapshot);

  @override
  Widget build(BuildContext context) {
    // Converte os dados do snapshot para um Map
    var data = snapshot.data() as Map<String, dynamic>;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(data["title"]),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(
                  Icons.grid_on,
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.list,
                ),
              ),
            ],
          ),
        ),
        body: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection("products").doc(
              snapshot.id).
          collection("items").get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator(),);
            } else {
              return TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  GridView.builder(
                    padding: EdgeInsets.all(4),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder:(context, index){
                      ProductData data1 = ProductData.fromDocument(
                          snapshot.data!.docs[index] as DocumentSnapshot<Map<String, dynamic>>
                      );
                      data1.category = this.snapshot.id;
                      return ProductTile("grid",data1);
                    },
                  ),
                  ListView.builder(
                    padding: EdgeInsets.all(4),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder:(context, index){
                      ProductData data1 = ProductData.fromDocument(
                          snapshot.data!.docs[index] as DocumentSnapshot<Map<String, dynamic>>
                      );
                      data1.category = this.snapshot.id;
                      return ProductTile("list",data1);
                    },
                  )
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
