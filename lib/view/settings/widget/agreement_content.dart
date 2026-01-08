import 'package:flutter/material.dart';
import 'package:wrapped_korean_text/wrapped_korean_text.dart';

import '../../../theme/custom_theme_data.dart';

class AgreementSection extends StatelessWidget {
  final String sectionTitle;
  final String sectionBody;

  const AgreementSection({
    super.key,
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
        AgreementBodyRenderer(
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
class AgreementBodyRenderer extends StatelessWidget {
  final String text;
  final TextStyle bodyStyle;

  const AgreementBodyRenderer({
    super.key,
    required this.text,
    required this.bodyStyle,
  });

  @override
  Widget build(BuildContext context) {
    final lines = _normalize(text).split('\n');

    final widgets = <Widget>[];
    for (final raw in lines) {
      final line = raw.trimRight();

      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 10));
        continue;
      }

      if (line.trimLeft().startsWith('- ')) {
        final content = line.trimLeft().substring(2).trim();
        widgets.add(AgreementBulletLine(text: content, style: bodyStyle));
        continue;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: WrappedKoreanText(line, style: bodyStyle),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  String _normalize(String s) {
    return s.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  }
}

class AgreementBulletLine extends StatelessWidget {
  final String text;
  final TextStyle style;

  const AgreementBulletLine({
    super.key,
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
          Expanded(
            child: WrappedKoreanText(text, style: style),
          ),
        ],
      ),
    );
  }
}
