import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  runApp(MyApp());
}

final ThemeData kIOSTheme = ThemeData(
    primarySwatch: Colors.orange,
    primaryColor: Colors.grey[100],
    primaryColorBrightness: Brightness.light);

final ThemeData kDefaultTheme = ThemeData(
    primarySwatch: Colors.purple, accentColor: Colors.orangeAccent[400]);

final googleSignin = GoogleSignIn();
final auth = FirebaseAuth.instance;

Future<Null> _ensureLoggedIn() async {
  GoogleSignInAccount user = googleSignin.currentUser;
  if (user == null) user = await googleSignin.signInSilently();
  if (user == null) user = await googleSignin.signIn();
  if (await auth.currentUser() == null) {
    GoogleSignInAuthentication credentials =
        await googleSignin.currentUser.authentication;
    await auth.signInWithCredential(GoogleAuthProvider.getCredential(
        idToken: credentials.idToken, accessToken: credentials.accessToken));
  }
}

_handleSubmitted(String text) async {
  await _ensureLoggedIn();
  _sendMessage(text: text);
}

void _sendMessage({String text, String imageUrl}) {
  Firestore.instance.collection("mensagens").add({
    "text": text,
    "imageUrl": imageUrl,
    "senderName": googleSignin.currentUser.displayName,
    "senderPhotoUrl": googleSignin.currentUser.photoUrl,
    "sendTime": DateTime.now()
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Chatzin",
      debugShowCheckedModeBanner: false,
      theme: Theme.of(context).platform == TargetPlatform.iOS
          ? kIOSTheme
          : kDefaultTheme,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Chat App"),
          centerTitle: true,
          elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0 : 4,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder(
                stream: Firestore.instance.collection("mensagens").snapshots(),
                builder: (context, snapshot) {
                  if (googleSignin.currentUser == null) _ensureLoggedIn();
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    default:
                      return ListView.builder(
                        reverse: true,
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          List r = snapshot.data.documents.reversed.toList();
                          r.sort((b, a) {
                            return a.data['sendTime']
                                .compareTo(b.data['sendTime']);
                          });
                          return ChatMessage(r[index].data);
                        },
                      );
                  }
                },
              ),
            ),
            Divider(
              height: 1,
            ),
            Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              child: TextComposer(),
            )
          ],
        ),
      ),
    );
  }
}

class TextComposer extends StatefulWidget {
  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  final _textController = TextEditingController();

  bool _isCompose = false;

  void _reset() {
    _textController.clear();
    setState(() {
      _isCompose = false;
    });
  }

  Future<File> _showOptions(BuildContext context) async {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: FlatButton(
                        child: Text(
                          "Galeria",
                          style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 20),
                        ),
                        onPressed: () {
                          Navigator.pop(context);

                          ImagePicker.pickImage(source: ImageSource.gallery)
                              .then((file) {
                            if (file == null) return;

                            setState(() {
                              return file.path;
                            });
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: FlatButton(
                        child: Text(
                          "Camera",
                          style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 20),
                        ),
                        onPressed: () {
                          ImagePicker.pickImage(source: ImageSource.camera)
                              .then((file) {
                            if (file == null) return;

                            setState(() {
                              return file.path;
                            });
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: Theme.of(context).platform == TargetPlatform.iOS
            ? BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[200])))
            : null,
        child: Row(
          children: <Widget>[
            Container(
              child: IconButton(
                  icon: Icon(Icons.photo_camera),
                  onPressed: () async {
                    await _ensureLoggedIn();
                    File image =
                        await ImagePicker.pickImage(source: ImageSource.camera);
                    if (image == null) return;
                    StorageUploadTask task = FirebaseStorage.instance
                        .ref()
                        .child(googleSignin.currentUser.id.toString() +
                            DateTime.now().millisecondsSinceEpoch.toString())
                        .putFile(image);
                    StorageTaskSnapshot taskSnapshot = await task.onComplete;
                    String url = await taskSnapshot.ref.getDownloadURL();
                    _sendMessage(imageUrl: url);
                  }),
            ),
            Expanded(
              child: TextField(
                decoration:
                    InputDecoration.collapsed(hintText: "Enviar uma mensagem"),
                onChanged: (text) {
                  setState(() {
                    _isCompose = text.length > 0;
                  });
                },
                onSubmitted: (text) {
                  _handleSubmitted(text);
                  _reset();
                },
                controller: _textController,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Theme.of(context).platform == TargetPlatform.iOS
                  ? CupertinoButton(
                      child: Text("Enviar"),
                      onPressed: _isCompose
                          ? () {
                              _handleSubmitted(_textController.text);
                              _reset();
                            }
                          : null,
                    )
                  : IconButton(
                      icon: Icon(Icons.send),
                      onPressed: _isCompose
                          ? () {
                              _handleSubmitted(_textController.text);
                              _reset();
                            }
                          : null,
                    ),
            )
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final Map<String, dynamic> data;

  ChatMessage(this.data);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          photoChat(data),
          Expanded(
            child: Column(
              crossAxisAlignment: data["senderName"] ==
                      (googleSignin.currentUser != null
                          ? googleSignin.currentUser.displayName
                          : null)
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: <Widget>[
                Text(data["senderName"],
                    style: Theme.of(context).textTheme.subhead),
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: data["imageUrl"] != null
                      ? Image.network(
                          data["imageUrl"],
                          width: 250,
                        )
                      : Text(data["text"]),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

Widget photoChat(Map<String, dynamic> data) {
  if (googleSignin.currentUser != null &&
      data["senderName"] == googleSignin.currentUser.displayName) {
    return Container();
  } else {
    return Container(
        margin: const EdgeInsets.only(right: 16),
        child: CircleAvatar(
          backgroundImage: NetworkImage(data["senderPhotoUrl"]),
        ));
  }
}
