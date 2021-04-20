import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'Firebase/FirebaseHelper.dart';
import 'Firebase/auth_repository.dart';

class SheetContent extends StatefulWidget {
  @override
  _SheetContentState createState() => _SheetContentState();
}

class _SheetContentState extends State<SheetContent> {
  String imageURL = "";
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    FirebaseStorage.instance
        .ref()
        .child("userAvatars/" + AuthRepository.instance().user!.uid)
        .getDownloadURL()
        .then(updateURL);
  }

  updateURL(String url) {
    imageURL = url;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            (imageURL == "") ?
            CircleAvatar(
              maxRadius: 50,
              backgroundColor: Colors.transparent,
            ) :
            CircleAvatar(
              maxRadius: 50,
              backgroundImage: NetworkImage(imageURL),
            ),
            SizedBox(width: 10),
            SingleChildScrollView(
              child: Column(
                children: [
                  Text(AuthRepository.instance().user!.email!, style: TextStyle(fontSize: 20),),
                  SizedBox(height: 10),
                  ElevatedButton(
                      child: Text("Change Avatar"),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.teal),
                        minimumSize: MaterialStateProperty.all<Size>(Size(140, 30)),
                      ),
                      onPressed: getImage
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      imageURL = await FirebaseHelper().uploadImage(File(pickedFile.path));
    } else {
      final snackBar = SnackBar(
        content: Text('No image selected'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    setState(() {});
  }
}