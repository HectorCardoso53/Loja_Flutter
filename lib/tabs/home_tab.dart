import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:transparent_image/transparent_image.dart';

class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget _buildBackground() => Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 211, 118, 130),
            Color.fromARGB(255, 253, 181, 168),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );

    return Stack(
      children: [
        _buildBackground(),
        CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "Novidades",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
              ),
            ),
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection("home")
                  .orderBy("pos")
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SliverToBoxAdapter(
                    child: Container(
                      height: 200,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  );
                } else {
                  print("Número de documentos recuperados: ${snapshot.data!.docs.length}");

                  return SliverToBoxAdapter(
                    child: StaggeredGrid.count(
                      crossAxisCount: 2, // Define quantas colunas a grade terá
                      mainAxisSpacing: 1.0,
                      crossAxisSpacing: 1.0,
                      children: List.generate(snapshot.data!.docs.length, (index) {
                        DocumentSnapshot doc = snapshot.data!.docs[index];

                        // Depuração: printar as informações de cada documento
                        print("Documento $index: ${doc.data()}");

                        return StaggeredGridTile.count(
                          crossAxisCellCount: doc['x'], // Largura do bloco
                          mainAxisCellCount: doc['y'], // Altura do bloco
                          child: FadeInImage.memoryNetwork(
                            placeholder: kTransparentImage,
                            image: doc['image'],
                            fit: BoxFit.cover,
                          ),
                        );
                      }),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
