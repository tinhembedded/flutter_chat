import 'package:flutter/material.dart';
import 'package:flutter_message_app/pages/GroupList.dart';
import 'package:flutter_message_app/pages/UserList.dart';
import 'package:flutter_message_app/pages/EditProfileScreen.dart';
import 'package:flutter_message_app/socket/SocketService.dart';
import 'package:provider/provider.dart';

class MyTabBar extends StatefulWidget {
  final String loggedInUsername;
  final String loggedInPassword;

  const MyTabBar(
      {required this.loggedInUsername, required this.loggedInPassword});
  @override
  _MyTabBarState createState() => _MyTabBarState();
}

class _MyTabBarState extends State<MyTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text('My App'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'User List',
            ),
            Tab(
              text: 'Group List',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          UserList(loggedInUsername: widget.loggedInUsername),
          GroupList(loggedInUsername: widget.loggedInUsername),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabController.index,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewProfileScreen(
                    loggedInUsername: widget.loggedInUsername,
                    loggedInPassword: widget.loggedInPassword),
              ),
            );
          } else {
            setState(() {
              _tabController.index = index;
            });
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Edit',
          ),
        ],
      ),
    );
  }
}
