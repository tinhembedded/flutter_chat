import 'package:flutter/material.dart';
import 'package:flutter_message_app/socket/SocketService.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:hive_flutter/hive_flutter.dart';

class ChatGroupScreen extends StatefulWidget {
  final String username;
  final String groupName;

  ChatGroupScreen({required this.username, required this.groupName});

  @override
  _ChatGroupScreenState createState() => _ChatGroupScreenState();
}

class _ChatGroupScreenState extends State<ChatGroupScreen> {
  TextEditingController _textEditingController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  final _messages = ValueNotifier<List<Map<String, dynamic>>>([]);
  String boxName = '';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    boxName = '${widget.username}_${widget.groupName}';
    _initHive();
  }

  Future<void> _initHive() async {
    final appDocumentDirectory =
        await path_provider.getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDirectory.path);
    await Hive.openBox(boxName);
    _getMessagesFromHive();

    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.emit('connect user', {'username': widget.username});
    socketService.on('chat group', _handleReceivedMessage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _getMessagesFromHive();
      _isInitialized = true;
    }
  }

  void _getMessagesFromHive() {
    final chatBox = Hive.box(boxName);
    final List<dynamic> history = chatBox.get('history', defaultValue: []);
    final List<Map<String, dynamic>> messages =
        history.map((message) => Map<String, dynamic>.from(message)).toList();
    _messages.value = messages;
  }

  void _handleReceivedMessage(data) {
    print('_handleReceivedMessage return : ' +
        data['groupName'].toString() +
        'and ' +
        widget.groupName.toString());

    if (data['groupName'] == widget.groupName) {
      final updatedMessages = List<Map<String, dynamic>>.from(_messages.value);
      updatedMessages.add(data);
      _messages.value = updatedMessages;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 200), curve: Curves.easeOut);
      }

      // Save the message to Hive
      final chatBox = Hive.box(boxName);
      chatBox.add(data);
    }
  }

  void _sendMessage() {
    final message = _textEditingController.text.trim();

    if (message.isNotEmpty) {
      final data = {
        'senderUsername': widget.username,
        'groupName': widget.groupName,
        'message': message,
        'timestamp': DateTime.now().toString(),
      };

      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.emit(boxName, data);

      final updatedMessages = List<Map<String, dynamic>>.from(_messages.value);
      updatedMessages.add(data);
      _messages.value = updatedMessages;

      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 200), curve: Curves.easeOut);
      }

      // Save the message to Hive
      final chatBox = Hive.box(boxName);
      chatBox.add(data);

      _textEditingController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _messages,
              builder: (BuildContext context,
                  List<Map<String, dynamic>> messages, _) {
                boxName = '${widget.username}_${widget.groupName}';
                Hive.box(boxName).put('history', messages);
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final message = messages[index];
                    final isSentByMe =
                        message['senderUsername'] == widget.username;
                    return Row(
                      mainAxisAlignment: isSentByMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 14),
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 14),
                          decoration: BoxDecoration(
                            color: isSentByMe
                                ? Colors.blueAccent
                                : Colors.grey[300],
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                              bottomLeft: isSentByMe
                                  ? Radius.circular(15)
                                  : Radius.zero,
                              bottomRight: !isSentByMe
                                  ? Radius.circular(15)
                                  : Radius.zero,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['message'],
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 5),
                              Text(
                                message['timestamp'],
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  child: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
