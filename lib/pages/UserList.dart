import 'package:flutter/material.dart';
import 'package:flutter_message_app/socket/SocketService.dart';
import 'package:provider/provider.dart';
import 'package:flutter_message_app/pages/ChatScreen.dart';
import 'package:flutter_message_app/pages/EditProfileScreen.dart';

class UserList extends StatefulWidget {
  final String loggedInUsername;

  const UserList({required this.loggedInUsername});

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  late final ValueNotifier<List<Map<String, dynamic>>> _userList;
  late final int _currentIndex;

  @override
  void initState() {
    super.initState();
    _userList = ValueNotifier<List<Map<String, dynamic>>>([]);
    _currentIndex = 0;
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.emit('get all user');
    socketService.on('get all user', (data) {
      try {
        _userList.value = List<Map<String, dynamic>>.from(data);
      } catch (e) {
        print(e);
      }
    });
  }

  @override
  void dispose() {
    _userList.dispose();
    super.dispose();
  }

  Widget _buildUserStatus(bool isOnline) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOnline ? Colors.green : Colors.red,
          ),
          margin: EdgeInsets.only(right: 5),
        ),
        CircleAvatar(
          child: Text('U'),
          backgroundColor: Colors.grey[300],
        ),
      ],
    );
  }

  void _onUserTap(String user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatUserScreen(
          username: widget.loggedInUsername,
          receiverUsername: user,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: _userList,
        builder: (context, userList, _) {
          return ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {
              final filteredUserList = userList
                  .where((user) => user['email'] != widget.loggedInUsername)
                  .toList();
              if (index >= filteredUserList.length) {
                return SizedBox.shrink(); // Or any other fallback widget
              }
              final user = filteredUserList[index];

              final isOnline = user['isOnline'] ?? false;
              return ListTile(
                leading: CircleAvatar(
                  child: Text(user['username'][0]),
                ),
                title: Text(user['username']),
                subtitle: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOnline ? Colors.green : Colors.red,
                      ),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(isOnline ? 'Online' : 'Offline'),
                  ],
                ),
                onTap: () {
                  _onUserTap(user['email']);
                },
              );
            },
          );
        },
      ),
    );
  }
}
