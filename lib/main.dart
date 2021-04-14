
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:provider/provider.dart';

import 'auth_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
      ChangeNotifierProvider(
        create: (context) => AuthRepository.instance(),
        child: App(),
  ));
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        primaryColor: Colors.red,
      ),
      home: RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = generateWordPairs().take(10).toList();
  final _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18);

  Widget _buildSuggestions() {
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
          if(alreadySaved){
            _saved.remove(pair);
          }else {
            _saved.add(pair);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    AuthRepository rep = AuthRepository.instance();
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

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final tiles = _saved.map(
                (WordPair pair) {
              return ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
                trailing:
                Icon(
                    Icons.delete_outline
                ),
                onTap: (){
                  final snackBar = SnackBar(
                    content: Text('Deletion is not implemented yet'),
                  );

                  // Find the ScaffoldMessenger in the widget tree
                  // and use it to show a SnackBar.
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
              );
            },
          );
          final divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        }, // ...to here.
      ),
    );
  }

  void _navigateToLogin(){
    AuthRepository rep = AuthRepository.instance();
    if(rep.status == Status.Authenticated){
      rep.signOut();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          TextEditingController userName = TextEditingController();
          TextEditingController pass = TextEditingController();
          return Scaffold(
              appBar: AppBar(
                title: Text('Login'),
              ),
              body: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text("Welcome to Startup Names Generator, please log in below"),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Email',
                    ),
                    controller: userName,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Password'
                    ),
                    controller: pass,
                  ),
                  SizedBox(height: 10),
                  Consumer<AuthRepository>(
                      builder: (context, rep, _) {
                        String text = "log in";
                        if(rep.status == Status.Authenticating){
                            return Container(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                              ),
                              padding: const EdgeInsets.fromLTRB(
                                  135.0,
                                  0.0,
                                  135.0,
                                  0.0
                              ),
                            );
                        }
                        if(rep.status == Status.Authenticated) text = "logged in";
                        return Container(
                            child: TextButton(
                                child: Text(text, style: TextStyle(color: Colors.white),),
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(18.0),
                                            side: BorderSide(color: Colors.red)
                                        )
                                    )
                                ),
                                onPressed: ()  {
                                  rep.signIn(userName.text, pass.text).then((value) {
                                    if(value == false){
                                      final snackBar = SnackBar(
                                        content: Text('There was an error logging into the app'),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    }else{
                                      Navigator.pop(context);
                                    }
                                  }
                                  );
                                }
                            ),
                          );
                        }
                  ),
                ],
              )
          );
        },
      ),
    );
  }
}


class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
      setState(() {});
    });
    controller.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CircularProgressIndicator(
              value: controller.value,
              semanticsLabel: 'Linear progress indicator',
            ),
          ],
        ),
      ),
    );
  }
}

