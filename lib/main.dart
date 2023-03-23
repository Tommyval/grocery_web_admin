import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:grocery_admin_panel/inner_screens/add_prod.dart';
import 'package:grocery_admin_panel/inner_screens/edit_prod.dart';
import 'package:grocery_admin_panel/screens/main_screen.dart';
import 'package:provider/provider.dart';

import 'consts/theme_data.dart';
import 'controllers/MenuController.dart';
import 'providers/dark_theme_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  void initState() {
    getCurrentAppTheme();
    super.initState();
  }

  static final Future<FirebaseApp> _initialization = Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDSvgX99uxSew3JjfRHBuzoKk_IEE6eRNA",
          authDomain: "grocery-flutter-course-f7e3d.firebaseapp.com",
          projectId: "grocery-flutter-course-f7e3d",
          storageBucket: "grocery-flutter-course-f7e3d.appspot.com",
          messagingSenderId: "1057783779334",
          appId: "1:1057783779334:web:868465fe38b50e838f7387",
          measurementId: "G-N3EB8M770Y"));
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              home: Scaffold(body: Center(child: CircularProgressIndicator())),
            );
          } else if (snapshot.hasError) {
            const MaterialApp(
              home: Scaffold(body: Center(child: Text('An error occured'))),
            );
          }
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => MenuController(),
              ),
              ChangeNotifierProvider(
                create: (_) {
                  return themeChangeProvider;
                },
              ),
            ],
            child: Consumer<DarkThemeProvider>(
              builder: (context, themeProvider, child) {
                return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: 'Grocery',
                    theme:
                        Styles.themeData(themeProvider.getDarkTheme, context),
                    home: const MainScreen(),
                    routes: {
                      UploadProductForm.routeName: (context) =>
                          const UploadProductForm(),
                      EditProductScreen.routeName: (context) =>
                          const EditProductScreen()
                    });
              },
            ),
          );
        });
  }
}
