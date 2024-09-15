import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:reflect/main.dart';
import 'package:reflect/pages/favourites.dart';
import 'package:reflect/pages/home.dart';
import 'package:reflect/pages/journal.dart';
import 'package:reflect/pages/settings.dart';
import 'package:reflect/services/auth_service.dart';

class NavigationPage extends ConsumerStatefulWidget {
  const NavigationPage({super.key});

  @override
  ConsumerState<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends ConsumerState<NavigationPage> {
  int currentPageIndex = 0;
  PageController _pageController = PageController(initialPage: 0);

  List<Widget> pages = <Widget>[const HomePage(), const JournalPage(), const FavPage(), const SettingsPage()];
  List<String> titles = ["Welcome, User", "Journal", "Your favourites", "Settings"];
  
  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: CircleAvatar(maxRadius: 5,),
        ),
        title: Text(titles[currentPageIndex]),
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.call)),
          IconButton(onPressed: (){}, icon: const Icon(Icons.notifications))
        ],
      ),

      bottomNavigationBar: Container(
        //padding: const EdgeInsets.symmetric(vertical: 10),
        child: GNav(
          rippleColor: Colors.grey[300]!,
          hoverColor: Colors.grey[100]!,
          gap: 8,
          color: themeData.colorScheme.onPrimary,
          activeColor: themeData.colorScheme.primary,
          backgroundColor: themeData.brightness == Brightness.dark ? const Color(0xff1E1E1E) : Colors.white,
          
          tabBackgroundColor: themeData.brightness == Brightness.dark ? const Color(0xff303030) : Colors.white,
          tabs: [
            GButton(
              icon: Icons.home,
              text: 'Home',
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              textColor: themeData.colorScheme.surfaceContainer,
              iconColor: themeData.colorScheme.surfaceContainerHighest,
              iconActiveColor: themeData.colorScheme.surfaceContainer,
              backgroundColor: themeData.brightness == Brightness.dark ? const Color(0xff303030) : themeData.primaryColor,
            ),
            GButton(
              icon: Icons.book,
              text: 'Journal',
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              textColor: themeData.colorScheme.surfaceContainer,
              iconColor: themeData.colorScheme.surfaceContainerHighest,
              iconActiveColor: themeData.colorScheme.surfaceContainer,
              backgroundColor: themeData.brightness == Brightness.dark ? const Color(0xff303030) : themeData.primaryColor,
            ),
            GButton(
              icon: Icons.favorite,
              text: 'Likes',
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              textColor: themeData.colorScheme.surfaceContainer,
              iconColor: themeData.colorScheme.surfaceContainerHighest,
              iconActiveColor: themeData.colorScheme.surfaceContainer,
              backgroundColor: themeData.brightness == Brightness.dark ? const Color(0xff303030) : themeData.primaryColor,
            ),
            GButton(
              icon: Icons.settings,
              text: 'Settings',
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              textColor: themeData.colorScheme.surfaceContainer,
              iconColor: themeData.colorScheme.surfaceContainerHighest,
              iconActiveColor: themeData.colorScheme.surfaceContainer,
              backgroundColor: themeData.brightness == Brightness.dark ? const Color(0xff303030) : themeData.primaryColor,
            ),
          ],
          selectedIndex: 0,
          onTabChange: (index) {
            _pageController.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.ease);
          },
        ),
      ),
      /*bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index){
          _pageController.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.ease);
        },
        indicatorColor: Colors.grey.shade400,
        selectedIndex: currentPageIndex,
        backgroundColor: Colors.white,
        indicatorShape: const CircleBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.cottage_outlined),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.privacy_tip_outlined),
            label: "Info",
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_alt_outlined),
            label: "Service Request",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: "My Account",
          ),
        ],
      ),*/
      //body: ,
      body: PageView(
        children: pages,
        controller: _pageController,
        onPageChanged: (int index){
          setState(() {
            currentPageIndex = index;
          });
        },
      ),
    );
  }
}