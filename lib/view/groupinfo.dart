import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../controller/database_service.dart';
import 'home.dart';
import 'widgets.dart';

class Groupinfo extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String adminName;
  final String userName;
  const Groupinfo(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.adminName,
      required this.userName});

  @override
  State<Groupinfo> createState() => _GroupinfoState();
}

class _GroupinfoState extends State<Groupinfo> {
  Stream? members;
  Stream? profile;
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
          title: const Text('Group info'),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Exit'),
                          content: const Text('Are you sure exit the group?'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
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
                                          context, const MyHomePage()));
                                },
                                child: const Text(
                                  'ok',
                                  style: TextStyle(fontSize: 20),
                                )),
                          ],
                        );
                      });
                },
                icon: const Icon(Icons.exit_to_app))
          ],
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
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
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Group:${widget.groupName}'),
                        const SizedBox(
                          height: 5,
                        ),
                        Text('Admin:${getname(widget.adminName)}')
                      ],
                    )
                  ],
                ),
              ),
              memberList()
            ],
          ),
        ));
  }

  memberList() {
    return StreamBuilder(
      stream: members,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['members'] != null) {
            if (snapshot.data['members'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['members'].length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: ListTile(
                      leading: FutureBuilder<String>(
                        future: Databaseservice(
                                FirebaseAuth.instance.currentUser!.uid)
                            .profile(widget.groupId, index),
                        builder: (context, snapshott) {
                          if (snapshott.connectionState ==
                              ConnectionState.waiting) {
                            return const CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey,
                            );
                          } else if (snapshott.hasError ||
                              snapshott.data == null ||
                              snapshott.data!.isEmpty) {
                            return CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.red,
                              child: Text(
                                getname(snapshot.data['members'][index])
                                    .substring(0, 1)
                                    .toUpperCase(),
                              ),
                            );
                          } else {
                            return CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(snapshott.data!),
                            );
                          }
                        },
                      ),
                      title: Text(getname(snapshot.data['members'][index])),
                      subtitle: Text(getid(snapshot.data['members'][index])),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text("NO MEMBERS"),
              );
            }
          } else {
            return const Center(
              child: Text("NO MEMBERS"),
            );
          }
        } else {
          return Center(
              child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ));
        }
      },
    );
  }
}
