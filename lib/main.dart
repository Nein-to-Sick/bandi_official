import 'dart:developer';

import 'package:bandi_official/controller/alarm_controller.dart';
import 'package:bandi_official/controller/diary_ai_analysis_controller.dart';
import 'package:bandi_official/controller/diary_ai_chat_controller.dart';
import 'package:bandi_official/controller/mail_controller.dart';
import 'package:bandi_official/controller/permission_controller.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/theme/custom_theme_mode.dart';
import 'package:bandi_official/view/navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badge_control/flutter_app_badge_control.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'controller/home_to_write.dart';
import 'controller/navigation_toggle_provider.dart';
import 'controller/user_info_controller.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:developer' as dev;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // preserve splash screen
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  CustomThemeMode.instance;
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Initialize firebase connection
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initialize env file
  await dotenv.load(fileName: 'assets/config/.env');
  // Initialize date formatting for the 'ko' locale
  await initializeDateFormatting('ko', null);

  // firebase notification setting
  AlarmController alarmController = AlarmController();
  alarmController.firebaseOnMessageListen();
  alarmController.firebaseOnMessageOpenedApp();
  alarmController.firebaseGetInitialListen();

  // local notification setting
  alarmController.localNotificationInitialization();

  // remove message badge
  FlutterAppBadgeControl.removeBadge();

  // remove splash screen
  FlutterNativeSplash.remove();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: CustomThemeMode.themeMode,
      builder: (context, mode, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => NavigationToggleProvider(),
            ),
            ChangeNotifierProvider(
              create: (context) => DiaryAIAnalysisController(),
            ),
            ChangeNotifierProvider(
              create: (context) => DiaryAiChatController(),
            ),
            ChangeNotifierProvider(
              create: (context) => HomeToWrite(),
            ),
            ChangeNotifierProvider(
              create: (context) => UserInfoValueModel(),
            ),
            ChangeNotifierProvider(
              create: (context) => MailController(),
            ),
            ChangeNotifierProvider(
              create: (context) => AlarmController(),
            ),
            ChangeNotifierProvider(
              create: (context) => PermissionController(),
            ),
          ],
          child: MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: true,
            darkTheme: CustomThemeData.dark,
            theme: CustomThemeData.light,
            themeMode: CustomThemeMode.themeMode.value,
            home: const Navigation(),
          ),
          // AuthWrapper(),
        );
      },
    );
  }

  // Future<void> _checkLoginStatus(BuildContext context) async {
  //   final storage = FlutterSecureStorage();
  //   String? token = await storage.read(key: 'token'); // 저장된 토큰 확인
  //   final provider =
  //       Provider.of<NavigationToggleProvider>(context, listen: false);

  //   if (token != null) {
  //     provider.selectIndex(0); // 토큰이 있으면 홈으로 이동
  //     log("토큰 있음");
  //   } else {
  //     provider.selectIndex(-1); // 토큰이 없으면 로그인 화면으로 이동
  //     log("토큰 없음");
  //   }
  // }
}

// class AuthWrapper extends StatefulWidget {
//   const AuthWrapper({Key? key}) : super(key: key);

//   @override
//   _AuthWrapperState createState() => _AuthWrapperState();
// }

// class _AuthWrapperState extends State<AuthWrapper> {
//   String? token;

//   @override
//   void initState() {
//     super.initState();
//     log("initState wokring");
//     checkToken();
//   }

//   Future<void> checkToken() async {
//     final storage = FlutterSecureStorage();
//     final navigationProvider =
//         Provider.of<NavigationToggleProvider>(context, listen: false);
//     token = await storage.read(key: 'authToken');
//     if (token != null) {
//       // Token found, use it to sign in
//       try {
//         await FirebaseAuth.instance.signInWithCustomToken(token!);
//         setState(() {
//           // NavigationToggleProvider.selectedIndex = 0; // Go to home
//           navigationProvider.selectIndex(0);
//           log("token is here.");
//         });
//       } catch (e) {
//         setState(() {
//           // NavigationToggleProvider.selectedIndex = -1; // Go to login
//           navigationProvider.selectIndex(-1);
//           log("didn't work");
//         });
//       }
//     } else {
//       setState(() {
//         // NavigationToggleProvider.selectedIndex = -1; // Go to login
//         navigationProvider.selectIndex(-1);
//         log("no token");
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey,
//       debugShowCheckedModeBanner: true,
//       darkTheme: CustomThemeData.dark,
//       theme: CustomThemeData.light,
//       themeMode: CustomThemeMode.themeMode.value,
//       home: const Navigation(),
//     );
//     // Navigation(); // Main Navigation structure
//   }
// }
