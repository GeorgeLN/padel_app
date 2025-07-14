
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:padel_app/features/bloc/bottom_nav_cubit.dart';
import 'package:padel_app/features/design/app_colors.dart';
import 'package:padel_app/features/pages/_pages.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  /// Top Level Pages
  final List<Widget> topLevelPages = [
    HomePage(),
    TablePage(),
    ProfilePage(),
  ];

  /// On Page Changed
  void onPageChanged(int page) {
    BlocProvider.of<BottomNavCubit>(context).changeSelectedIndex(page);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 2, 2, 2),
        //appBar: _LandingScreenAppBar(),
        body: _LandingScreenBody(),
        bottomNavigationBar: _LandingScreenBottomNavBar(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        //floatingActionButton: _LandingScreenFab(),
      ),
    );
  }

  // Bottom Navigation Bar - LandingScreen Widget
  BottomAppBar _LandingScreenBottomNavBar(BuildContext context) {
    return BottomAppBar(
      padding: const EdgeInsets.all(10),
      color: AppColors.primaryBlue,

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _bottomAppBarItem(
                  context,
                  defaultIcon: IconlyLight.home,
                  page: 0,
                  label: "Home",
                  filledIcon: IconlyBold.home,
                ),

                _bottomAppBarItem(
                  context,
                  defaultIcon: IconlyLight.chart,
                  page: 1,
                  label: "Tablas",
                  filledIcon: IconlyBold.chart,
                ),
            
                _bottomAppBarItem(
                  context,
                  defaultIcon: IconlyLight.profile,
                  page: 2,
                  label: "Perfil",
                  filledIcon: IconlyBold.profile,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Body - LandingScreen Widget
  PageView _LandingScreenBody() {
    return PageView(
      onPageChanged: (int page) => onPageChanged(page),
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: topLevelPages,
    );
  }

  // Bottom Navigation Bar Single item - LandingScreen Widget
  Widget _bottomAppBarItem(BuildContext context, {required defaultIcon, required page, required label, required filledIcon}) {
    return GestureDetector(
      onTap: () {
        BlocProvider.of<BottomNavCubit>(context).changeSelectedIndex(0);

        pageController.animateToPage(
          page,
          duration: const Duration(milliseconds: 10),
          curve: Curves.fastLinearToSlowEaseIn
        );
      },

      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 10,
            ),
            Icon(
              context.watch<BottomNavCubit>().state == page ? filledIcon : defaultIcon,
              color: context.watch<BottomNavCubit>().state == page ? Colors.blueGrey : Colors.grey,
              size: 26,
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              label,
              style: TextStyle(
                color: context.watch<BottomNavCubit>().state == page ? Colors.blueGrey : Colors.grey,
                fontSize: 13,
                fontWeight: context.watch<BottomNavCubit>().state == page ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}