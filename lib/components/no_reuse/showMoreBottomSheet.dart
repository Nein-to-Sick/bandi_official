import 'package:bandi_official/string_extention.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/emotion_provider.dart';
import '../../controller/home_to_write.dart';
import '../../theme/custom_theme_data.dart';
import '../button/primary_button.dart';

class EmotionBottomSheet extends StatefulWidget {
  const EmotionBottomSheet({
    super.key,
    required this.emotion,
    required this.writeProvider,
    required this.provider,
  });

  final List<dynamic> emotion;
  final HomeToWrite writeProvider;
  final EmotionProvider provider;

  @override
  _EmotionBottomSheetState createState() => _EmotionBottomSheetState();
}

class _EmotionBottomSheetState extends State<EmotionBottomSheet> {
  final List<GlobalKey> _tabKeys = [];
  double _underlineLeft = 24;
  double _underlineWidth = 43.7684326171875;
  bool _isInitialized = false;
  bool _providerInitialized = false;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateUnderline);
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final provider = widget.provider;
        await provider.initialize(context);

        _tabKeys.clear();
        _tabKeys.addAll(List.generate(provider.emotionKeys.length, (_) => GlobalKey()));

        for (String emotion in widget.emotion) {
          if (!provider.selectedEmotions.contains(emotion)) {
            provider.selectedEmotions.add(emotion);
          }
        }

        _updateUnderline();

        setState(() {
          _providerInitialized = true;
        });
      });
      _isInitialized = true;
    }

  }

  void _updateUnderline() {
    final selectedIndex = widget.provider.emotionKeys.indexOf(widget.provider.selectedEmotion);
    if (selectedIndex < 0 || selectedIndex >= _tabKeys.length) return;
    final key = _tabKeys[selectedIndex];
    final ctx = key.currentContext;
    if (ctx == null) return;

    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return;

    final position = box.localToGlobal(Offset.zero, ancestor: context.findRenderObject());

    setState(() {
      _underlineLeft = position.dx;
      _underlineWidth = box.size.width;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateUnderline);
    _scrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<EmotionProvider>(
      builder: (context, provider, _) {
        if (!provider.isInitialized || !_providerInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        final isEnglish = Localizations.localeOf(context).languageCode == 'en';

        Widget emotionTabBar = isEnglish
            ? Column(
          children: [
            SingleChildScrollView(
              controller: _scrollController,  // ✅ 여기에 추가
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: List.generate(provider.emotionKeys.length, (i) {
                    final isSelected = provider.selectedEmotion == provider.emotionKeys[i];
                    return GestureDetector(
                      key: _tabKeys[i],
                      onTap: () {
                        provider.selectEmotion(provider.emotionKeys[i]);
                        WidgetsBinding.instance.addPostFrameCallback((_) => _updateUnderline());
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              provider.emotionKeys[i],
                              style: BandiFont.headlineMedium(context)?.copyWith(
                                color: isSelected
                                    ? BandiColor.foundationColor100(context)
                                    : BandiColor.foundationColor20(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            Stack(
              children: [
                Divider(
                    height: 1,
                    color: BandiColor.foundationColor10(context)),
                Positioned(
                  left: _underlineLeft,
                  bottom: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: _underlineWidth,
                    height: 2,
                    color: BandiColor.foundationColor100(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
          ],
        )
            : Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(provider.emotionKeys.length, (i) {
                final isSelected = provider.selectedEmotion == provider.emotionKeys[i];
                return GestureDetector(
                  key: _tabKeys[i], // 👈 key 추가
                  onTap: () {
                    provider.selectEmotion(provider.emotionKeys[i]);
                    WidgetsBinding.instance.addPostFrameCallback((_) => _updateUnderline());
                  },
                  child: Column(
                    children: [
                      Text(
                        provider.emotionKeys[i],
                        style: BandiFont.headlineMedium(context)?.copyWith(
                          color: isSelected
                              ? BandiColor.foundationColor100(context)
                              : BandiColor.foundationColor20(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              }),
            ),
            Stack(
              children: [
                Divider(
                  height: 1,
                  color: BandiColor.foundationColor10(context),
                ),
                Positioned(
                  left: _underlineLeft,
                  bottom: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: _underlineWidth,
                    height: 2,
                    color: BandiColor.foundationColor100(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
          ],
        );

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
                emotionTabBar,
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24), // 양쪽 여백 24px
                    child: Align(
                      alignment: Alignment.topLeft, // 왼쪽 정렬 보장
                      child: Wrap(
                        alignment: WrapAlignment.start, // 줄 내에서 왼쪽 정렬
                        spacing: 8, // 가로 간격
                        runSpacing: 8, // 세로 간격
                        children: provider.emotionOptions.map((emotion) {
                          final isSelected = provider.selectedEmotions.contains(emotion);
                          return GestureDetector(
                            onTap: () => provider.toggleEmotion(emotion),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? BandiColor.foundationColor100(context)
                                    : BandiColor.foundationColor10(context),
                                borderRadius: BandiEffects.radius(),
                              ),
                              child: Text(
                                "emotion_keyword_$emotion".tr(context),
                                style: BandiFont.bodySmall(context)?.copyWith(
                                  color: isSelected
                                      ? BandiColor.neutralColor80(context)
                                      : BandiColor.foundationColor20(context),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),



                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: CustomPrimaryButton(
                    title: 'confirm'.tr(context),
                    onPrimaryButtonPressed: () {
                      widget.writeProvider.changeDiaryValue(provider.selectedEmotions);
                      Navigator.pop(context);
                    },
                    disableButton: false,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void showMoreBottomSheet(BuildContext context, HomeToWrite writeProvider) {
  final emotionProvider = EmotionProvider();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return ChangeNotifierProvider.value(
        value: emotionProvider,
        child: Builder(
          builder: (context) {
            return EmotionBottomSheet(
              writeProvider: writeProvider,
              emotion: writeProvider.diaryModel.emotion,
              provider: emotionProvider,
            );
          },
        ),
      );
    },
  );
}
