//lib/widgets/language_selector.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../provider/language_provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);

    return DropdownButton<String>(
      value: languageProvider.currentLocale.languageCode,
      items: [
        DropdownMenuItem(
          value: 'en',
          child: Text(localizations.english),
        ),
        DropdownMenuItem(
          value: 'es',
          child: Text(localizations.spanish),
        ),
        DropdownMenuItem(
          value: 'ca',
          child: Text(localizations.catalan),
        ),
      ],
      onChanged: (String? value) {
        if (value != null) {
          languageProvider.setLanguage(value);
        }
      },
    );
  }
} 