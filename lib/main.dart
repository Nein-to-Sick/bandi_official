import 'package:bandi_official/controller/diary_ai_analysis_controller.dart';
import 'package:bandi_official/controller/diary_ai_chat_controller.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/theme/custom_theme_mode.dart';
import 'package:bandi_official/view/navigation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'controller/home_to_write.dart';
import 'controller/navigation_toggle_provider.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  CustomThemeMode.instance;
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: 'assets/config/.env');

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: CustomThemeMode.themeMode,
      builder: (context, mode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: true,
          darkTheme: CustomThemeData.dark,
          theme: CustomThemeData.light,
          themeMode: CustomThemeMode.themeMode.value,
          home: MultiProvider(
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
            ],
            child: const Navigation(),
          ),
        );
      },
    );
  }
}
