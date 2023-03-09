import 'package:flutter/material.dart';
import 'package:flutter_message_app/pages/ChatGroupScreen.dart';
import 'package:flutter_message_app/socket/SocketService.dart';
import 'package:provider/provider.dart';

class GroupList extends StatefulWidget {
  final String loggedInUsername;

  const GroupList({required this.loggedInUsername});

  @override
  _GroupListState createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  late final ValueNotifier<List<Map<String, dynamic>>> _groupList;
  final TextEditingController _groupNameController = TextEditingController();
  final List<String> _selectedUsers = [];
  late final List<Map<String, dynamic>> _userList;

  @override
  void initState() {
    super.initState();

    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.emit('get all groups');
    socketService.on('get all groups', (data) {
      try {
        _groupList.value = List<Map<String, dynamic>>.from(data);
      } catch (e) {
        print(e);
      }
    });
    socketService.emit('get all user');
    socketService.on('get all user', (data) {
      try {
        _userList.addAll(List<Map<String, dynamic>>.from(data));
      } catch (e) {
        print(e);
      }
    });
    _groupList = ValueNotifier<List<Map<String, dynamic>>>([]);
    _userList = [];
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  void _createNewGroup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Create New Group'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _groupNameController,
                    decoration: InputDecoration(hintText: 'Group Name'),
                  ),
                  SizedBox(height: 10),
                  Text('Select users to add to the group:'),
                  SizedBox(height: 5),
                  Container(
                    height: 200,
                    width: 200,
                    child: ListView.builder(
                      itemCount: _userList.length,
                      itemBuilder: (context, index) {
                        final user = _userList[index];
                        bool isSelected =
                            _selectedUsers.contains(user['email']);
                        final isOnline = user['isOnline'] ?? false;
                        return GestureDetector(
                          onTap: () {
                            if (isSelected) {
                              _selectedUsers.remove(user['email']);
                            } else {
                              _selectedUsers.add(user['email']);
                            }
                            isSelected = !isSelected;
                            setState(() {});
                          },
                          child: ListTile(
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
                            trailing: isSelected
                                ? Icon(Icons.check_box)
                                : Icon(Icons.check_box_outline_blank),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Create'),
                  onPressed: () {
                    final groupName = _groupNameController.text;
                    if (groupName.isNotEmpty && _selectedUsers.isNotEmpty) {
                      final socketService =
                          Provider.of<SocketService>(context, listen: false);
                      socketService.emit('create group', {
                        'name': groupName,
                        'users': _selectedUsers,
                      });
                      Navigator.of(context).pop();
                      _groupNameController.clear();
                      _selectedUsers.clear();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onGroupTap(String groupName) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChatGroupScreen(
              username: widget.loggedInUsername, groupName: groupName)),
    );
  }

  void _addUsersToGroup(String groupName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Users to Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select users to add to the group:'),
              SizedBox(height: 5),
              Container(
                height: 200,
                child: ListView.builder(
                  itemCount: _userList.length,
                  itemBuilder: (context, index) {
                    final user = _userList[index];
                    final isSelected = _selectedUsers.contains(user['email']);
                    return CheckboxListTile(
                      title: Text(user['username']),
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedUsers.add(user['email']);
                          } else {
                            _selectedUsers.remove(user['email']);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add Users'),
              onPressed: () {
                if (_selectedUsers.isNotEmpty) {
                  final socketService =
                      Provider.of<SocketService>(context, listen: false);
                  socketService.emit('add users to group', {
                    'groupName': groupName,
                    'users': _selectedUsers,
                  });
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedUsers.clear();
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: _groupList,
        builder:
            (BuildContext context, List<Map<String, dynamic>> groupList, _) {
          if (groupList.isEmpty) {
            return Center(
              child: Text('No groups found.'),
            );
          }
          return ListView.builder(
            itemCount: groupList.length,
            itemBuilder: (context, index) {
              final group = groupList[index];
              final groupName = group['name'];
              final users = group['users'];
              final isUserInGroup = users.contains(widget.loggedInUsername);
              return ListTile(
                title: Text(groupName),
                subtitle: Text('${users.length} members'),
                trailing: isUserInGroup
                    ? IconButton(
                        icon: Icon(Icons.chat),
                        onPressed: () => _onGroupTap(groupName),
                      )
                    : null,
                onTap: () {
                  if (!isUserInGroup) {
                    _selectedUsers.clear();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Add Users to Group'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Select users to add to the group:'),
                              SizedBox(height: 5),
                              Container(
                                height: 200,
                                child: ListView.builder(
                                  itemCount: users.length,
                                  itemBuilder: (context, index) {
                                    final user = users[index];
                                    final isSelected =
                                        _selectedUsers.contains(user);
                                    return CheckboxListTile(
                                      title: Text(user),
                                      value: isSelected,
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            _selectedUsers.add(user);
                                          } else {
                                            _selectedUsers.remove(user);
                                          }
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Add Users'),
                              onPressed: () {
                                if (_selectedUsers.isNotEmpty) {
                                  final socketService =
                                      Provider.of<SocketService>(context,
                                          listen: false);
                                  socketService.emit('add users to group', {
                                    'groupName': groupName,
                                    'users': _selectedUsers,
                                  });
                                  Navigator.of(context).pop();
                                  _selectedUsers.clear();
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _createNewGroup,
      ),
    );
  }
}
