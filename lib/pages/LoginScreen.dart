import 'package:flutter/material.dart';
import 'package:flutter_message_app/pages/TabBar.dart';
import 'package:flutter_message_app/pages/UserList.dart';
import 'package:flutter_message_app/socket/SocketService.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  String loggedInUsername = '';
  String loggedInPassword = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    // final socket = socketService.socket;
    return Scaffold(
      appBar: AppBar(
        title: Text('LogIn'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a email';
                }
                if (!value.contains('@')) {
                  return 'Please enter the right format';
                }
                return null;
              },
            ),
            TextFormField(
              obscureText: _showPassword,
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(
                      () {
                        _showPassword = !_showPassword;
                      },
                    );
                  },
                  icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                // if (value.length < 6) {
                //   return 'Password is at least 6 characters';
                // }
                return null;
              },
            ),
            // ElevatedButton(
            //   onPressed: (() {
            //     if (_formKey.currentState!.validate()) {
            //       socketService.emit('SignIn', {
            //         'email': _emailController.text,
            //         'password': _passwordController.text
            //       });
            //       print('SignInCon is called');
            //       socketService.on('SignInCon', (data) {
            //         print('recieve SignInConfirm event');
            //         if (data['username'] != null) {
            //           print('go to user list page');
            //           Navigator.of(context).pushReplacementNamed('/userList');
            //         } else {
            //           print('show error dialog');
            //           final snackBar = SnackBar(
            //             content:
            //                 const Text('Email or password is not correct!'),
            //             action: SnackBarAction(
            //               label: 'Undo',
            //               onPressed: () {
            //                 // Some code to undo the change.
            //               },
            //             ),
            //           );
            //           ScaffoldMessenger.of(context).showSnackBar(snackBar);
            //         }
            //       });
            //     }
            //   }),
            //   child: Text('Login'),
            // ),
            ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    print('run into sign in emit');

                    socketService.emit('SignIn', {
                      'email': _emailController.text,
                      'password': _passwordController.text,
                    });
                    socketService.on('SignInCon', (data) {
                      // print('return: ' + data['check']);
                      // setState(() {
                      if (data['check'] == true) {
                        print('go to user list');
                        loggedInUsername = _emailController.text;
                        loggedInPassword = _passwordController.text;
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyTabBar(
                                  loggedInUsername: loggedInUsername,
                                  loggedInPassword: loggedInPassword),
                            ));
                      } else {
                        print('show error dialog');
                        final snackBar = SnackBar(
                          content: const Text('Email or password is wrong!'),
                          duration: Duration(seconds: 5),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              // Some code to undo the change.
                            },
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                      // });
                    });
                  }
                },
                child: Text('Log in'))
          ],
        ),
      ),
    );
  }
}
