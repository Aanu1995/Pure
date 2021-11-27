import 'package:flutter/material.dart';

import '../../widgets/bottom_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 1, title: Text("Home")),
      body: Container(),
      bottomNavigationBar: const BottomBar(),
    );
  }
}
