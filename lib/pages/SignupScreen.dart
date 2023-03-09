import 'package:flutter/material.dart';
import 'package:flutter_message_app/socket/SocketService.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  static const routeName = '/signup';
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    // final socket = socketService.socket;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign up'),
      ),
      body: Form(
        key: _formKey,
        child: Column(children: [
          TextFormField(
            controller: _userNameController,
            decoration: InputDecoration(labelText: "user name"),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a user name';
              }
              return null;
            },
          ),
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
          // TextFormField(
          //   obscureText: _showPassword,
          //   controller: _confirmPasswordController,
          //   decoration: InputDecoration(
          //     labelText: "Confirm password",
          //     suffixIcon: IconButton(
          //       onPressed: () {
          //         setState(
          //           () {
          //             _showPassword = !_showPassword;
          //           },
          //         );
          //       },
          //       icon: Icon(
          //           _showPassword ? Icons.visibility : Icons.visibility_off),
          //     ),
          //   ),
          //   validator: (value) {
          //     if (value == null || value.isEmpty) {
          //       return 'Please enter a confirm password';
          //     }
          //     if (value != _passwordController.text) {
          //       return 'Password does not match';
          //     }
          //     return null;
          //   },
          // ),
          ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  print('run into sign up emit');

                  socketService.emit('SignUp', {
                    'username': _userNameController.text,
                    'email': _emailController.text,
                    'password': _passwordController.text,
                  });
                  socketService.on('SignUpConfirm', (data) {
                    print(data['check']);
                    // setState(() {
                    if (data['check'] == true) {
                      print('go back to home screen in SignUp Page');
                      Navigator.of(context).pushReplacementNamed('/home');
                    } else {
                      print('show error dialog');
                      final snackBar = SnackBar(
                        content: const Text('Email is used!'),
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
              child: Text('Sign up'))
        ]),
      ),
    );
  }
}
