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
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                                        ? BandiColor.foundationColor100(context)
                                        : BandiColor.foundationColor20(context),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                      ],
                    ),
                    Stack(
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          bottom: 0,
                          left: MediaQuery.of(context).size.width /
                              provider.emotionKeys.length *
                              provider.emotionKeys
                                  .indexOf(provider.selectedEmotion),
                          child: Container(
                            width: MediaQuery.of(context).size.width /
                                provider.emotionKeys.length,
                            height: 2,
                            color: BandiColor.foundationColor100(context),
                          ),
                        ),
                        const Divider(),

                      ],
                    ),

                  ],
                ),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: provider.emotionOptions.map<Widget>((emotion) {
                    return ChoiceChip(
                      label: Text(emotion),
                      selected: provider.selectedEmotions.contains(emotion),
                      onSelected: (selected) {
                        if (selected) {
                          provider.addEmotion(emotion);
                        } else {
                          provider.removeEmotion(emotion);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                CustomPrimaryButton(
                  title: '확인',
                  onPrimaryButtonPressed: () {
                    Navigator.pop(context);
                  },
                  disableButton: false,
                ),
              ],
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
