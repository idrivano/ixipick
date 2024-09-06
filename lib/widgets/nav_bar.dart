import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../screens/home.dart';
import '../screens/convertio.dart';
import '../screens/upscaly.dart';
import 'styles/app_style.dart';
import 'svg_icons.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBar();
}

class _BottomBar extends State<BottomBar> {
  final List _pages = const [
    HomePage(title: 'RemoveBG'),
    UpscalyPage(title: 'Upscaly'),
    ConvertioPage(title: 'Convertir'),
  ];
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransitionSwitcher(
        duration: AppStyle.defaultDuration,
        transitionBuilder: (child, animation, secondAnimation) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondAnimation,
            child: child,
          );
        },
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: AppStyle.defaultPadding/2),
        color: Theme.of(context).brightness == Brightness.light ? AppStyle.whiteColor : AppStyle.blackColor,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index != _currentIndex) {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? AppStyle.whiteColor
              : AppStyle.blackColor.withOpacity(.5),
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          selectedItemColor: AppStyle.primaryColor,
          unselectedItemColor: AppStyle.blackColor.withOpacity(.5),
          items: [
            BottomNavigationBarItem(
              icon: SvgIcons(src: AppStyle.homeIcon, color: AppStyle.blackColor.withOpacity(.5)),
              activeIcon: const SvgIcons(src: AppStyle.homeIcon, color: AppStyle.primaryColor),
              label: "RemoveBG",
            ),
            BottomNavigationBarItem(
              icon: SvgIcons(src: AppStyle.imageIcon, color: AppStyle.blackColor.withOpacity(.5)),
              activeIcon: const SvgIcons(src: AppStyle.imageIcon, color: AppStyle.primaryColor),
              label: "Upscaly",
            ),
            BottomNavigationBarItem(
              icon: SvgIcons(src: AppStyle.imageIcon, color: AppStyle.blackColor.withOpacity(.5)),
              activeIcon: const SvgIcons(src: AppStyle.imageIcon, color: AppStyle.primaryColor),
              label: "Convertir",
            ),
          ],
        ),
      ),
    );
  }
}
