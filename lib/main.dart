import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:loja_compras/moldes/cart_model.dart';
import 'package:loja_compras/moldes/user_model.dart';
import 'package:loja_compras/screens/home_screen.dart';
import 'package:loja_compras/screens/login_screen.dart';
import 'package:scoped_model/scoped_model.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Garante que a inicialização do Flutter esteja completa
  await Firebase.initializeApp(); // Inicializa o Firebase
  runApp(MyApp()); // Inicia o aplicativo
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModel<UserModel>(
      model: UserModel(),
      child: ScopedModelDescendant<UserModel>(
        builder: (context, child, model) {
          return ScopedModel(
            model: CartModel(model),
            child: MaterialApp(
              title: "Flutter'Clothing",
              theme: ThemeData(
                primarySwatch: Colors.blue,
                primaryColor: Color.fromARGB(255, 4, 125, 141),
              ),
              debugShowCheckedModeBanner: false,
              home: HomeScreen(),
            ),
          );
        },
      ),
    );
  }
}
