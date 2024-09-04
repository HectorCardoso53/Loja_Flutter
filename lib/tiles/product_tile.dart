import 'package:flutter/material.dart';
import 'package:loja_compras/datas/product_data.dart';

import '../screens/product_screen.dart';

class ProductTile extends StatelessWidget {
  final String type;
  final ProductData product;

  ProductTile(this.type, this.product);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder:(context)=>ProductScreen(product)));
      },
      child: Card(
        child: type == "grid"
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 0.8,
                    child: Image.network(
                      // Verifica se a lista de imagens não é nula e se tem ao menos uma imagem
                      product.images != null && product.images!.isNotEmpty
                          ? product.images![0]
                          : 'https://via.placeholder.com/150',
                      // URL de uma imagem padrão
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            // Se o título for nulo, exibe uma string padrão
                            product.title ?? 'Sem título',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            // Tratar caso o preço seja nulo
                            "R\$ ${(product.price ?? 0.0).toStringAsFixed(2)}",
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: Image.network(
                      // Verifica se a lista de imagens não é nula e se tem ao menos uma imagem
                      product.images != null && product.images!.isNotEmpty
                          ? product.images![0]
                          : 'https://via.placeholder.com/150',
                      // URL de uma imagem padrão
                      fit: BoxFit.cover,
                      height: 250,
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            // Se o título for nulo, exibe uma string padrão
                            product.title ?? 'Sem título',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            // Tratar caso o preço seja nulo
                            "R\$ ${(product.price ?? 0.0).toStringAsFixed(2)}",
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ), // Implementar lógica para o tipo 'row' caso necessário
      ),
    );
  }
}
