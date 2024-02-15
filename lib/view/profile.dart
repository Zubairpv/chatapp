import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/authsevice.dart';
import '../controller/database_service.dart';
import '../controller/shared_preference.dart';
import 'home.dart';
import 'search.dart';
import 'widgets.dart';
import 'package:path_provider/path_provider.dart';

String? url;

class Profilepage extends StatefulWidget {
 final String email;
 final String name;
 final String groupId;

  const Profilepage(
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
                  nextscreen(context, const Searchpage());
                },
                icon: const Icon(Icons.search))
          ],
          title: const Text('Profile')),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: [
            FutureBuilder<File?>(
              future: getProfileImage(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Icon(
                    Icons.error,
                    size: 160,
                  );
                } else if (snapshot.data != null) {
                  return CircleAvatar(
                    backgroundImage: FileImage(snapshot.data!),
                    radius: 80,
                  );
                } else {
                  return const Icon(
                    Icons.person,
                    size: 160,
                  );
                }
              },
            ),
            Text(
              widget.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ListTile(
              onTap: () {
                nextscreen(context, const MyHomePage());
              },
              leading: const Icon(Icons.group),
              contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              title: const Text(
                'Groups',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              onTap: () {},
              leading: const Icon(Icons.person),
              contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              title: const Text(
                'Profile',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () {},
              leading: const Icon(Icons.exit_to_app),
              contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              title: const Text(
                'logout',
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 170),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Pick'),
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
                                icon: const Icon(
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
                                icon: const Icon(
                                  Icons.photo_camera_back,
                                  size: 20,
                                )),
                            IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
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
                  : const Icon(
                      Icons.person,
                      size: 160,
                    ),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'fullname:',
                  style: TextStyle(fontSize: 17),
                ),
                Text(
                  widget.name,
                  style: const TextStyle(fontSize: 17),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Email:',
                  style: TextStyle(fontSize: 17),
                ),
                Text(
                  widget.email,
                  style: const TextStyle(fontSize: 17),
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
      debugPrint('Failed to pick image: $e');
    }
  }

  Future<File?> getProfileImage() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imageFile = File('${appDir.path}/profile/profile_image.jpg');

    return await imageFile.exists() ? imageFile : null;
  }
}
