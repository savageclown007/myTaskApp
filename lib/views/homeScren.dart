import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mytask/config/config.dart';

class HomeScren extends StatefulWidget {
  HomeScren({Key key}) : super(key: key);

  @override
  _HomeScrenState createState() => _HomeScrenState();
}

class _HomeScrenState extends State<HomeScren> {
  final TextEditingController _taskController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User user;

  @override
  void initState() {
    _getUid();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showTaskDialoue();
          },
          child: Icon(
            Icons.add,
            color: Colors.black,
          ),
          elevation: 4,
          backgroundColor: primaryColor,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    _changeBrightness();
                  }),
              IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  })
            ],
          ),
        ),
        body: Container(
          child: StreamBuilder(
              stream: _db
                  .collection("users")
                  .doc(user.uid.toString())
                  .collection("tasks")
                  .orderBy("time", descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.docs.isNotEmpty) {
                    return ListView(
                      children:
                          snapshot.data.docs.map((DocumentSnapshot snaps) {
                        Map<String, dynamic> data =
                            snaps.data() as Map<String, dynamic>;
                        return ListTile(
                          
                          title: Card(child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(data["task"].toString(),style: TextStyle(color: Colors.white,fontSize: 20),),
                                IconButton(
                              icon: Icon(Icons.delete
                              ,color: Colors.white,),
                              onPressed: () {
                                _db
                                    .collection("users")
                                    .doc(user.uid.toString())
                                    .collection("tasks")
                                    .doc(snaps.id.toString())
                                    .delete();
                              },
                            ),

                              ],
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Colors.grey[700]
                          ),
                        
                        );
                      }).toList(),
                    );
                  } else {
                    return Container(
                      child: Center(
                        child: Image(image: AssetImage("assets/no_task.png")),
                      ),
                    );
                  }
                }

                return Container(
                  child: Center(
                    child: Image(image: AssetImage("assets/no_task.png")),
                  ),
                );
              }),
        ));
  }

  void _showTaskDialoue() {
    showDialog(
        context: context,
        builder: (ctx) {
          return SimpleDialog(
            title: Text("Add Task"),
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10),
                child: TextField(
                  controller: _taskController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Write your task here.",
                      labelText: "Task",
                      alignLabelWithHint: true,
                      labelStyle: TextStyle(
                        fontSize: 24.0,
                      )),
                  maxLines: 3,
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 10.0),
                        child: Text("Cancel"),
                      ),
                      style: TextButton.styleFrom(
                        primary: Colors.black,
                        backgroundColor: primaryColor,
                        onSurface: Colors.grey,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        String task = _taskController.text.trim();
                        User user = await FirebaseAuth.instance.currentUser;

                        _db
                            .collection('users')
                            .doc(user.uid.toString())
                            .collection('tasks')
                            .add({
                          "task": task,
                          "time": DateTime.now(),
                          "done": false,
                        });
                        _taskController.clear();
                        Navigator.of(ctx).pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 10.0),
                        child: Text("Add"),
                      ),
                      style: TextButton.styleFrom(
                        primary: Colors.black,
                        backgroundColor: primaryColor,
                        onSurface: Colors.grey,
                      ),
                    )
                  ],
                ),
              )
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          );
        });
  }

  void _getUid() async {
    User u = _auth.currentUser;
    setState(() {
      user = u;
    });
  }

  void _changeBrightness() {}
}
