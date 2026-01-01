// widgets/language_toggle_switch.dart
import 'package:flutter/material.dart';
import '../../controller/deepl_service.dart';
import '../../theme/custom_theme_data.dart';

class LanguageToggleSwitch extends StatefulWidget {
  final String originalContent;
  final String originalTitle;

  /// 초기 언어 값 ('KO' 또는 'EN')
  final String initialLanguage;

  /// 토글 완료 후 번역된 결과(내용, 제목, 현재 언어)를 부모 위젯에 전달하는 콜백 함수
  final void Function(String content, String title, String currentLanguage)
  onToggleCompleted;

  const LanguageToggleSwitch({
    super.key,
    required this.originalContent,
    required this.originalTitle,
    required this.initialLanguage,
    required this.onToggleCompleted,
  });

  @override
  _LanguageToggleSwitchState createState() => _LanguageToggleSwitchState();
}

class _LanguageToggleSwitchState extends State<LanguageToggleSwitch> {
  bool isKorean = true;
  bool isLoading = false;
  String? cachedEnglishContent;
  String? cachedEnglishTitle;
  String? cachedKoreanContent;
  String? cachedKoreanTitle;

  final DeepLService _deepLService = DeepLService();

  @override
  void initState() {
    super.initState();
    // 초기 언어에 따라 상태를 결정합니다.
    isKorean = widget.initialLanguage == 'KO';
  }

  Future<void> _handleToggle() async {
    setState(() {
      isLoading = true;
    });
    try {
      // 원본 언어가 한글인 경우
      if (widget.initialLanguage == 'KO') {
        if (isKorean) {
          // 현재 한글이면 영어로 번역
          if (cachedEnglishContent != null && cachedEnglishTitle != null) {
            setState(() {
              isKorean = false;
              isLoading = false;
            });
            widget.onToggleCompleted(
                cachedEnglishContent!, cachedEnglishTitle!, 'EN');
          } else {
            final translatedContent =
            await _deepLService.translate(widget.originalContent, 'EN');
            final translatedTitle =
            await _deepLService.translate(widget.originalTitle, 'EN');
            setState(() {
              cachedEnglishContent = translatedContent;
              cachedEnglishTitle = translatedTitle;
              isKorean = false;
              isLoading = false;
            });
            widget.onToggleCompleted(translatedContent, translatedTitle, 'EN');
          }
        } else {
          // 현재 영어이면 원문(한글)으로 복원
          setState(() {
            isKorean = true;
            isLoading = false;
          });
          widget.onToggleCompleted(
              widget.originalContent, widget.originalTitle, 'KO');
        }
      } else {
        // 원본 언어가 영어인 경우
        if (!isKorean) {
          // 현재 영어이면 한국어로 번역
          if (cachedKoreanContent != null && cachedKoreanTitle != null) {
            setState(() {
              isKorean = true;
              isLoading = false;
            });
            widget.onToggleCompleted(
                cachedKoreanContent!, cachedKoreanTitle!, 'KO');
          } else {
            final translatedContent =
            await _deepLService.translate(widget.originalContent, 'KO');
            final translatedTitle =
            await _deepLService.translate(widget.originalTitle, 'KO');
            setState(() {
              cachedKoreanContent = translatedContent;
              cachedKoreanTitle = translatedTitle;
              isKorean = true;
              isLoading = false;
            });
            widget.onToggleCompleted(translatedContent, translatedTitle, 'KO');
          }
        } else {
          // 현재 한국어이면 원문(영어)으로 복원
          setState(() {
            isKorean = false;
            isLoading = false;
          });
          widget.onToggleCompleted(
              widget.originalContent, widget.originalTitle, 'EN');
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // 오류 발생 시 원문 상태로 복원
      widget.onToggleCompleted(
          widget.originalContent, widget.originalTitle, widget.initialLanguage);
    }
  }

  @override
  Widget build(BuildContext context) {
    String toggleText;
    if (widget.initialLanguage == 'KO') {
      // 원본이 한글일 경우
      toggleText = isKorean ? 'Translate' : 'See original';
    } else {
      // 원본이 영어일 경우
      toggleText = isKorean ? '원본 보기' : '한글로 번역하기';
    }
    return GestureDetector(
      onTap: _handleToggle,
      child: Row(
        children: [
          Image.asset(
            "./assets/images/icons/translateToggleImage.png",
            scale: 1.8,
          ),
          const SizedBox(width: 4),
          Text(
            toggleText,
            style: BandiFont.bodySmall(context)
                ?.copyWith(color: BandiColor.foundationColor80(context)),
          ),
          if (isLoading)
            const SizedBox(
                width: 16, height: 16, child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
