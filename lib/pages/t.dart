import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Bot App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    String userMessage = _messageController.text.trim();
    if (userMessage.isNotEmpty) {
      // Add user message to the chat
      _addMessage(userMessage, true);

      // Send HTTP post request to the bot API
      String apiUrl = 'http://10.0.2.2:8080/api';
      Map<String, String> requestBody = {'input': userMessage};

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          // Parse and add bot response to the chat
          Map<String, dynamic> responseData = jsonDecode(response.body);
          String botResponse = responseData['response'];

          print(botResponse);

          _addMessage(botResponse, false);
        } else {
          print('Error: ${response.statusCode}');
        }
      } catch (e) {
        print('Error: $e');
      }

      // Clear the input field
      _messageController.clear();
    }
  }

  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: isUser));
    });
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  bool isUser = false;

  ChatMessage({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      alignment: isUser ? Alignment.center : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: isUser ? Colors.blue : Colors.red,
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}
