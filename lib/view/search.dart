import 'package:chatt_app/view/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../controller/database_service.dart';
import '../controller/shared_preference.dart';
import 'chatpage.dart';

class Searchpage extends StatefulWidget {
  const Searchpage({super.key});

  @override
  State<Searchpage> createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  QuerySnapshot? searchSnapshot;
  bool hasSearch = false;
  bool isLoading = false;
  bool isJoined = false;
  TextEditingController searchcontroller = TextEditingController();
  String userName = '';
  User? user;
  @override
  void initState() {
    super.initState();
    getCurrentUserIdAndName();
  }

  String getname(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  getid(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  getCurrentUserIdAndName() async {
    await Shared.getname().then((value) {
      setState(() {
        userName = value!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Search',
          style: TextStyle(
              fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: searchcontroller,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search for groups...',
                      hintStyle: TextStyle(color: Colors.white, fontSize: 16)),
                )),
                InkWell(
                  onTap: () {
                    debugPrint("a$hasSearch");
                    inisiateSearchMethod();
                    debugPrint(hasSearch.toString());
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: Colors.white.withOpacity(0.1)),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                )
              : groupList()
        ],
      ),
    );
  }

  inisiateSearchMethod() async {
    if (searchcontroller.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      await Databaseservice(FirebaseAuth.instance.currentUser!.uid)
          .searchByName(searchcontroller.text)
          .then((snapshot) {
        setState(() {
          searchSnapshot = snapshot;
          isLoading = false;
          hasSearch = true;
        });
      });
    }
  }

  groupList() {
    if (hasSearch == true) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: searchSnapshot!.docs.length,
        itemBuilder: (context, index) {
          return groupTile(
              userName,
              searchSnapshot!.docs[index]['groupId'],
              searchSnapshot!.docs[index]['groupName'],
              searchSnapshot!.docs[index]['admin']);
        },
      );
    } else {
      return const Text('');
    }
  }

  joinedOrNot(
      String userName, String groupId, String groupname, String admin) async {
    await Databaseservice(FirebaseAuth.instance.currentUser!.uid)
        .isUserJoined(groupname, groupId, userName)
        .then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }

  Widget groupTile(
      String userName, String groupId, String groupName, String admin) {
    joinedOrNot(userName, groupId, groupName, admin);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      leading: CircleAvatar(
        radius: 30,

        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          groupName.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ), // Text
      ), // CircleAvatar
      title: Text(
        'Group name:$groupName',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text("Admin: ${getname(admin)}"),
      trailing: InkWell(
          onTap: () async {
            final a = showsnackbar(
                context, Colors.green, "Successfully joined he group");
            await Databaseservice(FirebaseAuth.instance.currentUser!.uid)
                .toggleGroupJoin(groupId, userName, groupName);
            if (isJoined) {
              setState(() {
                isJoined = !isJoined;
              });
              a;
              Future.delayed(const Duration(seconds: 2), () {
                nextscreen(
                    context,
                    ChatPage(
                        groupId: groupId,
                        groupName: groupName,
                        userName: userName));
              });
            } else {
              setState(() {
                isJoined = !isJoined;
                showsnackbar(context, Colors.red, "Left the group $groupName");
              });
            }
          },
          child: isJoined
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1)),
                  child: const Text(
                    'Joined',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1)),
                  child: const Text(
                    'Join',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
    ); // ListTile
  }
}
