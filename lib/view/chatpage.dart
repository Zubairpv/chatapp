import 'dart:io';
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
  bool isVoice = false;
  int i = 0;
  FlutterSoundRecorder recorder = FlutterSoundRecorder();
  bool isRecording = false;
  Future<void> startRecording() async {
    // Check for and request necessary permissions
    Permission.microphone.request();
    if (await Permission.microphone.request().isGranted) {
      // Permission is granted
      try {
        setState(() {
          i++;
        });
        await recorder.openRecorder();
        await recorder.startRecorder(toFile: '/sdcard/Download/$i.wav');
        setState(() {
          isRecording = true;
          isVoice = true;
        });
      } catch (err) {
        print('Error: $err');
      }
    } else {
      Permission.microphone.request();
      print('Microphone permission not granted');
    }
  }

  Future<void> stopRecording() async {
    try {
      await recorder.stopRecorder();
      await recorder.closeRecorder();
      final storage = FirebaseStorage.instance;
      final ref = storage
          .ref()
          .child('voice_messages/${DateTime.now().millisecondsSinceEpoch}.wav');
      final task = ref.putFile(File('/sdcard/Download/$i.wav'));
      final snapshot = await task.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      sendMessage(downloadUrl, 'voice');

      setState(() {
        isRecording = false;
        isVoice = false;
      });
    } catch (err) {
      print('Error: $err');
    }
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }

  @override
  void initState() {
    getChatandAdmin();
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
          // chat messages here
          chatMessages(),
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
                    hintStyle: TextStyle(color: Colors.white, fontSize: 16),
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
                      color: Color.fromARGB(255, 0, 0, 0),
                    )),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    sendMessage(messageController.text, 'text');
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
                  return MessageTile(
                    message: snapshot.data.docs[index]['message'],
                    sender: snapshot.data.docs[index]['sender'],
                    sentByMe:
                        widget.userName == snapshot.data.docs[index]['sender'],
                    isVoice: true,
                  );
                },
              )
            : Container();
      },
    );
  }

  sendMessage(String message, String type) {
    if (message.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": message,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
        "messegeType": type
      };

      Databaseservice(FirebaseAuth.instance.currentUser!.uid)
          .sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }
}
