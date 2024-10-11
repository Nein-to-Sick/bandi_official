import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';

class FontTest extends StatelessWidget {
  const FontTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              color: Colors.black,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'displayLarge',
                      style: BandiFont.displayLarge(context)?.copyWith(
                        color: BandiColor.neutralColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'displayMedium',
                      style: BandiFont.displayMedium(context)?.copyWith(
                        color: BandiColor.neutralColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'displaySmall',
                      style: BandiFont.displaySmall(context)?.copyWith(
                        color: BandiColor.neutralColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'headlineMedium',
                      style: BandiFont.headlineMedium(context)?.copyWith(
                        color: BandiColor.neutralColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'headlineSmall',
                      style: BandiFont.headlineSmall(context)?.copyWith(
                        color: BandiColor.neutralColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'titleLarge',
                      style: BandiFont.titleLarge(context)?.copyWith(
                        color: BandiColor.neutralColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'titleMedium',
                      style: BandiFont.titleMedium(context)?.copyWith(
                        color: BandiColor.neutralColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'titleSmall',
                      style: BandiFont.titleSmall(context)?.copyWith(
                        color: BandiColor.neutralColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'bodyLarge',
                      style: BandiFont.bodyLarge(context)?.copyWith(
                        color: BandiColor.neutralColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'bodyMedium',
                      style: BandiFont.bodyMedium(context)?.copyWith(
                        color: BandiColor.neutralColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'bodySmall',
                      style: BandiFont.bodySmall(context)?.copyWith(
                        color: BandiColor.neutralColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'labelLarge',
                      style: BandiFont.labelLarge(context)?.copyWith(
                        color: BandiColor.neutralColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'labelMedium',
                      style: BandiFont.labelMedium(context)?.copyWith(
                        color: BandiColor.neutralColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'labelSmall',
                      style: BandiFont.labelSmall(context)?.copyWith(
                        color: BandiColor.neutralColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'headlineLarge',
                      style: BandiFont.headlineLarge(context)?.copyWith(
                        color: BandiColor.neutralColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.white,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'displayLarge',
                      style: BandiFont.displayLarge(context)?.copyWith(
                        color: BandiColor.foundationColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'displayMedium',
                      style: BandiFont.displayMedium(context)?.copyWith(
                        color: BandiColor.foundationColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'displaySmall',
                      style: BandiFont.displaySmall(context)?.copyWith(
                        color: BandiColor.foundationColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'headlineMedium',
                      style: BandiFont.headlineMedium(context)?.copyWith(
                        color: BandiColor.foundationColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'headlineSmall',
                      style: BandiFont.headlineSmall(context)?.copyWith(
                        color: BandiColor.foundationColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'titleLarge',
                      style: BandiFont.titleLarge(context)?.copyWith(
                        color: BandiColor.foundationColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'titleMedium',
                      style: BandiFont.titleMedium(context)?.copyWith(
                        color: BandiColor.foundationColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'titleSmall',
                      style: BandiFont.titleSmall(context)?.copyWith(
                        color: BandiColor.foundationColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'bodyLarge',
                      style: BandiFont.bodyLarge(context)?.copyWith(
                        color: BandiColor.foundationColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'bodyMedium',
                      style: BandiFont.bodyMedium(context)?.copyWith(
                        color: BandiColor.foundationColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'bodySmall',
                      style: BandiFont.bodySmall(context)?.copyWith(
                        color: BandiColor.foundationColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'labelLarge',
                      style: BandiFont.labelLarge(context)?.copyWith(
                        color: BandiColor.foundationColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'labelMedium',
                      style: BandiFont.labelMedium(context)?.copyWith(
                        color: BandiColor.foundationColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'labelSmall',
                      style: BandiFont.labelSmall(context)?.copyWith(
                        color: BandiColor.foundationColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'headlineLarge',
                      style: BandiFont.headlineLarge(context)?.copyWith(
                        color: BandiColor.foundationColor80(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
