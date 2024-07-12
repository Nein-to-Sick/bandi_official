import 'package:bandi_official/view/homePage.dart';
import 'package:bandi_official/view/listPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/noreuse/navigationbar.dart';
import '../controller/navigationToggleProvider.dart';

class Navigation extends StatelessWidget {
  const Navigation({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationToggleProvider =
        Provider.of<NavigationToggleProvider>(context);

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image:
              AssetImage('assets/images/backgrounds/background.png'), // 배경 이미지
        ),
      ),
      child: SafeArea(
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(children: [
              navigationToggleProvider.selectedIndex == 0
                  ? const HomePage()
                  : const ListPage(),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [navigationBar(context)],
              ),
            ])),
      ),
    );
  }
}
