import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import 'auth_repository.dart';

class FirebaseHelper{
  static final FirebaseHelper firebaseHelper = FirebaseHelper._internal();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  factory FirebaseHelper() {
    return firebaseHelper;
  }
  FirebaseHelper._internal();

  Stream<DocumentSnapshot> getSavedList(){
    var docID = AuthRepository.instance().user!.uid;
    return _db.collection("users").doc(docID).snapshots();
  }

  Future<void> addWord(WordPair word) {
    var docID = AuthRepository.instance().user!.uid;
    return _db.collection("users").doc(docID).update({
      word.asPascalCase : [word.first, word.second]
    });
  }

  Future<void> removeWord(WordPair word){
    var docID = AuthRepository.instance().user!.uid;
    return _db.collection("users").doc(docID).update({
      word.asPascalCase: FieldValue.delete()
    });
  }

  void createNewUser( String email, String password){
    var docID = AuthRepository.instance().user!.uid;
    _db.collection("users")
    .doc(docID)
    .set({ "email" : email});
  }

  Future<String> getImageURL() async{
    FirebaseStorage storage = FirebaseStorage.instance;
    var url = await storage
        .ref()
        .child("userAvatars/" + AuthRepository.instance().user!.uid)
        .getDownloadURL();
    return url;
  }

  Future<String> uploadImage(File image) async{
    FirebaseStorage storage = FirebaseStorage.instance;
    TaskSnapshot uploadTask = await storage
        .ref()
        .child("userAvatars/" + AuthRepository.instance().user!.uid)
        .putFile(image);
    String url = await uploadTask.ref.getDownloadURL();
    return url;
/*    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("userAvatars/" + AuthRepository.instance().user!.uid);
    UploadTask uploadTask = ref.putFile(image);
    uploadTask.then((res) {
      return res.ref.getDownloadURL();
    });
    return "";*/
  }

  void backupSaved(Set<WordPair> saved){
    saved.forEach((element) {
      addWord(element);
    });
  }

}