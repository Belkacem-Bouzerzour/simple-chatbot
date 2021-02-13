import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatbot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(title: 'Chatbot'),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _formKey = GlobalKey<FormState>();

  List<Item> _messages;

  TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    _messages = [];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            widget.title,
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                for (var item in _messages)
                  MessageItem(
                    name: item.name,
                    message: item.message,
                    sender: item.sender,
                  ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        color: Colors.black12,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextFormField(
                            controller: _controller,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FlatButton.icon(
                    onPressed: () async {
                      if (_controller.text.isEmpty) {
                        return;
                      }

                      setState(() {
                        _messages.add(Item(
                            message: _controller.text,
                            name: 'Sender',
                            sender: true));
                      });

                      var response = await http.get(
                        'http://10.0.2.2:5000/',
                        headers: {'message': _controller.text},
                      );

                      if (response.statusCode == 200) {
                        setState(() {
                          _messages.add(Item(
                              message: response.body,
                              name: 'Bot',
                              sender: false));
                        });
                      }

                      _controller.text = "";
                    },
                    icon: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    label: Text(
                      'SEND',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.green,
                    shape: RoundedRectangleBorder(),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MessageItem extends StatelessWidget {
  final String name;
  final String message;
  final bool sender;

  const MessageItem({
    Key key,
    @required this.name,
    @required this.message,
    @required this.sender,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            children: [
              if (sender == true) Spacer(),
              Container(
                color: sender == true ? Colors.black12 : Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Text(
                  name,
                  style: TextStyle(
                      color: sender == true ? Colors.black : Colors.white),
                ),
              ),
              if (sender == false) Spacer(),
            ],
          ),
          Container(
            width: double.infinity,
            color: sender == true ? Colors.black12 : Colors.blue,
            padding: const EdgeInsets.all(16),
            child: Text(
              message,
              textAlign: sender == true ? TextAlign.end : TextAlign.start,
              style: TextStyle(
                color: sender == true ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Item {
  String message;
  String name;
  bool sender;

  Item({this.message, this.name, this.sender});
}