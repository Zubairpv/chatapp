import 'dart:io';
import 'package:chatt_app/controller/shared_preference.dart';
import 'package:chatt_app/view/voicetile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controller/database_service.dart';
import 'groupinfo.dart';
import 'messegetile.dart';
import 'widgets.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  const ChatPage(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.userName})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  String admin = "";

  int i = 0;
  FlutterSoundRecorder recorder = FlutterSoundRecorder();
  bool isRecording = false;

  Future<void> startRecording() async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      return;
    }
    Permission.microphone.request();
    if (await Permission.microphone.request().isGranted) {
      try {
        await recorder.openRecorder();
        await recorder.startRecorder(toFile: '/sdcard/Download/$i.wav');
        setState(() {
          isRecording = true;
        });
      } catch (err) {
        debugPrint('Error: $err');
      }
    } else {
      Permission.microphone.request();
      debugPrint('Microphone permission not granted');
    }
  }

  Future<void> stopRecording() async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      return;
    } else {
      try {
        await recorder.stopRecorder();
        await recorder.closeRecorder();
        final storage = FirebaseStorage.instance;
        final ref = storage.ref().child(
            'voice_messages/${DateTime.now().millisecondsSinceEpoch}.wav');
        final task = ref.putFile(File('/sdcard/Download/$i.wav'));
        final snapshot = await task.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        Map<String, dynamic> chatMessageMap = {
          "url": downloadUrl,
          "sender": widget.userName,
          "time": DateTime.now().millisecondsSinceEpoch,
          "messegeType": 'voice'
        };

        Databaseservice(FirebaseAuth.instance.currentUser!.uid)
            .sendMessage(widget.groupId, chatMessageMap);

        setState(() {
          isRecording = false;
          i++;
          Shared.savefile1(i);
        });
      } catch (err) {
        debugPrint('Error: $err');
      }
    }
  }

  @override
  void initState() {
    getChatandAdmin();
    Shared.getFile().then((value) {
      setState(() {
        i = value!;
      });
    });
    super.initState();
  }

  getChatandAdmin() {
    Databaseservice(FirebaseAuth.instance.currentUser!.uid)
        .getChats(widget.groupId)
        .then((val) {
      setState(() {
        chats = val;
      });
    });
    Databaseservice(FirebaseAuth.instance.currentUser!.uid)
        .getGroupAdmin(widget.groupId)
        .then((val) {
      setState(() {
        admin = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupName),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
              onPressed: () {
                nextscreen(
                    context,
                    Groupinfo(
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                      adminName: admin,
                      userName: widget.userName,
                    ));
              },
              icon: const Icon(Icons.info))
        ],
      ),
      body: Stack(
        children: <Widget>[    
          SizedBox(
            height: size.height * 0.79,
            width: size.width,
            child: chatMessages(),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[700],
              child: Row(children: [
                Expanded(
                    child: TextFormField(
                  controller: messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: isRecording ? "recording" : "Send a message...",
                    hintStyle: const TextStyle(color: Colors.white, fontSize: 16),
                    border: InputBorder.none,
                  ),
                )),
                const SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  onTap: () {
                    isRecording ? stopRecording() : startRecording();
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                        child: Icon(
                      isRecording ? Icons.send : Icons.mic,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    )),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    sendMessage();
                  
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                        child: Icon(
                      Icons.send,
                      color: Colors.white,
                    )),
                  ),
                )
              ]),
            ),
          )
        ],
      ),
    );
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  if (snapshot.data.docs[index]['messegeType'] == 'voice') {
                    return Voicetile(
                      url: snapshot.data.docs[index]['url'],
                      sender: snapshot.data.docs[index]['sender'],
                      sentByMe: widget.userName ==
                          snapshot.data.docs[index]['sender'],
                    );
                  } else {
                    return MessageTile(
                      message: snapshot.data.docs[index]['message'],
                      sender: snapshot.data.docs[index]['sender'],
                      sentByMe: widget.userName ==
                          snapshot.data.docs[index]['sender'],
                    );
                  }
                },
              )
            : Container();
      },
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
        "messegeType": 'text'
      };

      Databaseservice(FirebaseAuth.instance.currentUser!.uid)
          .sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }
}
