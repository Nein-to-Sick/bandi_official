import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import '../../components/no_reuse/home_top_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BandiColor.transparent(context),
      body: HomeTopBar(),
    );
  }
}
