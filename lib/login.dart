import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_chat/DatabaseHelper.dart';

import 'Dashboard.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();

  Color themeColor = Colors.blue;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final databaseReference = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => exit(0),
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text("Login"),
          automaticallyImplyLeading: false,
          backgroundColor: themeColor,
        ),
        body: Center(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 20),
                width: double.infinity,
                alignment: Alignment.center,
                child: Container(
                  margin: EdgeInsets.only(left: 10, top: 10, right: 10),
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/login_bg.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Spacer(),
              Container(
                margin:
                    EdgeInsets.only(left: 10, top: 0, right: 10, bottom: 10),
                padding: EdgeInsets.all(5),
                child: TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: themeColor,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: themeColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: themeColor),
                    ),
                    filled: true,
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: themeColor,
                    ),
                    labelText: "Email",
                    labelStyle: TextStyle(color: themeColor),
                    fillColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                // ignore: deprecated_member_use
                child: FlatButton(
                  color: themeColor,
                  child: Text(
                    "Login",
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                  onPressed: () async {
                    if (emailController.text.isEmpty) {
                      showSnackBar("Please enter the email address");
                    } else {
                      await databaseReference
                          .collection("Users")
                          .document(emailController.text.toString())
                          .setData({"Active": "1"});

                      final databaseHelper = DatabaseHelper.instance;
                      databaseHelper.deleteUserData();
                      Map<String, dynamic> row = {
                        DatabaseHelper.U_COL_USER:
                            emailController.text.toString()
                      };
                      final id = await databaseHelper.insertUserData(row);
                      print(id);

                      showSnackBar("Login successful");
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Dashboard(email: emailController.text.toString()),
                        ),
                      );
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  showSnackBar(message) {
    final snackBar = SnackBar(content: Text(message));
    scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
