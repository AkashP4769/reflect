import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:reflect/main.dart';
import 'package:reflect/pages/achievement.dart';
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
  late TextEditingController searchController;

  List<String> titles = [/*"Welcome, User",*/ "Journal", /*"Your favourites",*/ "Settings"];
  String searchQuery = '';
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    searchController = TextEditingController(text: '');

    searchController.addListener(() {
      if(searchQuery != searchController.text) setState(() => searchQuery = searchController.text);
      print(searchController.text);
    });

  }

  @override
  void dispose() {
    // TODO: implement dispose
    searchController.dispose();
    super.dispose();
  }

  void goToJournalPage(){
    _pageController.animateToPage(1, duration: const Duration(milliseconds: 500), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
    final columnCount = MediaQuery.of(context).size.width < 700 ? 1 : 2;
    List<Widget> pages = <Widget>[
      HomePage(goToJournalPage: goToJournalPage,), 
      JournalPage(searchQuery: searchQuery,), 
      const AchievementPage(), 
      const SettingsPage()
    ];

    final List<GButton> navItems =  [
      GButton(
        icon: Icons.home,
        text: 'Home',
        margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        textColor: themeData.colorScheme.onPrimary,
        iconColor: themeData.colorScheme.onPrimary,
        iconActiveColor: themeData.colorScheme.primary,
        backgroundColor: themeData.brightness == Brightness.dark ? const Color(0xff303030) : themeData.primaryColor,
      ),
      GButton(
        icon: Icons.book,
        text: 'Journal',
        margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        textColor: themeData.colorScheme.onPrimary,
        iconColor: themeData.colorScheme.onPrimary,
        iconActiveColor: themeData.colorScheme.primary,
        backgroundColor: themeData.brightness == Brightness.dark ? const Color(0xff303030) : themeData.primaryColor,
      ),
      GButton(
        icon: Icons.star,
        text: 'Progress',
        margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        textColor: themeData.colorScheme.onPrimary,
        iconColor: themeData.colorScheme.onPrimary,
        iconActiveColor: themeData.colorScheme.primary,
        backgroundColor: themeData.brightness == Brightness.dark ? const Color(0xff303030) : themeData.primaryColor,
      ),
      GButton(
        icon: Icons.settings,
        text: 'Settings',
        margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        textColor: themeData.colorScheme.onPrimary,
        iconColor: themeData.colorScheme.onPrimary,
        iconActiveColor: themeData.colorScheme.primary,
        backgroundColor: themeData.brightness == Brightness.dark ? const Color(0xff303030) : themeData.primaryColor,
      ),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: 70,
        titleSpacing: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: FirebaseAuth.instance.currentUser!.photoURL != null ? CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(FirebaseAuth.instance.currentUser!.photoURL!, scale: 0.5, cacheKey: FirebaseAuth.instance.currentUser!.uid,),
            radius: 5,
          ) : Container(),
        ),
        title: Container(
          margin: const EdgeInsets.only(left: 10),
          height: 45,
          width: double.infinity,
          child: SearchBar(
            backgroundColor: WidgetStateProperty.all(themeData.colorScheme.onTertiary),
            elevation: WidgetStateProperty.all(0),
            controller: searchController,
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
          }, icon: themeData.brightness == Brightness.dark ? Icon(Icons.brightness_2) : Icon(Icons.brightness_5), color: themeData.colorScheme.onPrimary,),
        ],
      ),
      
      bottomNavigationBar: columnCount == 1 ? Container(
        width: MediaQuery.of(context).size.width,
        child: GNav(
          rippleColor: Colors.transparent,
          hoverColor: Colors.grey[100]!,
          gap: 8,
          color: themeData.colorScheme.onPrimary,
          activeColor: themeData.colorScheme.primary,
          backgroundColor: themeData.brightness == Brightness.dark ? const Color(0xff1E1E1E) : Colors.white,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          tabBackgroundColor: themeData.brightness == Brightness.dark ? const Color(0xff303030) : Colors.white,
          tabs: navItems,
          selectedIndex: currentPageIndex,
          onTabChange: (index) {
            _pageController.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.ease);
          },
        ),
      ) : null,
      body: Row(
        children: [
          columnCount == 2 ? Container(
            width: 70,
            decoration: BoxDecoration(
              //color: Colors.lightGreen
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [themeData.colorScheme.tertiary, themeData.colorScheme.onTertiary]
              )
            ),
            child: ListView.builder(
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    _pageController.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.ease);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: currentPageIndex == index ? themeData.colorScheme.primary : themeData.colorScheme.surface,
                    ),
                    
                    //padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    child: Icon(
                      navItems[index].icon,
                      size: 28,
                      color: themeData.colorScheme.onPrimary,
                    ),
                  ),
                );
              },
            ),
          ) : Container(),
          Expanded(
            child: PageView(
              children: pages,
              controller: _pageController,
              onPageChanged: (int index){
                print("new page $index");
                setState(() {
                  currentPageIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}