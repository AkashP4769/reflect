import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reflect/components/signup/bg_splash.dart';
import 'package:reflect/firebase_options.dart';
import 'package:reflect/models/entry.dart';
import 'package:reflect/pages/auth.dart';
import 'package:reflect/pages/entry.dart';
import 'package:reflect/pages/entrylist.dart';
import 'package:reflect/pages/entry.dart';
import 'package:reflect/pages/login.dart';
import 'package:reflect/pages/navigation.dart';
import 'package:reflect/theme/theme_constants.dart';
import 'package:reflect/theme/theme_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final themeManagerProvider = StateNotifierProvider<ThemeManager, ThemeData>((ref) => ThemeManager());

void main() async {
  

  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  if (defaultTargetPlatform == TargetPlatform.windows) {
    await windowManager.ensureInitialized();
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kIsWeb) {
    // Initialize Hive for web
    Hive.initFlutter();
  } else {
    // Initialize Hive for mobile
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }

  await Hive.openBox('chapters');
  await Hive.openBox('entries');
  await Hive.openBox('settings');
  await Hive.openBox('timestamps');
  await Hive.openBox('tags');
  await Hive.openBox('sorts');


  // final timestampBox = Hive.box('timestamps');
  // timestampBox.clear();

  // final entryBox = Hive.box('entries');
  // entryBox.clear();

  // final chapterbox = Hive.box('chapters');
  // chapterbox.clear();

  // final settingBox = Hive.box('settings');
  // settingBox.clear();

  // await const FlutterSecureStorage().deleteAll();

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(themeManagerProvider.notifier).initializeTheme();
    final themeData = ref.watch(themeManagerProvider);

    //return a normal page
    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home: Scaffold(
    //     body: Center(
    //       child: Text(
    //         'Welcome to Reflect',
    //         style: TextStyle(fontSize: 24, color: Theme.of(context).primaryColor),
    //       ),
    //     ),
    //   ) // Replace with your initial page
    // );

    return MaterialApp(
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeData.brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      routes: {
        '/': (context) => const AuthPage(),
        '/login': (context) => const LoginPage(),
        '/navigation': (context) => const NavigationPage(),
        '/entrylist': (context) => const EntryListPage(),
        '/entry': (context) => EntryPage(entry: Entry(),),
      },
    );
  }
}
