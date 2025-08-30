import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleStorageKey = '__locale_key__';

class FFLocalizations {
  FFLocalizations(this.locale);

  final Locale locale;

  static FFLocalizations of(BuildContext context) =>
      Localizations.of<FFLocalizations>(context, FFLocalizations)!;

  static List<String> languages() => ['it', 'en', 'fr'];

  static late SharedPreferences _prefs;
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();
  static Future storeLocale(String locale) =>
      _prefs.setString(_kLocaleStorageKey, locale);
  static Locale? getStoredLocale() {
    final locale = _prefs.getString(_kLocaleStorageKey);
    return locale != null && locale.isNotEmpty ? createLocale(locale) : null;
  }

  String get languageCode => locale.toString();
  String? get languageShortCode =>
      _languagesWithShortCode.contains(locale.toString())
          ? '${locale.toString()}_short'
          : null;
  int get languageIndex => languages().contains(languageCode)
      ? languages().indexOf(languageCode)
      : 0;

  String getText(String key) =>
      (kTranslationsMap[key] ?? {})[locale.toString()] ?? '';

  String getVariableText({
    String? itText = '',
    String? enText = '',
    String? frText = '',
  }) =>
      [itText, enText, frText][languageIndex] ?? '';

  static const Set<String> _languagesWithShortCode = {
    'ar',
    'az',
    'ca',
    'cs',
    'da',
    'de',
    'dv',
    'en',
    'es',
    'et',
    'fi',
    'fr',
    'gr',
    'he',
    'hi',
    'hu',
    'it',
    'km',
    'ku',
    'mn',
    'ms',
    'no',
    'pt',
    'ro',
    'ru',
    'rw',
    'sv',
    'th',
    'uk',
    'vi',
  };
}

/// Used if the locale is not supported by GlobalMaterialLocalizations.
class FallbackMaterialLocalizationDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      SynchronousFuture<MaterialLocalizations>(
        const DefaultMaterialLocalizations(),
      );

  @override
  bool shouldReload(FallbackMaterialLocalizationDelegate old) => false;
}

/// Used if the locale is not supported by GlobalCupertinoLocalizations.
class FallbackCupertinoLocalizationDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      SynchronousFuture<CupertinoLocalizations>(
        const DefaultCupertinoLocalizations(),
      );

  @override
  bool shouldReload(FallbackCupertinoLocalizationDelegate old) => false;
}

class FFLocalizationsDelegate extends LocalizationsDelegate<FFLocalizations> {
  const FFLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<FFLocalizations> load(Locale locale) =>
      SynchronousFuture<FFLocalizations>(FFLocalizations(locale));

  @override
  bool shouldReload(FFLocalizationsDelegate old) => false;
}

Locale createLocale(String language) => language.contains('_')
    ? Locale.fromSubtags(
        languageCode: language.split('_').first,
        scriptCode: language.split('_').last,
      )
    : Locale(language);

bool _isSupportedLocale(Locale locale) {
  final language = locale.toString();
  return FFLocalizations.languages().contains(
    language.endsWith('_')
        ? language.substring(0, language.length - 1)
        : language,
  );
}

final kTranslationsMap = <Map<String, Map<String, String>>>[
  // Routing
  {
    'aelk5y5x': {
      'it': 'Home',
      'en': 'Home',
      'fr': 'Maison',
    },
  },
  // HomePublic
  {
    '8vm8nube': {
      'it': 'Entra nel mondo delle certificazioni digitalizzate',
      'en': 'Enter the world of digital certifications',
      'fr': 'Entrez dans le monde des certifications numériques',
    },
    'dcnvoq68': {
      'it': 'Gestisci certificazioni affidabili per la tua organizzazione',
      'en': 'Manage trusted certifications for your organization',
      'fr': 'Gérez les certifications de confiance pour votre organisation',
    },
    'icabsa4a': {
      'it':
          'Gestione certificatori, controllo e tracciabilità completa delle certificazioni notarizzate.',
      'en':
          'Management of certifiers, control, and complete traceability of notarized certifications.',
      'fr':
          'Gestion des certificateurs, contrôle et traçabilité complète des certifications notariées.',
    },
    'tuzamoir': {
      'it': 'Delegation & Governance',
      'en': 'Delegation & Governance',
      'fr': 'Délégation et gouvernance',
    },
    '4eqlhh1v': {
      'it': 'Assegna certificatori e monitora le certificazioni emesse',
      'en': 'Assign certifiers and monitor issued certifications',
      'fr':
          'Affecter des certificateurs et surveiller les certifications délivrées',
    },
    'g7udcpby': {
      'it': 'Certificazioni robuste',
      'en': 'Robust certifications',
      'fr': 'Des certifications robustes',
    },
    'hgx69gue': {
      'it':
          'Crea certificazioni, aggiungi documenti e informazioni per i singoli partecipanti',
      'en':
          'Create certifications, add documents and information for individual participants',
      'fr':
          'Créez des certifications, ajoutez des documents et des informations pour les participants individuels',
    },
    'ggf0q22u': {
      'it': 'Audit trail & Compliance',
      'en': 'Audit trail & Compliance',
      'fr': 'Piste d\'audit et conformité',
    },
    'ah35v40y': {
      'it': 'Ogni certificazione è tracciabile su blockchain',
      'en': 'Each certification is traceable on blockchain',
      'fr': 'Chaque certification est traçable sur la blockchain',
    },
    '2vdo5phf': {
      'it': 'Enterprise',
      'en': 'Enterprise',
      'fr': 'Entreprise',
    },
    '4un9fahj': {
      'it':
          'Accedi a strumenti enterprise per la ricerca del personale e navigator per competenze certificate',
      'en':
          'Access enterprise recruitment tools and certified skills navigators.',
      'fr':
          'Accédez à des outils de recrutement d’entreprise et à des navigateurs de compétences certifiés.',
    },
    'yql3y7x1': {
      'it': 'Pronto per iniziale?',
      'en': 'Ready to start?',
      'fr': 'Prêt à commencer ?',
    },
    'pcpk10z0': {
      'it': 'Registrati come Certficatore o Legal entity in pochi minuti.',
      'en': 'Register as a Certifier or Legal entity in minutes.',
      'fr':
          'Inscrivez-vous en tant que certificateur ou entité juridique en quelques minutes.',
    },
    'fsxhy6fk': {
      'it': 'Inizia ora',
      'en': 'Start now',
      'fr': 'Commencez maintenant',
    },
  },
  // Login
  {
    'ljbtjbug': {
      'it': 'Accedi',
      'en': 'Sign in',
      'fr': 'Se connecter',
    },
    '34f50wdh': {
      'it': 'Continua con Google',
      'en': 'Continue with Google',
      'fr': 'Continuer avec Google',
    },
    '12yxd6by': {
      'it': 'Continua con Email',
      'en': 'Continue with Email',
      'fr': 'Continuer avec l\'e-mail',
    },
    'wcvbswm7': {
      'it': 'Home',
      'en': 'Home',
      'fr': 'Maison',
    },
  },
  // Logout
  {
    'z8y8yjp1': {
      'it': 'Home',
      'en': 'Home',
      'fr': 'Maison',
    },
  },
  // UserInformation
  {
    '10ozn781': {
      'it': 'Dati personali',
      'en': 'Personal data',
      'fr': 'Données personnelles',
    },
    'hwumzyhc': {
      'it': 'Dati Personali',
      'en': 'Personal Data',
      'fr': 'Données personnelles',
    },
    'av0ohflf': {
      'it': 'Inserisci i tuoi dati per continuare',
      'en': 'Enter your details to continue',
      'fr': 'Entrez vos coordonnées pour continuer',
    },
    '8i2ps8i1': {
      'it': 'Nome',
      'en': 'Name',
      'fr': 'Nom',
    },
    'yf5ae5wi': {
      'it': 'Cognome',
      'en': 'Surname',
      'fr': 'Nom de famille',
    },
    'ugv964yi': {
      'it': 'Email',
      'en': 'E-mail',
      'fr': 'E-mail',
    },
    'zx0pqlmi': {
      'it': 'Cellulare',
      'en': 'Mobile phone',
      'fr': 'Téléphone mobile',
    },
    'e0xg62r8': {
      'it': 'Data di nascita',
      'en': 'Date of birth',
      'fr': 'Date de naissance',
    },
    'rku6epos': {
      'it': 'Genere',
      'en': 'Type',
      'fr': 'Taper',
    },
    'r01z98un': {
      'it': '',
      'en': '',
      'fr': '',
    },
    'bthmj558': {
      'it': 'Maschio',
      'en': 'Male',
      'fr': 'Mâle',
    },
    'lpka68o2': {
      'it': 'Femmina',
      'en': 'Female',
      'fr': 'Femelle',
    },
    'v77c5d28': {
      'it': 'Altro',
      'en': 'Other',
      'fr': 'Autre',
    },
    'es8d7ow2': {
      'it': 'Indirizzo',
      'en': 'Address',
      'fr': 'Adresse',
    },
    'hdpkr506': {
      'it': 'Città',
      'en': 'City',
      'fr': 'Ville',
    },
    '24njlzb3': {
      'it': 'CAP',
      'en': 'ZIP CODE',
      'fr': 'CODE POSTAL',
    },
    'jdwxq8c8': {
      'it': 'Provincia',
      'en': 'Province',
      'fr': 'Province',
    },
    'isyfl4ro': {
      'it': 'Stato',
      'en': 'State',
      'fr': 'État',
    },
    'k9ok8tom': {
      'it': '',
      'en': '',
      'fr': '',
    },
    'm8zc06aj': {
      'it': 'Cerca...',
      'en': 'Near...',
      'fr': 'Près...',
    },
    'phv2qghe': {
      'it': 'Lingua',
      'en': 'Tongue',
      'fr': 'Langue',
    },
    '8r7q2uum': {
      'it':
          'Questa è la lingua in cui visualizzerai l\'applicazione e i contenuti',
      'en':
          'This is the language in which you will view the application and content.',
      'fr':
          'Il s\'agit de la langue dans laquelle vous visualiserez l\'application et le contenu.',
    },
    'ahcj87ji': {
      'it': 'Inserisci il Nome',
      'en': 'Enter Name',
      'fr': 'Entrez le nom',
    },
    '8xd4brg8': {
      'it': 'Please choose an option from the dropdown',
      'en': 'Please choose an option from the dropdown',
      'fr': 'Veuillez choisir une option dans la liste déroulante',
    },
    'cscgb7s5': {
      'it': 'Inserisci il Cognome',
      'en': 'Enter your surname',
      'fr': 'Entrez votre nom de famille',
    },
    'gxl10tl3': {
      'it': 'Please choose an option from the dropdown',
      'en': 'Please choose an option from the dropdown',
      'fr': 'Veuillez choisir une option dans la liste déroulante',
    },
    'bx1rtakj': {
      'it': 'Inserisci l\'email',
      'en': 'Enter your email address',
      'fr': 'Entrez votre adresse e-mail',
    },
    '63jn76gu': {
      'it': 'Inserisci un\'email valida',
      'en': 'Please enter a valid email address.',
      'fr': 'S\'il vous plaît, mettez une adresse email valide.',
    },
    'qzkbdwl3': {
      'it': 'Please choose an option from the dropdown',
      'en': 'Please choose an option from the dropdown',
      'fr': 'Veuillez choisir une option dans la liste déroulante',
    },
    '3rgxlcph': {
      'it': 'Inserisci il Cellulare',
      'en': 'Enter your mobile number',
      'fr': 'Entrez votre numéro de portable',
    },
    'f6zz3kf8': {
      'it': 'Please choose an option from the dropdown',
      'en': 'Please choose an option from the dropdown',
      'fr': 'Veuillez choisir une option dans la liste déroulante',
    },
    'whf3vewn': {
      'it': 'Inserisci l\'Indirizzo',
      'en': 'Enter the Address',
      'fr': 'Entrez l\'adresse',
    },
    '46026oho': {
      'it': 'Please choose an option from the dropdown',
      'en': 'Please choose an option from the dropdown',
      'fr': 'Veuillez choisir une option dans la liste déroulante',
    },
    's4u6kbwp': {
      'it': 'Inserisci la Città',
      'en': 'Enter the City',
      'fr': 'Entrez dans la ville',
    },
    'trv79x9l': {
      'it': 'Please choose an option from the dropdown',
      'en': 'Please choose an option from the dropdown',
      'fr': 'Veuillez choisir une option dans la liste déroulante',
    },
    '5jjuocij': {
      'it': 'Inserisci il CAP',
      'en': 'Enter the postal code',
      'fr': 'Entrez le code postal',
    },
    '1413c3o6': {
      'it': 'Please choose an option from the dropdown',
      'en': 'Please choose an option from the dropdown',
      'fr': 'Veuillez choisir une option dans la liste déroulante',
    },
    '546pm9jh': {
      'it': 'Inserisci la Provincia',
      'en': 'Enter the Province',
      'fr': 'Entrez dans la province',
    },
    'ks71ytf8': {
      'it': 'Please choose an option from the dropdown',
      'en': 'Please choose an option from the dropdown',
      'fr': 'Veuillez choisir une option dans la liste déroulante',
    },
    'kwlp57zo': {
      'it': 'Salva',
      'en': 'Save',
      'fr': 'Sauvegarder',
    },
    't3ud5r9b': {
      'it': 'Home',
      'en': 'Home',
      'fr': 'Maison',
    },
  },
  // WelcomeUser
  {
    '0oy88bpk': {
      'it': 'Benvenuto/a in JetCV Enterprise,',
      'en': '',
      'fr': '',
    },
    'mq5n6p1u': {
      'it': 'Il tuo account è stato creato con successo.',
      'en': 'Your account has been successfully created.',
      'fr': 'Votre compte a été créé avec succès.',
    },
    'um0pmel4': {
      'it': 'Inizia ora',
      'en': 'Start now',
      'fr': 'Commencez maintenant',
    },
    'w0olt08t': {
      'it': 'Home',
      'en': 'Home',
      'fr': 'Maison',
    },
  },
  // HomeCertifier
  {
    'hl45lblk': {
      'it': 'Home',
      'en': 'Home',
      'fr': 'Maison',
    },
    '8w0kn1ia': {
      'it': 'Ciao,',
      'en': 'HI,',
      'fr': 'SALUT,',
    },
    'fev6y5nv': {
      'it':
          'Hai completato correttamente la registrazione, ora attendi che la tua legal entity ti aggiunga come certificatore.',
      'en':
          'You\'ve successfully completed registration. Now wait for your legal entity to add you as a certifier.',
      'fr':
          'Votre inscription est terminée. Attendez maintenant que votre entité juridique vous ajoute comme certificateur.',
    },
    'du3sjxrb': {
      'it': 'Home',
      'en': 'Home',
      'fr': 'Maison',
    },
  },
  // LegalEntityInformation
  {
    'wetv1dd6': {
      'it': 'Informazioni Legal Entity',
      'en': 'Legal Entity Information',
      'fr': 'Informations sur l\'entité juridique',
    },
    'e91wo9zs': {
      'it': 'Informazioni Legal Entity',
      'en': 'Legal Entity Information',
      'fr': 'Informations sur l\'entité juridique',
    },
    '6ix5osqx': {
      'it':
          'Inserisci i dati della tua legal entity per richiedere l\'accreditamento.',
      'en': 'Enter your legal entity details to request accreditation.',
      'fr':
          'Saisissez les coordonnées de votre entité juridique pour demander une accréditation.',
    },
    'b4s83d2k': {
      'it': 'Ragione Sociale',
      'en': 'Company Name',
      'fr': 'Nom de l\'entreprise',
    },
    'hgrxbpf6': {
      'it': 'Codice Identificativo',
      'en': 'Identification Code',
      'fr': 'Code d\'identification',
    },
    'ubb0vi94': {
      'it':
          'Identificativo univoco della tua legal entity (ad esempio codice maccanografico per le scuole, codice fiscale per le associazioni o partita iva per le aziende)',
      'en':
          'Unique identifier of your legal entity (e.g., machine code for schools, tax code for associations, or VAT number for companies)',
      'fr':
          'Identifiant unique de votre entité juridique (par exemple, code machine pour les écoles, code fiscal pour les associations ou numéro de TVA pour les entreprises)',
    },
    'rljrugjm': {
      'it': 'Legale Rappresentante',
      'en': 'Legal Representative',
      'fr': 'Représentant légal',
    },
    'cbu2qkru': {
      'it': 'Logo azienda',
      'en': 'Registered Office Address',
      'fr': 'Adresse du siège social',
    },
    'fws1rpq5': {
      'it': 'Foto azienda',
      'en': 'Registered Office Address',
      'fr': 'Adresse du siège social',
    },
    'l1efwrya': {
      'it': 'Sede Legale',
      'en': 'Registered Office Address',
      'fr': 'Adresse du siège social',
    },
    '8ku3sygj': {
      'it': 'Sede amministrativa dell\'organizzazione',
      'en': 'Main place of performance of activities or certifications',
      'fr': 'Lieu principal d\'exercice des activités ou des certifications',
    },
    'jubg2bwv': {
      'it': 'Indirizzo',
      'en': 'Registered Office Address',
      'fr': 'Adresse du siège social',
    },
    '5kpsuo3z': {
      'it': 'Città',
      'en': 'City',
      'fr': 'Ville',
    },
    'owhbrmdr': {
      'it': 'CAP',
      'en': 'ZIP CODE',
      'fr': 'CODE POSTAL',
    },
    'dusrn2xd': {
      'it': 'Provincia',
      'en': 'Province',
      'fr': 'Province',
    },
    '6mi6terw': {
      'it': 'Stato',
      'en': 'State',
      'fr': 'État',
    },
    'b1yb9nbd': {
      'it': '',
      'en': '',
      'fr': '',
    },
    'dwb2o6tn': {
      'it': 'Cerca...',
      'en': 'Near...',
      'fr': 'Près...',
    },
    'u20s4md6': {
      'it': 'Sede Operativa',
      'en': 'Registered Office Address',
      'fr': 'Adresse du siège social',
    },
    '9kx7ac6r': {
      'it': 'Luogo prevalente di svolgimento delle attività o certificazioni',
      'en': 'Main place of performance of activities or certifications',
      'fr': 'Lieu principal d\'exercice des activités ou des certifications',
    },
    '0a6tpv0v': {
      'it': 'Indirizzo',
      'en': 'Registered Office Address',
      'fr': 'Adresse du siège social',
    },
    'kmmy5ar4': {
      'it': 'Città',
      'en': 'City',
      'fr': 'Ville',
    },
    'wrp397i3': {
      'it': 'CAP',
      'en': 'ZIP CODE',
      'fr': 'CODE POSTAL',
    },
    'pflsh0s9': {
      'it': 'Provincia',
      'en': 'Province',
      'fr': 'Province',
    },
    'a81ix17c': {
      'it': 'Stato',
      'en': 'State',
      'fr': 'État',
    },
    '5e0r2nfe': {
      'it': '',
      'en': '',
      'fr': '',
    },
    'zzk61oua': {
      'it': 'Cerca...',
      'en': 'Near...',
      'fr': 'Près...',
    },
    'cyjk8kxk': {
      'it': 'Email',
      'en': 'E-mail',
      'fr': 'E-mail',
    },
    'd7y4nijf': {
      'it': 'PEC',
      'en': 'PEC',
      'fr': 'PEC',
    },
    'k26w27le': {
      'it': 'Telefono',
      'en': 'Telephone',
      'fr': 'Téléphone',
    },
    '79ofuxdb': {
      'it': 'Sito Web',
      'en': 'Website',
      'fr': 'Site web',
    },
    'lslp2bsd': {
      'it': 'Linkedin',
      'en': 'Website',
      'fr': 'Site web',
    },
    '93ktf5qs': {
      'it': 'Inserisci la Ragione Sociale',
      'en': 'Enter your company name',
      'fr': 'Entrez le nom de votre entreprise',
    },
    '0pbt83tp': {
      'it': 'Please choose an option from the dropdown',
      'en': 'Please choose an option from the dropdown',
      'fr': 'Veuillez choisir une option dans la liste déroulante',
    },
    'ubmae0sw': {
      'it': 'Inserisci il Codice Identificativo',
      'en': 'Enter the Identification Code',
      'fr': 'Entrez le code d\'identification',
    },
    'gstz1yfj': {
      'it': 'Please choose an option from the dropdown',
      'en': 'Please choose an option from the dropdown',
      'fr': 'Veuillez choisir une option dans la liste déroulante',
    },
    '77gb6saq': {
      'it': 'Inserisci il Legale Rappresentante',
      'en': 'Enter the Legal Representative',
      'fr': 'Entrez le représentant légal',
    },
    '41h8ob0n': {
      'it': 'Please choose an option from the dropdown',
      'en': 'Please choose an option from the dropdown',
      'fr': 'Veuillez choisir une option dans la liste déroulante',
    },
    'd5610222': {
      'it': 'Inserisci l\'Indirizzo Sede Legale',
      'en': 'Enter your registered office address',
      'fr': 'Entrez l\'adresse de votre siège social',
    },
    'yifiklhn': {
      'it': 'Please choose an option from the dropdown',
      'en': 'Please choose an option from the dropdown',
      'fr': 'Veuillez choisir une option dans la liste déroulante',
    },
    'k24yh2bj': {
      'it': 'Inserisci l\'Indirizzo Operativo',
      'en': 'Enter the Operational Address',
      'fr': 'Entrez l\'adresse d\'exploitation',
    },
    '0m71xp0o': {
      'it': 'Please choose an option from the dropdown',
      'en': 'Please choose an option from the dropdown',
      'fr': 'Veuillez choisir une option dans la liste déroulante',
    },
    'gz9x9t69': {
      'it': 'Inserisci l\'email',
      'en': 'Enter your email address',
      'fr': 'Entrez votre adresse e-mail',
    },
    'cz2ta5re': {
      'it': 'Inserisci un\'email valida',
      'en': 'Please enter a valid email address.',
      'fr': 'S\'il vous plaît, mettez une adresse email valide.',
    },
    '8se9vww8': {
      'it': 'Please choose an option from the dropdown',
      'en': 'Please choose an option from the dropdown',
      'fr': 'Veuillez choisir une option dans la liste déroulante',
    },
    'xvw6lefg': {
      'it': 'Field is required',
      'en': 'Field is required',
      'fr': 'Le champ est obligatoire',
    },
    '58ynycjp': {
      'it': 'Please choose an option from the dropdown',
      'en': 'Please choose an option from the dropdown',
      'fr': 'Veuillez choisir une option dans la liste déroulante',
    },
    'kz7zp6u7': {
      'it': 'Inserisci il Cellulare',
      'en': 'Enter your mobile number',
      'fr': 'Entrez votre numéro de portable',
    },
    'wphw178v': {
      'it': 'Please choose an option from the dropdown',
      'en': 'Please choose an option from the dropdown',
      'fr': 'Veuillez choisir une option dans la liste déroulante',
    },
    'w63gt5mt': {
      'it': 'Field is required',
      'en': 'Field is required',
      'fr': 'Le champ est obligatoire',
    },
    'iz7oduhj': {
      'it': 'Please choose an option from the dropdown',
      'en': 'Please choose an option from the dropdown',
      'fr': 'Veuillez choisir une option dans la liste déroulante',
    },
    'eatt5iwk': {
      'it': 'Home',
      'en': 'Home',
      'fr': 'Maison',
    },
  },
  // UserTypeSelection
  {
    'twlx5paa': {
      'it': 'Seleziona Tipologia utente',
      'en': 'Select User Type',
      'fr': 'Sélectionnez le type d\'utilisateur',
    },
    '84otvia4': {
      'it': 'Seleziona la tipologia di utente per continuare',
      'en': 'Select your user type to continue',
      'fr': 'Sélectionnez votre type d\'utilisateur pour continuer',
    },
    'nxc7v7jv': {
      'it':
          'Potrai creare nuove certificazioni per conto della tua legal entity, aggiungere utenti ad esse, allegare documenti e molto altro ancora.',
      'en':
          'You\'ll be able to create new certifications on behalf of your legal entity, add users to them, attach documents, and much more.',
      'fr':
          'Vous pourrez créer de nouvelles certifications au nom de votre entité juridique, y ajouter des utilisateurs, joindre des documents et bien plus encore.',
    },
    'pryr0ptw': {
      'it': 'Emettere nuove certificazione',
      'en': 'Issue new certifications',
      'fr': 'Délivrer de nouvelles certifications',
    },
    '1l1a4lcq': {
      'it': 'Aggiungere in modo semplice e veloce tutti i partecipanti',
      'en': 'Add all participants quickly and easily',
      'fr': 'Ajoutez tous les participants rapidement et facilement',
    },
    'z2zbk6pb': {
      'it': 'Allegare documentazione real-time',
      'en': 'Attach real-time documentation',
      'fr': 'Joindre une documentation en temps réel',
    },
    '320o24pn': {
      'it': 'Aggiungere e gestire certificatori alla tua organizzazione',
      'en': 'Add and manage certifiers in your organization',
      'fr': 'Ajoutez et gérez les certificateurs dans votre organisation',
    },
    'tru7bctq': {
      'it': 'Dashboard intuitiva per monitorare le certificazioni emesse',
      'en': 'Intuitive dashboard to monitor issued certifications',
      'fr': 'Tableau de bord intuitif pour suivre les certifications délivrées',
    },
    'zlw7cjxz': {
      'it': 'Sicurezza livello enterprise garantita dalla blockchain',
      'en': 'Enterprise-grade security ensured by blockchain',
      'fr': 'Sécurité de niveau entreprise assurée par la blockchain',
    },
  },
  // HomeLegalEntity
  {
    'o1d8dze9': {
      'it': 'Home',
      'en': 'Home',
      'fr': 'Maison',
    },
    '4f1mzyhc': {
      'it': 'Ciao,',
      'en': 'HI,',
      'fr': 'SALUT,',
    },
    '28cjaere': {
      'it': 'Home',
      'en': 'Home',
      'fr': 'Maison',
    },
  },
  // HomeAdmin
  {
    '2q43hv7n': {
      'it': 'Home',
      'en': 'Home',
      'fr': 'Maison',
    },
    'rmqmng1u': {
      'it': 'Ciao,',
      'en': 'HI,',
      'fr': 'SALUT,',
    },
    'ocnjuowu': {
      'it': 'Home',
      'en': 'Home',
      'fr': 'Maison',
    },
  },
  // MyWallets
  {
    'rq1qnle5': {
      'it': 'I miei Wallet',
      'en': 'My Wallets',
      'fr': 'Mes portefeuilles',
    },
    '5odu2j3m': {
      'it': 'Home',
      'en': 'Home',
      'fr': 'Maison',
    },
  },
  // KycRequestSession
  {
    'urvzold5': {
      'it': 'Verifica dell\'identità',
      'en': 'Identity verification',
      'fr': 'Vérification d\'identité',
    },
    'ddtlipkj': {
      'it': 'Verifica dell\'identità',
      'en': 'Identity verification',
      'fr': 'Vérification d\'identité',
    },
    '1jl7wx78': {
      'it': 'Verifica ora',
      'en': 'Check now',
      'fr': 'Vérifiez maintenant',
    },
    'ygbmcpae': {
      'it': 'Premendo il pulsante si aprirà una nuova finestra nel browser.',
      'en': 'Pressing the button will open a new window in your browser.',
      'fr':
          'Appuyez sur le bouton pour ouvrir une nouvelle fenêtre dans votre navigateur.',
    },
    '1x24gbez': {
      'it': 'Home',
      'en': 'Home',
      'fr': 'Maison',
    },
  },
  // KycSessionResult
  {
    '7z9ch2y3': {
      'it': 'Esito verifica dell\'identità',
      'en': 'Identity verification result',
      'fr': 'Résultat de la vérification d\'identité',
    },
    'iprpme2s': {
      'it': 'La verifica sta impiegando troppo tempo?',
      'en': 'Is the verification taking too long?',
      'fr': 'La vérification prend-elle trop de temps ?',
    },
    '51niewbn': {
      'it': 'Nuovo tentativo',
      'en': 'New attempt',
      'fr': 'Nouvelle tentative',
    },
    'shfdi0kl': {
      'it': 'Identità verificata correttamente.',
      'en': 'Identity verified successfully.',
      'fr': 'Identité vérifiée avec succès.',
    },
    '94a7r6kz': {
      'it': 'Continua',
      'en': 'Continues',
      'fr': 'Continue',
    },
    'yvcjy5ho': {
      'it': 'Nuovo tentativo',
      'en': 'New attempt',
      'fr': 'Nouvelle tentative',
    },
    '1pytwe8f': {
      'it': 'Vai alla Home',
      'en': 'Go to Home',
      'fr': 'Aller à l\'accueil',
    },
    'ij6fv52p': {
      'it': 'Home',
      'en': 'Home',
      'fr': 'Maison',
    },
  },
  // EmaiLogin
  {
    'iwbctiuv': {
      'it': 'Accedi',
      'en': 'Sign in',
      'fr': 'Se connecter',
    },
    'mq1dsx1t': {
      'it': 'Email',
      'en': 'E-mail',
      'fr': 'E-mail',
    },
    'jcgpiqw6': {
      'it': 'Password',
      'en': 'Password',
      'fr': 'Mot de passe',
    },
    'uxcgiw51': {
      'it': 'Accedi',
      'en': 'Sign in',
      'fr': 'Se connecter',
    },
    '5xtmyndo': {
      'it': 'Non possiedi un account?',
      'en': 'Don\'t have an account?',
      'fr': 'Vous n\'avez pas de compte ?',
    },
    '4obp5gz3': {
      'it': 'Crea un account',
      'en': 'Create an account',
      'fr': 'Créer un compte',
    },
    'l7rdogz8': {
      'it': 'Home',
      'en': 'Home',
      'fr': 'Maison',
    },
  },
  // EmaiRegistration
  {
    'j6x5b71d': {
      'it': 'Crea un account',
      'en': 'Sign in',
      'fr': 'Se connecter',
    },
    'r2w2tmdd': {
      'it': 'Email',
      'en': 'E-mail',
      'fr': 'E-mail',
    },
    'oxja39it': {
      'it': 'Password',
      'en': 'Password',
      'fr': 'Mot de passe',
    },
    '9phct2q6': {
      'it': 'Ripeti Password',
      'en': 'Retype password',
      'fr': 'retaper le mot de passe',
    },
    'uqnoifup': {
      'it': 'Accetto termini e condizioni',
      'en': 'I accept the terms and conditions',
      'fr': 'J\'accepte les termes et conditions',
    },
    'rp2dphjb': {
      'it': 'Crea il tuo account',
      'en': 'Create your account',
      'fr': 'Créez votre compte',
    },
    '2ecjqrhv': {
      'it': 'Hai già un account?',
      'en': 'Already have an account?',
      'fr': 'Vous avez déjà un compte ?',
    },
    'eu53ezu1': {
      'it': 'Accedi',
      'en': 'Sign in',
      'fr': 'Se connecter',
    },
    'c5t0qf8n': {
      'it': 'Home',
      'en': 'Home',
      'fr': 'Maison',
    },
  },
  // Nav
  {
    'xbtxfhpy': {
      'it': 'Cristina Rossi',
      'en': '',
      'fr': '',
    },
    '1mr0a7fr': {
      'it': 'Home',
      'en': 'Home',
      'fr': 'Maison',
    },
    'eoo79qjf': {
      'it': 'Il mio profilo',
      'en': 'My profile',
      'fr': 'Mon profil',
    },
    'kax330dg': {
      'it': 'La mia legal entity',
      'en': 'My legal entity',
      'fr': 'Mon entité juridique',
    },
    '7h1iyofc': {
      'it': 'I miei Wallet',
      'en': 'My Wallets',
      'fr': 'Mes portefeuilles',
    },
    '9lrxncf3': {
      'it': 'Elimina utente',
      'en': 'Delete user',
      'fr': 'Supprimer l\'utilisateur',
    },
    'dvvevbep': {
      'it': 'Esci',
      'en': 'You go out',
      'fr': 'Tu sors',
    },
  },
  // LegalEntitiesList
  {
    'f2zn4qz8': {
      'it': 'Legal Entities',
      'en': 'Legal Entities',
      'fr': 'Entités juridiques',
    },
    '33vaiyp6': {
      'it': 'Global Industries Inc.',
      'en': 'Global Industries Inc.',
      'fr': 'Industries mondiales inc.',
    },
    'u5xj138q': {
      'it': 'ID: GI-2024-002',
      'en': 'ID: GI-2024-002',
      'fr': 'ID : GI-2024-002',
    },
    'svk3tmrp': {
      'it': 'Approved',
      'en': 'Approved',
      'fr': 'Approuvé',
    },
    'jiixxog8': {
      'it': 'Operational: 789 Industry Rd, Manufacturing City, MC 54321',
      'en': 'Operational: 789 Industry Rd, Manufacturing City, MC 54321',
      'fr': 'Opérationnel : 789 Industry Rd, Manufacturing City, MC 54321',
    },
    'xgyp4z51': {
      'it': 'Headquarters: 321 Executive Plaza, Capital City, CC 98765',
      'en': 'Headquarters: 321 Executive Plaza, Capital City, CC 98765',
      'fr': 'Siège social : 321 Executive Plaza, Capital City, CC 98765',
    },
    'z5x1hu9o': {
      'it': 'Legal Rep: Sarah Johnson',
      'en': 'Legal Representative: Sarah Johnson',
      'fr': 'Représentant légal : Sarah Johnson',
    },
    '8x9nphj0': {
      'it': 'info@globalind.com',
      'en': 'info@globalind.com',
      'fr': 'info@globalind.com',
    },
    'aelhy2wy': {
      'it': '+1 (555) 987-6543',
      'en': '+1 (555) 987-6543',
      'fr': '+1 (555) 987-6543',
    },
    'kxcbn10k': {
      'it': 'pec@globalind.pec.it',
      'en': 'pec@globalind.pec.it',
      'fr': 'pec@globalind.pec.it',
    },
    'e5yyio3a': {
      'it': 'www.globalindustries.com',
      'en': 'www.globalindustries.com',
      'fr': 'www.globalindustries.com',
    },
    '13kr702q': {
      'it': 'Created: February 28, 2024',
      'en': 'Created: February 28, 2024',
      'fr': 'Créé le 28 février 2024',
    },
    'vckamyl3': {
      'it': 'Requested by: User ID 67890',
      'en': 'Requested by: User ID 67890',
      'fr': 'Demandé par : ID utilisateur 67890',
    },
    'a2lf3e3b': {
      'it': 'Approved on March 20, 2024',
      'en': 'Approved on March 20, 2024',
      'fr': 'Approuvé le 20 mars 2024',
    },
    'lsayfqip': {
      'it': 'StartupVentures LLC',
      'en': 'StartupVentures LLC',
      'fr': 'StartupVentures LLC',
    },
    '33zgfljy': {
      'it': 'ID: SV-2024-003',
      'en': 'ID: SV-2024-003',
      'fr': 'ID : SV-2024-003',
    },
    'yk21c6e7': {
      'it': 'Denied',
      'en': 'Denied',
      'fr': 'Refusé',
    },
    'su0980qg': {
      'it': 'Operational: 456 Startup Lane, Innovation City, IC 11111',
      'en': 'Operational: 456 Startup Lane, Innovation City, IC 11111',
      'fr': 'Opérationnel : 456 Startup Lane, Innovation City, IC 11111',
    },
    'esetfxha': {
      'it': 'Headquarters: 789 Venture St, Entrepreneur City, EC 22222',
      'en': 'Headquarters: 789 Venture St, Entrepreneur City, EC 22222',
      'fr': 'Siège social : 789 Venture St, Entrepreneur City, EC 22222',
    },
    'ntnqejed': {
      'it': 'Legal Rep: Michael Chen',
      'en': 'Legal Rep: Michael Chen',
      'fr': 'Représentant juridique : Michael Chen',
    },
    'rke5ahhw': {
      'it': 'hello@startupventures.com',
      'en': 'hello@startupventures.com',
      'fr': 'bonjour@startupventures.com',
    },
    'kd9pmwpq': {
      'it': '+1 (555) 456-7890',
      'en': '+1 (555) 456-7890',
      'fr': '+1 (555) 456-7890',
    },
    'tk4ahxnm': {
      'it': 'pec@startupventures.pec.it',
      'en': 'pec@startupventures.pec.it',
      'fr': 'pec@startupventures.pec.it',
    },
    'yxnolc9y': {
      'it': 'www.startupventures.com',
      'en': 'www.startupventures.com',
      'fr': 'www.startupventures.com',
    },
    'ko5ppjg1': {
      'it': 'Created: March 10, 2024',
      'en': 'Created: March 10, 2024',
      'fr': 'Créé le 10 mars 2024',
    },
    'cc51kg8i': {
      'it': 'Requested by: User ID 54321',
      'en': 'Requested by: User ID 54321',
      'fr': 'Demandé par : ID utilisateur 54321',
    },
    'ypzegw87': {
      'it': 'Denied on March 18, 2024',
      'en': 'Denied on March 18, 2024',
      'fr': 'Refusé le 18 mars 2024',
    },
  },
  // LegalEntityCard
  {
    '2ugw059q': {
      'it': 'In attesa',
      'en': 'Pending',
      'fr': 'En attente',
    },
    '8ci4uymx': {
      'it': 'Approvato',
      'en': 'Approved',
      'fr': 'Approuvé',
    },
    'kx3a29iw': {
      'it': 'Rifiutato',
      'en': 'Rejected',
      'fr': 'Rejeté',
    },
    'f9mswoec': {
      'it': 'Sede Operativa:',
      'en': 'Operational Headquarters:',
      'fr': 'Quartier général opérationnel :',
    },
    'ht9qf8nt': {
      'it': 'Sede Legale:',
      'en': 'Registered office:',
      'fr': 'Siège social :',
    },
    'atvbnzjm': {
      'it': 'Rappresentate Legale:',
      'en': 'Legal Representative:',
      'fr': 'Représentant légal :',
    },
    '95x7ygxk': {
      'it': 'Richiesta il:',
      'en': 'Requested on:',
      'fr': 'Demandé le :',
    },
    'mj16mp0x': {
      'it': 'Richiesta inviata da:',
      'en': 'Request sent by:',
      'fr': 'Demande envoyée par :',
    },
    'hq1ytflf': {
      'it': 'Davide Bianchi (bianchi@acme.com)',
      'en': '',
      'fr': '',
    },
    '43hrz2a7': {
      'it': 'Rifiuta',
      'en': 'Refuse',
      'fr': 'Refuser',
    },
    '8w0pmyzs': {
      'it': 'Accetta',
      'en': 'Accept',
      'fr': 'Accepter',
    },
  },
  // EmailModal
  {
    'vr4krgum': {
      'it': 'Accedi con Email',
      'en': 'Sign in with Email',
      'fr': 'Connectez-vous avec votre e-mail',
    },
    'bu6tkxyl': {
      'it': 'Registrati con Email',
      'en': 'Register with Email',
      'fr': 'Inscrivez-vous avec e-mail',
    },
  },
  // Miscellaneous
  {
    'hwymfg3q': {
      'it': '',
      'en': '',
      'fr': '',
    },
    'dzysi2zh': {
      'it': '',
      'en': '',
      'fr': '',
    },
    '1sn4vi7p': {
      'it': '',
      'en': '',
      'fr': '',
    },
    'x8h9feh7': {
      'it': '',
      'en': '',
      'fr': '',
    },
    '9n5oho3d': {
      'it': '',
      'en': '',
      'fr': '',
    },
    '85hrnhqi': {
      'it': '',
      'en': '',
      'fr': '',
    },
    'qnrw2t2b': {
      'it': '',
      'en': '',
      'fr': '',
    },
    'qn044nvd': {
      'it': '',
      'en': '',
      'fr': '',
    },
    'pthwsk6a': {
      'it': '',
      'en': '',
      'fr': '',
    },
    'qufqi8sk': {
      'it': '',
      'en': '',
      'fr': '',
    },
    'fyhoebm3': {
      'it': '',
      'en': '',
      'fr': '',
    },
    'mi5l075x': {
      'it': '',
      'en': '',
      'fr': '',
    },
    'hfw8hd09': {
      'it': '',
      'en': '',
      'fr': '',
    },
    'euel216p': {
      'it': '',
      'en': '',
      'fr': '',
    },
    'i524m1ii': {
      'it': '',
      'en': '',
      'fr': '',
    },
    't0qw7wvp': {
      'it': '',
      'en': '',
      'fr': '',
    },
    'ucwf5m5j': {
      'it': '',
      'en': '',
      'fr': '',
    },
    'bvg2abgc': {
      'it': '',
      'en': '',
      'fr': '',
    },
    'biysvre6': {
      'it': '',
      'en': '',
      'fr': '',
    },
    'azrlqhfm': {
      'it': '',
      'en': '',
      'fr': '',
    },
    'kzfeede7': {
      'it': '',
      'en': '',
      'fr': '',
    },
    '0625yp9l': {
      'it': '',
      'en': '',
      'fr': '',
    },
    '6nr4w7zl': {
      'it': '',
      'en': '',
      'fr': '',
    },
    'u5ypo97o': {
      'it': '',
      'en': '',
      'fr': '',
    },
    'w8lo255y': {
      'it': '',
      'en': '',
      'fr': '',
    },
    '23kzt3l5': {
      'it': '',
      'en': '',
      'fr': '',
    },
    '5y7yw1or': {
      'it': '',
      'en': '',
      'fr': '',
    },
  },
].reduce((a, b) => a..addAll(b));
