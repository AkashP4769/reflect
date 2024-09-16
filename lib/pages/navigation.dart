import 'package:firebase_auth/firebase_auth.dart';
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        //toolbarHeight: 70,
        //backgroundColor: Colors.grey,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: CircleAvatar(
            backgroundImage: NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!, scale: 2),
            radius: 5,
          ),
        ),
        title: Container(
          height: 45,
          child: SearchBar(
            backgroundColor: WidgetStateProperty.all(themeData.colorScheme.onTertiary),
            elevation: WidgetStateProperty.all(0),
            trailing: [
              IconButton(
                onPressed: (){},
                icon: const Icon(Icons.search),
                color: themeData.colorScheme.onPrimary,
              ),
            ],
          ),
        ),
        actions: [
          IconButton(onPressed: (){
            ref.read(themeManagerProvider.notifier).toggleTheme(!(themeData.brightness == Brightness.dark));
          }, icon: themeData.brightness == Brightness.dark ? Icon(Icons.brightness_2) : Icon(Icons.brightness_5), color: themeData.colorScheme.surfaceContainerHighest,),
        ],
      ),

      bottomNavigationBar: Container(
        //padding: const EdgeInsets.symmetric(vertical: 10),
        child: GNav(
          rippleColor: Colors.transparent,
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
              margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              textColor: themeData.colorScheme.surfaceContainer,
              iconColor: themeData.colorScheme.surfaceContainerHighest,
              iconActiveColor: themeData.colorScheme.surfaceContainer,
              backgroundColor: themeData.brightness == Brightness.dark ? const Color(0xff303030) : themeData.primaryColor,
            ),
            GButton(
              icon: Icons.book,
              text: 'Journal',
              margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              textColor: themeData.colorScheme.surfaceContainer,
              iconColor: themeData.colorScheme.surfaceContainerHighest,
              iconActiveColor: themeData.colorScheme.surfaceContainer,
              backgroundColor: themeData.brightness == Brightness.dark ? const Color(0xff303030) : themeData.primaryColor,
            ),
            GButton(
              icon: Icons.favorite,
              text: 'Likes',
              margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              textColor: themeData.colorScheme.surfaceContainer,
              iconColor: themeData.colorScheme.surfaceContainerHighest,
              iconActiveColor: themeData.colorScheme.surfaceContainer,
              backgroundColor: themeData.brightness == Brightness.dark ? const Color(0xff303030) : themeData.primaryColor,
            ),
            GButton(
              icon: Icons.settings,
              text: 'Settings',
              margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              textColor: themeData.colorScheme.surfaceContainer,
              iconColor: themeData.colorScheme.surfaceContainerHighest,
              iconActiveColor: themeData.colorScheme.surfaceContainer,
              backgroundColor: themeData.brightness == Brightness.dark ? const Color(0xff303030) : themeData.primaryColor,
            ),
          ],
          selectedIndex: currentPageIndex,
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