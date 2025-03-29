import 'package:bandi_official/controller/alarm_controller.dart';
import 'package:bandi_official/controller/date_provider.dart';
import 'package:bandi_official/controller/diary_ai_analysis_controller.dart';
import 'package:bandi_official/controller/diary_ai_chat_controller.dart';
import 'package:bandi_official/controller/mail_controller.dart';
import 'package:bandi_official/controller/permission_controller.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/theme/custom_theme_mode.dart';
import 'package:bandi_official/view/navigation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badge_control/flutter_app_badge_control.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'controller/home_to_write.dart';
import 'controller/navigation_toggle_provider.dart';
import 'controller/securestorage_controller.dart';
import 'controller/user_info_controller.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'local.dart';

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
  // Initialize .env file
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
            ChangeNotifierProvider(
              create: (context) => SecureStorageProvider(),
            ),
            ChangeNotifierProvider(
              create: (context) => DateProvider(),
            ),
          ],
          child: MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            darkTheme: CustomThemeData.dark,
            theme: CustomThemeData.light,
            themeMode: CustomThemeMode.themeMode.value,
            localizationsDelegates: const [
              Local.delegate, // 생성된 delegate 추가
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ko', 'KR'),
              // Locale('ja', 'JP'), // 일본어 추가하고 싶으면 이런식으로 추가하고 local 파일에 isSupprottedd에 추가
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale!.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            home: const Navigation(),
          ),
          // AuthWrapper(),
        );
      },
    );
  }
}
