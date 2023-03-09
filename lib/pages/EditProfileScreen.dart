import 'package:flutter/material.dart';
import 'package:flutter_message_app/socket/SocketService.dart';
import 'package:provider/provider.dart';

class ViewProfileScreen extends StatefulWidget {
  final String loggedInUsername;
  final String loggedInPassword;

  ViewProfileScreen(
      {required this.loggedInUsername, required this.loggedInPassword});

  @override
  _ViewProfileScreenState createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.loggedInUsername);
    _passwordController = TextEditingController(text: widget.loggedInPassword);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username'),
            SizedBox(height: 8.0),
            TextFormField(
              controller: _usernameController,
              enabled: _isEditing,
            ),
            SizedBox(height: 16.0),
            Text('Password'),
            SizedBox(height: 8.0),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              enabled: _isEditing,
            ),
            SizedBox(height: 16.0),
            _isEditing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          final newUsername = _usernameController.text;
                          final updatedUser = {
                            'username': newUsername,
                          };
                          socketService.emit('updateUser', updatedUser);
                          setState(() {
                            _isEditing = false;
                          });
                        },
                        child: Text('Save'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _usernameController.text = widget.loggedInUsername;
                            _passwordController.text = widget.loggedInPassword;
                          });
                        },
                        child: Text('Cancel'),
                      ),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () {
          setState(() {
            _isEditing = true;
          });
        },
      ),
    );
  }
}
