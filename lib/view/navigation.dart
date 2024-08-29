import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:bandi_official/controller/alarm_controller.dart';
import 'package:bandi_official/controller/diary_ai_chat_controller.dart';
import 'package:bandi_official/controller/mail_controller.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/home/home_view.dart';
import 'package:bandi_official/view/list/list_view.dart';
import 'package:bandi_official/view/login/login_view.dart';
import 'package:bandi_official/view/mail/mail_view.dart';
import 'package:bandi_official/view/otherDiary.dart';
import 'package:bandi_official/view/user/user_view.dart';
import 'package:bandi_official/view/login/login_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/no_reuse/firefly.dart';
import '../components/no_reuse/navigation_bar.dart';
import '../controller/home_to_write.dart';
import '../controller/navigation_toggle_provider.dart';

late AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer.newPlayer();
bool speakerOn = true; // Default to true

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  @override
  void initState() {
    super.initState();
    _loadSpeakerPreference();
  }

  // Load the speakerOn preference from SharedPreferences
  Future<void> _loadSpeakerPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      speakerOn =
          prefs.getBool('speakerOn') ?? true; // Default to true if not found
    });
    _initializeAudio();
  }

  // Initialize audio based on the speakerOn preference
  void _initializeAudio() {
    assetsAudioPlayer.open(
      Audio("assets/bgm/bgm.mp3"),
      loopMode: LoopMode.single, // Repeat mode (LoopMode.none: No repeat)
      autoStart: speakerOn, // Auto start based on speakerOn
      showNotification: false, // Show notification on smartphone
    );
  }

  @override
  Widget build(BuildContext context) {
    final navigationToggleProvider =
        Provider.of<NavigationToggleProvider>(context);
    final writeProvider = Provider.of<HomeToWrite>(context);
    final DiaryAiChatController diaryAiChatController =
        context.watch<DiaryAiChatController>();
    final MailController mailController = context.watch<MailController>();
    final AlarmController alarmController = context.watch<AlarmController>();

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image:
              AssetImage('assets/images/backgrounds/background.png'), // 배경 이미지
        ),
      ),
      child: Scaffold(
        backgroundColor: BandiColor.transparent(context),
        body: Stack(
          children: [
            const FireFly(),
            (writeProvider.otherDiaryOpen == true && writeProvider.step == 1)
                ? OtherDiary(
                    writeProvider: writeProvider,
                  )
                : navigationToggleProvider.selectedIndex == -1
                    ? const LoginView()
                    : navigationToggleProvider.selectedIndex == 0
                        ? const HomePage()
                        : navigationToggleProvider.selectedIndex == 1
                            ? const ListPage()
                            : navigationToggleProvider.selectedIndex == 2
                                ? AnimatedOpacity(
                                    opacity:
                                        (!mailController.isDetailViewShowing)
                                            ? 1.0
                                            : 0.0,
                                    duration: const Duration(milliseconds: 300),
                                    child: const MailView(),
                                  )
                                : const UserView(),
            if (navigationToggleProvider.selectedIndex >= 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    (!writeProvider.write &&
                                !diaryAiChatController.isChatOpen &&
                                !mailController.isDetailViewShowing &&
                                !alarmController.isAlarmOpen) &&
                            !(writeProvider.otherDiaryOpen == true &&
                                writeProvider.step == 1)
                        ? navigationBar(context)
                        : Container()
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
