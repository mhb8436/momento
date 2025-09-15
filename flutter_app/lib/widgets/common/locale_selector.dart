import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../config/theme.dart';

class LocaleSelector extends StatelessWidget {
  final bool showFlag;
  final bool isCompact;
  
  const LocaleSelector({
    super.key,
    this.showFlag = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        return PopupMenuButton<Locale>(
          icon: _buildTrigger(context, localeProvider),
          onSelected: (locale) {
            localeProvider.setLocale(locale);
          },
          itemBuilder: (context) {
            return localeProvider.supportedLocales.map((locale) {
              final isSelected = localeProvider.currentLocale == locale;
              return PopupMenuItem<Locale>(
                value: locale,
                child: Row(
                  children: [
                    if (showFlag) ...[
                      Text(
                        _getFlagEmoji(locale),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        localeProvider.getLocaleName(locale),
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppTheme.primaryColor : null,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check,
                        size: 18,
                        color: AppTheme.primaryColor,
                      ),
                  ],
                ),
              );
            }).toList();
          },
        );
      },
    );
  }

  Widget _buildTrigger(BuildContext context, LocaleProvider localeProvider) {
    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showFlag) ...[
              Text(
                _getFlagEmoji(localeProvider.currentLocale),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              localeProvider.getLocaleName(localeProvider.currentLocale),
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 16),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.language,
            size: 20,
            color: AppTheme.primaryColor,
          ),
          if (showFlag) ...[
            const SizedBox(width: 4),
            Text(
              _getFlagEmoji(localeProvider.currentLocale),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ],
      ),
    );
  }

  String _getFlagEmoji(Locale locale) {
    switch ('${locale.languageCode}_${locale.countryCode}') {
      case 'ko_KR':
        return '🇰🇷';
      case 'en_US':
        return '🇺🇸';
      case 'ja_JP':
        return '🇯🇵';
      case 'es_ES':
        return '🇪🇸';
      default:
        return '🌍';
    }
  }
}

// Settings screen language selector
class LanguageSettingTile extends StatelessWidget {
  const LanguageSettingTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        return ListTile(
          leading: const Icon(Icons.language),
          title: Text(l10n.settings), // Use appropriate localized string
          subtitle: Text(localeProvider.getLocaleName(localeProvider.currentLocale)),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            _showLanguageDialog(context, localeProvider);
          },
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, LocaleProvider localeProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('언어 선택 / Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: localeProvider.supportedLocales.map((locale) {
              final isSelected = localeProvider.currentLocale == locale;
              return ListTile(
                leading: Text(
                  _getFlagEmoji(locale),
                  style: const TextStyle(fontSize: 20),
                ),
                title: Text(localeProvider.getLocaleName(locale)),
                trailing: isSelected 
                    ? Icon(Icons.check, color: AppTheme.primaryColor)
                    : null,
                selected: isSelected,
                onTap: () {
                  localeProvider.setLocale(locale);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        );
      },
    );
  }

  String _getFlagEmoji(Locale locale) {
    switch ('${locale.languageCode}_${locale.countryCode}') {
      case 'ko_KR':
        return '🇰🇷';
      case 'en_US':
        return '🇺🇸';
      case 'ja_JP':
        return '🇯🇵';
      case 'es_ES':
        return '🇪🇸';
      default:
        return '🌍';
    }
  }
}