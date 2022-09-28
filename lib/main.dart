
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:whatsapp_clone/app/data/constants.dart';
import 'package:whatsapp_clone/app/landing/landing_screen.dart';
import 'package:whatsapp_clone/app/auth/controller/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp().then((value) => Get.put(AuthController()));
  
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(GetMaterialApp(
    defaultTransition: Transition.rightToLeft,
    debugShowCheckedModeBanner: false,
    title: "Twitch Clone",
    theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: CustomColor.backgroundColor,
        appBarTheme:  AppBarTheme(
          color: CustomColor.appBarColor,
        ),
      ),
    home: LandingScreen(),
  ));
}
