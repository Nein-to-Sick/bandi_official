import 'package:flutter/material.dart';
import '../../components/no_reuse/home_top_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: HomeTopBar(),
    );
  }
}
