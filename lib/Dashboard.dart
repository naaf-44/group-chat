import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:group_chat/DatabaseHelper.dart';
import 'package:group_chat/main.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  final String email;

  Dashboard({Key key, @required this.email}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState(email);
}

class _DashboardState extends State<Dashboard> {
  final String email;

  _DashboardState(this.email);

  bool hasText = false;
  final textController = TextEditingController();

  Color themeColor = Colors.blue;

  final databaseReference = Firestore.instance;

  List<String> itemID = List();
  List<String> itemMessage = List();
  List<String> itemFrom = List();
  List<String> itemDisplayname = List();
  List<String> itemDate = List();
  List<String> itemTime = List();
  List<String> itemDisplayDate = List();

  final scrollController = ScrollController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    //getAllText();
    listenForMessage();
  }

  @override
  Widget build(BuildContext context) {
    double fullWidth = MediaQuery.of(context).size.width;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //print("scroll ${scrollController.position.maxScrollExtent}");
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });

    return WillPopScope(
      onWillPop: () => exit(0),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: themeColor,
          title: Text("Group Chat"),
          actions: [
            isLoading
                ? Container(
                    child: SpinKitDoubleBounce(
                      color: Colors.white,
                    ),
                  )
                : SizedBox(
                    width: 0,
                  ),
            PopupMenuButton<String>(
              onSelected: handleClick,
              itemBuilder: (BuildContext context) {
                return {'Logout'}.map(
                  (String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Row(
                        children: [
                          Text(
                            choice,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  },
                ).toList();
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            children: [
              Visibility(
                visible: itemID.length == 0 ? true : false,
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Text("Start new conversation"),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: itemID.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        itemDisplayDate[index] == ""
                            ? Container()
                            : Column(
                                children: [
                                  SizedBox(
                                    height: index == 0 ? 0 : 20,
                                  ),
                                  Text(
                                    itemDisplayDate[index],
                                    style: TextStyle(
                                      color: themeColor,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                ],
                              ),
                        itemFrom[index].toString() == email
                            ? Row(
                                children: [
                                  Spacer(),
                                  displayMessage(index, fullWidth)
                                ],
                              )
                            : Row(
                                children: [
                                  displayMessage(index, fullWidth),
                                ],
                              )
                      ],
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(5),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        //padding: EdgeInsets.all(5),
                        child: TextFormField(
                          onChanged: (data) {
                            if (data.length > 0) {
                              setState(() {
                                hasText = true;
                              });
                            } else {
                              setState(() {
                                hasText = false;
                              });
                            }
                          },
                          controller: textController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(color: themeColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(color: themeColor),
                            ),
                            filled: true,
                            prefixIcon: Icon(
                              Icons.message,
                              color: themeColor,
                            ),
                            labelText: "Type....",
                            labelStyle: TextStyle(color: themeColor),
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    hasText
                        ? Container(
                            width: 60,
                            height: 60,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: themeColor),
                              borderRadius: BorderRadius.all(
                                Radius.circular(100),
                              ),
                            ),
                            child: IconButton(
                                icon: Icon(
                                  Icons.send,
                                  color: themeColor,
                                ),
                                onPressed: () {
                                  if (textController.text.isNotEmpty) {
                                    String textMessage =
                                        textController.text.toString();
                                    setState(() {
                                      textController.clear();
                                      hasText = false;
                                    });
                                    sendMessage(textMessage);
                                  }
                                }),
                          )
                        : Container(
                            width: 0,
                          )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void handleClick(String value) {
    switch (value) {
      case 'Logout':
        final databaseHelper = DatabaseHelper.instance;
        databaseHelper.deleteUserData();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyApp(),
          ),
        );
        break;
    }
  }

  Future<void> sendMessage(String textMessage) async {
    //String key = (DateTime.now().millisecondsSinceEpoch).toString();
    String date = DateFormat('dd/MM/yyyy').format(DateTime.now());
    String time = DateFormat('HH:mm:ss').format(DateTime.now());

    DocumentReference documentReference = await databaseReference
        .collection("Messages")
        .add({
      "From": email,
      "Message": textMessage,
      "Date": date,
      "Time": time
    });
    print(documentReference.documentID);
  }

  // this function is not used
  void getAllText() {
    setState(() {
      isLoading = true;
    });
    itemID.clear();
    itemFrom.clear();
    itemDisplayname.clear();
    itemDate.clear();
    itemTime.clear();
    itemMessage.clear();

    databaseReference
        .collection("Messages")
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) {
        //print('${f.data}}');
        //print('${f.documentID}');

        setData(
            f.documentID.toString(),
            f.data['From'].toString(),
            f.data['Date'].toString(),
            f.data['Time'].toString(),
            f.data['Message'].toString());
      });
    });
  }

  void listenForMessage() {
    CollectionReference reference = Firestore.instance.collection('Messages');
    reference.snapshots().listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((change) {
        //print("Data is ${change.document.data}");
        setData(
            change.document.documentID.toString(),
            change.document.data['From'].toString(),
            change.document.data['Date'].toString(),
            change.document.data['Time'].toString(),
            change.document.data['Message'].toString());
      });
    });
  }

  void setData(String documentID, String from, String date, String time,
      String message) {
    setState(() {
      itemID.add(documentID);
      itemFrom.add(from);
      itemDate.add(date);
      itemTime.add(time);
      itemMessage.add(message);

      if (itemDisplayDate.contains(date)) {
        itemDisplayDate.add("");
      } else {
        itemDisplayDate.add(date);
      }

      String tempFrom = from;
      int i = 0;
      while (tempFrom[i] != "@") {
        i++;
      }
      String display = from.substring(0, i);
      itemDisplayname.add(display);

      isLoading = false;
    });
  }

  Widget displayMessage(int index, double fullWidth) {
    return Container(
      width: fullWidth - (fullWidth / 4) - 50,
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Column(
        children: [
          itemFrom[index] != email
              ? Container(
                  margin: EdgeInsets.only(bottom: 3),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      itemDisplayname[index],
                      style: TextStyle(
                          fontWeight: FontWeight.w500, color: themeColor),
                    ),
                  ),
                )
              : SizedBox(
                  height: 0,
                ),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              itemMessage[index],
            ),
          ),
          SizedBox(height: 5),
          timeWidget(index),
        ],
      ),
    );
  }

  Widget timeWidget(int index) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Text(
        itemTime[index].substring(0, 5),
        textAlign: TextAlign.end,
        style: TextStyle(color: Colors.blue, fontSize: 10),
      ),
    );
  }
}
