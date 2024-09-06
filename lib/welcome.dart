import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widgets/nav_bar.dart';
import 'widgets/svg_icons.dart';
import 'widgets/styles/app_style.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePage();
}

class _WelcomePage extends State<WelcomePage> {
  int currentIndex = 0;
  late PageController _controller;

  Future<void> storeFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('seen', true);
  }

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
    storeFirstSeen();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: contents.length,
              onPageChanged: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (_, i) {
                return Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Image.asset(contents[i].image, height: 300),
                      const SizedBox(height: AppStyle.defaultPadding*3),
                      Text(
                        contents[i].title,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 25, fontWeight: FontWeight.w600, color: AppStyle.primaryColor
                        ),
                      ),
                      const SizedBox(height: AppStyle.defaultPadding),
                      Text(
                        contents[i].description,
                        textAlign: TextAlign.justify,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 14, fontWeight: FontWeight.w400, color: AppStyle.blackColor
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              contents.length, (index) => buildDot(index, context),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (currentIndex == contents.length - 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BottomBar(),
                  ),
                );
              }
              _controller.nextPage(
                duration: const Duration(milliseconds: 100),
                curve: Curves.bounceIn,
              );
            },
            child: Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(AppStyle.smallPadding),
              margin: const EdgeInsets.all(AppStyle.smallPadding*4),
              decoration: BoxDecoration(
                color: AppStyle.primaryColor,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const SvgIcons(src: AppStyle.arrowRightIcon, color: AppStyle.whiteColor),
            ),
          )
        ],
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 9,
      width: currentIndex == index ? 30 : 9,
      margin: const EdgeInsets.only(right: AppStyle.smallPadding/2),
      decoration: BoxDecoration(
        color: AppStyle.primaryColor.withOpacity(.3),
        borderRadius: BorderRadius.circular(AppStyle.defaultBorderRadious),
      ),
    );
  }
}

class WelcomeContent {
  String image, title, description;

  WelcomeContent({required this.image, required this.title, required this.description});
}

List<WelcomeContent> contents = [
  WelcomeContent(
    image: AppStyle.icon,
    title: AppStyle.stepOneTitle,
    description: AppStyle.stepOneContent,
  ),
  WelcomeContent(
    image: AppStyle.icon,
    title: AppStyle.stepTwoTitle,
    description: AppStyle.stepTwoContent,
  ),
];