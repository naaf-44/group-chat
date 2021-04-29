import 'package:flutter/material.dart';
import 'package:group_chat/Dashboard.dart';
import 'package:group_chat/DatabaseHelper.dart';
import 'package:group_chat/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Group Chat',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoaded = false;

  @override
  Widget build(BuildContext context) {
    double fullHeight = MediaQuery.of(context).size.height;

    if (!isLoaded) {
      isLoaded = true;
      checkDatabase();
    }
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 20),
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.only(
                    left: 10, top: fullHeight / 2 - 100, right: 10),
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/logo.png"),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Spacer(),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Text("A Group Chat Application"),
            )
          ],
        ),
      ),
    );
  }

  Future<void> checkDatabase() async {
    final databaseHelper = DatabaseHelper.instance;
    int row = await databaseHelper.userRowCount();
    if (row > 0) {
      final rowData = await databaseHelper.getUserData();
      var userData = rowData;
      String email = userData[0]['col_user'];
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Dashboard(email: email),
          ),
        );
      });
    } else {
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Login(),
          ),
        );
      });
    }
  }
}
