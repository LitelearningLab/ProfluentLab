import 'package:flutter/material.dart';

class NewSearchScreen extends StatefulWidget {

  @override
  State<NewSearchScreen> createState() => _NewSearchScreenState();
}

class _NewSearchScreenState extends State<NewSearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("new search bar"),
      ),
    );
  }
}
