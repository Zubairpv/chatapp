import 'package:chatt_app/home.dart';
import 'package:chatt_app/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'database_service.dart';

class Groupinfo extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String adminName;
  const Groupinfo(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.adminName});

  @override
  State<Groupinfo> createState() => _GroupinfoState();
}

class _GroupinfoState extends State<Groupinfo> {
  Stream? members;
  @override
  void initState() {
    getmembers();
    super.initState();
  }

  getmembers() {
    Databaseservice(FirebaseAuth.instance.currentUser!.uid)
        .getGroupMembers(widget.groupId)
        .then((val) {
      setState(() {
        members = val;
      });
    });
  }

  String getname(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  getid(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text('Group info'),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Exit'),
                          content: Text('Are you sure exit the group?'),
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
                                onPressed: () async {
                                  Databaseservice(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .toggleGroupJoin(
                                          widget.groupId,
                                          getname(widget.adminName),
                                          widget.groupName)
                                      .whenComplete(() => nextscreenreplace(
                                          context, MyHomePage()));
                                },
                                child: Text(
                                  'ok',
                                  style: TextStyle(fontSize: 20),
                                )),
                          ],
                        );
                      });
                },
                icon: Icon(Icons.exit_to_app))
          ],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).primaryColor.withOpacity(0.2)),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        widget.groupName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Group:${widget.groupName}'),
                        SizedBox(
                          height: 5,
                        ),
                        Text('Admin:${getname(widget.adminName)}')
                      ],
                    )
                  ],
                ),
              ),
              memberlist()
            ],
          ),
        ));
  }

  memberlist() {
    return StreamBuilder(
      stream: members,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['members'] != null) {
            if (snapshot.data['members'].length != 0) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data['members'].length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: ListTile(
                      onTap: () {
                        print(snapshot.data['members'].length);
                      },
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          getname(snapshot.data['members'][index])
                              .substring(0, 2)
                              .toUpperCase(),
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      title: Text(getname(snapshot.data['members'][index])),
                      subtitle: Text(getid(snapshot.data['members'][index])),
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: Text('no members'),
              );
            }
          } else {
            return Center(
              child: Text('no members'),
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        }
      },
    );
  }
}
