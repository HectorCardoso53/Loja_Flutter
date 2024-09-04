import 'dart:ffi';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';

class UserModel extends Model {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User? firebaseUser; // Use 'User' em vez de 'FirebaseUser'

  Map<String, dynamic> userData = {};

  bool isLoading = false;

  static UserModel of(BuildContext context) => ScopedModel.of<UserModel>(context);

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);

    _loadCurrentUser();

  }

  void signUp({
    required Map<String, dynamic> userData,
    required String pass,
    required VoidCallback onSucess,
    required VoidCallback onFailed,
  }) {
    isLoading = true;
    notifyListeners();

    _auth.createUserWithEmailAndPassword(
      email: userData["email"],
      password: pass,
    ).then((userCredential) async {
      firebaseUser = userCredential.user;

      await _saveUserData(userData);

      onSucess();
      isLoading = false;
      notifyListeners();
    }).catchError((e) {
      onFailed();
      isLoading = false;
      notifyListeners();
    });
  }

  void signIn ({
    required String email,
    required String pass,
    required VoidCallback onSucces,
    required VoidCallback onFailed,
  }) async {
    isLoading = true;
    notifyListeners();

    _auth.signInWithEmailAndPassword(email: email, password: pass).then(
            (user) async {
      firebaseUser = user.user;

      await _loadCurrentUser();

      onSucces();
      isLoading = false;
      notifyListeners();
    }).catchError((e) {
      onFailed();
      isLoading = false;
      notifyListeners();
    });
  }

  void signOut()async{
    await _auth.signOut();

    userData = Map();
    firebaseUser = null;
    notifyListeners();
  }

  void recoverPass(String email) {
    // Implemente a recuperação de senha aqui
    _auth.sendPasswordResetEmail(email: email);
  }

  Future<Null> _saveUserData(Map<String, dynamic> userData) async {
    this.userData = userData;
    if (firebaseUser != null) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(firebaseUser!.uid)
          .set(userData);
    }
  }
  bool isLoggedIn(){
    return firebaseUser != null;
  }

  Future<Null> _loadCurrentUser() async {
    if (firebaseUser == null)
      firebaseUser = await _auth.currentUser;

    if (firebaseUser != null) {
      if (userData["name"] == null) {
        DocumentSnapshot docUser = await FirebaseFirestore.instance
            .collection("users")
            .doc(firebaseUser!.uid)
            .get();

        // Converte o retorno de data() para Map<String, dynamic>
        userData = docUser.data() as Map<String, dynamic>;
      }
    }
    notifyListeners();
  }

}
