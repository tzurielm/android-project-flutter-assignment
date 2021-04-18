import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/auth_repository.dart';
import 'package:provider/provider.dart';

import 'FirebaseHelper.dart';

class LoginPage extends StatefulWidget {
  Set<WordPair> saved = {};

  LoginPage(this.saved);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController userName = TextEditingController();
  TextEditingController pass = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                          137.0,
                          0.0,
                          137.0,
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
                              FirebaseHelper().backupSaved(widget.saved);
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
  }
}
