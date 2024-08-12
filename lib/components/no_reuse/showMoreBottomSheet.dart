import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/emotion_provider.dart';
import '../../theme/custom_theme_data.dart';
import '../button/primary_button.dart';

class EmotionBottomSheet extends StatefulWidget {
  @override
  _EmotionBottomSheetState createState() => _EmotionBottomSheetState();
}

class _EmotionBottomSheetState extends State<EmotionBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final emotionProvider = Provider.of<EmotionProvider>(context);

    return ChangeNotifierProvider.value(
      value: emotionProvider,
      child: Consumer<EmotionProvider>(
        builder: (context, provider, child) {
          double flag = 0;
          int index = provider.emotionKeys.indexOf(provider.selectedEmotion);
          if (index < 3) {
            flag = 3;
          } else if (index == 3) {
            flag = 1;
          } else if (index == 4) {
            flag = 0;
          } else if (index == 5) {
            flag = -0.5;
          }
          return SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.58,
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 상단 키워드
                  Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (int i = 0; i < provider.emotionKeys.length; i++)
                            GestureDetector(
                              onTap: () {
                                provider.selectEmotion(provider.emotionKeys[i]);
                              },
                              child: Column(
                                children: [
                                  Text(
                                    provider.emotionKeys[i],
                                    style: BandiFont.headlineMedium(context)
                                        ?.copyWith(
                                      color: provider.selectedEmotion ==
                                              provider.emotionKeys[i]
                                          ? BandiColor.foundationColor100(
                                              context)
                                          : BandiColor.foundationColor20(
                                              context),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 34.0),
                        child: Stack(
                          children: [
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              bottom: 0,
                              left: (MediaQuery.of(context).size.width - 25) /
                                      6 *
                                      provider.emotionKeys
                                          .indexOf(provider.selectedEmotion) +
                                  22 +
                                  flag *
                                      (provider.emotionKeys
                                          .indexOf(provider.selectedEmotion)),
                              child: Container(
                                width:
                                    (MediaQuery.of(context).size.width - 115) /
                                        6,
                                height: 2,
                                color: BandiColor.foundationColor100(context),
                              ),
                            ),
                            Divider(
                                height: 1,
                                color: BandiColor.foundationColor10(context)),
                            Container(
                              height: 2,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  // emotion sets
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 24, left: 24, right: 24, bottom: 24),
                                  child: Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    children: provider.emotionOptions
                                        .map<Widget>((emotion) {
                                      return GestureDetector(
                                        onTap: () {
                                          if (provider.selectedEmotions
                                              .contains(emotion)) {
                                            provider.removeEmotion(emotion);
                                          } else {
                                            provider.addEmotion(emotion);
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            color: provider.selectedEmotions
                                                    .contains(emotion)
                                                ? BandiColor.foundationColor100(
                                                    context) // selected color
                                                : BandiColor.foundationColor10(
                                                    context), // unselected color
                                            borderRadius: BandiEffects.radius(),
                                          ),
                                          child: Text(
                                            emotion,
                                            style: BandiFont.bodySmall(context)
                                                ?.copyWith(
                                              color: provider.selectedEmotions
                                                      .contains(emotion)
                                                  ? BandiColor.neutralColor80(
                                                      context) // selected text color
                                                  : BandiColor.foundationColor20(
                                                      context), // unselected text color
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomPrimaryButton(
                            title: '확인',
                            onPrimaryButtonPressed: () {
                              Navigator.pop(context);
                            },
                            disableButton: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

void showMoreBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return MultiProvider(providers: [
        ChangeNotifierProvider(
          create: (context) => EmotionProvider(),
        ),
      ], child: EmotionBottomSheet());
    },
  );
}
