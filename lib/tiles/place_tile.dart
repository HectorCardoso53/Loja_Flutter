import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceTile extends StatelessWidget {
  final DocumentSnapshot snapshot;

  PlaceTile(this.snapshot);

  @override
  Widget build(BuildContext context) {
    // Verifique se os dados estão presentes e são do tipo Map<String, dynamic>
    var data = snapshot.data() as Map<String, dynamic>?;

    // Log para verificar se os dados foram carregados corretamente
    print("Dados do snapshot: $data");

    // Trate o caso em que os dados podem ser nulos
    if (data == null) {
      return Center(
        child: Text('Dados não disponíveis'),
      ); // Exibe uma mensagem se os dados forem nulos
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 100,
            child: Image.network(
              data["image"] ?? '', // Usa uma string vazia como fallback
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(child: Icon(Icons.error));
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data["title"] ?? 'Título não disponível',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                Text(
                  data["address"] ?? 'Endereço não disponível',
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  final Uri location = Uri.parse(
                      'https://www.google.com/maps/search/?api=1&query=${data["lat"]},${data["long"]}');
                  launchUrl(location);
                },
                child: Text(
                  "Ver no Mapa",
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ),
              SizedBox(width: 10,),
              ElevatedButton(
                onPressed: () {
                  final Uri phoneUri = Uri.parse('tel:${data['phone']}');
                  launchUrl(phoneUri);
                },
                child: Text(
                  "Ligar",
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
