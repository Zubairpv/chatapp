import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/authsevice.dart';
import '../controller/database_service.dart';
import '../controller/shared preference.dart';
import 'home.dart';
import 'search.dart';
import 'widgets.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

String? url;

class Profilepage extends StatefulWidget {
  String email;
  String name;
  String groupId;

  Profilepage(
      {super.key,
      required this.email,
      required this.name,
      required this.groupId});

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  AuthService authService = AuthService();
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
          title: const Text('Profile')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 50),
          children: [
            FutureBuilder<File?>(
              future: getProfileImage(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Icon(
                    Icons.error,
                    size: 160,
                  );
                } else if (snapshot.data != null) {
                  return CircleAvatar(
                    backgroundImage: FileImage(snapshot.data!),
                    radius: 80,
                  );
                } else {
                  return Icon(
                    Icons.person,
                    size: 160,
                  );
                }
              },
            ),
            Text(
              widget.name,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ListTile(
              onTap: () {
                nextscreen(context, MyHomePage());
              },
              leading: Icon(Icons.group),
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              title: Text(
                'Groups',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              onTap: () {},
              leading: Icon(Icons.person),
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              title: Text(
                'Profile',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () {},
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
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 170),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Pick'),
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                                onPressed: () {
                                  pickImage(ImageSource.camera)
                                      .whenComplete(() {
                                    Navigator.pop(context);
                                    Databaseservice(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .upadateprofile(image!)
                                        .whenComplete(() async {
                                      QuerySnapshot snapshot =
                                          await Databaseservice(FirebaseAuth
                                                  .instance.currentUser!.uid)
                                              .gettingUserData(widget.email);
                                      setState(() {
                                        url = snapshot.docs[0]['profilePic'];
                                        Shared.saveprofile(url!);
                                      });
                                    });
                                  });
                                },
                                icon: Icon(
                                  Icons.camera,
                                  size: 20,
                                )),
                            IconButton(
                                onPressed: () {
                                  pickImage(ImageSource.gallery)
                                      .whenComplete(() {
                                    Navigator.pop(context);
                                    Databaseservice(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .upadateprofile(image!)
                                        .whenComplete(() async {
                                      QuerySnapshot snapshot =
                                          await Databaseservice(FirebaseAuth
                                                  .instance.currentUser!.uid)
                                              .gettingUserData(widget.email);
                                      setState(() {
                                        url = snapshot.docs[0]['profilePic'];
                                        Shared.saveprofile(url!);
                                      });
                                    });
                                  });
                                },
                                icon: Icon(
                                  Icons.photo_camera_back,
                                  size: 20,
                                )),
                            IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.exit_to_app,
                                  size: 20,
                                ))
                          ],
                        ),
                      );
                    });
              },
              child: url != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(url!),
                      radius: 80,
                    )
                  : Icon(
                      Icons.person,
                      size: 160,
                    ),
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'fullname:',
                  style: TextStyle(fontSize: 17),
                ),
                Text(
                  widget.name,
                  style: TextStyle(fontSize: 17),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Email:',
                  style: TextStyle(fontSize: 17),
                ),
                Text(
                  widget.email,
                  style: TextStyle(fontSize: 17),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  File? image;

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final appDir = await getApplicationDocumentsDirectory();
      final profileDir = Directory('${appDir.path}/profile');
      await profileDir.create(recursive: true);

      final imageFile = File('${profileDir.path}/profile_image.jpg');
      await imageFile.writeAsBytes(await image.readAsBytes());

      setState(() => this.image = imageFile);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<File?> getProfileImage() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imageFile = File('${appDir.path}/profile/profile_image.jpg');

    return await imageFile.exists() ? imageFile : null;
  }
}
