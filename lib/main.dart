import 'dart:async';
import 'package:english_words/english_words.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/Pages/RandomWords.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'Firebase/auth_repository.dart';

import 'Pages/SnappingSheet.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
      ChangeNotifierProvider(
        create: (context) => AuthRepository.instance(),
        builder: (context, snapshot) {
          return App();
        }
  )
  );
}
class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Scaffold(
            body: Center(
                child: Text(snapshot.error.toString(),
                    textDirection: TextDirection.ltr)));
      }
      if (snapshot.connectionState == ConnectionState.done) {
        return MyApp();
      }
      return Center(child: CircularProgressIndicator());
        },
    );
  }
}

class MyApp extends StatelessWidget {
  final _suggestions = <WordPair>[];
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthRepository>(
        builder: (context, authRep, snapshot) {
          return MaterialApp(
            title: 'Startup Name Generator',
            theme: ThemeData(
              primaryColor: Colors.red.shade800,
            ),
            home: AuthRepository.instance().isAuthenticated ? MySnappingSheet(_suggestions) : RandomWords(SnappingSheetController(),_suggestions),
          );
        }
    );
  }
}


