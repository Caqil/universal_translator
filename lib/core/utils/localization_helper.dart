// lib/core/utils/localization_helper.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LocalizationHelper {
  // Complete language mapping for Easy Localization
  static String mapLanguageCode(String code) {
    final languageMap = {
      // Major languages
      'en': 'en-US',
      'es': 'es-ES',
      'fr': 'fr-FR',
      'de': 'de-DE',
      'it': 'it-IT',
      'pt': 'pt-BR',
      'ru': 'ru-RU',
      'ja': 'ja-JP',
      'ko': 'ko-KR',
      'zh': 'zh-CN',
      'ar': 'ar-SA',
      'hi': 'hi-IN',

      // European languages
      'nl': 'nl-NL', // Dutch
      'pl': 'pl-PL', // Polish
      'sv': 'sv-SE', // Swedish
      'da': 'da-DK', // Danish
      'no': 'nb-NO', // Norwegian
      'fi': 'fi-FI', // Finnish
      'cs': 'cs-CZ', // Czech
      'hu': 'hu-HU', // Hungarian
      'ro': 'ro-RO', // Romanian
      'bg': 'bg-BG', // Bulgarian
      'hr': 'hr-HR', // Croatian
      'sk': 'sk-SK', // Slovak
      'sl': 'sl-SI', // Slovenian
      'et': 'et-EE', // Estonian
      'lv': 'lv-LV', // Latvian
      'lt': 'lt-LT', // Lithuanian
      'mt': 'mt-MT', // Maltese
      'ga': 'ga-IE', // Irish
      'gl': 'gl-ES', // Galician
      'ca': 'ca-ES', // Catalan
      'eu': 'eu-ES', // Basque
      'el': 'el-GR', // Greek
      'tr': 'tr-TR', // Turkish
      'uk': 'uk-UA', // Ukrainian
      'mk': 'mk-MK', // Macedonian
      'sq': 'sq-AL', // Albanian
      'sr': 'sr-RS', // Serbian
      'bs': 'bs-BA', // Bosnian
      'me': 'me-ME', // Montenegrin

      // Asian languages
      'th': 'th-TH', // Thai
      'vi': 'vi-VN', // Vietnamese
      'id': 'id-ID', // Indonesian
      'ms': 'ms-MY', // Malay
      'tl': 'tl-PH', // Filipino/Tagalog
      'my': 'my-MM', // Burmese
      'km': 'km-KH', // Khmer
      'lo': 'lo-LA', // Lao
      'ka': 'ka-GE', // Georgian
      'hy': 'hy-AM', // Armenian
      'az': 'az-AZ', // Azerbaijani
      'kk': 'kk-KZ', // Kazakh
      'ky': 'ky-KG', // Kyrgyz
      'uz': 'uz-UZ', // Uzbek
      'tg': 'tg-TJ', // Tajik
      'mn': 'mn-MN', // Mongolian
      'ne': 'ne-NP', // Nepali
      'si': 'si-LK', // Sinhala
      'ta': 'ta-IN', // Tamil
      'te': 'te-IN', // Telugu
      'kn': 'kn-IN', // Kannada
      'ml': 'ml-IN', // Malayalam
      'gu': 'gu-IN', // Gujarati
      'pa': 'pa-IN', // Punjabi
      'bn': 'bn-BD', // Bengali
      'or': 'or-IN', // Odia
      'as': 'as-IN', // Assamese
      'mr': 'mr-IN', // Marathi
      'ur': 'ur-PK', // Urdu
      'fa': 'fa-IR', // Persian/Farsi
      'ps': 'ps-AF', // Pashto
      'he': 'he-IL', // Hebrew

      // African languages
      'ar-EG': 'ar-EG', // Egyptian Arabic
      'ar-SA': 'ar-SA', // Saudi Arabic
      'ar-AE': 'ar-AE', // UAE Arabic
      'sw': 'sw-KE', // Swahili
      'am': 'am-ET', // Amharic
      'ha': 'ha-NG', // Hausa
      'yo': 'yo-NG', // Yoruba
      'ig': 'ig-NG', // Igbo
      'zu': 'zu-ZA', // Zulu
      'af': 'af-ZA', // Afrikaans
      'xh': 'xh-ZA', // Xhosa
      'st': 'st-ZA', // Sotho
      'tn': 'tn-ZA', // Tswana
      'ss': 'ss-ZA', // Swati
      've': 've-ZA', // Venda
      'ts': 'ts-ZA', // Tsonga
      'nr': 'nr-ZA', // Ndebele
      'nso': 'nso-ZA', // Northern Sotho

      // Americas
      'pt-BR': 'pt-BR', // Brazilian Portuguese
      'pt-PT': 'pt-PT', // European Portuguese
      'es-ES': 'es-ES', // European Spanish
      'es-MX': 'es-MX', // Mexican Spanish
      'es-AR': 'es-AR', // Argentinian Spanish
      'es-CO': 'es-CO', // Colombian Spanish
      'es-CL': 'es-CL', // Chilean Spanish
      'es-PE': 'es-PE', // Peruvian Spanish
      'es-VE': 'es-VE', // Venezuelan Spanish
      'qu': 'qu-PE', // Quechua
      'gn': 'gn-PY', // Guarani
      'ay': 'ay-BO', // Aymara
      'ht': 'ht-HT', // Haitian Creole

      // Pacific
      'mi': 'mi-NZ', // Maori
      'haw': 'haw-US', // Hawaiian
      'fj': 'fj-FJ', // Fijian
      'to': 'to-TO', // Tongan
      'sm': 'sm-WS', // Samoan

      // Constructed languages
      'eo': 'eo-001', // Esperanto
      'ia': 'ia-001', // Interlingua
      'ie': 'ie-001', // Interlingue
      'vo': 'vo-001', // Volapük

      // Regional variants
      'en-US': 'en-US', // American English
      'en-GB': 'en-GB', // British English
      'en-AU': 'en-AU', // Australian English
      'en-CA': 'en-CA', // Canadian English
      'en-IN': 'en-IN', // Indian English
      'en-ZA': 'en-ZA', // South African English
      'fr-FR': 'fr-FR', // French (France)
      'fr-CA': 'fr-CA', // French (Canada)
      'fr-BE': 'fr-BE', // French (Belgium)
      'fr-CH': 'fr-CH', // French (Switzerland)
      'de-DE': 'de-DE', // German (Germany)
      'de-AT': 'de-AT', // German (Austria)
      'de-CH': 'de-CH', // German (Switzerland)
      'it-IT': 'it-IT', // Italian (Italy)
      'it-CH': 'it-CH', // Italian (Switzerland)
      'zh-CN': 'zh-CN', // Chinese (Simplified)
      'zh-TW': 'zh-TW', // Chinese (Traditional)
      'zh-HK': 'zh-HK', // Chinese (Hong Kong)
      'zh-SG': 'zh-SG', // Chinese (Singapore)
    };

    return languageMap[code.toLowerCase()] ?? 'en-US';
  }

  // Get supported locales for Easy Localization
  static List<Locale> getSupportedLocales() {
    return [
      const Locale('en', 'US'), // English
      const Locale('es', 'ES'), // Spanish
      const Locale('fr', 'FR'), // French
      const Locale('de', 'DE'), // German
      const Locale('it', 'IT'), // Italian
      const Locale('pt', 'BR'), // Portuguese (Brazil)
      const Locale('ru', 'RU'), // Russian
      const Locale('ja', 'JP'), // Japanese
      const Locale('ko', 'KR'), // Korean
      const Locale('zh', 'CN'), // Chinese (Simplified)
      const Locale('ar', 'SA'), // Arabic
      const Locale('hi', 'IN'), // Hindi
      const Locale('nl', 'NL'), // Dutch
      const Locale('pl', 'PL'), // Polish
      const Locale('sv', 'SE'), // Swedish
      const Locale('da', 'DK'), // Danish
      const Locale('nb', 'NO'), // Norwegian
      const Locale('fi', 'FI'), // Finnish
      const Locale('cs', 'CZ'), // Czech
      const Locale('hu', 'HU'), // Hungarian
      const Locale('ro', 'RO'), // Romanian
      const Locale('tr', 'TR'), // Turkish
      const Locale('th', 'TH'), // Thai
      const Locale('vi', 'VN'), // Vietnamese
      const Locale('id', 'ID'), // Indonesian
      const Locale('uk', 'UA'), // Ukrainian
      const Locale('he', 'IL'), // Hebrew
      const Locale('fa', 'IR'), // Persian
      const Locale('ur', 'PK'), // Urdu
      const Locale('bn', 'BD'), // Bengali
      const Locale('ta', 'IN'), // Tamil
      const Locale('te', 'IN'), // Telugu
    ];
  }

  // Get locale from language code
  static Locale getLocaleFromCode(String code) {
    final mappedCode = mapLanguageCode(code);
    final parts = mappedCode.split('-');
    if (parts.length >= 2) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(parts[0]);
  }

  // Get language name with localization
  static String getLocalizedLanguageName(String code) {
    // Map language codes to translation keys
    final languageKeys = {
      'en': 'languages.english',
      'es': 'languages.spanish',
      'fr': 'languages.french',
      'de': 'languages.german',
      'it': 'languages.italian',
      'pt': 'languages.portuguese',
      'ru': 'languages.russian',
      'ja': 'languages.japanese',
      'ko': 'languages.korean',
      'zh': 'languages.chinese',
      'ar': 'languages.arabic',
      'hi': 'languages.hindi',
      'nl': 'languages.dutch',
      'pl': 'languages.polish',
      'sv': 'languages.swedish',
      'da': 'languages.danish',
      'no': 'languages.norwegian',
      'fi': 'languages.finnish',
      'cs': 'languages.czech',
      'hu': 'languages.hungarian',
      'ro': 'languages.romanian',
      'tr': 'languages.turkish',
      'th': 'languages.thai',
      'vi': 'languages.vietnamese',
      'id': 'languages.indonesian',
      'uk': 'languages.ukrainian',
      'he': 'languages.hebrew',
      'fa': 'languages.persian',
      'ur': 'languages.urdu',
      'bn': 'languages.bengali',
      'ta': 'languages.tamil',
      'te': 'languages.telugu',
    };

    final key = languageKeys[code.toLowerCase()];
    return key?.tr() ?? code.toUpperCase();
  }

  // Change app language
  static Future<void> changeLanguage(
      BuildContext context, String languageCode) async {
    final locale = getLocaleFromCode(languageCode);
    await context.setLocale(locale);
  }

  // Get current language code
  static String getCurrentLanguageCode(BuildContext context) {
    final locale = context.locale;
    return '${locale.languageCode}-${locale.countryCode}';
  }

  // Check if language is RTL
  static bool isRTL(String code) {
    const rtlLanguages = {
      'ar', 'ar-SA', 'ar-EG', 'ar-AE', 'ar-JO', 'ar-LB', 'ar-SY', 'ar-IQ',
      'he', 'he-IL',
      'fa', 'fa-IR',
      'ur', 'ur-PK',
      'ps', 'ps-AF',
      'yi', // Yiddish
      'ku', // Kurdish
      'sd', // Sindhi
      'ug', // Uyghur
    };
    return rtlLanguages.contains(code.toLowerCase());
  }

  // Get text direction
  static TextDirection getTextDirection(String code) {
    return isRTL(code) ? TextDirection.RTL : TextDirection.LTR;
  }

  // Format locale for display
  static String formatLocaleForDisplay(Locale locale) {
    return '${locale.languageCode}-${locale.countryCode}';
  }

  // Get fallback locale
  static Locale getFallbackLocale() {
    return const Locale('en', 'US');
  }

  // Validate if locale is supported
  static bool isSupportedLocale(Locale locale) {
    return getSupportedLocales().any((supportedLocale) =>
        supportedLocale.languageCode == locale.languageCode &&
        supportedLocale.countryCode == locale.countryCode);
  }
}

// Extension for easier locale handling
extension LocaleExtension on Locale {
  String get displayName {
    return LocalizationHelper.getLocalizedLanguageName(languageCode);
  }

  bool get isRTL {
    return LocalizationHelper.isRTL(languageCode);
  }

  TextDirection get textDirection {
    return LocalizationHelper.getTextDirection(languageCode);
  }
}

// Widget for language switching
class LanguageSwitcher extends StatelessWidget {
  final Function(String)? onLanguageChanged;

  const LanguageSwitcher({
    super.key,
    this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;

    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      tooltip: 'change_language'.tr(),
      onSelected: (Locale locale) async {
        await LocalizationHelper.changeLanguage(
            context, '${locale.languageCode}-${locale.countryCode}');
        onLanguageChanged?.call('${locale.languageCode}-${locale.countryCode}');
      },
      itemBuilder: (BuildContext context) {
        return LocalizationHelper.getSupportedLocales().map((Locale locale) {
          final isSelected = locale == currentLocale;
          return PopupMenuItem<Locale>(
            value: locale,
            child: Row(
              children: [
                Text(locale.displayName),
                const Spacer(),
                if (isSelected) const Icon(Icons.check, size: 16),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
