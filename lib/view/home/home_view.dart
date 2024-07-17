import 'package:flutter/material.dart';
import '../../components/no_reuse/firefly.dart';
import '../../components/no_reuse/home_top_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: homeTopBar(context),
    );
  }
}
