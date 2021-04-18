import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Firebase/FirebaseHelper.dart';
import '../Firebase/auth_repository.dart';
import 'LoginPage.dart';

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18);
  StreamController<WordPair> _controller = new StreamController<WordPair>.broadcast();

  Widget getSavedStream(bool isSavedList){
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseHelper().getSavedList(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if(snapshot.hasData){
            Map<String, dynamic> data = snapshot.data?.data() ?? {};
            _saved.clear();
            for( var word in data.values) {
              word = word.toList();
              var pair = new WordPair(word[0],word[1]);
              _saved.add(pair);
            }
          }
          if(isSavedList){
            return ListView(children: getDivided());
          }else {
            return WordsListBuilder();
          }
        }
    );
  }

  Widget WordsListBuilder(){
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd) {
            return Divider();
          }
          final int index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index]);
        }
    );
  }

  Widget _buildSuggestions() {
    return Consumer<AuthRepository>(
        builder: (context, rep, _) {
          if (AuthRepository.instance().isAuthenticated) {
            return getSavedStream(false);
          } else {
            return WordsListBuilder();
          }
        }
    );
  }

  Widget _buildRow(WordPair pair) {
    final alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: (){
        setState(() {
          Status status = AuthRepository.instance().status;
          if(alreadySaved){
            if(status == Status.Authenticated){
              FirebaseHelper().removeWord(pair);
            }
            _saved.remove(pair);
          }else {
            if(status == Status.Authenticated){
              FirebaseHelper().addWord(pair);
            }
            _saved.add(pair);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: Text('Startup Name Generator', style: TextStyle( fontSize: 17 ),),
        actions: [
          IconButton(icon: Icon(Icons.favorite), onPressed: _pushSaved),
          Consumer<AuthRepository>(
              builder: (context, rep, _) {
                return IconButton(icon: rep.status == Status.Authenticated ? Icon(Icons.exit_to_app) : Icon(Icons.login) , onPressed: _navigateToLogin);
              }
          )
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  List<Widget> getDivided(){
    final tiles = _saved.map(
          (WordPair pair) {
        return ListTile(
          title: Text(
            pair.asPascalCase,
            style: _biggerFont,
          ),
          trailing:
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: (){
              setState(() {
                if(AuthRepository.instance().status == Status.Authenticated){
                  FirebaseHelper().removeWord(pair);
                }else {
                  _controller.sink.add(pair);
                }
                _saved.remove(pair);
              });
            } ,
          ),
        );
      },
    );
    var divided;
    if(tiles.isEmpty){
      divided = tiles.toList();
    }else{
      divided = ListTile.divideTiles(
        context: context,
        tiles: tiles,
      ).toList();
    }
    return divided;
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
              appBar: AppBar(
                title: Text('Saved Suggestions'),
              ),
              body: AuthRepository.instance().status == Status.Authenticated ? getSavedStream(true) :
              StreamBuilder<WordPair>(
                  stream: _controller.stream,
                  builder: (BuildContext context, AsyncSnapshot<WordPair> snapshot) {
                    return ListView(children: getDivided());
                  }
              )
          );
        }, // ...to here.
      ),
    );
  }

  void _navigateToLogin(){
    AuthRepository rep = AuthRepository.instance();
    if(rep.isAuthenticated){
      rep.signOut();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return LoginPage(_saved);
        },
      ),
    );
  }
}

