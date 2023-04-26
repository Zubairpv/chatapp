import 'package:flutter/material.dart';

import 'chatpage.dart';
import 'widgets.dart';

class GroupTile extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;

  const GroupTile(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.userName});

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: ListTile(
        onTap: () {
          nextscreen(
              context,
              ChatPage(
                  groupId: widget.groupId,
                  groupName: widget.groupName,
                  userName: widget.userName));
        },
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            widget.groupName.substring(0, 1).toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
        title: Text(
          widget.groupName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "join the conversation as ${widget.userName}",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
