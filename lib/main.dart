import 'package:bandi_official/controller/alarm_controller.dart';
import 'package:bandi_official/controller/diary_ai_analysis_controller.dart';
import 'package:bandi_official/controller/diary_ai_chat_controller.dart';
import 'package:bandi_official/controller/mail_controller.dart';
import 'package:bandi_official/controller/permission_controller.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/theme/custom_theme_mode.dart';
import 'package:bandi_official/view/navigation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
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

  runApp(const MainApp());
}

backgroundHandler() {
  // Put handling  here.
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
        );
      },
    );
  }
}
