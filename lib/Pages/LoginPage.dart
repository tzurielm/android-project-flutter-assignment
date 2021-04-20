import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Firebase/FirebaseHelper.dart';
import '../Firebase/auth_repository.dart';

class LoginPage extends StatefulWidget {
  Set<WordPair> saved = {};

  LoginPage(this.saved);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController userName = TextEditingController();
  TextEditingController pass = TextEditingController();

  Widget waitingConnectionWidget(Color color){
    return Container(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
      padding: const EdgeInsets.fromLTRB(
          137.0,
          0.0,
          137.0,
          0.0
      ),
    );
  }

  Widget loginButtonWidget(AuthRepository rep){
    return Container(
      child: TextButton(
          child: Text("log in", style: TextStyle(color: Colors.white),),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.red.shade800),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.red.shade800)
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
                  if(rep.status == Status.Authenticating){
                    return waitingConnectionWidget(Colors.red.shade800);
                  }else{
                    return loginButtonWidget(rep);
                  }
                }
            ),
            TextButton(
                child: Text("New user? Click to sign up", style: TextStyle(color: Colors.white),),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.teal),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.teal)
                        )
                    )
                ),
              onPressed:() {
                  showBottomSheet();
              },
            )
          ],
        )
    );
  }

  void showBottomSheet(){
    TextEditingController newPassword = TextEditingController();
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 5),
                    Text("Please confirm your password below:"),
                    Divider(),
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Password'
                      ),
                      controller: newPassword,
                    ),
                    Divider(),
                    SizedBox(height: 5),
                    SizedBox(
                      height: 40,
                      width: 95,
                      child: Consumer<AuthRepository>(
                          builder: (context, rep, _) {
                            if(rep.status == Status.Authenticating){
                              return waitingConnectionWidget(Colors.teal);
                            }else{
                              return TextButton(
                                  child: Text("Confirm", style: TextStyle(color: Colors.white),),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(Colors.teal),
                                  ),
                                  onPressed:() {
                                    if ( newPassword.text != pass.text ){
                                      final snackBar = SnackBar(
                                        content: Text('Passwords must match'),
                                      );
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                      return;
                                    }
                                    var rep = AuthRepository.instance();
                                    rep.signUp(userName.text, pass.text).then((value) {
                                      if(!rep.isAuthenticated){
                                        final snackBar = SnackBar(
                                          content: Text('There was an error Signing into the app'),
                                        );
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                      }else{
                                        FirebaseHelper().createNewUser(userName.text, newPassword.text);
                                        FirebaseHelper().backupSaved(widget.saved);
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      }
                                    }
                                    );
                                  }
                              );
                            }
                          }
                      )
                    )
                  ],
                ),
              )
            )
          );
        }
    );
  }

}
