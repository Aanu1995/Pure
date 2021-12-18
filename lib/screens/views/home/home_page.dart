import 'package:flutter/material.dart';
import 'package:pure/utils/app_theme.dart';

import '../../widgets/bottom_bar.dart';
import '../../widgets/page_transition.dart';
import 'posts/create_post_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text("Home"),
      ),
      body: Container(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Palette.tintColor,
        child: Icon(
          Icons.post_add,
          color: Theme.of(context).colorScheme.secondary,
        ),
        onPressed: () => _onCreatePostTapped(),
      ),
      bottomNavigationBar: const BottomBar(),
    );
  }

  void _onCreatePostTapped() {
    Navigator.of(context).push<void>(
      PageTransition(
        child: CreatePostScreen(),
        type: PageTransitionType.bottomToTop,
      ),
    );
  }
}
