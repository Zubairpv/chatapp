import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class Voicetile extends StatefulWidget {
  final String url;
  final String sender;
  final bool sentByMe;
  const Voicetile({
    Key? key,
    required this.url,
    required this.sender,
    required this.sentByMe,
  }) : super(key: key);

  @override
  State<Voicetile> createState() => _VoicetileState();
}

class _VoicetileState extends State<Voicetile> {
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Future play() async {
    try {
      audioPlayer.setUrl(widget.url);

      setState(() {
        isPlaying = true;
      });
      audioPlayer.play().whenComplete(() {
        setState(() {
          isPlaying = false;
        });
      });
    } catch (e) {
      debugPrint('error$e');
    }
  }

  Future pause() async {
    try {
      audioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: widget.sentByMe ? 0 : 24,
          right: widget.sentByMe ? 24 : 0),
      alignment: widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: widget.sentByMe
            ? const EdgeInsets.only(left: 30)
            : const EdgeInsets.only(right: 30),
        padding:
            const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
        decoration: BoxDecoration(
            borderRadius: widget.sentByMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
            color: widget.sentByMe
                ? Theme.of(context).primaryColor
                : Colors.grey[700]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.sender.toUpperCase(),
              textAlign: TextAlign.start,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5),
            ),
            const SizedBox(
              height: 8,
            ),
            IconButton(
                onPressed: () {
                  audioPlayer.playerState.playing ? pause() : play();
                },
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow)),
          ],
        ),
      ),
    );
  }
}
