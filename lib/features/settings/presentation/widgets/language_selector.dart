import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starter_app/core/constants/constants.dart';
import 'package:starter_app/core/presentation/bloc/bloc.dart';
import 'package:starter_app/core/presentation/responsive/responsive.dart';
import 'package:starter_app/features/settings/l10n/l10n_extensions.dart';

final class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.settingsL10n;
    final textTheme = TextTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.languageSectionTitle,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const ResponsiveVerticalGap(
          height: PaddingConstants.small,
        ),
        Wrap(
          spacing: PaddingConstants.small,
          runSpacing: PaddingConstants.small,
          children: [
            ElevatedButton(
              onPressed: () {
                context.read<LocaleCubit>().setEnglish();
              },
              child: Text(l10n.languageEnglish),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<LocaleCubit>().setSpanish();
              },
              child: Text(l10n.languageSpanish),
            ),
          ],
        ),
      ],
    );
  }
}
