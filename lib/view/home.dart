import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../controller/authsevice.dart';
import '../controller/database_service.dart';
import '../controller/shared preference.dart';
import 'grouptile.dart';
import 'login.dart';
import 'profile.dart';
import 'search.dart';
import 'widgets.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AuthService authService = AuthService();
  String name = '';
  String email = '';
  Stream? groups;
  bool isLoading = false;
  String groupName = '';

  @override
  void initState() {
    getuserdata();
    super.initState();
  }

  getid(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  getuserdata() async {
    await Shared.getname().then((value) {
      setState(() {
        name = value!;
      });
    });
    await Shared.getemail().then((value) {
      setState(() {
        email = value!;
      });
    });
    await Databaseservice(FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  nextscreen(context, Searchpage());
                },
                icon: Icon(Icons.search))
          ],
          title: const Text('Groups')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 50),
          children: [
            url != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(url!),
                    radius: 80,
                  )
                : Icon(
                    Icons.person,
                    size: 160,
                  ),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ListTile(
              onTap: () {},
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              leading: Icon(Icons.group),
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              title: Text(
                'Groups',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () {
                nextscreen(
                    context,
                    Profilepage(
                      email: email,
                      name: name, groupId: '',
                    ));
              },
              leading: Icon(Icons.person),
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              title: Text(
                'Profile',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Logout'),
                        content: Text('Are you sure?'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'cancel    ',
                                style: TextStyle(fontSize: 20),
                              )),
                          TextButton(
                              onPressed: () {
                                authService.signout();

                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: ((context) => Login())),
                                    (route) => false);
                              },
                              child: Text(
                                'ok',
                                style: TextStyle(fontSize: 20),
                              )),
                        ],
                      );
                    });
              },
              leading: Icon(Icons.exit_to_app),
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              title: Text(
                'logout',
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
      ),
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popuop(context);
        },
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  groupList() {
    return StreamBuilder(
        stream: groups,
        builder: ((context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data['groups'] != null) {
              if (snapshot.data['groups'].length != 0) {
                return ListView.builder(
                    itemCount: snapshot.data['groups'].length,
                    itemBuilder: (context, index) {
                      return GroupTile(
                          groupId: getid(snapshot.data['groups'][index]),
                          groupName: getName(snapshot.data['groups'][index]),
                          userName: snapshot.data["fullName"]);
                    });
              } else {
                return newGroupwidget();
              }
            } else {
              return newGroupwidget();
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

  popuop(context) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(
                  'Create a group',
                  textAlign: TextAlign.start,
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        : TextField(
                            onChanged: (value) {
                              setState(() {
                                groupName = value;
                              });
                            },
                            style: TextStyle(color: Colors.black),
                            decoration: textinputdecoration,
                          )
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (groups != "") {
                        isLoading = true;
                      }
                      Databaseservice(FirebaseAuth.instance.currentUser!.uid)
                          .createGroup(name, groupName)
                          .whenComplete(() {
                        isLoading = false;
                      });
                      Navigator.pop(context);
                      showsnackbar(
                          context, Colors.green, 'Group created Successfully.');
                    },
                    child: Text('Ok'),
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ],
              );
            },
          );
        });
  }

  newGroupwidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              popuop(context);
            },
            child: Icon(
              Icons.add_circle,
              color: Colors.grey,
              size: 75,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "you've not joined any group,tap on the add icon to create a group or also search from top seach button",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
