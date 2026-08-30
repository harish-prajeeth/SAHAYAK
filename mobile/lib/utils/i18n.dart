import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, tamil, hindi, telugu }

class LanguageOption {
  final AppLanguage code;
  final String name;
  final String native;
  final String flag;

  const LanguageOption(this.code, this.name, this.native, this.flag);
}

const List<LanguageOption> supportedLanguages = [
  LanguageOption(AppLanguage.english, 'English', 'English', '🇬🇧'),
  LanguageOption(AppLanguage.tamil, 'Tamil', 'தமிழ்', '🇮🇳'),
  LanguageOption(AppLanguage.hindi, 'Hindi', 'हिन्दी', '🇮🇳'),
  LanguageOption(AppLanguage.telugu, 'Telugu', 'తెలుగు', '🇮🇳'),
];

class I18n {
  static const Map<String, Map<AppLanguage, String>> _translations = {
    // Navigation
    'nav.home': {
      AppLanguage.english: 'Home',
      AppLanguage.tamil: 'முகப்பு',
      AppLanguage.hindi: 'होम',
      AppLanguage.telugu: 'హోమ్',
    },
    'nav.schemes': {
      AppLanguage.english: 'Schemes',
      AppLanguage.tamil: 'திட்டங்கள்',
      AppLanguage.hindi: 'योजनाएँ',
      AppLanguage.telugu: 'పథకాలు',
    },
    'nav.partners': {
      AppLanguage.english: 'Partners',
      AppLanguage.tamil: 'கூட்டாளர்கள்',
      AppLanguage.hindi: 'साझेदार',
      AppLanguage.telugu: 'భాగస్వాములు',
    },
    'nav.applications': {
      AppLanguage.english: 'Applications',
      AppLanguage.tamil: 'விண்ணப்பங்கள்',
      AppLanguage.hindi: 'आवेदन',
      AppLanguage.telugu: 'దరఖాస్తులు',
    },
    'nav.calculator': {
      AppLanguage.english: 'Calculator',
      AppLanguage.tamil: 'கால்குலேட்டர்',
      AppLanguage.hindi: 'कैल्कुलेटर',
      AppLanguage.telugu: 'కాలిక్యులేటర్',
    },
    'nav.analytics': {
      AppLanguage.english: 'Analytics',
      AppLanguage.tamil: 'பகுப்பாய்வு',
      AppLanguage.hindi: 'एनालिटिक्स',
      AppLanguage.telugu: 'విశ్లేషణలు',
    },
    'nav.compare': {
      AppLanguage.english: 'Compare',
      AppLanguage.tamil: 'ஒப்பிடு',
      AppLanguage.hindi: 'तुलना',
      AppLanguage.telugu: 'పోల్చండి',
    },
    'nav.logout': {
      AppLanguage.english: 'Logout',
      AppLanguage.tamil: 'வெளியேறு',
      AppLanguage.hindi: 'लॉगआउट',
      AppLanguage.telugu: 'లాగ్అవుట్',
    },

    // Dashboard
    'dashboard.greeting': {
      AppLanguage.english: 'Welcome, {name}!',
      AppLanguage.tamil: 'வரவேற்கிறோம், {name}!',
      AppLanguage.hindi: 'स्वागत है, {name}!',
      AppLanguage.telugu: 'స్వాగతం, {name}!',
    },
    'dashboard.subtitle': {
      AppLanguage.english: 'Find schemes, calculate loans, and track applications',
      AppLanguage.tamil: 'திட்டங்களைக் கண்டறியவும், கடன்களைக் கணக்கிடவும், விண்ணப்பங்களைக் கண்காணிக்கவும்',
      AppLanguage.hindi: 'योजनाएँ खोजें, ऋण की गणना करें, और आवेदन ट्रैक करें',
      AppLanguage.telugu: 'పథకాలను కనుగొనండి, రుణాలను లెక్కించండి, దరఖాస్తులను ట్రాక్ చేయండి',
    },
    'dashboard.active_schemes': {
      AppLanguage.english: 'Active Schemes',
      AppLanguage.tamil: 'செயலில் உள்ள திட்டங்கள்',
      AppLanguage.hindi: 'सक्रिय योजनाएँ',
      AppLanguage.telugu: 'సక్రియ పథకాలు',
    },
    'dashboard.my_applications': {
      AppLanguage.english: 'My Applications',
      AppLanguage.tamil: 'என் விண்ணப்பங்கள்',
      AppLanguage.hindi: 'मेरे आवेदन',
      AppLanguage.telugu: 'నా దరఖాస్తులు',
    },
    'dashboard.quick_actions': {
      AppLanguage.english: 'Quick Actions',
      AppLanguage.tamil: 'விரைவு செயல்கள்',
      AppLanguage.hindi: 'त्वरित कार्य',
      AppLanguage.telugu: 'త్వరిత చర్యలు',
    },

    // Quick Actions
    'action.get_matched': {
      AppLanguage.english: 'Get Matched',
      AppLanguage.tamil: 'பொருத்தமானதைப் பெறுங்கள்',
      AppLanguage.hindi: 'मैच प्राप्त करें',
      AppLanguage.telugu: 'మ్యాచ్ పొందండి',
    },
    'action.find_best_scheme': {
      AppLanguage.english: 'Find best scheme',
      AppLanguage.tamil: 'சிறந்த திட்டத்தைக் கண்டறியவும்',
      AppLanguage.hindi: 'सर्वोत्तम योजना खोजें',
      AppLanguage.telugu: 'ఉత్తమ పథకాన్ని కనుగొనండి',
    },
    'action.calculator': {
      AppLanguage.english: 'Calculator',
      AppLanguage.tamil: 'கால்குலேட்டர்',
      AppLanguage.hindi: 'कैल्कुलेटर',
      AppLanguage.telugu: 'కాలిక్యులేటర్',
    },
    'action.emi_amortization': {
      AppLanguage.english: 'EMI & amortization',
      AppLanguage.tamil: 'EMI மற்றும் தவணை அட்டவணை',
      AppLanguage.hindi: 'EMI और परिशोधन',
      AppLanguage.telugu: 'EMI మరియు అమోర్టైజేషన్',
    },
    'action.find_partners': {
      AppLanguage.english: 'Find Partners',
      AppLanguage.tamil: 'கூட்டாளர்களைக் கண்டறியவும்',
      AppLanguage.hindi: 'साझेदार खोजें',
      AppLanguage.telugu: 'భాగస్వాములను కనుగొనండి',
    },
    'action.nearby_locations': {
      AppLanguage.english: 'Nearby locations',
      AppLanguage.tamil: 'அருகிலுள்ள இடங்கள்',
      AppLanguage.hindi: 'निकटवर्ती स्थान',
      AppLanguage.telugu: 'సమీప ప్రదేశాలు',
    },
    'action.my_applications': {
      AppLanguage.english: 'My Applications',
      AppLanguage.tamil: 'என் விண்ணப்பங்கள்',
      AppLanguage.hindi: 'मेरे आवेदन',
      AppLanguage.telugu: 'నా దరఖాస్తులు',
    },
    'action.track_status': {
      AppLanguage.english: 'Track status',
      AppLanguage.tamil: 'நிலையைக் கண்காணி',
      AppLanguage.hindi: 'स्थिति ट्रैक करें',
      AppLanguage.telugu: 'స్థితిని ట్రాక్ చేయండి',
    },
    'action.compare_schemes': {
      AppLanguage.english: 'Compare Schemes',
      AppLanguage.tamil: 'திட்டங்களை ஒப்பிடுங்கள்',
      AppLanguage.hindi: 'योजनाओं की तुलना करें',
      AppLanguage.telugu: 'పథకాలను పోల్చండి',
    },
    'action.side_by_side': {
      AppLanguage.english: 'Side-by-side comparison',
      AppLanguage.tamil: 'ஒப்பீட்டு ஒப்பீடு',
      AppLanguage.hindi: 'तुलनात्मक विश्लेषण',
      AppLanguage.telugu: 'పక్కపక్కన పోలిక',
    },

    // Scheme Categories
    'category.micro_finance': {
      AppLanguage.english: 'Micro Finance',
      AppLanguage.tamil: 'நுண் நிதி',
      AppLanguage.hindi: 'सूक्ष्म वित्त',
      AppLanguage.telugu: 'మైక్రో ఫైనాన్స్',
    },
    'category.term_loan': {
      AppLanguage.english: 'Term Loan',
      AppLanguage.tamil: 'கால கடன்',
      AppLanguage.hindi: 'अवधि ऋण',
      AppLanguage.telugu: 'టర్మ్ లోన్',
    },
    'category.education': {
      AppLanguage.english: 'Education',
      AppLanguage.tamil: 'கல்வி',
      AppLanguage.hindi: 'शिक्षा',
      AppLanguage.telugu: 'విద్య',
    },
    'category.sc_st_special': {
      AppLanguage.english: 'SC/ST Special',
      AppLanguage.tamil: 'SC/ST சிறப்பு',
      AppLanguage.hindi: 'SC/ST विशेष',
      AppLanguage.telugu: 'SC/ST ప్రత్యేక',
    },

    // Recent Applications
    'recent.applications': {
      AppLanguage.english: 'Recent Applications',
      AppLanguage.tamil: 'சமீபத்திய விண்ணப்பங்கள்',
      AppLanguage.hindi: 'हाल के आवेदन',
      AppLanguage.telugu: 'ఇటీవలి దరఖాస్తులు',
    },

    // Schemes Screen
    'schemes.title': {
      AppLanguage.english: 'Schemes',
      AppLanguage.tamil: 'திட்டங்கள்',
      AppLanguage.hindi: 'योजनाएँ',
      AppLanguage.telugu: 'పథకాలు',
    },
    'schemes.all': {
      AppLanguage.english: 'All',
      AppLanguage.tamil: 'அனைத்தும்',
      AppLanguage.hindi: 'सभी',
      AppLanguage.telugu: 'అన్నీ',
    },

    // Calculator
    'calc.title': {
      AppLanguage.english: 'Loan Calculator',
      AppLanguage.tamil: 'கடன் கால்குலேட்டர்',
      AppLanguage.hindi: 'ऋण कैल्कुलेटर',
      AppLanguage.telugu: 'రుణ కాలిక్యులేటర్',
    },
    'calc.amount': {
      AppLanguage.english: 'Loan Amount (₹)',
      AppLanguage.tamil: 'கடன் தொகை (₹)',
      AppLanguage.hindi: 'ऋण राशि (₹)',
      AppLanguage.telugu: 'రుణ మొత్తం (₹)',
    },
    'calc.rate': {
      AppLanguage.english: 'Interest Rate (%)',
      AppLanguage.tamil: 'வட்டி விகிதம் (%)',
      AppLanguage.hindi: 'ब्याज दर (%)',
      AppLanguage.telugu: 'వడ్డీ రేటు (%)',
    },
    'calc.tenure': {
      AppLanguage.english: 'Tenure (months)',
      AppLanguage.tamil: 'காலம் (மாதங்கள்)',
      AppLanguage.hindi: 'अवधि (महीने)',
      AppLanguage.telugu: 'కాలం (నెలలు)',
    },
    'calc.moratorium': {
      AppLanguage.english: 'Moratorium',
      AppLanguage.tamil: 'தள்ளுபடி',
      AppLanguage.hindi: 'स्थगन',
      AppLanguage.telugu: 'మొరటోరియం',
    },
    'calc.calculate_emi': {
      AppLanguage.english: 'Calculate EMI',
      AppLanguage.tamil: 'EMI கணக்கிடுங்கள்',
      AppLanguage.hindi: 'EMI की गणना करें',
      AppLanguage.telugu: 'EMI లెక్కించండి',
    },
    'calc.monthly_emi': {
      AppLanguage.english: 'Monthly EMI',
      AppLanguage.tamil: 'மாத EMI',
      AppLanguage.hindi: 'मासिक EMI',
      AppLanguage.telugu: 'నెలవారీ EMI',
    },
    'calc.total_payment': {
      AppLanguage.english: 'Total Payment',
      AppLanguage.tamil: 'மொத்த பணம்',
      AppLanguage.hindi: 'कुल भुगतान',
      AppLanguage.telugu: 'మొత్తం చెల్లింపు',
    },
    'calc.total_interest': {
      AppLanguage.english: 'Total Interest',
      AppLanguage.tamil: 'மொத்த வட்டி',
      AppLanguage.hindi: 'कुल ब्याज',
      AppLanguage.telugu: 'మొత్తం వడ్డీ',
    },
    'calc.effective_tenure': {
      AppLanguage.english: 'Effective Tenure',
      AppLanguage.tamil: 'செயல்திறன் காலம்',
      AppLanguage.hindi: 'प्रभावी अवधि',
      AppLanguage.telugu: 'ప్రభావవంతమైన కాలం',
    },
    'calc.moratorium_period': {
      AppLanguage.english: 'Moratorium',
      AppLanguage.tamil: 'தள்ளுபடி காலம்',
      AppLanguage.hindi: 'स्थगन अवधि',
      AppLanguage.telugu: 'మొరటోరియం',
    },
    'calc.payment_breakdown': {
      AppLanguage.english: 'Payment Breakdown',
      AppLanguage.tamil: 'பணம் செலுத்தல் விவரம்',
      AppLanguage.hindi: 'भुगतान विवरण',
      AppLanguage.telugu: 'చెల్లింపు వివరాలు',
    },
    'calc.principal': {
      AppLanguage.english: 'Principal',
      AppLanguage.tamil: 'முதல்',
      AppLanguage.hindi: 'मूलधन',
      AppLanguage.telugu: 'మూలధనం',
    },
    'calc.interest': {
      AppLanguage.english: 'Interest',
      AppLanguage.tamil: 'வட்டி',
      AppLanguage.hindi: 'ब्याज',
      AppLanguage.telugu: 'వడ్డీ',
    },
    'calc.yearly_summary': {
      AppLanguage.english: 'Yearly Summary',
      AppLanguage.tamil: 'ஆண்டு சுருக்கம்',
      AppLanguage.hindi: 'वार्षिक सारांश',
      AppLanguage.telugu: 'వార్షిక సారాంశం',
    },

    // Partners
    'partners.title': {
      AppLanguage.english: 'Nearby Partners',
      AppLanguage.tamil: 'அருகிலுள்ள கூட்டாளர்கள்',
      AppLanguage.hindi: 'निकटवर्ती साझेदार',
      AppLanguage.telugu: 'సమీప భాగస్వాములు',
    },
    'partners.getting_location': {
      AppLanguage.english: 'Getting location...',
      AppLanguage.tamil: 'இருப்பிடம் பெறுகிறது...',
      AppLanguage.hindi: 'स्थान प्राप्त हो रहा है...',
      AppLanguage.telugu: 'స్థానం పొందుతోంది...',
    },
    'partners.using_default': {
      AppLanguage.english: 'Using default location (Chennai)',
      AppLanguage.tamil: 'இயல்புநிலை இருப்பிடம் (சென்னை)',
      AppLanguage.hindi: 'डिफ़ॉल्ट स्थान (चेन्नई)',
      AppLanguage.telugu: 'డిఫాల్ట్ స్థానం (చెన్నై)',
    },
    'partners.location_denied': {
      AppLanguage.english: 'Location permission denied',
      AppLanguage.tamil: 'இருப்பிட அனுமதி மறுக்கப்பட்டது',
      AppLanguage.hindi: 'स्थान अनुमति अस्वीकृत',
      AppLanguage.telugu: 'స్థాన అనుమతి నిరాకరించబడింది',
    },
    'partners.no_partners': {
      AppLanguage.english: 'No partners found nearby',
      AppLanguage.tamil: 'அருகில் கூட்டாளர்கள் இல்லை',
      AppLanguage.hindi: 'पास में कोई साझेदार नहीं मिला',
      AppLanguage.telugu: 'సమీపంలో భాగస్వాములు కనుగొనబడలేదు',
    },
    'partners.finding': {
      AppLanguage.english: 'Finding nearby partners...',
      AppLanguage.tamil: 'அருகிலுள்ள கூட்டாளர்களைத் தேடுகிறது...',
      AppLanguage.hindi: 'निकटवर्ती साझेदार खोज रहे हैं...',
      AppLanguage.telugu: 'సమీప భాగస్వాములను వెతుకుతోంది...',
    },
    'partners.eligible': {
      AppLanguage.english: 'Eligible',
      AppLanguage.tamil: 'தகுதியானது',
      AppLanguage.hindi: 'पात्र',
      AppLanguage.telugu: 'అర్హుడు',
    },
    'partners.not_eligible': {
      AppLanguage.english: 'Not Eligible',
      AppLanguage.tamil: 'தகுதியற்றது',
      AppLanguage.hindi: 'पात्र नहीं',
      AppLanguage.telugu: 'అర్హత లేదు',
    },

    // Applications
    'apps.title': {
      AppLanguage.english: 'My Applications',
      AppLanguage.tamil: 'என் விண்ணப்பங்கள்',
      AppLanguage.hindi: 'मेरे आवेदन',
      AppLanguage.telugu: 'నా దరఖాస్తులు',
    },
    'apps.no_apps': {
      AppLanguage.english: 'No applications yet',
      AppLanguage.tamil: 'இன்னும் விண்ணப்பங்கள் இல்லை',
      AppLanguage.hindi: 'अभी तक कोई आवेदन नहीं',
      AppLanguage.telugu: 'ఇంకా దరఖాస్తులు లేవు',
    },

    // Disbursement Chain
    'disbursement.title': {
      AppLanguage.english: 'Disbursement Chain',
      AppLanguage.tamil: 'செலுத்தல் சங்கிலி',
      AppLanguage.hindi: 'वितरण श्रृंखला',
      AppLanguage.telugu: 'విస్తృత గొలుసు',
    },

    // Analytics
    'analytics.title': {
      AppLanguage.english: 'Analytics Dashboard',
      AppLanguage.tamil: 'பகுப்பாய்வு டாஷ்போர்டு',
      AppLanguage.hindi: 'एनालिटिक्स डैशबोर्ड',
      AppLanguage.telugu: 'విశ్లేషణల డాష్‌బోర్డ్',
    },
    'analytics.total_users': {
      AppLanguage.english: 'Total Users',
      AppLanguage.tamil: 'மொத்த பயனர்கள்',
      AppLanguage.hindi: 'कुल उपयोगकर्ता',
      AppLanguage.telugu: 'మొత్తం వినియోగదారులు',
    },
    'analytics.total_schemes': {
      AppLanguage.english: 'Total Schemes',
      AppLanguage.tamil: 'மொத்த திட்டங்கள்',
      AppLanguage.hindi: 'कुल योजनाएँ',
      AppLanguage.telugu: 'మొత్తం పథకాలు',
    },
    'analytics.total_partners': {
      AppLanguage.english: 'Total Partners',
      AppLanguage.tamil: 'மொத்த கூட்டாளர்கள்',
      AppLanguage.hindi: 'कुल साझेदार',
      AppLanguage.telugu: 'మొత్తం భాగస్వాములు',
    },
    'analytics.total_applications': {
      AppLanguage.english: 'Total Applications',
      AppLanguage.tamil: 'மொத்த விண்ணப்பங்கள்',
      AppLanguage.hindi: 'कुल आवेदन',
      AppLanguage.telugu: 'మొత్తం దరఖాస్తులు',
    },
    'analytics.approval_rate': {
      AppLanguage.english: 'Approval Rate',
      AppLanguage.tamil: 'ஒப்புதல் விகிதம்',
      AppLanguage.hindi: 'अनुमोदन दर',
      AppLanguage.telugu: 'ఆమోద రేటు',
    },
    'analytics.by_scheme': {
      AppLanguage.english: 'Applications by Scheme',
      AppLanguage.tamil: 'திட்டம் வாரியான விண்ணப்பங்கள்',
      AppLanguage.hindi: 'योजना के अनुसार आवेदन',
      AppLanguage.telugu: 'పథకం ప్రకారం దరఖాస్తులు',
    },
    'analytics.by_project': {
      AppLanguage.english: 'Applications by Project Type',
      AppLanguage.tamil: 'திட்ட வகை வாரியான விண்ணப்பங்கள்',
      AppLanguage.hindi: 'प्रकार के अनुसार आवेदन',
      AppLanguage.telugu: 'ప్రాజెక్ట్ రకం ప్రకారం దరఖాస్తులు',
    },
    'analytics.top_partners': {
      AppLanguage.english: 'Top Partners',
      AppLanguage.tamil: 'சிறந்த கூட்டாளர்கள்',
      AppLanguage.hindi: 'शीर्ष साझेदार',
      AppLanguage.telugu: 'టాప్ భాగస్వాములు',
    },
    'analytics.rejection_analysis': {
      AppLanguage.english: 'Rejection Analysis',
      AppLanguage.tamil: 'நிராகரிப்பு பகுப்பாய்வு',
      AppLanguage.hindi: 'अस्वीकृति विश्लेषण',
      AppLanguage.telugu: 'తిరస్కరణ విశ్లేషణ',
    },
    'analytics.disbursement_pipeline': {
      AppLanguage.english: 'Disbursement Pipeline',
      AppLanguage.tamil: 'செலுத்தல் குழாய்',
      AppLanguage.hindi: 'वितरण पाइपलाइन',
      AppLanguage.telugu: 'విస్తృత పైప్‌లైన్',
    },

    // Compare
    'compare.title': {
      AppLanguage.english: 'Compare Schemes',
      AppLanguage.tamil: 'திட்டங்களை ஒப்பிடுங்கள்',
      AppLanguage.hindi: 'योजनाओं की तुलना करें',
      AppLanguage.telugu: 'పథకాలను పోల్చండి',
    },
    'compare.select_schemes': {
      AppLanguage.english: 'Select schemes to compare',
      AppLanguage.tamil: 'ஒப்பிட திட்டங்களைத் தேர்ந்தெடுக்கவும்',
      AppLanguage.hindi: 'तुलना के लिए योजनाएँ चुनें',
      AppLanguage.telugu: 'పోల్చడానికి పథకాలను ఎంచుకోండి',
    },
    'compare.max_loan': {
      AppLanguage.english: 'Max Loan',
      AppLanguage.tamil: 'அதிகபட்ச கடன்',
      AppLanguage.hindi: 'अधिकतम ऋण',
      AppLanguage.telugu: 'గరిష్ట రుణం',
    },
    'compare.interest_rate': {
      AppLanguage.english: 'Interest Rate',
      AppLanguage.tamil: 'வட்டி விகிதம்',
      AppLanguage.hindi: 'ब्याज दर',
      AppLanguage.telugu: 'వడ్డీ రేటు',
    },
    'compare.max_tenure': {
      AppLanguage.english: 'Max Tenure',
      AppLanguage.tamil: 'அதிகபட்ச காலம்',
      AppLanguage.hindi: 'अधिकतम अवधि',
      AppLanguage.telugu: 'గరిష్ట కాలం',
    },
    'compare.moratorium': {
      AppLanguage.english: 'Moratorium',
      AppLanguage.tamil: 'தள்ளுபடி',
      AppLanguage.hindi: 'स्थगन',
      AppLanguage.telugu: 'మొరటోరియం',
    },
    'compare.channels': {
      AppLanguage.english: 'Channels',
      AppLanguage.tamil: 'சேனல்கள்',
      AppLanguage.hindi: 'चैनल',
      AppLanguage.telugu: 'ఛానెల్స్',
    },

    // Common
    'common.loading': {
      AppLanguage.english: 'Loading...',
      AppLanguage.tamil: 'ஏற்றுகிறது...',
      AppLanguage.hindi: 'लोड हो रहा है...',
      AppLanguage.telugu: 'లోడ్ అవుతోంది...',
    },
    'common.retry': {
      AppLanguage.english: 'Retry',
      AppLanguage.tamil: 'மீண்டும் முயற்சி',
      AppLanguage.hindi: 'पुनः प्रयास करें',
      AppLanguage.telugu: 'మళ్ళీ ప్రయత్నించండి',
    },
    'common.error': {
      AppLanguage.english: 'Something went wrong',
      AppLanguage.tamil: 'ஏதோ தவறு நடந்தது',
      AppLanguage.hindi: 'कुछ गलत हो गया',
      AppLanguage.telugu: 'ఏదో తప్పు జరిగింది',
    },
  };

  static String translate(String key, {Map<String, String>? params}) {
    final translations = _translations[key];
    if (translations == null) return key;

    final lang = AppLanguageProvider.currentLanguage ?? AppLanguage.english;
    String text = translations[lang] ?? translations[AppLanguage.english] ?? key;

    // Replace parameters like {name}
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        text = text.replaceAll('{$paramKey}', paramValue);
      });
    }

    return text;
  }
}

/// InheritedNotifier to provide language throughout the widget tree
class AppLanguageProvider extends InheritedNotifier<ValueNotifier<AppLanguage>> {
  const AppLanguageProvider({
    super.key,
    required super.notifier,
    required super.child,
  });

  static AppLanguage get currentLanguage {
    // Default to English; overridden by the notifier
    return AppLanguage.english;
  }

  static AppLanguage? _current;

  static AppLanguage get language => _current ?? AppLanguage.english;

  static void setLanguage(AppLanguage lang) {
    _current = lang;
  }

  @override
  bool updateShouldNotify(AppLanguageProvider oldWidget) {
    return notifier != oldWidget.notifier;
  }
}

/// Simple language manager using SharedPreferences
class LanguageManager extends ChangeNotifier {
  AppLanguage _language = AppLanguage.english;

  AppLanguage get language => _language;

  LanguageManager() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langIndex = prefs.getInt('app_language') ?? 0;
    _language = AppLanguage.values[langIndex];
    AppLanguageProvider.setLanguage(_language);
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage lang) async {
    _language = lang;
    AppLanguageProvider.setLanguage(lang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('app_language', lang.index);
    notifyListeners();
  }

  String t(String key, {Map<String, String>? params}) {
    final translations = I18n._translations[key];
    if (translations == null) return key;
    String text = translations[_language] ?? translations[AppLanguage.english] ?? key;
    if (params != null) {
      params.forEach((k, v) => text = text.replaceAll('{$k}', v));
    }
    return text;
  }
}
