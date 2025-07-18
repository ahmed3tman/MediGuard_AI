import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spider_doctor/core/shared/theme/my_colors.dart';
import 'locale_cubit.dart';
import '../../l10n/generated/app_localizations.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return PopupMenuButton<String>(
          icon: const Icon(Icons.language, color: AppColors.primaryColor),
          onSelected: (String languageCode) {
            context.read<LocaleCubit>().changeLanguage(languageCode);
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'en',
              child: Row(
                children: [
                  const Icon(Icons.flag, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context).english),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'ar',
              child: Row(
                children: [
                  const Icon(Icons.flag, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context).arabic),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class LanguageDialog extends StatelessWidget {
  const LanguageDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).selectLanguage),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.flag, color: Colors.blue),
            title: Text(AppLocalizations.of(context).english),
            onTap: () async {
              await context.read<LocaleCubit>().changeLanguage('en');
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.flag, color: Colors.green),
            title: Text(AppLocalizations.of(context).arabic),
            onTap: () async {
              await context.read<LocaleCubit>().changeLanguage('ar');
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class LanguageSettingTile extends StatelessWidget {
  const LanguageSettingTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return ListTile(
          leading: const Icon(Icons.language),
          title: Text(AppLocalizations.of(context).language),
          subtitle: Text(
            locale.languageCode == 'en'
                ? AppLocalizations.of(context).english
                : AppLocalizations.of(context).arabic,
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const LanguageDialog(),
            );
          },
        );
      },
    );
  }
}
