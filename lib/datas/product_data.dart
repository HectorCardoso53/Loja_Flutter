import 'package:cloud_firestore/cloud_firestore.dart';

class ProductData {
  String category; // Categoria do produto
  String id; // ID do produto
  String title; // Título do produto
  List<String> images; // Imagens do produto
  List<String> sizes; // Tamanhos disponíveis
  String description; // Descrição do produto
  double price; // Preço do produto

  // Construtor com valores padrão para campos não nulos
  ProductData({
    this.category = '',
    this.id = '',
    this.title = '',
    this.images = const [],
    this.sizes = const [],
    this.description = '',
    this.price = 0.0,
  });

  ProductData.fromDocument(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : category = snapshot.data()?['category'] as String? ?? '',
        id = snapshot.id,
        title = snapshot.data()?['title'] as String? ?? '',
        description = snapshot.data()?['description'] as String? ?? '',
        price = (snapshot.data()?['price'] as num?)?.toDouble() ?? 0.0,
        images = List<String>.from(snapshot.data()?['images'] ?? []),
        sizes = List<String>.from(snapshot.data()?['sizes'] ?? []);

  // Converte o ProductData para um mapa (usado ao salvar dados no Firestore)
  Map<String, dynamic> toResumeMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
    };
  }
}
