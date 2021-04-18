import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';

class FirebaseHelper{
  static final FirebaseHelper firebaseHelper = FirebaseHelper._internal();
  final docID = "tNPOoiMNFCne6eOvVqht";
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  factory FirebaseHelper() {
    return firebaseHelper;
  }
  FirebaseHelper._internal();

  Stream<DocumentSnapshot> getSavedList(){
    return _db.collection("users").doc(docID).snapshots();
  }

  Future<void> addWord(WordPair word) {
    return _db.collection("users").doc(docID).update({
      word.asPascalCase : [word.first, word.second]
    });
  }

  Future<void> removeWord(WordPair word){
    return _db.collection("users").doc(docID).update({
      word.asPascalCase: FieldValue.delete()
    });
  }

  void backupSaved(Set<WordPair> saved){
    saved.forEach((element) {
      addWord(element);
    });
  }
}