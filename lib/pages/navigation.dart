import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';

class NavigationPage extends ConsumerStatefulWidget {
  const NavigationPage({super.key});

  @override
  ConsumerState<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends ConsumerState<NavigationPage> {
  int currentPageIndex = 0;
  PageController _pageController = PageController(initialPage: 0);
  late TextEditingController searchController;
  final bool isWin = defaultTargetPlatform == TargetPlatform.windows;

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

  Future<void> toggleFullScreen() async {
    if(!isWin) return;

    if (await windowManager.isFullScreen()) {
      await windowManager.setFullScreen(false);
      await windowManager.maximize();
      await windowManager.setTitleBarStyle(TitleBarStyle.normal);
    } else {
      await windowManager.setFullScreen(true);
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    }
    setState(() {});
    }

  void goToJournalPage(){
    _pageController.animateToPage(1, duration: const Duration(milliseconds: 500), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeManagerProvider);
    final columnCount = MediaQuery.of(context).size.width < 720 ? 1 : 2;
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
        iconActiveColor: themeData.colorScheme.onPrimary,
        backgroundColor: themeData.brightness == Brightness.dark ? const Color(0xff303030) : themeData.primaryColor,
      ),
      GButton(
        icon: Icons.book,
        text: 'Journal',
        margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        textColor: themeData.colorScheme.onPrimary,
        iconColor: themeData.colorScheme.onPrimary,
        iconActiveColor: themeData.colorScheme.onPrimary,
        backgroundColor: themeData.brightness == Brightness.dark ? const Color(0xff303030) : themeData.primaryColor,
      ),
      GButton(
        icon: Icons.star,
        text: 'Progress',
        margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        textColor: themeData.colorScheme.onPrimary,
        iconColor: themeData.colorScheme.onPrimary,
        iconActiveColor: themeData.colorScheme.onPrimary,
        backgroundColor: themeData.brightness == Brightness.dark ? const Color(0xff303030) : themeData.primaryColor,
      ),
      GButton(
        icon: Icons.settings,
        text: 'Settings',
        margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        textColor: themeData.colorScheme.onPrimary,
        iconColor: themeData.colorScheme.onPrimary,
        iconActiveColor: themeData.colorScheme.onPrimary,
        backgroundColor: themeData.brightness == Brightness.dark ? const Color(0xff303030) : themeData.primaryColor,
      ),
    ];

    List<Widget> appBarWidgets = [
      Expanded(
        child: Container(
          //margin: const EdgeInsets.only(left: 10, top: 20),
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
      ),

      IconButton(onPressed: (){
        ref.read(themeManagerProvider.notifier).toggleTheme(!(themeData.brightness == Brightness.dark));
        }, icon: themeData.brightness == Brightness.dark ? Icon(Icons.brightness_2) : Icon(Icons.brightness_5), color: themeData.colorScheme.onPrimary,
      ),

      if(isWin) IconButton(onPressed: toggleFullScreen, icon: const Icon(Icons.fullscreen), color: themeData.colorScheme.onPrimary,
      ),
    ];

    print("width: ${MediaQuery.of(context).size.width}");
    print("Column count: $columnCount");
    return Theme(
      data: themeData,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: columnCount == 1 ? AppBar(
          toolbarHeight: 70,
          titleSpacing: 0,
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: FirebaseAuth.instance.currentUser!.photoURL != null && columnCount == 1 ? CircleAvatar(
            backgroundImage: Image.network(
                FirebaseAuth.instance.currentUser!.photoURL!, 
                scale: 0.5, cacheWidth: 100, cacheHeight: 100,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.person, color: themeData.colorScheme.onPrimary,);
                },
                ).image,
              radius: 5,
            ) : null,
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
            if(isWin) IconButton(onPressed: toggleFullScreen, icon: const Icon(Icons.fullscreen), color: themeData.colorScheme.onPrimary,
            ),
          ],
        ) : null,
        
        bottomNavigationBar: columnCount == 1 ? SizedBox(
          //color: Colors.greenAccent,
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
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [themeData.colorScheme.tertiary, themeData.colorScheme.onTertiary]
            )
          ),
          child: Row(
            children: [
              if (columnCount == 2)
                SizedBox(
                  width: 70,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (FirebaseAuth.instance.currentUser!.photoURL != null && columnCount == 2)
                        Container(
                          //color: Colors.amber,
                          margin: const EdgeInsets.only(top: 20),
                          child: CircleAvatar(
                            backgroundImage: Image.network(
                              FirebaseAuth.instance.currentUser!.photoURL!, 
                              scale: 0.5, cacheWidth: 100, cacheHeight: 100,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.person, color: themeData.colorScheme.onPrimary,);
                              },
                              ).image,
                            radius: 24,
                          ),
                        ),
                      Expanded(
                        child: Container(
                          //color: Colors.green,
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            reverse: true,
                            //shrinkWrap: true,
                            itemCount: navItems.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  _pageController.animateToPage(
                                    navItems.length - index - 1,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.ease,
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: currentPageIndex == navItems.length - index - 1
                                        ? themeData.colorScheme.primary
                                        : themeData.colorScheme.surface,
                                  ),
                                  child: Icon(
                                    navItems[navItems.length - index - 1].icon,
                                    size: 28,
                                    color: themeData.colorScheme.onPrimary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if(columnCount == 2) Container(
                      margin: const EdgeInsets.only(left: 10, top: 20),
                      //color: Colors.lightGreen,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: appBarWidgets,
                      ),
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        children: pages,
                        onPageChanged: (int index) {
                          setState(() {
                            currentPageIndex = index;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],),
        )
      ),
    );
  }
}