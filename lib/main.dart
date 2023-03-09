import 'package:flutter/material.dart';
import 'package:flutter_message_app/pages/LoginScreen.dart';
import 'package:flutter_message_app/pages/SignupScreen.dart';
import 'package:flutter_message_app/pages/UserList.dart';

import 'package:flutter_message_app/socket/SocketService.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => SocketService(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  static const routeName = '/home';

  // socketService.initSocket();
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    socketService.initSocket();
    return MaterialApp(
      home: HomeScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        // '/userList': (context) => UserList(),
        LoginScreen.routeName: (context) => LoginScreen(),
        SignupScreen.routeName: (context) => SignupScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(LoginScreen.routeName),
              child: Text('Login'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(SignupScreen.routeName),
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
