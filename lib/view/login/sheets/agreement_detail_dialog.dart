import 'package:flutter/material.dart';
import 'package:wrapped_korean_text/wrapped_korean_text.dart';

import '../../../string_extention.dart';
import '../../../theme/custom_theme_data.dart';
import '../../../components/button/primary_button.dart';

Future<void> showAgreementDetailDialog(
    BuildContext context, {
      required List<List<String>> data,
      required String titleKey,
    }) {
  return showDialog(
    context: context,
    useSafeArea: false,
    barrierDismissible: false,
    builder: (ctx) {
      return _AgreementDetailDialog(
        title: titleKey.tr(ctx),
        data: data,
      );
    },
  );
}

class _AgreementDetailDialog extends StatelessWidget {
  final String title;
  final List<List<String>> data;

  const _AgreementDetailDialog({
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Material(
      color: Colors.transparent,
      child: Container(
        color: BandiColor.neutralColor80(context),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: [
              // ===== Header =====
              Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: safeTop + 18,
                  bottom: 14,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: BandiFont.headlineMedium(context)?.copyWith(
                      color: BandiColor.foundationColor100(context),
                    ),
                  ),
                ),
              ),

              Divider(
                color: BandiColor.foundationColor04(context),
                thickness: 1,
                height: 1,
              ),

              // ===== Content + Bottom button overlay =====
              Expanded(
                child: Stack(
                  children: [
                    // Scroll content
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          top: 18,
                          bottom: 140 + safeBottom, // 버튼 공간 확보
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0; i < data.length; i++) ...[
                              if (i != 0) const SizedBox(height: 26),
                              _AgreementSection(
                                sectionTitle: data[i][0],
                                sectionBody: data[i][1],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Bottom button
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: safeBottom,
                      child: CustomPrimaryButton(
                        title: 'onboarding_button'.tr(context), // "닫기" 등
                        onPrimaryButtonPressed: () => Navigator.pop(context),
                        disableButton: false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgreementSection extends StatelessWidget {
  final String sectionTitle;
  final String sectionBody;

  const _AgreementSection({
    required this.sectionTitle,
    required this.sectionBody,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = BandiFont.titleSmall(context)?.copyWith(
      color: BandiColor.foundationColor90(context),
      height: 1.15,
    );

    final bodyStyle = BandiFont.bodyMedium(context)!.copyWith(
      color: BandiColor.foundationColor90(context),
      height: 1.35,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WrappedKoreanText(
          sectionTitle.trim(),
          style: titleStyle,
        ),
        const SizedBox(height: 10),
        _AgreementBodyRenderer(
          text: sectionBody,
          bodyStyle: bodyStyle,
        ),
      ],
    );
  }
}

/// 본문 문자열을 줄 단위로 파싱해서
/// - "- " 로 시작하면 bullet
/// - 일반 줄은 문단
/// - 빈 줄은 작은 간격(문단 분리)
class _AgreementBodyRenderer extends StatelessWidget {
  final String text;
  final TextStyle bodyStyle;

  const _AgreementBodyRenderer({
    required this.text,
    required this.bodyStyle,
  });

  @override
  Widget build(BuildContext context) {
    final lines = _normalize(text).split('\n');

    final widgets = <Widget>[];
    for (final raw in lines) {
      final line = raw.trimRight();

      // 완전 빈 줄: 문단 간격만 조금
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 10));
        continue;
      }

      // bullet 처리
      if (line.trimLeft().startsWith('- ')) {
        final content = line.trimLeft().substring(2).trim();
        widgets.add(_BulletLine(
          text: content,
          style: bodyStyle,
        ));
        continue;
      }

      // 일반 문단
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: WrappedKoreanText(
            line,
            style: bodyStyle,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  String _normalize(String s) {
    // 너무 많은 줄바꿈(3줄 이상)을 2줄로 제한 (과한 공백 방지)
    return s.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  }
}

class _BulletLine extends StatelessWidget {
  final String text;
  final TextStyle style;

  const _BulletLine({
    required this.text,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 10, left: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // bullet dot
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: BandiColor.foundationColor90(context),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // text
          Expanded(
            child: WrappedKoreanText(
              text,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}
