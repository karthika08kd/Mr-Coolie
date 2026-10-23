import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as ll;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

const String backendBaseUrl = 'http://10.52.110.158:5000';
const bool mapsEnabled = bool.fromEnvironment('MAPS_ENABLED');
final FlutterTts appTts = FlutterTts();

String _speechLocaleFor(String language) =>
    const {
      'ta': 'ta-IN',
      'en': 'en-IN',
      'hi': 'hi-IN',
      'te': 'te-IN',
      'kn': 'kn-IN',
      'ml': 'ml-IN',
    }[language] ??
    'en-IN';

/// Lightweight in-app language state. Core screens use these translations;
/// continue adding keys as additional screens are localized.
final ValueNotifier<String> appLanguage = ValueNotifier<String>('ta');
const Map<String, Map<String, String>> appTranslations = {
  'ta': {
    'home': 'முகப்பு',
    'find_work': 'அருகிலுள்ள வேலைகள்',
    'departments': 'துறைகள்',
    'finance': 'வருமானம்',
    'profile': 'சுயவிவரம்',
    'hello': 'வணக்கம்',
    'tagline': 'வேலை தேடுங்கள். வருமானம் ஈட்டுங்கள். முன்னேறுங்கள்.',
    'post_job': 'வேலை பதிவு செய்க',
    'nearby_jobs': 'அருகிலுள்ள வேலைகள்',
    'view_all': 'அனைத்தையும் பார்க்க',
    'search_jobs': 'வேலை, திறன் அல்லது இடத்தைத் தேடுங்கள்',
    'no_jobs': 'வேலைகள் எதுவும் இல்லை',
    'job_title': 'வேலை தலைப்பு',
    'department': 'துறை',
    'skill': 'தேவையான திறன்',
    'description': 'வேலை விவரம்',
    'location': 'இடம்',
    'payment': 'கூலி',
    'duration': 'கால அளவு',
    'post': 'வேலையை பதிவு செய்க',
    'language': 'மொழி',
    'quote': 'உங்கள் உழைப்பு உங்கள் பெருமை. உங்கள் திறமை உங்கள் அடையாளம்.',
    'worker': 'தொழிலாளர்',
    'employer': 'வேலை வழங்குநர்',
    'customer': 'வாடிக்கையாளர்',
    'find_workers': 'தொழிலாளர்களைக் கண்டறிய',
    'find_jobs_action': 'வேலை தேடுங்கள்',
    'browse_nearby_jobs': 'அருகிலுள்ள வேலைகளைப் பாருங்கள்',
    'hire_worker_action': 'தொழிலாளரைத் தேவை',
    'post_work_action': 'வேலை விவரத்தை வெளியிடுங்கள்',
    'popular_departments': 'பிரபலமான துறைகள்',
    'welcome_back': 'மீண்டும் வருக',
    'login_continue': 'தொடர உள்நுழையுங்கள்',
    'phone_otp': 'தொலைபேசி OTP',
    'email': 'மின்னஞ்சல்',
    'phone_number': 'தொலைபேசி எண்',
    'otp_code': '6 இலக்க OTP',
    'verify_login': 'சரிபார்த்து உள்நுழை',
    'send_otp': 'OTP அனுப்பு',
    'resend_otp': 'OTP மீண்டும் அனுப்பு',
    'change_number': 'எண்ணை மாற்று',
    'sms_notice': 'ஒருமுறை பயன்படுத்தும் SMS குறியீடு அனுப்பப்படும். SMS கட்டணம் இருக்கலாம்.',
    'password': 'கடவுச்சொல்',
    'forgot_password': 'கடவுச்சொல் மறந்துவிட்டதா?',
    'login': 'உள்நுழை',
    'new_user_register': 'புதியவரா? கணக்கு உருவாக்குங்கள்',
  },
  'en': {
    'home': 'Home',
    'find_work': 'Find Work',
    'departments': 'Departments',
    'finance': 'Earnings',
    'profile': 'Profile',
    'hello': 'Hello',
    'tagline': 'Find work. Earn money. Build your future.',
    'post_job': 'Post a Job',
    'nearby_jobs': 'Nearby Jobs',
    'view_all': 'View All',
    'search_jobs': 'Search jobs, skills or location',
    'no_jobs': 'No jobs found',
    'job_title': 'Job Title',
    'department': 'Department',
    'skill': 'Required Skill',
    'description': 'Job Description',
    'location': 'Location',
    'payment': 'Wage',
    'duration': 'Duration',
    'post': 'POST JOB',
    'language': 'Language',
    'quote': 'Your hard work is your pride. Your skill is your identity.',
    'worker': 'Worker',
    'employer': 'Employer',
    'customer': 'Customer',
    'find_workers': 'Find Workers',
    'find_jobs_action': 'Find Work',
    'browse_nearby_jobs': 'Browse nearby jobs',
    'hire_worker_action': 'Need a Worker',
    'post_work_action': 'Post a job',
    'popular_departments': 'Popular Departments',
    'welcome_back': 'Welcome Back',
    'login_continue': 'Login to continue',
    'phone_otp': 'Phone OTP',
    'email': 'Email',
    'phone_number': 'Phone Number',
    'otp_code': '6-digit OTP',
    'verify_login': 'VERIFY & LOGIN',
    'send_otp': 'SEND OTP',
    'resend_otp': 'Resend OTP',
    'change_number': 'Change number',
    'sms_notice': 'We will send a one-time SMS verification code. Standard messaging rates may apply.',
    'password': 'Password',
    'forgot_password': 'Forgot Password?',
    'login': 'LOGIN',
    'new_user_register': 'New user? Create Account',
  },
  'hi': {
    'payment_hint': 'यदि बाद में तय करना है तो खाली छोड़ें',
    'home': 'होम',
    'find_work': 'काम खोजें',
    'departments': 'विभाग',
    'finance': 'कमाई',
    'profile': 'प्रोफ़ाइल',
    'hello': 'नमस्ते',
    'tagline': 'काम खोजें। कमाएँ। आगे बढ़ें।',
    'post_job': 'काम पोस्ट करें',
    'nearby_jobs': 'आस-पास के काम',
    'view_all': 'सभी देखें',
    'search_jobs': 'काम, कौशल या स्थान खोजें',
    'no_jobs': 'कोई काम नहीं मिला',
    'job_title': 'काम का शीर्षक',
    'department': 'विभाग',
    'skill': 'आवश्यक कौशल',
    'description': 'काम का विवरण',
    'location': 'स्थान',
    'payment': 'मजदूरी',
    'duration': 'अवधि',
    'post': 'काम पोस्ट करें',
    'language': 'भाषा',
    'quote': 'आपकी मेहनत ही आपका गौरव है।',
    'worker': 'कामगार',
    'employer': 'नियोक्ता',
    'customer': 'ग्राहक',
    'find_workers': 'कामगार खोजें',
    'find_jobs_action': 'काम खोजें',
    'browse_nearby_jobs': 'आस-पास के काम देखें',
    'hire_worker_action': 'कामगार चाहिए',
    'post_work_action': 'काम पोस्ट करें',
    'popular_departments': 'लोकप्रिय विभाग',
    'welcome_back': 'वापसी पर स्वागत है',
    'login_continue': 'जारी रखने के लिए लॉगिन करें',
    'phone_otp': 'फोन OTP',
    'email': 'ईमेल',
    'phone_number': 'फोन नंबर',
    'otp_code': '6 अंकों का OTP',
    'verify_login': 'सत्यापित करें और लॉगिन करें',
    'send_otp': 'OTP भेजें',
    'resend_otp': 'OTP फिर भेजें',
    'change_number': 'नंबर बदलें',
    'sms_notice':
        'एक बार इस्तेमाल होने वाला SMS कोड भेजा जाएगा। SMS शुल्क लग सकता है।',
    'password': 'पासवर्ड',
    'forgot_password': 'पासवर्ड भूल गए?',
    'login': 'लॉगिन',
    'new_user_register': 'नए हैं? खाता बनाएँ',
  },
  'te': {
    'payment_hint': 'తర్వాత మాట్లాడి నిర్ణయించాలంటే ఖాళీగా వదలండి',
    'home': 'హోమ్',
    'find_work': 'పనులు వెతకండి',
    'departments': 'విభాగాలు',
    'finance': 'ఆదాయం',
    'profile': 'ప్రొఫైల్',
    'hello': 'నమస్కారం',
    'tagline': 'పని కనుగొనండి. సంపాదించండి. ఎదగండి.',
    'post_job': 'పని పోస్ట్ చేయండి',
    'nearby_jobs': 'మీ దగ్గర పనులు',
    'view_all': 'అన్నీ చూడండి',
    'search_jobs': 'పని, నైపుణ్యం లేదా ప్రదేశం వెతకండి',
    'no_jobs': 'పనులు కనబడలేదు',
    'job_title': 'పని పేరు',
    'department': 'విభాగం',
    'skill': 'అవసరమైన నైపుణ్యం',
    'description': 'పని వివరాలు',
    'location': 'ప్రదేశం',
    'payment': 'కూలి',
    'duration': 'వ్యవధి',
    'post': 'పని పోస్ట్ చేయండి',
    'language': 'భాష',
    'quote': 'మీ కష్టమే మీ గర్వం.',
    'worker': 'కార్మికుడు',
    'employer': 'యజమాని',
    'customer': 'కస్టమర్',
    'find_workers': 'కార్మికులను కనుగొనండి',
    'find_jobs_action': 'పని వెతకండి',
    'browse_nearby_jobs': 'దగ్గరలోని పనులు చూడండి',
    'hire_worker_action': 'కార్మికుడు కావాలి',
    'post_work_action': 'పని పోస్ట్ చేయండి',
    'popular_departments': 'ప్రసిద్ధ విభాగాలు',
    'welcome_back': 'తిరిగి స్వాగతం',
    'login_continue': 'కొనసాగడానికి లాగిన్ అవ్వండి',
    'phone_otp': 'ఫోన్ OTP',
    'email': 'ఇమెయిల్',
    'phone_number': 'ఫోన్ నంబర్',
    'otp_code': '6 అంకెల OTP',
    'verify_login': 'ధృవీకరించి లాగిన్ అవ్వండి',
    'send_otp': 'OTP పంపండి',
    'resend_otp': 'OTP మళ్లీ పంపండి',
    'change_number': 'నంబర్ మార్చండి',
    'sms_notice':
        'ఒకసారి ఉపయోగించే SMS కోడ్ పంపబడుతుంది. SMS ఛార్జీలు వర్తించవచ్చు.',
    'password': 'పాస్‌వర్డ్',
    'forgot_password': 'పాస్‌వర్డ్ మర్చిపోయారా?',
    'login': 'లాగిన్',
    'new_user_register': 'కొత్తవారా? ఖాతా సృష్టించండి',
  },
  'kn': {
    'payment_hint': 'ನಂತರ ಚರ್ಚಿಸಿ ನಿರ್ಧರಿಸಲು ಖಾಲಿ ಬಿಡಿ',
    'home': 'ಮುಖಪುಟ',
    'find_work': 'ಕೆಲಸ ಹುಡುಕಿ',
    'departments': 'ವಿಭಾಗಗಳು',
    'finance': 'ಆದಾಯ',
    'profile': 'ಪ್ರೊಫೈಲ್',
    'hello': 'ನಮಸ್ಕಾರ',
    'tagline': 'ಕೆಲಸ ಹುಡುಕಿ. ಸಂಪಾದಿಸಿ. ಬೆಳೆಯಿರಿ.',
    'post_job': 'ಕೆಲಸ ಪ್ರಕಟಿಸಿ',
    'nearby_jobs': 'ಹತ್ತಿರದ ಕೆಲಸಗಳು',
    'view_all': 'ಎಲ್ಲವನ್ನೂ ನೋಡಿ',
    'search_jobs': 'ಕೆಲಸ, ಕೌಶಲ್ಯ ಅಥವಾ ಸ್ಥಳ ಹುಡುಕಿ',
    'no_jobs': 'ಕೆಲಸಗಳು ಕಂಡುಬಂದಿಲ್ಲ',
    'job_title': 'ಕೆಲಸದ ಶೀರ್ಷಿಕೆ',
    'department': 'ವಿಭಾಗ',
    'skill': 'ಅಗತ್ಯ ಕೌಶಲ್ಯ',
    'description': 'ಕೆಲಸದ ವಿವರ',
    'location': 'ಸ್ಥಳ',
    'payment': 'ಕೂಲಿ',
    'duration': 'ಅವಧಿ',
    'post': 'ಕೆಲಸ ಪ್ರಕಟಿಸಿ',
    'language': 'ಭಾಷೆ',
    'quote': 'ನಿಮ್ಮ ಶ್ರಮವೇ ನಿಮ್ಮ ಹೆಮ್ಮೆ.',
    'worker': 'ಕಾರ್ಮಿಕ',
    'employer': 'ಉದ್ಯೋಗದಾತ',
    'customer': 'ಗ್ರಾಹಕ',
    'find_workers': 'ಕಾರ್ಮಿಕರನ್ನು ಹುಡುಕಿ',
    'find_jobs_action': 'ಕೆಲಸ ಹುಡುಕಿ',
    'browse_nearby_jobs': 'ಹತ್ತಿರದ ಕೆಲಸಗಳನ್ನು ನೋಡಿ',
    'hire_worker_action': 'ಕೆಲಸಗಾರ ಬೇಕು',
    'post_work_action': 'ಕೆಲಸ ಪ್ರಕಟಿಸಿ',
    'popular_departments': 'ಜನಪ್ರಿಯ ವಿಭಾಗಗಳು',
    'welcome_back': 'ಮರಳಿ ಸ್ವಾಗತ',
    'login_continue': 'ಮುಂದುವರಿಯಲು ಲಾಗಿನ್ ಮಾಡಿ',
    'phone_otp': 'ಫೋನ್ OTP',
    'email': 'ಇಮೇಲ್',
    'phone_number': 'ಫೋನ್ ಸಂಖ್ಯೆ',
    'otp_code': '6 ಅಂಕಿಯ OTP',
    'verify_login': 'ಪರಿಶೀಲಿಸಿ ಲಾಗಿನ್ ಮಾಡಿ',
    'send_otp': 'OTP ಕಳುಹಿಸಿ',
    'resend_otp': 'OTP ಮತ್ತೆ ಕಳುಹಿಸಿ',
    'change_number': 'ಸಂಖ್ಯೆ ಬದಲಿಸಿ',
    'sms_notice':
        'ಒಮ್ಮೆ ಬಳಸುವ SMS ಕೋಡ್ ಕಳುಹಿಸಲಾಗುತ್ತದೆ. SMS ಶುಲ್ಕ ಅನ್ವಯಿಸಬಹುದು.',
    'password': 'ಪಾಸ್‌ವರ್ಡ್',
    'forgot_password': 'ಪಾಸ್‌ವರ್ಡ್ ಮರೆತಿರಾ?',
    'login': 'ಲಾಗಿನ್',
    'new_user_register': 'ಹೊಸಬರೇ? ಖಾತೆ ರಚಿಸಿ',
  },
  'ml': {
    'payment_hint': 'പിന്നീട് തീരുമാനിക്കാനാണെങ്കിൽ ഒഴിച്ചിടുക',
    'home': 'ഹോം',
    'find_work': 'ജോലികൾ കണ്ടെത്തുക',
    'departments': 'വിഭാഗങ്ങൾ',
    'finance': 'വരുമാനം',
    'profile': 'പ്രൊഫൈൽ',
    'hello': 'നമസ്കാരം',
    'tagline': 'ജോലി കണ്ടെത്തൂ. സമ്പാദിക്കൂ. മുന്നേറൂ.',
    'post_job': 'ജോലി പോസ്റ്റ് ചെയ്യുക',
    'nearby_jobs': 'സമീപ ജോലികൾ',
    'view_all': 'എല്ലാം കാണുക',
    'search_jobs': 'ജോലി, കഴിവ് അല്ലെങ്കിൽ സ്ഥലം തിരയുക',
    'no_jobs': 'ജോലികൾ കണ്ടെത്തിയില്ല',
    'job_title': 'ജോലിയുടെ പേര്',
    'department': 'വിഭാഗം',
    'skill': 'ആവശ്യമായ കഴിവ്',
    'description': 'ജോലി വിവരണം',
    'location': 'സ്ഥലം',
    'payment': 'കൂലി',
    'duration': 'കാലാവധി',
    'post': 'ജോലി പോസ്റ്റ് ചെയ്യുക',
    'language': 'ഭാഷ',
    'quote': 'നിങ്ങളുടെ അധ്വാനമാണ് നിങ്ങളുടെ അഭിമാനം.',
    'worker': 'തൊഴിലാളി',
    'employer': 'തൊഴിൽദാതാവ്',
    'customer': 'ഉപഭോക്താവ്',
    'find_workers': 'തൊഴിലാളികളെ കണ്ടെത്തുക',
    'find_jobs_action': 'ജോലി കണ്ടെത്തൂ',
    'browse_nearby_jobs': 'സമീപ ജോലികൾ കാണൂ',
    'hire_worker_action': 'തൊഴിലാളി വേണം',
    'post_work_action': 'ജോലി പോസ്റ്റ് ചെയ്യൂ',
    'popular_departments': 'പ്രധാന വിഭാഗങ്ങൾ',
    'welcome_back': 'വീണ്ടും സ്വാഗതം',
    'login_continue': 'തുടരാൻ ലോഗിൻ ചെയ്യുക',
    'phone_otp': 'ഫോൺ OTP',
    'email': 'ഇമെയിൽ',
    'phone_number': 'ഫോൺ നമ്പർ',
    'otp_code': '6 അക്ക OTP',
    'verify_login': 'പരിശോധിച്ച് ലോഗിൻ ചെയ്യുക',
    'send_otp': 'OTP അയയ്ക്കുക',
    'resend_otp': 'OTP വീണ്ടും അയയ്ക്കുക',
    'change_number': 'നമ്പർ മാറ്റുക',
    'sms_notice': 'ഒറ്റത്തവണ ഉപയോഗിക്കാവുന്ന SMS കോഡ് അയയ്ക്കും. SMS നിരക്കുകൾ ബാധകമായേക്കാം.',
    'password': 'പാസ്‌വേഡ്',
    'forgot_password': 'പാസ്‌വേഡ് മറന്നോ?',
    'login': 'ലോഗിൻ',
    'new_user_register': 'പുതിയ ആളാണോ? അക്കൗണ്ട് സൃഷ്ടിക്കുക',
  },
};

const Map<String, Map<String, String>> extendedTranslations = {
  'en': {
    'my_jobs': 'My jobs',
    'applicants': 'Applicants',
    'my_profile': 'My Profile',
    'this_week_earnings': 'This Week Earnings',
    'growth_from_last_week': '+18% from last week',
    'digital_work_id': 'Digital Work ID preview',
    'identity_not_verified': 'Identity details; work stats are not verified',
    'my_skills': 'My Skills',
    'skills_from_registration': 'Skills saved during registration',
    'work_availability': 'Work availability',
    'availability_description': 'Choose whether employers can find you',
    'my_applications': 'My Applications',
    'track_application_status': 'Track application status',
    'live_location_sharing': 'Live location sharing',
    'share_accepted_job': 'Share location only for an accepted job',
    'work_history': 'Work History',
    'completed_applications': 'View completed applications',
    'ratings': 'Ratings',
    'completed_job_ratings': 'Review ratings for completed jobs',
    'manage_job_posts': 'Manage your job postings',
    'review_applicants': 'Review workers who applied',
    'search_available_workers': 'Search available worker profiles',
    'settings': 'Settings',
    'account_preferences': 'Account and preferences',
    'logout': 'LOGOUT',
    'create_account': 'Create Account',
    'join_coolie': 'Join Mr. கூலி',
    'full_name': 'Full Name',
    'account_type': 'Account Type',
    'customer_find_workers': 'Customer / Find Workers',
    'confirm_password': 'Confirm Password',
    'save_continue': 'CREATE ACCOUNT',
    'already_have_account': 'Already have an account? Login',
    'complete_required_fields': 'Please complete all required fields.',
    'passwords_mismatch': 'Passwords do not match.',
    'worker_profile_required':
        'Worker location, department and skill are required.',
    'account_created': 'Account Created',
    'registration_success': 'Your Firebase account was created successfully. You can now continue to Mr. கூலி.',
    'continue': 'CONTINUE',
    'change_language': 'Change language',
    'nearby_jobs_map': 'Nearby jobs map',
    'stop_voice_search': 'Stop voice search',
    'search_by_voice': 'Search by voice',
    'use_my_location': 'Use my location',
    'post_job_title': 'Post a Job',
    'find_right_worker': 'Find the right worker for your work.',
    'email_address': 'Email',
    'worker_role': 'Worker',
    'employer_role': 'Employer',
    'department_label': 'Department',
    'skill_label': 'Skill',
    'location_label': 'Location',
    'password_label': 'Password',
    'profile_complete_title': 'Complete your profile',
    'role_prompt': 'Choose how you want to use Mr. Coolie. This role cannot be changed later.',
    'city_area': 'City / area',
    'save_and_continue': 'SAVE AND CONTINUE',
    'sign_out': 'SIGN OUT',
    'retry': 'RETRY',
    'find_workers_title': 'Find Workers',
    'worker_search_hint': 'Search skill, worker or location',
    'all_departments': 'All departments',
    'no_workers_match': 'No available workers match your search.',
    'private_contact_notice': 'Contact details are private. The worker must approve a contact workflow.',
    'use_job_site_location': 'Use this device location for the job site',
    'job_site_coordinates_saved': 'Job site coordinates saved',
    'one_day': '1 Day',
    'two_days': '2 Days',
    'three_days': '3 Days',
    'one_week': '1 Week',
    'transactions': 'Transactions',
    'savings_goals': 'Savings Goals',
    'financial_insights': 'Payments & records',
    'work_ratings': 'Work ratings',
    'work_profile_id': 'Work Profile ID',
    'digital_payment_demo': 'Digital Payment Demo',
    'available_for_work': 'Available for work',
    'not_available': 'Not available',
    'my_applications_title': 'My Applications',
  },
  'ta': {
    'my_jobs': 'என் வேலைகள்',
    'applicants': 'விண்ணப்பதாரர்கள்',
    'my_profile': 'என் சுயவிவரம்',
    'this_week_earnings': 'இந்த வார வருமானம்',
    'growth_from_last_week': 'கடந்த வாரத்தை விட +18%',
    'digital_work_id': 'டிஜிட்டல் வேலை அடையாள அட்டை (முன்னோட்டம்)',
    'identity_not_verified':
        'அடையாள விவரங்கள்; வேலை புள்ளிவிவரங்கள் சரிபார்க்கப்படவில்லை',
    'my_skills': 'என் திறன்கள்',
    'skills_from_registration': 'பதிவின்போது சேமித்த திறன்கள்',
    'work_availability': 'வேலை கிடைக்கும் நிலை',
    'availability_description':
        'வேலை வழங்குநர்கள் உங்களைக் காண வேண்டுமா என்பதைத் தேர்ந்தெடுக்கவும்',
    'my_applications': 'என் விண்ணப்பங்கள்',
    'track_application_status': 'விண்ணப்ப நிலையைப் பார்க்கவும்',
    'live_location_sharing': 'நேரடி இருப்பிடப் பகிர்வு',
    'share_accepted_job':
        'ஏற்றுக்கொண்ட வேலைக்காக மட்டும் இருப்பிடத்தைப் பகிரவும்',
    'work_history': 'வேலை வரலாறு',
    'completed_applications': 'முடித்த விண்ணப்பங்களைப் பார்க்கவும்',
    'ratings': 'மதிப்பீடுகள்',
    'completed_job_ratings': 'முடித்த வேலைகளின் மதிப்பீடுகளைப் பார்க்கவும்',
    'manage_job_posts': 'உங்கள் வேலைப் பதிவுகளை நிர்வகிக்கவும்',
    'review_applicants': 'விண்ணப்பித்த தொழிலாளர்களைப் பார்க்கவும்',
    'search_available_workers': 'கிடைக்கும் தொழிலாளர் விவரங்களைத் தேடவும்',
    'settings': 'அமைப்புகள்',
    'account_preferences': 'கணக்கு மற்றும் விருப்பங்கள்',
    'logout': 'வெளியேறு',
    'create_account': 'கணக்கை உருவாக்கு',
    'join_coolie': 'Mr. கூலியில் இணையுங்கள்',
    'full_name': 'முழுப் பெயர்',
    'account_type': 'கணக்கு வகை',
    'customer_find_workers': 'வாடிக்கையாளர் / தொழிலாளர் தேடல்',
    'confirm_password': 'கடவுச்சொல்லை உறுதிப்படுத்தவும்',
    'save_continue': 'கணக்கை உருவாக்கு',
    'already_have_account': 'ஏற்கனவே கணக்கு உள்ளதா? உள்நுழையுங்கள்',
    'complete_required_fields': 'தேவையான அனைத்து விவரங்களையும் நிரப்பவும்.',
    'passwords_mismatch': 'கடவுச்சொற்கள் பொருந்தவில்லை.',
    'worker_profile_required':
        'தொழிலாளர் இடம், துறை, திறனைத் தேர்ந்தெடுக்க வேண்டும்.',
    'account_created': 'கணக்கு உருவாக்கப்பட்டது',
    'registration_success':
        'Firebase கணக்கு உருவாக்கப்பட்டது. இப்போது Mr. கூலியைத் தொடரலாம்.',
    'continue': 'தொடரவும்',
    'change_language': 'மொழியை மாற்றவும்',
    'email_address': 'மின்னஞ்சல்',
    'worker_role': 'தொழிலாளர்',
    'employer_role': 'வேலை வழங்குநர்',
    'department_label': 'துறை',
    'skill_label': 'திறன்',
    'location_label': 'இடம்',
    'password_label': 'கடவுச்சொல்',
    'profile_complete_title': 'சுயவிவரத்தை நிறைவு செய்க',
    'role_prompt': 'Mr. கூலியை எப்படிப் பயன்படுத்த விரும்புகிறீர்கள் என்பதைத் தேர்ந்தெடுக்கவும். இந்தப் பங்கை பின்னர் மாற்ற முடியாது.',
    'city_area': 'நகரம் / பகுதி',
    'save_and_continue': 'சேமித்து தொடரவும்',
    'sign_out': 'வெளியேறு',
    'retry': 'மீண்டும் முயற்சி',
    'find_workers_title': 'தொழிலாளர்களைக் கண்டறிய',
    'worker_search_hint': 'திறன், தொழிலாளர் அல்லது இடத்தைத் தேடுங்கள்',
    'all_departments': 'அனைத்து துறைகளும்',
    'no_workers_match': 'உங்கள் தேடலுக்குப் பொருந்தும் தொழிலாளர்கள் இல்லை.',
    'private_contact_notice':
        'தொடர்பு விவரங்கள் தனிப்பட்டவை. தொடர்புக்கு தொழிலாளரின் ஒப்புதல் தேவை.',
    'use_job_site_location':
        'வேலை இடத்திற்காக இந்த சாதனத்தின் இருப்பிடத்தைப் பயன்படுத்தவும்',
    'job_site_coordinates_saved': 'வேலை இடத்தின் இருப்பிடம் சேமிக்கப்பட்டது',
    'one_day': '1 நாள்',
    'two_days': '2 நாட்கள்',
    'three_days': '3 நாட்கள்',
    'one_week': '1 வாரம்',
    'transactions': 'பரிவர்த்தனைகள்',
    'savings_goals': 'சேமிப்பு இலக்குகள்',
    'financial_insights': '????? ?????????',
    'work_ratings': 'வேலை மதிப்பீடுகள்',
    'work_profile_id': 'வேலை சுயவிவர அடையாளம்',
    'digital_payment_demo': 'டிஜிட்டல் கட்டண முன்னோட்டம்',
    'available_for_work': 'வேலைக்குக் கிடைக்கிறார்',
    'not_available': 'கிடைக்கவில்லை',
    'my_applications_title': 'என் விண்ணப்பங்கள்',
  },
  'hi': {
    'my_jobs': 'मेरे काम',
    'applicants': 'आवेदक',
    'my_profile': 'मेरी प्रोफ़ाइल',
    'this_week_earnings': 'इस सप्ताह की कमाई',
    'growth_from_last_week': 'पिछले सप्ताह से +18%',
    'digital_work_id': 'डिजिटल कार्य पहचान पत्र (पूर्वावलोकन)',
    'identity_not_verified': 'पहचान विवरण; कार्य आँकड़े सत्यापित नहीं हैं',
    'my_skills': 'मेरे कौशल',
    'skills_from_registration': 'पंजीकरण के दौरान सहेजे गए कौशल',
    'work_availability': 'काम की उपलब्धता',
    'availability_description': 'चुनें कि नियोक्ता आपको ढूँढ सकें या नहीं',
    'my_applications': 'मेरे आवेदन',
    'track_application_status': 'आवेदन की स्थिति देखें',
    'live_location_sharing': 'लाइव स्थान साझा करना',
    'share_accepted_job': 'केवल स्वीकार किए गए काम के लिए स्थान साझा करें',
    'work_history': 'कार्य इतिहास',
    'completed_applications': 'पूरे किए गए आवेदन देखें',
    'ratings': 'रेटिंग',
    'completed_job_ratings': 'पूरे किए गए काम की रेटिंग देखें',
    'manage_job_posts': 'अपनी नौकरी पोस्टिंग प्रबंधित करें',
    'review_applicants': 'आवेदन करने वाले कामगार देखें',
    'search_available_workers': 'उपलब्ध कामगार प्रोफ़ाइल खोजें',
    'settings': 'सेटिंग्स',
    'account_preferences': 'खाता और प्राथमिकताएँ',
    'logout': 'लॉग आउट',
    'create_account': 'खाता बनाएँ',
    'join_coolie': 'Mr. கூலி से जुड़ें',
    'full_name': 'पूरा नाम',
    'account_type': 'खाते का प्रकार',
    'customer_find_workers': 'ग्राहक / कामगार खोजें',
    'confirm_password': 'पासवर्ड की पुष्टि करें',
    'save_continue': 'खाता बनाएँ',
    'already_have_account': 'पहले से खाता है? लॉगिन करें',
    'complete_required_fields': 'कृपया सभी आवश्यक जानकारी भरें.',
    'passwords_mismatch': 'पासवर्ड मेल नहीं खाते.',
    'worker_profile_required': 'कामगार का स्थान, विभाग और कौशल आवश्यक हैं.',
    'account_created': 'खाता बन गया',
    'registration_success': 'आपका Firebase खाता बन गया. अब Mr. கூலி जारी रखें.',
    'continue': 'जारी रखें',
    'change_language': 'भाषा बदलें',
    'email_address': 'ईमेल',
    'worker_role': 'कामगार',
    'employer_role': 'नियोक्ता',
    'department_label': 'विभाग',
    'skill_label': 'कौशल',
    'location_label': 'स्थान',
    'password_label': 'पासवर्ड',
    'profile_complete_title': 'अपनी प्रोफ़ाइल पूरी करें',
    'role_prompt': 'चुनें कि आप Mr. Coolie का उपयोग कैसे करना चाहते हैं। यह भूमिका बाद में नहीं बदली जा सकती।',
    'city_area': 'शहर / क्षेत्र',
    'save_and_continue': 'सहेजें और जारी रखें',
    'sign_out': 'लॉग आउट',
    'retry': 'फिर कोशिश करें',
    'find_workers_title': 'कामगार खोजें',
    'worker_search_hint': 'कौशल, कामगार या स्थान खोजें',
    'all_departments': 'सभी विभाग',
    'no_workers_match': 'आपकी खोज से मेल खाते कामगार उपलब्ध नहीं हैं।',
    'private_contact_notice':
        'संपर्क विवरण निजी हैं। संपर्क प्रक्रिया के लिए कामगार की सहमति चाहिए।',
    'use_job_site_location': 'कार्यस्थल के लिए इस डिवाइस का स्थान उपयोग करें',
    'job_site_coordinates_saved': 'कार्यस्थल का स्थान सहेजा गया',
    'one_day': '1 दिन',
    'two_days': '2 दिन',
    'three_days': '3 दिन',
    'one_week': '1 सप्ताह',
    'transactions': 'लेन-देन',
    'savings_goals': 'बचत लक्ष्य',
    'financial_insights': '?????? ?????',
    'work_ratings': 'काम की रेटिंग',
    'work_profile_id': 'कार्य प्रोफ़ाइल आईडी',
    'digital_payment_demo': 'डिजिटल भुगतान पूर्वावलोकन',
    'available_for_work': 'काम के लिए उपलब्ध',
    'not_available': 'उपलब्ध नहीं',
    'my_applications_title': 'मेरे आवेदन',
  },
  'te': {
    'my_jobs': 'నా పనులు',
    'applicants': 'దరఖాస్తుదారులు',
    'my_profile': 'నా ప్రొఫైల్',
    'this_week_earnings': 'ఈ వారం ఆదాయం',
    'growth_from_last_week': 'గత వారం కంటే +18%',
    'digital_work_id': 'డిజిటల్ పని గుర్తింపు (ప్రివ్యూ)',
    'identity_not_verified': 'గుర్తింపు వివరాలు; పని గణాంకాలు ధృవీకరించబడలేదు',
    'my_skills': 'నా నైపుణ్యాలు',
    'skills_from_registration': 'నమోదు సమయంలో సేవ్ చేసిన నైపుణ్యాలు',
    'work_availability': 'పని అందుబాటు',
    'availability_description': 'యజమానులు మిమ్మల్ని కనుగొనాలా ఎంచుకోండి',
    'my_applications': 'నా దరఖాస్తులు',
    'track_application_status': 'దరఖాస్తు స్థితిని చూడండి',
    'live_location_sharing': 'ప్రత్యక్ష స్థాన భాగస్వామ్యం',
    'share_accepted_job': 'అంగీకరించిన పని కోసం మాత్రమే స్థానాన్ని పంచుకోండి',
    'work_history': 'పని చరిత్ర',
    'completed_applications': 'పూర్తయిన దరఖాస్తులను చూడండి',
    'ratings': 'రేటింగ్‌లు',
    'completed_job_ratings': 'పూర్తయిన పనుల రేటింగ్‌లను చూడండి',
    'manage_job_posts': 'మీ పని పోస్టులను నిర్వహించండి',
    'review_applicants': 'దరఖాస్తు చేసిన కార్మికులను చూడండి',
    'search_available_workers':
        'అందుబాటులో ఉన్న కార్మికుల ప్రొఫైల్‌లను వెతకండి',
    'settings': 'సెట్టింగ్‌లు',
    'account_preferences': 'ఖాతా మరియు ప్రాధాన్యతలు',
    'logout': 'లాగ్ అవుట్',
    'create_account': 'ఖాతా సృష్టించండి',
    'join_coolie': 'Mr. கூலி లో చేరండి',
    'full_name': 'పూర్తి పేరు',
    'account_type': 'ఖాతా రకం',
    'customer_find_workers': 'కస్టమర్ / కార్మికులను వెతకండి',
    'confirm_password': 'పాస్‌వర్డ్ నిర్ధారించండి',
    'save_continue': 'ఖాతా సృష్టించండి',
    'already_have_account': 'ఇప్పటికే ఖాతా ఉందా? లాగిన్ అవ్వండి',
    'complete_required_fields': 'అవసరమైన అన్ని వివరాలను పూరించండి.',
    'passwords_mismatch': 'పాస్‌వర్డ్‌లు సరిపోలలేదు.',
    'worker_profile_required': 'కార్మికుడి ప్రాంతం, విభాగం, నైపుణ్యం అవసరం.',
    'account_created': 'ఖాతా సృష్టించబడింది',
    'registration_success':
        'మీ Firebase ఖాతా సృష్టించబడింది. ఇప్పుడు Mr. கூலி కొనసాగించండి.',
    'continue': 'కొనసాగించండి',
    'change_language': 'భాష మార్చండి',
    'email_address': 'ఇమెయిల్',
    'worker_role': 'కార్మికుడు',
    'employer_role': 'యజమాని',
    'department_label': 'విభాగం',
    'skill_label': 'నైపుణ్యం',
    'location_label': 'ప్రదేశం',
    'password_label': 'పాస్‌వర్డ్',
    'profile_complete_title': 'మీ ప్రొఫైల్‌ను పూర్తి చేయండి',
    'role_prompt': 'Mr. கூலி ను ఎలా ఉపయోగించాలనుకుంటున్నారో ఎంచుకోండి. ఈ పాత్రను తర్వాత మార్చలేరు.',
    'city_area': 'నగరం / ప్రాంతం',
    'save_and_continue': 'సేవ్ చేసి కొనసాగించండి',
    'sign_out': 'లాగ్ అవుట్',
    'retry': 'మళ్లీ ప్రయత్నించండి',
    'find_workers_title': 'కార్మికులను కనుగొనండి',
    'worker_search_hint': 'నైపుణ్యం, కార్మికుడు లేదా ప్రదేశం వెతకండి',
    'all_departments': 'అన్ని విభాగాలు',
    'no_workers_match': 'మీ శోధనకు సరిపడే కార్మికులు లేరు.',
    'private_contact_notice':
        'సంప్రదింపు వివరాలు ప్రైవేట్. సంప్రదింపుకు కార్మికుడి అనుమతి అవసరం.',
    'use_job_site_location': 'పని స్థలం కోసం ఈ పరికరం స్థానాన్ని ఉపయోగించండి',
    'job_site_coordinates_saved': 'పని స్థలం స్థానం సేవ్ చేయబడింది',
    'one_day': '1 రోజు',
    'two_days': '2 రోజులు',
    'three_days': '3 రోజులు',
    'one_week': '1 వారం',
    'transactions': 'లావాదేవీలు',
    'savings_goals': 'పొదుపు లక్ష్యాలు',
    'financial_insights': '????????? ???????',
    'work_ratings': 'పని రేటింగ్‌లు',
    'work_profile_id': 'పని ప్రొఫైల్ ID',
    'digital_payment_demo': 'డిజిటల్ చెల్లింపు ప్రివ్యూ',
    'available_for_work': 'పనికి అందుబాటులో ఉన్నారు',
    'not_available': 'అందుబాటులో లేరు',
    'my_applications_title': 'నా దరఖాస్తులు',
  },
  'kn': {
    'my_jobs': 'ನನ್ನ ಕೆಲಸಗಳು',
    'applicants': 'ಅರ್ಜಿದಾರರು',
    'my_profile': 'ನನ್ನ ಪ್ರೊಫೈಲ್',
    'this_week_earnings': 'ಈ ವಾರದ ಆದಾಯ',
    'growth_from_last_week': 'ಕಳೆದ ವಾರಕ್ಕಿಂತ +18%',
    'digital_work_id': 'ಡಿಜಿಟಲ್ ಕೆಲಸದ ಗುರುತಿನ ಚೀಟಿ (ಮುನ್ನೋಟ)',
    'identity_not_verified':
        'ಗುರುತಿನ ವಿವರಗಳು; ಕೆಲಸದ ಅಂಕಿಅಂಶಗಳು ಪರಿಶೀಲಿಸಲ್ಪಟ್ಟಿಲ್ಲ',
    'my_skills': 'ನನ್ನ ಕೌಶಲ್ಯಗಳು',
    'skills_from_registration': 'ನೋಂದಣಿ ಸಮಯದಲ್ಲಿ ಉಳಿಸಿದ ಕೌಶಲ್ಯಗಳು',
    'work_availability': 'ಕೆಲಸದ ಲಭ್ಯತೆ',
    'availability_description':
        'ಉದ್ಯೋಗದಾತರು ನಿಮ್ಮನ್ನು ಹುಡುಕಬಹುದೇ ಎಂದು ಆಯ್ಕೆಮಾಡಿ',
    'my_applications': 'ನನ್ನ ಅರ್ಜಿಗಳು',
    'track_application_status': 'ಅರ್ಜಿಯ ಸ್ಥಿತಿಯನ್ನು ನೋಡಿ',
    'live_location_sharing': 'ನೇರ ಸ್ಥಳ ಹಂಚಿಕೆ',
    'share_accepted_job': 'ಒಪ್ಪಿಕೊಂಡ ಕೆಲಸಕ್ಕೆ ಮಾತ್ರ ಸ್ಥಳ ಹಂಚಿಕೊಳ್ಳಿ',
    'work_history': 'ಕೆಲಸದ ಇತಿಹಾಸ',
    'completed_applications': 'ಪೂರ್ಣಗೊಂಡ ಅರ್ಜಿಗಳನ್ನು ನೋಡಿ',
    'ratings': 'ರೇಟಿಂಗ್‌ಗಳು',
    'completed_job_ratings': 'ಪೂರ್ಣಗೊಂಡ ಕೆಲಸಗಳ ರೇಟಿಂಗ್ ನೋಡಿ',
    'manage_job_posts': 'ನಿಮ್ಮ ಕೆಲಸದ ಪೋಸ್ಟ್‌ಗಳನ್ನು ನಿರ್ವಹಿಸಿ',
    'review_applicants': 'ಅರ್ಜಿ ಸಲ್ಲಿಸಿದ ಕಾರ್ಮಿಕರನ್ನು ಪರಿಶೀಲಿಸಿ',
    'search_available_workers': 'ಲಭ್ಯವಿರುವ ಕಾರ್ಮಿಕರ ಪ್ರೊಫೈಲ್ ಹುಡುಕಿ',
    'settings': 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು',
    'account_preferences': 'ಖಾತೆ ಮತ್ತು ಆದ್ಯತೆಗಳು',
    'logout': 'ಲಾಗ್ ಔಟ್',
    'create_account': 'ಖಾತೆ ರಚಿಸಿ',
    'join_coolie': 'Mr. கூலி ಗೆ ಸೇರಿ',
    'full_name': 'ಪೂರ್ಣ ಹೆಸರು',
    'account_type': 'ಖಾತೆಯ ಪ್ರಕಾರ',
    'customer_find_workers': 'ಗ್ರಾಹಕ / ಕಾರ್ಮಿಕರನ್ನು ಹುಡುಕಿ',
    'confirm_password': 'ಪಾಸ್‌ವರ್ಡ್ ದೃಢೀಕರಿಸಿ',
    'save_continue': 'ಖಾತೆ ರಚಿಸಿ',
    'already_have_account': 'ಈಗಾಗಲೇ ಖಾತೆ ಇದೆಯೇ? ಲಾಗಿನ್ ಮಾಡಿ',
    'complete_required_fields': 'ಅಗತ್ಯವಿರುವ ಎಲ್ಲಾ ವಿವರಗಳನ್ನು ಭರ್ತಿ ಮಾಡಿ.',
    'passwords_mismatch': 'ಪಾಸ್‌ವರ್ಡ್‌ಗಳು ಹೊಂದಿಕೆಯಾಗುತ್ತಿಲ್ಲ.',
    'worker_profile_required': 'ಕಾರ್ಮಿಕರ ಸ್ಥಳ, ವಿಭಾಗ ಮತ್ತು ಕೌಶಲ್ಯ ಅಗತ್ಯ.',
    'account_created': 'ಖಾತೆ ರಚಿಸಲಾಗಿದೆ',
    'registration_success':
        'ನಿಮ್ಮ Firebase ಖಾತೆ ರಚಿಸಲಾಗಿದೆ. ಈಗ Mr. கூಲಿ ಮುಂದುವರಿಸಿ.',
    'continue': 'ಮುಂದುವರಿಸಿ',
    'change_language': 'ಭಾಷೆ ಬದಲಿಸಿ',
    'email_address': 'ಇಮೇಲ್',
    'worker_role': 'ಕಾರ್ಮಿಕ',
    'employer_role': 'ಉದ್ಯೋಗದಾತ',
    'department_label': 'ವಿಭಾಗ',
    'skill_label': 'ಕೌಶಲ್ಯ',
    'location_label': 'ಸ್ಥಳ',
    'password_label': 'ಪಾಸ್‌ವರ್ಡ್',
    'profile_complete_title': 'ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಪೂರ್ಣಗೊಳಿಸಿ',
    'role_prompt': 'Mr. கூலி ಅನ್ನು ಹೇಗೆ ಬಳಸಬೇಕೆಂದು ಆಯ್ಕೆಮಾಡಿ. ಈ ಪಾತ್ರವನ್ನು ನಂತರ ಬದಲಾಯಿಸಲಾಗುವುದಿಲ್ಲ.',
    'city_area': 'ನಗರ / ಪ್ರದೇಶ',
    'save_and_continue': 'ಉಳಿಸಿ ಮತ್ತು ಮುಂದುವರಿಸಿ',
    'sign_out': 'ಲಾಗ್ ಔಟ್',
    'retry': 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ',
    'find_workers_title': 'ಕಾರ್ಮಿಕರನ್ನು ಹುಡುಕಿ',
    'worker_search_hint': 'ಕೌಶಲ್ಯ, ಕಾರ್ಮಿಕ ಅಥವಾ ಸ್ಥಳ ಹುಡುಕಿ',
    'all_departments': 'ಎಲ್ಲಾ ವಿಭಾಗಗಳು',
    'no_workers_match': 'ನಿಮ್ಮ ಹುಡುಕಾಟಕ್ಕೆ ಹೊಂದುವ ಕಾರ್ಮಿಕರು ಲಭ್ಯವಿಲ್ಲ.',
    'private_contact_notice':
        'ಸಂಪರ್ಕ ವಿವರಗಳು ಖಾಸಗಿ. ಸಂಪರ್ಕಕ್ಕೆ ಕಾರ್ಮಿಕರ ಅನುಮತಿ ಅಗತ್ಯ.',
    'use_job_site_location': 'ಕೆಲಸದ ಸ್ಥಳಕ್ಕೆ ಈ ಸಾಧನದ ಸ್ಥಳ ಬಳಸಿ',
    'job_site_coordinates_saved': 'ಕೆಲಸದ ಸ್ಥಳ ಉಳಿಸಲಾಗಿದೆ',
    'one_day': '1 ದಿನ',
    'two_days': '2 ದಿನಗಳು',
    'three_days': '3 ದಿನಗಳು',
    'one_week': '1 ವಾರ',
    'transactions': 'ವಹಿವಾಟುಗಳು',
    'savings_goals': 'ಉಳಿತಾಯ ಗುರಿಗಳು',
    'financial_insights': '????? ???????',
    'work_ratings': 'ಕೆಲಸದ ರೇಟಿಂಗ್‌ಗಳು',
    'work_profile_id': 'ಕೆಲಸದ ಪ್ರೊಫೈಲ್ ID',
    'digital_payment_demo': 'ಡಿಜಿಟಲ್ ಪಾವತಿ ಮುನ್ನೋಟ',
    'available_for_work': 'ಕೆಲಸಕ್ಕೆ ಲಭ್ಯ',
    'not_available': 'ಲಭ್ಯವಿಲ್ಲ',
    'my_applications_title': 'ನನ್ನ ಅರ್ಜಿಗಳು',
  },
  'ml': {
    'my_jobs': 'എന്റെ ജോലികൾ',
    'applicants': 'അപേക്ഷകർ',
    'my_profile': 'എന്റെ പ്രൊഫൈൽ',
    'this_week_earnings': 'ഈ ആഴ്ചയിലെ വരുമാനം',
    'growth_from_last_week': 'കഴിഞ്ഞ ആഴ്ചയേക്കാൾ +18%',
    'digital_work_id': 'ഡിജിറ്റൽ തൊഴിൽ തിരിച്ചറിയൽ (പ്രിവ്യൂ)',
    'identity_not_verified':
        'തിരിച്ചറിയൽ വിവരങ്ങൾ; തൊഴിൽ കണക്കുകൾ സ്ഥിരീകരിച്ചിട്ടില്ല',
    'my_skills': 'എന്റെ കഴിവുകൾ',
    'skills_from_registration': 'രജിസ്ട്രേഷൻ സമയത്ത് സംരക്ഷിച്ച കഴിവുകൾ',
    'work_availability': 'ജോലി ലഭ്യത',
    'availability_description':
        'തൊഴിൽദാതാക്കൾക്ക് നിങ്ങളെ കണ്ടെത്താനാകണോ എന്ന് തിരഞ്ഞെടുക്കുക',
    'my_applications': 'എന്റെ അപേക്ഷകൾ',
    'track_application_status': 'അപേക്ഷയുടെ നില കാണുക',
    'live_location_sharing': 'തത്സമയ സ്ഥലം പങ്കിടൽ',
    'share_accepted_job': 'അംഗീകരിച്ച ജോലിക്ക് മാത്രം സ്ഥലം പങ്കിടുക',
    'work_history': 'തൊഴിൽ ചരിത്രം',
    'completed_applications': 'പൂർത്തിയാക്കിയ അപേക്ഷകൾ കാണുക',
    'ratings': 'റേറ്റിംഗുകൾ',
    'completed_job_ratings': 'പൂർത്തിയാക്കിയ ജോലികളുടെ റേറ്റിംഗുകൾ കാണുക',
    'manage_job_posts': 'നിങ്ങളുടെ ജോലി പോസ്റ്റുകൾ നിയന്ത്രിക്കുക',
    'review_applicants': 'അപേക്ഷിച്ച തൊഴിലാളികളെ പരിശോധിക്കുക',
    'search_available_workers': 'ലഭ്യമായ തൊഴിലാളികളുടെ പ്രൊഫൈലുകൾ തിരയുക',
    'settings': 'ക്രമീകരണങ്ങൾ',
    'account_preferences': 'അക്കൗണ്ടും മുൻഗണനകളും',
    'logout': 'ലോഗ് ഔട്ട്',
    'create_account': 'അക്കൗണ്ട് സൃഷ്ടിക്കുക',
    'join_coolie': 'Mr. கூலி-യിൽ ചേരുക',
    'full_name': 'പൂർണ്ണ പേര്',
    'account_type': 'അക്കൗണ്ട് തരം',
    'customer_find_workers': 'ഉപഭോക്താവ് / തൊഴിലാളികളെ കണ്ടെത്തുക',
    'confirm_password': 'പാസ്‌വേഡ് സ്ഥിരീകരിക്കുക',
    'save_continue': 'അക്കൗണ്ട് സൃഷ്ടിക്കുക',
    'already_have_account': 'അക്കൗണ്ട് ഉണ്ടോ? ലോഗിൻ ചെയ്യുക',
    'complete_required_fields': 'ആവശ്യമായ എല്ലാ വിവരങ്ങളും പൂരിപ്പിക്കുക.',
    'passwords_mismatch': 'പാസ്‌വേഡുകൾ പൊരുത്തപ്പെടുന്നില്ല.',
    'worker_profile_required':
        'തൊഴിലാളിയുടെ സ്ഥലം, വിഭാഗം, കഴിവ് എന്നിവ ആവശ്യമാണ്.',
    'account_created': 'അക്കൗണ്ട് സൃഷ്ടിച്ചു',
    'registration_success':
        'നിങ്ങളുടെ Firebase അക്കൗണ്ട് സൃഷ്ടിച്ചു. ഇനി Mr. கூலி തുടരാം.',
    'continue': 'തുടരുക',
    'change_language': 'ഭാഷ മാറ്റുക',
    'email_address': 'ഇമെയിൽ',
    'worker_role': 'തൊഴിലാളി',
    'employer_role': 'തൊഴിൽദാതാവ്',
    'department_label': 'വിഭാഗം',
    'skill_label': 'കഴിവ്',
    'location_label': 'സ്ഥലം',
    'password_label': 'പാസ്‌വേഡ്',
    'profile_complete_title': 'നിങ്ങളുടെ പ്രൊഫൈൽ പൂർത്തിയാക്കുക',
    'role_prompt': 'Mr. கூலி എങ്ങനെ ഉപയോഗിക്കണമെന്ന് തിരഞ്ഞെടുക്കുക. ഈ പദവി പിന്നീട് മാറ്റാനാകില്ല.',
    'city_area': 'നഗരം / പ്രദേശം',
    'save_and_continue': 'സേവ് ചെയ്ത് തുടരുക',
    'sign_out': 'ലോഗ് ഔട്ട്',
    'retry': 'വീണ്ടും ശ്രമിക്കുക',
    'find_workers_title': 'തൊഴിലാളികളെ കണ്ടെത്തുക',
    'worker_search_hint': 'കഴിവ്, തൊഴിലാളി അല്ലെങ്കിൽ സ്ഥലം തിരയുക',
    'all_departments': 'എല്ലാ വിഭാഗങ്ങളും',
    'no_workers_match': 'നിങ്ങളുടെ തിരയലിന് അനുയോജ്യമായ തൊഴിലാളികളില്ല.',
    'private_contact_notice':
        'ബന്ധപ്പെടാനുള്ള വിവരങ്ങൾ സ്വകാര്യമാണ്. തൊഴിലാളിയുടെ സമ്മതം ആവശ്യമാണ്.',
    'use_job_site_location': 'ജോലിസ്ഥലത്തിന് ഈ ഉപകരണത്തിന്റെ സ്ഥലം ഉപയോഗിക്കുക',
    'job_site_coordinates_saved': 'ജോലിസ്ഥലം സംരക്ഷിച്ചു',
    'one_day': '1 ദിവസം',
    'two_days': '2 ദിവസം',
    'three_days': '3 ദിവസം',
    'one_week': '1 ആഴ്ച',
    'transactions': 'ഇടപാടുകൾ',
    'savings_goals': 'സേവിംഗ് ലക്ഷ്യങ്ങൾ',
    'financial_insights': '?????????? ???????????',
    'work_ratings': 'ജോലി റേറ്റിംഗുകൾ',
    'work_profile_id': 'ജോലി പ്രൊഫൈൽ ഐഡി',
    'digital_payment_demo': 'ഡിജിറ്റൽ പേയ്മെന്റ് പ്രിവ്യൂ',
    'available_for_work': 'ജോലിക്ക് ലഭ്യമാണ്',
    'not_available': 'ലഭ്യമല്ല',
    'my_applications_title': 'എന്റെ അപേക്ഷകൾ',
  },
};

const Map<String, Map<String, String>> workflowTranslations = {
  'en': {
    'job_details': 'Job Details',
    'app_submitted': 'Application submitted',
    'application_saved':
        'Your application has been saved and is visible to the employer.',
    'within_50_km': 'Within 50 km',
    'no_nearby_jobs': 'No nearby jobs match this filter.',
    'no_posted_jobs': 'You have not posted any jobs yet.',
    'post_job_to_receive': 'Post a job to receive applicants.',
    'no_applications': 'No applications yet.',
    'mark_completed': 'Mark work completed?',
    'complete_job_message':
        'This closes the job and enables both participants to submit a rating.',
    'cancel': 'CANCEL',
    'complete_job': 'COMPLETE JOB',
    'job_saved': 'Job saved to Firestore and is now open.',
    'rating_saved': 'Your rating was saved.',
    'location_private':
        'Location is private unless the assigned worker enables sharing.',
    'worker_not_sharing': 'The assigned worker has not enabled live location sharing for this job.',
    'worker_sharing': 'Worker is sharing live location',
    'maps_keys_missing':
        'Map view becomes available after Maps API keys are configured.',
    'use_location': 'Use my location',
    'profile_id': 'Work Profile ID',
    'transactions': 'Transactions',
    'savings': 'Savings Goals',
    'insights': 'Payments & records',
    'ratings': 'Work ratings',
    'payment_demo': 'Digital Payment Demo',
    'available': 'Available for work',
    'unavailable': 'Not available',
    'availability_public': 'Your profile is shown in worker search.',
    'availability_hidden': 'Your profile is hidden from worker search.',
    'already_rated': 'You have already rated this completed job.',
    'job_completed': 'Work marked completed.',
  },
  'ta': {
    'job_details': 'வேலை விவரங்கள்',
    'app_submitted': 'விண்ணப்பம் அனுப்பப்பட்டது',
    'application_saved':
        'உங்கள் விண்ணப்பம் சேமிக்கப்பட்டு வேலை வழங்குநருக்குத் தெரியும்.',
    'within_50_km': '50 கி.மீ.க்குள்',
    'no_nearby_jobs': 'இந்த வடிகட்டிக்கு அருகில் வேலைகள் இல்லை.',
    'no_posted_jobs': 'நீங்கள் இன்னும் வேலை பதிவு செய்யவில்லை.',
    'post_job_to_receive': 'விண்ணப்பங்களைப் பெற வேலை பதிவு செய்யுங்கள்.',
    'no_applications': 'இன்னும் விண்ணப்பங்கள் இல்லை.',
    'mark_completed': 'வேலையை முடித்ததாகக் குறிக்கவா?',
    'complete_job_message':
        'இது வேலையை மூடி, இருவரும் மதிப்பீடு செய்ய அனுமதிக்கும்.',
    'cancel': 'ரத்து செய்',
    'complete_job': 'வேலையை முடி',
    'job_saved': 'வேலை சேமிக்கப்பட்டு திறக்கப்பட்டது.',
    'rating_saved': 'உங்கள் மதிப்பீடு சேமிக்கப்பட்டது.',
    'location_private': 'தொழிலாளர் பகிர்வை இயக்கினால் மட்டுமே இடம் தெரியும்.',
    'worker_not_sharing':
        'இந்த வேலைக்கான நேரடி இருப்பிடத்தை தொழிலாளர் பகிரவில்லை.',
    'worker_sharing': 'தொழிலாளர் நேரடி இருப்பிடத்தைப் பகிர்கிறார்',
    'maps_keys_missing': 'Maps API keys அமைத்த பிறகு வரைபடம் கிடைக்கும்.',
    'use_location': 'என் இருப்பிடத்தைப் பயன்படுத்து',
    'profile_id': 'வேலை சுயவிவர அடையாளம்',
    'transactions': 'பரிவர்த்தனைகள்',
    'savings': 'சேமிப்பு இலக்குகள்',
    'insights': '????? ?????????',
    'ratings': 'மதிப்பீடுகள்',
    'payment_demo': 'டிஜிட்டல் கட்டண முன்னோட்டம்',
    'available': 'வேலைக்குக் கிடைக்கிறார்',
    'unavailable': 'கிடைக்கவில்லை',
    'availability_public': 'உங்கள் சுயவிவரம் தொழிலாளர் தேடலில் தெரியும்.',
    'availability_hidden': 'உங்கள் சுயவிவரம் தேடலில் மறைக்கப்பட்டுள்ளது.',
    'already_rated':
        'இந்த முடித்த வேலைக்கு நீங்கள் ஏற்கனவே மதிப்பிட்டுள்ளீர்கள்.',
    'job_completed': 'வேலை முடிக்கப்பட்டது.',
  },
  'hi': {
    'job_details': 'काम का विवरण',
    'app_submitted': 'आवेदन भेजा गया',
    'application_saved': 'आपका आवेदन सहेजा गया है और नियोक्ता इसे देख सकता है।',
    'within_50_km': '50 किमी के भीतर',
    'no_nearby_jobs': 'इस फ़िल्टर से मेल खाते आसपास के काम नहीं हैं।',
    'no_posted_jobs': 'आपने अभी तक कोई काम पोस्ट नहीं किया है।',
    'post_job_to_receive': 'आवेदक पाने के लिए काम पोस्ट करें।',
    'no_applications': 'अभी तक आवेदन नहीं हैं।',
    'mark_completed': 'काम पूरा चिह्नित करें?',
    'complete_job_message': 'इससे काम बंद होगा और दोनों पक्ष रेटिंग दे सकेंगे।',
    'cancel': 'रद्द करें',
    'complete_job': 'काम पूरा करें',
    'job_saved': 'काम सहेजा गया और खुला है।',
    'rating_saved': 'आपकी रेटिंग सहेजी गई।',
    'location_private': 'कामगार साझा करने पर ही स्थान दिखेगा।',
    'worker_not_sharing':
        'कामगार ने इस काम के लिए लाइव स्थान साझा नहीं किया है।',
    'worker_sharing': 'कामगार लाइव स्थान साझा कर रहा है',
    'maps_keys_missing':
        'Maps API keys कॉन्फ़िगर करने के बाद नक्शा उपलब्ध होगा।',
    'use_location': 'मेरे स्थान का उपयोग करें',
    'profile_id': 'कार्य प्रोफ़ाइल आईडी',
    'transactions': 'लेन-देन',
    'savings': 'बचत लक्ष्य',
    'insights': '?????? ?????',
    'ratings': 'रेटिंग',
    'payment_demo': 'डिजिटल भुगतान पूर्वावलोकन',
    'available': 'काम के लिए उपलब्ध',
    'unavailable': 'उपलब्ध नहीं',
  },
  'te': {
    'job_details': 'పని వివరాలు',
    'app_submitted': 'దరఖాస్తు పంపబడింది',
    'application_saved': 'మీ దరఖాస్తు సేవ్ చేయబడింది; యజమాని చూడగలరు.',
    'within_50_km': '50 కి.మీ. లోపు',
    'no_nearby_jobs': 'ఈ ఫిల్టర్‌కు దగ్గరలో పనులు లేవు.',
    'no_posted_jobs': 'మీరు ఇంకా పనిని పోస్ట్ చేయలేదు.',
    'post_job_to_receive': 'దరఖాస్తులు పొందడానికి పనిని పోస్ట్ చేయండి.',
    'no_applications': 'ఇంకా దరఖాస్తులు లేవు.',
    'mark_completed': 'పని పూర్తయినట్లు గుర్తించాలా?',
    'complete_job_message':
        'ఇది పనిని మూసి ఇద్దరికీ రేటింగ్ ఇవ్వడానికి అనుమతిస్తుంది.',
    'cancel': 'రద్దు చేయండి',
    'complete_job': 'పని పూర్తి చేయండి',
    'job_saved': 'పని సేవ్ చేసి తెరవబడింది.',
    'rating_saved': 'మీ రేటింగ్ సేవ్ చేయబడింది.',
    'location_private': 'కార్మికుడు పంచుకుంటేనే స్థానం కనిపిస్తుంది.',
    'worker_not_sharing':
        'ఈ పనికి కార్మికుడు ప్రత్యక్ష స్థానాన్ని పంచుకోవడం లేదు.',
    'worker_sharing': 'కార్మికుడు ప్రత్యక్ష స్థానాన్ని పంచుకుంటున్నారు',
    'maps_keys_missing':
        'Maps API keys అమర్చిన తర్వాత మ్యాప్ అందుబాటులో ఉంటుంది.',
    'use_location': 'నా స్థానాన్ని ఉపయోగించండి',
    'profile_id': 'పని ప్రొఫైల్ ID',
    'transactions': 'లావాదేవీలు',
    'savings': 'పొదుపు లక్ష్యాలు',
    'insights': '????????? ???????',
    'ratings': 'రేటింగ్‌లు',
    'payment_demo': 'డిజిటల్ చెల్లింపు ప్రివ్యూ',
    'available': 'పనికి అందుబాటులో ఉన్నారు',
    'unavailable': 'అందుబాటులో లేరు',
  },
  'kn': {
    'job_details': 'ಕೆಲಸದ ವಿವರ',
    'app_submitted': 'ಅರ್ಜಿ ಸಲ್ಲಿಸಲಾಗಿದೆ',
    'application_saved': 'ನಿಮ್ಮ ಅರ್ಜಿ ಉಳಿಸಲಾಗಿದೆ ಮತ್ತು ಉದ್ಯೋಗದಾತರು ನೋಡಬಹುದು.',
    'within_50_km': '50 ಕಿ.ಮೀ. ಒಳಗೆ',
    'no_nearby_jobs': 'ಈ ಫಿಲ್ಟರ್‌ಗೆ ಹತ್ತಿರದ ಕೆಲಸಗಳಿಲ್ಲ.',
    'no_posted_jobs': 'ನೀವು ಇನ್ನೂ ಕೆಲಸ ಪೋಸ್ಟ್ ಮಾಡಿಲ್ಲ.',
    'post_job_to_receive': 'ಅರ್ಜಿದಾರರನ್ನು ಪಡೆಯಲು ಕೆಲಸ ಪೋಸ್ಟ್ ಮಾಡಿ.',
    'no_applications': 'ಇನ್ನೂ ಅರ್ಜಿಗಳಿಲ್ಲ.',
    'mark_completed': 'ಕೆಲಸ ಪೂರ್ಣಗೊಂಡಿದೆಯೆಂದು ಗುರುತಿಸಬೇಕೇ?',
    'complete_job_message':
        'ಇದು ಕೆಲಸ ಮುಚ್ಚಿ ಇಬ್ಬರಿಗೂ ರೇಟಿಂಗ್ ನೀಡಲು ಅವಕಾಶ ಮಾಡುತ್ತದೆ.',
    'cancel': 'ರದ್ದುಮಾಡಿ',
    'complete_job': 'ಕೆಲಸ ಪೂರ್ಣಗೊಳಿಸಿ',
    'job_saved': 'ಕೆಲಸ ಉಳಿಸಿ ತೆರೆಯಲಾಗಿದೆ.',
    'rating_saved': 'ನಿಮ್ಮ ರೇಟಿಂಗ್ ಉಳಿಸಲಾಗಿದೆ.',
    'location_private': 'ಕಾರ್ಮಿಕರು ಹಂಚಿದರೆ ಮಾತ್ರ ಸ್ಥಳ ಕಾಣುತ್ತದೆ.',
    'worker_not_sharing': 'ಈ ಕೆಲಸಕ್ಕೆ ಕಾರ್ಮಿಕರು ನೇರ ಸ್ಥಳ ಹಂಚಿಲ್ಲ.',
    'worker_sharing': 'ಕಾರ್ಮಿಕರು ನೇರ ಸ್ಥಳ ಹಂಚುತ್ತಿದ್ದಾರೆ',
    'maps_keys_missing': 'Maps API ಕೀಗಳನ್ನು ಹೊಂದಿಸಿದ ನಂತರ ನಕ್ಷೆ ಲಭ್ಯವಾಗುತ್ತದೆ.',
    'use_location': 'ನನ್ನ ಸ್ಥಳ ಬಳಸಿ',
    'profile_id': 'ಕೆಲಸದ ಪ್ರೊಫೈಲ್ ID',
    'transactions': 'ವಹಿವಾಟುಗಳು',
    'savings': 'ಉಳಿತಾಯ ಗುರಿಗಳು',
    'insights': '????? ???????',
    'ratings': 'ರೇಟಿಂಗ್‌ಗಳು',
    'payment_demo': 'ಡಿಜಿಟಲ್ ಪಾವತಿ ಮುನ್ನೋಟ',
    'available': 'ಕೆಲಸಕ್ಕೆ ಲಭ್ಯ',
    'unavailable': 'ಲಭ್ಯವಿಲ್ಲ',
  },
  'ml': {
    'job_details': 'ജോലി വിവരങ്ങൾ',
    'app_submitted': 'അപേക്ഷ അയച്ചു',
    'application_saved': 'നിങ്ങളുടെ അപേക്ഷ സംരക്ഷിച്ചു; തൊഴിൽദാതാവിന് കാണാം.',
    'within_50_km': '50 കി.മീ. പരിധിയിൽ',
    'no_nearby_jobs': 'ഈ ഫിൽട്ടറിന് സമീപം ജോലികളില്ല.',
    'no_posted_jobs': 'നിങ്ങൾ ഇതുവരെ ജോലി പോസ്റ്റ് ചെയ്തിട്ടില്ല.',
    'post_job_to_receive': 'അപേക്ഷകൾ ലഭിക്കാൻ ജോലി പോസ്റ്റ് ചെയ്യുക.',
    'no_applications': 'അപേക്ഷകളൊന്നുമില്ല.',
    'mark_completed': 'ജോലി പൂർത്തിയായതായി അടയാളപ്പെടുത്തണോ?',
    'complete_job_message': 'ഇത് ജോലി അവസാനിപ്പിക്കുകയും ഇരുവർക്കും റേറ്റിംഗ് നൽകാൻ അനുവദിക്കുകയും ചെയ്യും.',
    'cancel': 'റദ്ദാക്കുക',
    'complete_job': 'ജോലി പൂർത്തിയാക്കുക',
    'job_saved': 'ജോലി സംരക്ഷിച്ച് തുറന്നു.',
    'rating_saved': 'നിങ്ങളുടെ റേറ്റിംഗ് സംരക്ഷിച്ചു.',
    'location_private': 'തൊഴിലാളി പങ്കിട്ടാൽ മാത്രമേ സ്ഥലം കാണൂ.',
    'worker_not_sharing': 'ഈ ജോലിക്ക് തൊഴിലാളി തത്സമയ സ്ഥലം പങ്കിടുന്നില്ല.',
    'worker_sharing': 'തൊഴിലാളി തത്സമയ സ്ഥലം പങ്കിടുന്നു',
    'maps_keys_missing': 'Maps API കീകൾ ക്രമീകരിച്ചാൽ മാപ്പ് ലഭ്യമാകും.',
    'use_location': 'എന്റെ സ്ഥലം ഉപയോഗിക്കുക',
    'profile_id': 'ജോലി പ്രൊഫൈൽ ഐഡി',
    'transactions': 'ഇടപാടുകൾ',
    'savings': 'സേവിംഗ് ലക്ഷ്യങ്ങൾ',
    'insights': '?????????? ???????????',
    'ratings': 'റേറ്റിംഗുകൾ',
    'payment_demo': 'ഡിജിറ്റൽ പേയ്മെന്റ് പ്രിവ്യൂ',
    'available': 'ജോലിക്ക് ലഭ്യമാണ്',
    'unavailable': 'ലഭ്യമല്ല',
  },
};

const Map<String, Map<String, String>> employerTranslations = {
  'en': {
    'employer_jobs_error': 'Could not load your jobs.',
    'employer_jobs_empty': 'You have not posted any jobs yet.',
    'employer_post_prompt': 'Post a job to receive applicants.',
    'applications_error': 'Could not load applications.',
    'applications_empty': 'No applications yet.',
    'job_status': 'Status',
    'open_status': 'Open',
    'closed_status': 'Closed',
    'assigned_status': 'Assigned',
    'completed_status': 'Completed',
    'accept_applicant': 'Accept applicant',
    'reject_applicant': 'Reject applicant',
    'worker_unavailable': 'Worker profile unavailable',
    'job_title_hint': 'Example: House Wiring',
    'select_department': 'Select Department',
    'select_skill': 'Select Skill',
    'job_description_hint': 'Describe the work...',
    'location_hint': 'Example: Sivakasi',
    'job_location_error': 'Could not get job location.',
    'payment_hint': 'Leave blank if you want to agree later',
    'select_duration': 'Select Duration',
    'job_location_use_device': 'Use this device location for the job site',
    'job_location_saved': 'Job site coordinates saved',
    'accept_failed': 'Could not accept applicant.',
    'reject_failed': 'Could not reject applicant.',
    'job_views_count': 'Worker detail views',
    'application_count': 'Applications',
    'notifications': 'Notifications',
    'new_job_application': 'New application',
    'notification_open_applicants': 'Open applicant management',
    'notifications_empty': 'No notifications yet.',
    'notifications_error': 'Could not load notifications.',
    'job_metrics_unavailable': 'Job counts unavailable.',
  },
  'ta': {
    'employer_jobs_error': 'உங்கள் வேலைகளை ஏற்ற முடியவில்லை.',
    'employer_jobs_empty': 'நீங்கள் இன்னும் வேலை எதையும் பதிவு செய்யவில்லை.',
    'employer_post_prompt':
        'விண்ணப்பங்களைப் பெற ஒரு வேலையைப் பதிவு செய்யுங்கள்.',
    'applications_error': 'விண்ணப்பங்களை ஏற்ற முடியவில்லை.',
    'applications_empty': 'இன்னும் விண்ணப்பங்கள் இல்லை.',
    'job_status': 'நிலை',
    'open_status': 'திறந்துள்ளது',
    'closed_status': 'மூடப்பட்டது',
    'assigned_status': 'ஒதுக்கப்பட்டது',
    'completed_status': 'முடிக்கப்பட்டது',
    'accept_applicant': 'விண்ணப்பதாரரை ஏற்கவும்',
    'reject_applicant': 'விண்ணப்பதாரரை நிராகரிக்கவும்',
    'worker_unavailable': 'தொழிலாளர் விவரம் கிடைக்கவில்லை',
    'job_title_hint': 'உதாரணம்: வீட்டு மின்கம்பி வேலை',
    'select_department': 'துறையைத் தேர்ந்தெடுக்கவும்',
    'select_skill': 'தேவையான திறனைத் தேர்ந்தெடுக்கவும்',
    'job_description_hint': 'வேலையை விவரிக்கவும்...',
    'location_hint': 'உதாரணம்: சிவகாசி',
    'job_location_error': 'வேலை இடத்தைப் பெற முடியவில்லை.',
    'payment_hint': 'பின்னர் பேச முடிவு செய்தால் காலியாக விடுங்கள்',
    'select_duration': 'கால அளவைத் தேர்ந்தெடுக்கவும்',
    'job_location_use_device':
        'வேலை இடத்திற்கு இந்த சாதனத்தின் இருப்பிடத்தைப் பயன்படுத்து',
    'job_location_saved': 'வேலை இடத்தின் இருப்பிட ஆயங்கள் சேமிக்கப்பட்டன',
    'accept_failed': 'விண்ணப்பதாரரை ஏற்க முடியவில்லை.',
    'reject_failed': 'விண்ணப்பதாரரை நிராகரிக்க முடியவில்லை.',
    'job_views_count': 'வேலை விவரத்தைப் பார்த்த தொழிலாளர்கள்',
    'application_count': 'விண்ணப்பங்கள்',
    'notifications': 'அறிவிப்புகள்',
    'new_job_application': 'புதிய விண்ணப்பம்',
    'notification_open_applicants': 'விண்ணப்பதாரர் நிர்வாகத்தைத் திறக்கவும்',
    'notifications_empty': 'இன்னும் அறிவிப்புகள் இல்லை.',
    'notifications_error': 'அறிவிப்புகளை ஏற்ற முடியவில்லை.',
    'job_metrics_unavailable': 'வேலை எண்ணிக்கையைப் பெற முடியவில்லை.',
  },
  'hi': {
    'employer_jobs_empty': 'आपने अभी तक कोई काम पोस्ट नहीं किया है.',
    'employer_post_prompt': 'आवेदक पाने के लिए काम पोस्ट करें.',
    'applications_empty': 'अभी तक कोई आवेदन नहीं है.',
    'job_status': 'स्थिति',
    'open_status': 'खुला',
    'closed_status': 'बंद',
    'assigned_status': 'आवंटित',
    'completed_status': 'पूरा हुआ',
    'accept_applicant': 'आवेदक स्वीकार करें',
    'reject_applicant': 'आवेदक अस्वीकार करें',
    'worker_unavailable': 'कामगार प्रोफ़ाइल उपलब्ध नहीं है',
    'job_views_count': 'काम देखने वाले कामगार',
    'application_count': 'आवेदन',
    'notifications': 'सूचनाएँ',
    'new_job_application': 'नया आवेदन',
    'notification_open_applicants': 'आवेदक प्रबंधन खोलें',
    'notifications_empty': 'अभी कोई सूचना नहीं है।',
    'notifications_error': 'सूचनाएँ लोड नहीं हो सकीं।',
    'job_metrics_unavailable': 'काम का आँकड़ा उपलब्ध नहीं है।',
  },
  'te': {
    'employer_jobs_empty': 'మీరు ఇంకా పనిని పోస్ట్ చేయలేదు.',
    'employer_post_prompt': 'దరఖాస్తులు పొందడానికి పనిని పోస్ట్ చేయండి.',
    'applications_empty': 'ఇంకా దరఖాస్తులు లేవు.',
    'job_status': 'స్థితి',
    'open_status': 'తెరిచి ఉంది',
    'closed_status': 'మూసివేశారు',
    'assigned_status': 'కేటాయించారు',
    'completed_status': 'పూర్తయింది',
    'accept_applicant': 'దరఖాస్తుదారుని అంగీకరించండి',
    'reject_applicant': 'దరఖాస్తుదారుని తిరస్కరించండి',
    'worker_unavailable': 'కార్మికుడి ప్రొఫైల్ అందుబాటులో లేదు',
    'job_views_count': 'పని వివరాలు చూసిన కార్మికులు',
    'application_count': 'దరఖాస్తులు',
    'notifications': 'నోటిఫికేషన్‌లు',
    'new_job_application': 'కొత్త దరఖాస్తు',
    'notification_open_applicants': 'దరఖాస్తుదారుల నిర్వహణ తెరవండి',
    'notifications_empty': 'ఇంకా నోటిఫికేషన్‌లు లేవు.',
    'notifications_error': 'నోటిఫికేషన్‌లను లోడ్ చేయలేకపోయాం.',
    'job_metrics_unavailable': 'పని గణాంకాలు అందుబాటులో లేవు.',
  },
  'kn': {
    'employer_jobs_empty': 'ನೀವು ಇನ್ನೂ ಕೆಲಸ ಪೋಸ್ಟ್ ಮಾಡಿಲ್ಲ.',
    'employer_post_prompt': 'ಅರ್ಜಿದಾರರನ್ನು ಪಡೆಯಲು ಕೆಲಸ ಪೋಸ್ಟ್ ಮಾಡಿ.',
    'applications_empty': 'ಇನ್ನೂ ಅರ್ಜಿಗಳಿಲ್ಲ.',
    'job_status': 'ಸ್ಥಿತಿ',
    'open_status': 'ತೆರೆದಿದೆ',
    'closed_status': 'ಮುಚ್ಚಲಾಗಿದೆ',
    'assigned_status': 'ನಿಯೋಜಿಸಲಾಗಿದೆ',
    'completed_status': 'ಪೂರ್ಣಗೊಂಡಿದೆ',
    'accept_applicant': 'ಅರ್ಜಿದಾರರನ್ನು ಸ್ವೀಕರಿಸಿ',
    'reject_applicant': 'ಅರ್ಜಿದಾರರನ್ನು ತಿರಸ್ಕರಿಸಿ',
    'worker_unavailable': 'ಕಾರ್ಮಿಕರ ಪ್ರೊಫೈಲ್ ಲಭ್ಯವಿಲ್ಲ',
    'job_views_count': 'ಕೆಲಸ ನೋಡಿದ ಕಾರ್ಮಿಕರು',
    'application_count': 'ಅರ್ಜಿಗಳು',
    'notifications': 'ಅಧಿಸೂಚನೆಗಳು',
    'new_job_application': 'ಹೊಸ ಅರ್ಜಿ',
    'notification_open_applicants': 'ಅರ್ಜಿದಾರರ ನಿರ್ವಹಣೆ ತೆರೆಯಿರಿ',
    'notifications_empty': 'ಇನ್ನೂ ಅಧಿಸೂಚನೆಗಳಿಲ್ಲ.',
    'notifications_error': 'ಅಧಿಸೂಚನೆಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
    'job_metrics_unavailable': 'ಕೆಲಸದ ಅಂಕಿಅಂಶ ಲಭ್ಯವಿಲ್ಲ.',
  },
  'ml': {
    'employer_jobs_empty': 'നിങ്ങൾ ഇതുവരെ ജോലി പോസ്റ്റ് ചെയ്തിട്ടില്ല.',
    'employer_post_prompt': 'അപേക്ഷകൾ ലഭിക്കാൻ ജോലി പോസ്റ്റ് ചെയ്യുക.',
    'applications_empty': 'അപേക്ഷകളൊന്നുമില്ല.',
    'job_status': 'നില',
    'open_status': 'തുറന്നിരിക്കുന്നു',
    'closed_status': 'അടച്ചു',
    'assigned_status': 'നിയമിച്ചു',
    'completed_status': 'പൂർത്തിയായി',
    'accept_applicant': 'അപേക്ഷകനെ സ്വീകരിക്കുക',
    'reject_applicant': 'അപേക്ഷകനെ നിരസിക്കുക',
    'worker_unavailable': 'തൊഴിലാളിയുടെ പ്രൊഫൈൽ ലഭ്യമല്ല',
    'job_views_count': 'ജോലി വിവരങ്ങൾ കണ്ട തൊഴിലാളികൾ',
    'application_count': 'അപേക്ഷകൾ',
    'notifications': 'അറിയിപ്പുകൾ',
    'new_job_application': 'പുതിയ അപേക്ഷ',
    'notification_open_applicants': 'അപേക്ഷക നിയന്ത്രണം തുറക്കുക',
    'notifications_empty': 'അറിയിപ്പുകളൊന്നുമില്ല.',
    'notifications_error': 'അറിയിപ്പുകൾ ലോഡ് ചെയ്യാനായില്ല.',
    'job_metrics_unavailable': 'ജോലി കണക്ക് ലഭ്യമല്ല.',
  },
};

const Map<String, Map<String, String>> contactTranslations = {
  'en': {
    'request_contact': 'Request contact',
    'service_request_title': 'Describe the work you need',
    'service_needed': 'What needs repair or service? *',
    'service_example': 'Example: ceiling fan making noise',
    'service_details': 'Describe the issue (optional)',
    'service_location': 'Work location / area *',
    'service_budget_optional': 'Your budget (optional)',
    'quote_first_note': 'No fixed price is set. The worker can inspect the details and discuss a quote with you before you agree.',
    'service_request_required': 'Enter the work needed and its location.',
    'service_request_too_long': 'Please shorten the details and try again.',
    'quote_pending': 'Quote to be discussed with the customer',
    'contact_requests': 'Contact requests',
    'contact_requests_empty': 'No contact requests yet.',
    'contact_pending': 'Request sent — waiting for worker',
    'contact_worker_pending': 'This customer is waiting for your response.',
    'contact_requests_desc':
        'Review requests and choose whether to share your phone number.',
    'contact_accepted': 'Worker accepted your request',
    'contact_phone_shared': 'Shared phone number',
    'contact_no_phone': 'Worker accepted, but no phone number is registered.',
    'contact_request_sent': 'Contact request sent to the worker.',
    'contact_accept': 'Accept and share my phone',
    'contact_accept_no_phone': 'Accept without sharing a phone',
    'contact_decline': 'Decline',
    'contact_status_declined': 'Request declined',
    'contact_request_error': 'Could not send contact request.',
    'contact_permission_denied': 'Check that you are signed in as a customer and that Firestore rules are deployed.',
    'contact_customer_role_required':
        'Use an account whose saved role is Customer to request a worker.',
    'contact_action_error': 'Could not update this request.',
  },
  'ta': {
    'request_contact': 'தொடர்பைக் கோரவும்',
    'service_request_title': 'உங்களுக்குத் தேவையான வேலையை விவரிக்கவும்',
    'service_needed': 'எதைச் சரிசெய்ய வேண்டும் அல்லது எந்த சேவை தேவை? *',
    'service_example': 'உதாரணம்: சத்தம் வரும் மின்விசிறி',
    'service_details': 'பிரச்சினையை விவரிக்கவும் (விருப்பம்)',
    'service_location': 'வேலை செய்யும் இடம் / பகுதி *',
    'service_budget_optional': 'உங்கள் பட்ஜெட் (விருப்பம்)',
    'quote_first_note': 'நிரந்தர விலை இல்லை. நீங்கள் ஒப்புக்கொள்வதற்கு முன், தொழிலாளர் விவரங்களைப் பார்த்து விலையை உங்களுடன் பேசலாம்.',
    'service_request_required': 'தேவையான வேலையையும் இடத்தையும் உள்ளிடுங்கள்.',
    'service_request_too_long': 'விவரங்களைச் சுருக்கி மீண்டும் முயற்சிக்கவும்.',
    'quote_pending': 'வாடிக்கையாளருடன் விலை பேச வேண்டும்',
    'contact_requests': 'தொடர்பு கோரிக்கைகள்',
    'contact_requests_empty': 'தொடர்பு கோரிக்கைகள் இன்னும் இல்லை.',
    'contact_pending':
        'கோரிக்கை அனுப்பப்பட்டது — தொழிலாளரின் பதிலுக்காக காத்திருக்கிறது',
    'contact_worker_pending':
        'இந்த வாடிக்கையாளர் உங்கள் பதிலுக்காக காத்திருக்கிறார்.',
    'contact_requests_desc': 'கோரிக்கைகளைப் பார்த்து உங்கள் எண்ணைப் பகிர வேண்டுமா எனத் தேர்ந்தெடுக்கவும்.',
    'contact_accepted': 'தொழிலாளர் உங்கள் கோரிக்கையை ஏற்றார்',
    'contact_phone_shared': 'பகிரப்பட்ட தொலைபேசி எண்',
    'contact_no_phone': 'தொழிலாளர் ஏற்றுக்கொண்டார்; ஆனால் பதிவு செய்யப்பட்ட தொலைபேசி எண் இல்லை.',
    'contact_request_sent': 'தொழிலாளருக்கு தொடர்பு கோரிக்கை அனுப்பப்பட்டது.',
    'contact_accept': 'ஏற்று என் எண்ணைப் பகிரவும்',
    'contact_accept_no_phone': 'தொலைபேசி எண்ணைப் பகிராமல் ஏற்கவும்',
    'contact_decline': 'நிராகரி',
    'contact_status_declined': 'கோரிக்கை நிராகரிக்கப்பட்டது',
    'contact_request_error': 'தொடர்பு கோரிக்கையை அனுப்ப முடியவில்லை.',
    'contact_action_error': 'கோரிக்கையைப் புதுப்பிக்க முடியவில்லை.',
  },
  'hi': {
    'request_contact': 'संपर्क का अनुरोध करें',
    'service_request_title': 'अपने काम की जानकारी दें',
    'service_needed': 'क्या मरम्मत या सेवा चाहिए? *',
    'service_example': 'उदाहरण: छत का पंखा आवाज़ कर रहा है',
    'service_details': 'समस्या का विवरण (वैकल्पिक)',
    'service_location': 'काम की जगह / क्षेत्र *',
    'service_budget_optional': 'आपका बजट (वैकल्पिक)',
    'quote_first_note': 'कोई तय कीमत नहीं है। सहमत होने से पहले कामगार विवरण देखकर आपसे कीमत पर चर्चा कर सकता है।',
    'service_request_required': 'काम और उसका स्थान दर्ज करें।',
    'service_request_too_long': 'विवरण छोटा करके फिर कोशिश करें।',
    'quote_pending': 'ग्राहक से कीमत पर चर्चा करनी है',
    'contact_requests': 'संपर्क अनुरोध',
    'contact_requests_empty': 'अभी कोई संपर्क अनुरोध नहीं है.',
    'contact_worker_pending': 'यह ग्राहक आपके जवाब की प्रतीक्षा कर रहा है।',
    'contact_requests_desc':
        'अनुरोध देखें और तय करें कि फ़ोन नंबर साझा करना है या नहीं।',
    'contact_pending': 'अनुरोध भेजा गया — कामगार के उत्तर की प्रतीक्षा',
    'contact_accepted': 'कामगार ने अनुरोध स्वीकार किया',
    'contact_phone_shared': 'साझा किया गया फ़ोन नंबर',
    'contact_no_phone': 'कामगार ने स्वीकार किया, लेकिन फ़ोन नंबर दर्ज नहीं है.',
    'contact_request_sent': 'कामगार को संपर्क अनुरोध भेजा गया.',
    'contact_accept': 'स्वीकार करें और मेरा नंबर साझा करें',
    'contact_accept_no_phone': 'नंबर साझा किए बिना स्वीकार करें',
    'contact_decline': 'अस्वीकार करें',
    'contact_status_declined': 'अनुरोध अस्वीकार किया गया',
    'contact_request_error': 'संपर्क अनुरोध नहीं भेजा जा सका.',
    'contact_action_error': 'अनुरोध अपडेट नहीं हो सका.',
  },
  'te': {
    'request_contact': 'సంప్రదింపును అభ్యర్థించండి',
    'service_request_title': 'మీకు కావాల్సిన పనిని వివరించండి',
    'service_needed': 'ఏది మరమ్మతు చేయాలి లేదా ఏ సేవ కావాలి? *',
    'service_example': 'ఉదాహరణ: సీలింగ్ ఫ్యాన్ శబ్దం చేస్తోంది',
    'service_details': 'సమస్య వివరాలు (ఐచ్ఛికం)',
    'service_location': 'పని చేసే ప్రదేశం / ప్రాంతం *',
    'service_budget_optional': 'మీ బడ్జెట్ (ఐచ్ఛికం)',
    'quote_first_note': 'స్థిర ధర లేదు. మీరు అంగీకరించే ముందు కార్మికుడు వివరాలు చూసి మీతో ధర గురించి చర్చించవచ్చు.',
    'service_request_required': 'కావాల్సిన పని, ప్రదేశం నమోదు చేయండి.',
    'service_request_too_long': 'వివరాలను చిన్నగా చేసి మళ్లీ ప్రయత్నించండి.',
    'quote_pending': 'కస్టమర్‌తో ధర చర్చించాలి',
    'contact_requests': 'సంప్రదింపు అభ్యర్థనలు',
    'contact_requests_empty': 'ఇంకా సంప్రదింపు అభ్యర్థనలు లేవు.',
    'contact_worker_pending': 'ఈ కస్టమర్ మీ సమాధానం కోసం ఎదురుచూస్తున్నారు.',
    'contact_requests_desc':
        'అభ్యర్థనలను చూసి ఫోన్ నంబర్ పంచుకోవాలా నిర్ణయించండి.',
    'contact_pending': 'అభ్యర్థన పంపబడింది — కార్మికుడి సమాధానం కోసం వేచి ఉంది',
    'contact_accepted': 'కార్మికుడు మీ అభ్యర్థనను అంగీకరించారు',
    'contact_phone_shared': 'పంచుకున్న ఫోన్ నంబర్',
    'contact_no_phone':
        'కార్మికుడు అంగీకరించారు, కానీ ఫోన్ నంబర్ నమోదు కాలేదు.',
    'contact_request_sent': 'కార్మికుడికి సంప్రదింపు అభ్యర్థన పంపబడింది.',
    'contact_accept': 'అంగీకరించి నా నంబర్ పంచుకోండి',
    'contact_accept_no_phone': 'నంబర్ పంచుకోకుండా అంగీకరించండి',
    'contact_decline': 'తిరస్కరించండి',
    'contact_status_declined': 'అభ్యర్థన తిరస్కరించబడింది',
    'contact_request_error': 'సంప్రదింపు అభ్యర్థన పంపలేకపోయాం.',
    'contact_action_error': 'అభ్యర్థనను నవీకరించలేకపోయాం.',
  },
  'kn': {
    'request_contact': 'ಸಂಪರ್ಕ ಕೋರಿಕೆ ಕಳುಹಿಸಿ',
    'service_request_title': 'ನಿಮಗೆ ಬೇಕಾದ ಕೆಲಸವನ್ನು ವಿವರಿಸಿ',
    'service_needed': 'ಏನನ್ನು ದುರಸ್ತಿ ಮಾಡಬೇಕು ಅಥವಾ ಯಾವ ಸೇವೆ ಬೇಕು? *',
    'service_example': 'ಉದಾಹರಣೆ: ಸೀಲಿಂಗ್ ಫ್ಯಾನ್ ಶಬ್ದ ಮಾಡುತ್ತಿದೆ',
    'service_details': 'ಸಮಸ್ಯೆಯ ವಿವರ (ಐಚ್ಛಿಕ)',
    'service_location': 'ಕೆಲಸದ ಸ್ಥಳ / ಪ್ರದೇಶ *',
    'service_budget_optional': 'ನಿಮ್ಮ ಬಜೆಟ್ (ಐಚ್ಛಿಕ)',
    'quote_first_note': 'ನಿಗದಿತ ಬೆಲೆ ಇಲ್ಲ. ನೀವು ಒಪ್ಪುವ ಮೊದಲು ಕೆಲಸಗಾರರು ವಿವರಗಳನ್ನು ನೋಡಿ ನಿಮ್ಮೊಂದಿಗೆ ಬೆಲೆಯನ್ನು ಚರ್ಚಿಸಬಹುದು.',
    'service_request_required': 'ಬೇಕಾದ ಕೆಲಸ ಮತ್ತು ಸ್ಥಳವನ್ನು ನಮೂದಿಸಿ.',
    'service_request_too_long': 'ವಿವರಗಳನ್ನು ಚಿಕ್ಕದಾಗಿ ಮಾಡಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.',
    'quote_pending': 'ಗ್ರಾಹಕರೊಂದಿಗೆ ಬೆಲೆ ಚರ್ಚಿಸಬೇಕು',
    'contact_requests': 'ಸಂಪರ್ಕ ಕೋರಿಕೆಗಳು',
    'contact_requests_empty': 'ಇನ್ನೂ ಸಂಪರ್ಕ ಕೋರಿಕೆಗಳಿಲ್ಲ.',
    'contact_worker_pending': 'ಈ ಗ್ರಾಹಕರು ನಿಮ್ಮ ಉತ್ತರಕ್ಕಾಗಿ ಕಾಯುತ್ತಿದ್ದಾರೆ.',
    'contact_requests_desc':
        'ಕೋರಿಕೆಗಳನ್ನು ಪರಿಶೀಲಿಸಿ, ಫೋನ್ ಸಂಖ್ಯೆಯನ್ನು ಹಂಚಬೇಕೇ ಆಯ್ಕೆಮಾಡಿ.',
    'contact_pending': 'ಕೋರಿಕೆ ಕಳುಹಿಸಲಾಗಿದೆ — ಕಾರ್ಮಿಕರ ಉತ್ತರಕ್ಕಾಗಿ ಕಾಯುತ್ತಿದೆ',
    'contact_accepted': 'ಕಾರ್ಮಿಕರು ನಿಮ್ಮ ಕೋರಿಕೆಯನ್ನು ಒಪ್ಪಿದ್ದಾರೆ',
    'contact_phone_shared': 'ಹಂಚಿಕೊಂಡ ಫೋನ್ ಸಂಖ್ಯೆ',
    'contact_no_phone': 'ಕಾರ್ಮಿಕರು ಒಪ್ಪಿದ್ದಾರೆ, ಆದರೆ ಫೋನ್ ಸಂಖ್ಯೆ ನೋಂದಾಯಿಸಿಲ್ಲ.',
    'contact_request_sent': 'ಕಾರ್ಮಿಕರಿಗೆ ಸಂಪರ್ಕ ಕೋರಿಕೆ ಕಳುಹಿಸಲಾಗಿದೆ.',
    'contact_accept': 'ಒಪ್ಪಿ ನನ್ನ ಸಂಖ್ಯೆಯನ್ನು ಹಂಚಿಕೊಳ್ಳಿ',
    'contact_accept_no_phone': 'ಸಂಖ್ಯೆ ಹಂಚದೆ ಒಪ್ಪಿಕೊಳ್ಳಿ',
    'contact_decline': 'ನಿರಾಕರಿಸಿ',
    'contact_status_declined': 'ಕೋರಿಕೆ ನಿರಾಕರಿಸಲಾಗಿದೆ',
    'contact_request_error': 'ಸಂಪರ್ಕ ಕೋರಿಕೆ ಕಳುಹಿಸಲಾಗಲಿಲ್ಲ.',
    'contact_action_error': 'ಕೋರಿಕೆಯನ್ನು ನವೀಕರಿಸಲಾಗಲಿಲ್ಲ.',
  },
  'ml': {
    'request_contact': 'ബന്ധപ്പെടാൻ അഭ്യർത്ഥിക്കുക',
    'service_request_title': 'ആവശ്യമായ ജോലി വിശദീകരിക്കുക',
    'service_needed':
        'എന്താണ് നന്നാക്കേണ്ടത് അല്ലെങ്കിൽ ഏത് സേവനമാണ് വേണ്ടത്? *',
    'service_example': 'ഉദാഹരണം: സീലിംഗ് ഫാൻ ശബ്ദമുണ്ടാക്കുന്നു',
    'service_details': 'പ്രശ്നത്തിന്റെ വിശദാംശങ്ങൾ (ഐച്ഛികം)',
    'service_location': 'ജോലി ചെയ്യുന്ന സ്ഥലം / പ്രദേശം *',
    'service_budget_optional': 'നിങ്ങളുടെ ബജറ്റ് (ഐച്ഛികം)',
    'quote_first_note': 'നിശ്ചിത വിലയില്ല. നിങ്ങൾ സമ്മതിക്കുന്നതിന് മുമ്പ് തൊഴിലാളിക്ക് വിവരങ്ങൾ കണ്ട് നിങ്ങളുമായി വില ചർച്ച ചെയ്യാം.',
    'service_request_required': 'ആവശ്യമായ ജോലിയും സ്ഥലവും നൽകുക.',
    'service_request_too_long': 'വിശദാംശങ്ങൾ ചുരുക്കി വീണ്ടും ശ്രമിക്കുക.',
    'quote_pending': 'ഉപഭോക്താവുമായി വില ചർച്ച ചെയ്യണം',
    'contact_requests': 'ബന്ധപ്പെടാനുള്ള അഭ്യർത്ഥനകൾ',
    'contact_requests_empty': 'ബന്ധപ്പെടാനുള്ള അഭ്യർത്ഥനകളില്ല.',
    'contact_worker_pending':
        'ഈ ഉപഭോക്താവ് നിങ്ങളുടെ മറുപടിക്കായി കാത്തിരിക്കുന്നു.',
    'contact_requests_desc':
        'അഭ്യർത്ഥന പരിശോധിച്ച് ഫോൺ നമ്പർ പങ്കിടണോ തീരുമാനിക്കുക.',
    'contact_pending':
        'അഭ്യർത്ഥന അയച്ചു — തൊഴിലാളിയുടെ മറുപടിക്കായി കാത്തിരിക്കുന്നു',
    'contact_accepted': 'തൊഴിലാളി നിങ്ങളുടെ അഭ്യർത്ഥന സ്വീകരിച്ചു',
    'contact_phone_shared': 'പങ്കിട്ട ഫോൺ നമ്പർ',
    'contact_no_phone':
        'തൊഴിലാളി സ്വീകരിച്ചു, പക്ഷേ ഫോൺ നമ്പർ രജിസ്റ്റർ ചെയ്തിട്ടില്ല.',
    'contact_request_sent': 'തൊഴിലാളിക്ക് ബന്ധപ്പെടാനുള്ള അഭ്യർത്ഥന അയച്ചു.',
    'contact_accept': 'സ്വീകരിച്ച് എന്റെ നമ്പർ പങ്കിടുക',
    'contact_accept_no_phone': 'നമ്പർ പങ്കിടാതെ സ്വീകരിക്കുക',
    'contact_decline': 'നിരസിക്കുക',
    'contact_status_declined': 'അഭ്യർത്ഥന നിരസിച്ചു',
    'contact_request_error': 'അഭ്യർത്ഥന അയയ്ക്കാനായില്ല.',
    'contact_action_error': 'അഭ്യർത്ഥന പുതുക്കാനായില്ല.',
  },
};

const Map<String, Map<String, String>> contactPerspectiveTranslations = {
  'en': {'contact_you_accepted': 'You accepted this customer’s request.'},
  'ta': {
    'contact_you_accepted':
        'இந்த வாடிக்கையாளரின் கோரிக்கையை நீங்கள் ஏற்றுக்கொண்டீர்கள்.',
  },
  'hi': {'contact_you_accepted': 'आपने इस ग्राहक का अनुरोध स्वीकार किया।'},
  'te': {'contact_you_accepted': 'మీరు ఈ కస్టమర్ అభ్యర్థనను అంగీకరించారు.'},
  'kn': {'contact_you_accepted': 'ನೀವು ಈ ಗ್ರಾಹಕರ ವಿನಂತಿಯನ್ನು ಸ್ವೀಕರಿಸಿದ್ದೀರಿ.'},
  'ml': {
    'contact_you_accepted': 'നിങ്ങൾ ഈ ഉപഭോക്താവിന്റെ അഭ്യർത്ഥന സ്വീകരിച്ചു.',
  },
};

const Map<String, Map<String, String>> customerFlowTranslations = {
  'en': {
    'customer_no_workers_next_step': 'No matching workers are available yet. Post your request so nearby workers can apply.',
    'service_pin_location': 'Pin the work location on the map',
    'service_location_pinned': 'Work location pinned',
    'service_request_location_required':
        'Pin the work location before posting so nearby workers can find it.',
    'service_nearby_broadcast_note': 'Workers with this skill who shared their map location within this radius can see and apply for your request.',
    'available_workers_title': 'Available workers',
    'customer_nearby_filter': 'Show workers near me',
    'worker_request_location': 'Use my location to find nearby requests',
    'worker_request_location_note': 'Share your location for this search, or enable worker map visibility, to see nearby customer requests for your skill.',
  },
  'ta': {
    'customer_no_workers_next_step': 'பொருந்தும் தொழிலாளர்கள் இப்போது இல்லை. உங்கள் கோரிக்கையைப் பதிவு செய்யுங்கள்; அருகிலுள்ள தொழிலாளர்கள் விண்ணப்பிக்கலாம்.',
    'service_pin_location': 'வரைபடத்தில் வேலை இடத்தைக் குறிக்கவும்',
    'service_location_pinned': 'வேலை இடம் வரைபடத்தில் குறிக்கப்பட்டது',
    'service_request_location_required': 'அருகிலுள்ள தொழிலாளர்கள் கண்டறிய, பதிவிடும் முன் வேலை இடத்தை வரைபடத்தில் குறிக்கவும்.',
    'service_nearby_broadcast_note': 'இந்தத் திறன் மற்றும் வரைபட இடப் பகிர்வை இயக்கியுள்ள, தேர்ந்தெடுத்த தூரத்திற்குள் உள்ள தொழிலாளர்கள் கோரிக்கையைப் பார்த்து விண்ணப்பிக்கலாம்.',
    'available_workers_title': 'கிடைக்கும் தொழிலாளர்கள்',
    'customer_nearby_filter': 'என் அருகிலுள்ள தொழிலாளர்களைக் காட்டு',
    'worker_request_location':
        'அருகிலுள்ள கோரிக்கைகளைக் காண என் இடத்தைப் பயன்படுத்து',
    'worker_request_location_note': 'உங்கள் திறனுக்கான அருகிலுள்ள வாடிக்கையாளர் கோரிக்கைகளைப் பார்க்க, இந்தத் தேடலுக்கான இருப்பிட அனுமதி வழங்கவும் அல்லது worker map visibility-ஐ இயக்கவும்.',
  },
};

const Map<String, Map<String, String>> customerDashboardTranslations = {
  'en': {
    'posted_jobs': 'Posted jobs',
    'open_service_requests': 'Customer job requests',
    'available_worker_requests': 'Available job requests',
    'service_request_count': 'matching requests',
  },
  'ta': {
    'posted_jobs': 'பதிவிட்ட வேலைகள்',
    'open_service_requests': 'வாடிக்கையாளர் வேலைக் கோரிக்கைகள்',
    'available_worker_requests': 'கிடைக்கும் வேலைக் கோரிக்கைகள்',
    'service_request_count': 'பொருந்தும் கோரிக்கைகள்',
  },
  'hi': {
    'posted_jobs': 'पोस्ट किए गए काम',
    'open_service_requests': 'ग्राहक के काम के अनुरोध',
    'available_worker_requests': 'उपलब्ध काम के अनुरोध',
    'service_request_count': 'मिलते-जुलते अनुरोध',
  },
  'te': {
    'posted_jobs': 'పోస్ట్ చేసిన పనులు',
    'open_service_requests': 'కస్టమర్ పని అభ్యర్థనలు',
    'available_worker_requests': 'అందుబాటులో ఉన్న పని అభ్యర్థనలు',
    'service_request_count': 'సరిపోలిన అభ్యర్థనలు',
  },
  'kn': {
    'posted_jobs': 'ಪೋಸ್ಟ್ ಮಾಡಿದ ಕೆಲಸಗಳು',
    'open_service_requests': 'ಗ್ರಾಹಕರ ಕೆಲಸದ ವಿನಂತಿಗಳು',
    'available_worker_requests': 'ಲಭ್ಯವಿರುವ ಕೆಲಸದ ವಿನಂತಿಗಳು',
    'service_request_count': 'ಹೊಂದಾಣಿಕೆಯ ವಿನಂತಿಗಳು',
  },
  'ml': {
    'posted_jobs': 'പോസ്റ്റ് ചെയ്ത ജോലികൾ',
    'open_service_requests': 'ഉപഭോക്തൃ ജോലി അഭ്യർത്ഥനകൾ',
    'available_worker_requests': 'ലഭ്യമായ ജോലി അഭ്യർത്ഥനകൾ',
    'service_request_count': 'പൊരുത്തപ്പെടുന്ന അഭ്യർത്ഥനകൾ',
  },
};

const Map<String, Map<String, String>> departmentFlowTranslations = {
  'en': {
    'wage_optional_hint': 'Optional — agree on the amount with the worker.',
    'wage_to_be_discussed': 'Wage to be discussed',
    'agreed_wage_title': 'Enter the agreed wage',
    'agreed_wage_help': 'Confirm the amount agreed with the worker before creating a payment QR.',
    'agreed_wage_invalid': 'Enter a valid amount greater than zero.',
    'radius_choose': 'Search radius',
    'radius_within': 'Within {radius} km',
    'radius_custom': 'Custom…',
    'radius_custom_title': 'Choose a search radius',
    'radius_custom_invalid': 'Enter a radius from 1 to 200 km.',
    'department_skill_customer': 'Choose a service to find available workers.',
    'department_skill_employer':
        'Choose a skill to prepare a matching job post.',
    'department_skill_worker': 'Choose a skill to find matching open jobs.',
    'department_skill_hint': 'Choose a skill to continue.',
    'post_service_request': 'Post a job',
    'my_service_requests': 'My repair requests',
    'open_service_requests': 'Customer repair requests',
    'service_request_posted': 'Your request is posted for matching workers.',
    'service_request_post_failed': 'Could not post the request.',
    'service_requests_empty': 'No matching customer requests right now.',
    'service_request_apply': 'I can do this',
    'service_request_applied': 'You have applied for this request.',
    'service_request_already_applied': 'You already applied for this request.',
    'service_request_applicants': 'worker applications',
    'service_request_open': 'Open',
    'service_request_applied_status': 'Applied',
    'service_request_role_needed': 'Select your worker department and skill in your profile to see matching requests.',
  },
  'ta': {
    'wage_optional_hint':
        'விருப்பம் — தொழிலாளருடன் தொகையைப் பேசி முடிவு செய்யுங்கள்.',
    'wage_to_be_discussed': 'கூலி பேசி முடிவு செய்யப்படும்',
    'agreed_wage_title': 'ஒப்புக்கொண்ட கூலியை உள்ளிடுங்கள்',
    'agreed_wage_help': 'Payment QR உருவாக்கும் முன் தொழிலாளருடன் ஒப்புக்கொண்ட தொகையை உறுதிசெய்யுங்கள்.',
    'agreed_wage_invalid':
        'பூஜ்ஜியத்தை விட அதிகமான சரியான தொகையை உள்ளிடுங்கள்.',
    'radius_choose': 'தேடல் தூரம்',
    'radius_within': '{radius} கி.மீ.க்குள்',
    'radius_custom': 'விருப்பத் தூரம்…',
    'radius_custom_title': 'தேடல் தூரத்தைத் தேர்ந்தெடுக்கவும்',
    'radius_custom_invalid': '1 முதல் 200 கி.மீ. வரை உள்ளிடுங்கள்.',
    'department_skill_customer':
        'கிடைக்கும் தொழிலாளர்களைத் தேட ஒரு சேவையைத் தேர்ந்தெடுக்கவும்.',
    'department_skill_employer':
        'பொருத்தமான வேலைப் பதிவைத் தொடங்க திறனைத் தேர்ந்தெடுக்கவும்.',
    'department_skill_worker':
        'பொருந்தும் திறந்த வேலைகளைத் தேட திறனைத் தேர்ந்தெடுக்கவும்.',
    'department_skill_hint': 'தொடர ஒரு திறனைத் தேர்ந்தெடுக்கவும்.',
  },
  'hi': {
    'wage_optional_hint': 'वैकल्पिक — कामगार से बात करके राशि तय करें।',
    'wage_to_be_discussed': 'मजदूरी पर चर्चा होगी',
    'agreed_wage_title': 'तय की गई मजदूरी दर्ज करें',
    'agreed_wage_help':
        'भुगतान QR बनाने से पहले कामगार के साथ तय राशि की पुष्टि करें।',
    'agreed_wage_invalid': 'शून्य से अधिक सही राशि दर्ज करें।',
    'radius_choose': 'खोज की दूरी',
    'radius_within': '{radius} किमी के भीतर',
    'radius_custom': 'अपनी दूरी…',
    'radius_custom_title': 'खोज की दूरी चुनें',
    'radius_custom_invalid': '1 से 200 किमी तक की दूरी दर्ज करें।',
    'department_skill_customer': 'उपलब्ध कामगार खोजने के लिए सेवा चुनें।',
    'department_skill_employer':
        'उपयुक्त काम पोस्ट शुरू करने के लिए कौशल चुनें।',
    'department_skill_worker': 'मिलते-जुलते खुले काम खोजने के लिए कौशल चुनें।',
    'department_skill_hint': 'आगे बढ़ने के लिए कौशल चुनें।',
  },
  'te': {
    'wage_optional_hint':
        'ఐచ్ఛికం — కార్మికుడితో మాట్లాడి మొత్తం నిర్ణయించండి.',
    'wage_to_be_discussed': 'కూలి చర్చించాలి',
    'agreed_wage_title': 'అంగీకరించిన కూలీని నమోదు చేయండి',
    'agreed_wage_help': 'చెల్లింపు QR రూపొందించే ముందు కార్మికుడితో అంగీకరించిన మొత్తాన్ని నిర్ధారించండి.',
    'agreed_wage_invalid': 'సున్నా కంటే ఎక్కువ సరైన మొత్తాన్ని నమోదు చేయండి.',
    'radius_choose': 'శోధన దూరం',
    'radius_within': '{radius} కి.మీ. లోపు',
    'radius_custom': 'అనుకూల దూరం…',
    'radius_custom_title': 'శోధన దూరాన్ని ఎంచుకోండి',
    'radius_custom_invalid': '1 నుంచి 200 కి.మీ. మధ్య నమోదు చేయండి.',
    'department_skill_customer':
        'అందుబాటులో ఉన్న కార్మికులను కనుగొనడానికి సేవను ఎంచుకోండి.',
    'department_skill_employer':
        'సరిపోయే పని పోస్టును ప్రారంభించడానికి నైపుణ్యాన్ని ఎంచుకోండి.',
    'department_skill_worker':
        'సంబంధిత తెరిచి ఉన్న పనులను కనుగొనడానికి నైపుణ్యాన్ని ఎంచుకోండి.',
    'department_skill_hint': 'కొనసాగించడానికి నైపుణ్యాన్ని ఎంచుకోండి.',
  },
  'kn': {
    'wage_optional_hint': 'ಐಚ್ಛಿಕ — ಕಾರ್ಮಿಕರೊಂದಿಗೆ ಮಾತನಾಡಿ ಮೊತ್ತ ನಿಗದಿಪಡಿಸಿ.',
    'wage_to_be_discussed': 'ಕೂಲಿ ಚರ್ಚಿಸಬೇಕು',
    'agreed_wage_title': 'ಒಪ್ಪಿದ ಕೂಲಿಯನ್ನು ನಮೂದಿಸಿ',
    'agreed_wage_help':
        'ಪಾವತಿ QR ರಚಿಸುವ ಮೊದಲು ಕಾರ್ಮಿಕರೊಂದಿಗೆ ಒಪ್ಪಿದ ಮೊತ್ತವನ್ನು ಖಚಿತಪಡಿಸಿ.',
    'agreed_wage_invalid': 'ಶೂನ್ಯಕ್ಕಿಂತ ಹೆಚ್ಚಿನ ಸರಿಯಾದ ಮೊತ್ತವನ್ನು ನಮೂದಿಸಿ.',
    'radius_choose': 'ಹುಡುಕಾಟದ ದೂರ',
    'radius_within': '{radius} ಕಿ.ಮೀ. ಒಳಗೆ',
    'radius_custom': 'ಕಸ್ಟಮ್ ದೂರ…',
    'radius_custom_title': 'ಹುಡುಕಾಟದ ದೂರ ಆಯ್ಕೆಮಾಡಿ',
    'radius_custom_invalid': '1ರಿಂದ 200 ಕಿ.ಮೀ.ವರೆಗೆ ನಮೂದಿಸಿ.',
    'department_skill_customer':
        'ಲಭ್ಯವಿರುವ ಕಾರ್ಮಿಕರನ್ನು ಹುಡುಕಲು ಸೇವೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ.',
    'department_skill_employer':
        'ಸೂಕ್ತ ಕೆಲಸದ ಪೋಸ್ಟ್ ಪ್ರಾರಂಭಿಸಲು ಕೌಶಲ್ಯ ಆಯ್ಕೆಮಾಡಿ.',
    'department_skill_worker':
        'ಹೊಂದುವ ತೆರೆದ ಕೆಲಸಗಳನ್ನು ಹುಡುಕಲು ಕೌಶಲ್ಯ ಆಯ್ಕೆಮಾಡಿ.',
    'department_skill_hint': 'ಮುಂದುವರಿಸಲು ಕೌಶಲ್ಯ ಆಯ್ಕೆಮಾಡಿ.',
  },
  'ml': {
    'wage_optional_hint':
        'ഐച്ഛികം — തൊഴിലാളിയുമായി സംസാരിച്ച് തുക തീരുമാനിക്കുക.',
    'wage_to_be_discussed': 'കൂലി ചർച്ച ചെയ്യണം',
    'agreed_wage_title': 'സമ്മതിച്ച കൂലി നൽകുക',
    'agreed_wage_help': 'പേയ്മെന്റ് QR സൃഷ്ടിക്കുന്നതിന് മുമ്പ് തൊഴിലാളിയുമായി സമ്മതിച്ച തുക ഉറപ്പാക്കുക.',
    'agreed_wage_invalid': 'പൂജ്യത്തേക്കാൾ കൂടുതലുള്ള ശരിയായ തുക നൽകുക.',
    'radius_choose': 'തിരയൽ ദൂരം',
    'radius_within': '{radius} കി.മീ. പരിധിയിൽ',
    'radius_custom': 'ഇഷ്ടദൂരം…',
    'radius_custom_title': 'തിരയൽ ദൂരം തിരഞ്ഞെടുക്കുക',
    'radius_custom_invalid': '1 മുതൽ 200 കി.മീ. വരെ നൽകുക.',
    'department_skill_customer':
        'ലഭ്യമായ തൊഴിലാളികളെ കണ്ടെത്താൻ സേവനം തിരഞ്ഞെടുക്കുക.',
    'department_skill_employer':
        'അനുയോജ്യമായ ജോലി പോസ്റ്റ് തുടങ്ങാൻ കഴിവ് തിരഞ്ഞെടുക്കുക.',
    'department_skill_worker':
        'പൊരുത്തമുള്ള തുറന്ന ജോലികൾ കണ്ടെത്താൻ കഴിവ് തിരഞ്ഞെടുക്കുക.',
    'department_skill_hint': 'തുടരാൻ ഒരു കഴിവ് തിരഞ്ഞെടുക്കുക.',
  },
};

const Map<String, Map<String, String>> paymentFlowTranslations = {
  'en': {
    'payout_jobs_title': 'UPI payment setup',
    'payout_jobs_hint':
        'Set your UPI ID for accepted jobs and review direct payments.',
    'upi_id': 'UPI ID (VPA)',
    'save_upi': 'Save UPI ID',
    'payment_qr_title': 'Pay worker by UPI',
    'payment_scan_hint':
        'Scan with any UPI app and confirm the recipient and amount.',
    'payment_direct_notice': 'Money goes directly to the worker’s bank through UPI. Mr. Coolie does not hold the money or verify the bank transfer.',
    'payment_mark_sent': 'I have paid by UPI',
    'payment_reference': 'UPI reference / UTR (optional)',
    'payment_waiting_worker':
        'You reported payment. Waiting for the worker to confirm receipt.',
    'payment_confirm_received': 'Confirm money received',
    'payment_worker_confirmed':
        'Worker confirmed receipt (bank transfer not independently verified).',
    'payment_profile_missing':
        'The worker needs to add a UPI ID for this job first.',
    'payment_profile_saved': 'UPI ID saved for this job.',
    'payment_save_failed': 'Could not save the UPI ID.',
    'payment_send_failed': 'Could not record the payment report.',
    'payment_confirm_failed': 'Could not update payment status.',
    'payment_no_jobs': 'No accepted or completed jobs yet.',
    'payment_status': 'Payment status',
    'open_payment_qr': 'Show UPI payment QR',
    'payment_pending': 'Awaiting payment',
    'payment_reported': 'Payer reported sent',
    'payment_confirmed': 'Receipt confirmed',
    'direct_upi_total': 'Worker-confirmed direct UPI receipts',
    'direct_upi_total_note': 'This total is reported in the app, not verified by a bank or payment gateway.',
    'payment_amount_mismatch':
        'Job amount is missing or invalid. Ask the employer to update the job.',
  },
  'ta': {
    'payout_jobs_title': 'UPI கட்டண அமைப்பு',
    'payout_jobs_hint': 'ஏற்றுக்கொண்ட வேலைகளுக்கு உங்கள் UPI ID-ஐ அமைத்து நேரடி கட்டணங்களைப் பாருங்கள்.',
    'upi_id': 'UPI ID (VPA)',
    'save_upi': 'UPI ID-ஐ சேமி',
    'payment_qr_title': 'UPI மூலம் தொழிலாளருக்குச் செலுத்துங்கள்',
    'payment_scan_hint':
        'UPI செயலியில் scan செய்து பெறுநர் மற்றும் தொகையைச் சரிபார்க்கவும்.',
    'payment_direct_notice': 'UPI பணம் நேரடியாக தொழிலாளரின் வங்கிக் கணக்குக்குச் செல்லும். Mr. Coolie பணத்தை வைத்திருக்காது; வங்கி பரிமாற்றத்தையும் சரிபார்க்காது.',
    'payment_mark_sent': 'UPI மூலம் பணம் அனுப்பிவிட்டேன்',
    'payment_reference': 'UPI reference / UTR (விருப்பம்)',
    'payment_waiting_worker': 'பணம் அனுப்பியதாகப் பதிவு செய்துள்ளீர்கள். தொழிலாளர் பெற்றதை உறுதிப்படுத்தக் காத்திருக்கிறது.',
    'payment_confirm_received': 'பணம் பெற்றதை உறுதிப்படுத்து',
    'payment_worker_confirmed': 'தொழிலாளர் பெற்றதாக உறுதிப்படுத்தினார் (வங்கி பரிமாற்றம் தனியாகச் சரிபார்க்கப்படவில்லை).',
    'payment_profile_missing':
        'இந்த வேலைக்கு தொழிலாளர் முதலில் UPI ID சேர்க்க வேண்டும்.',
    'payment_profile_saved': 'இந்த வேலைக்கான UPI ID சேமிக்கப்பட்டது.',
    'payment_save_failed': 'UPI ID-ஐ சேமிக்க முடியவில்லை.',
    'payment_send_failed': 'கட்டணப் பதிவைச் சேமிக்க முடியவில்லை.',
    'payment_confirm_failed': 'கட்டண நிலையை மாற்ற முடியவில்லை.',
    'payment_no_jobs': 'ஏற்றுக்கொண்ட அல்லது முடித்த வேலைகள் இல்லை.',
    'payment_status': 'கட்டண நிலை',
    'open_payment_qr': 'UPI கட்டண QR-ஐக் காட்டு',
    'payment_pending': 'கட்டணம் வர வேண்டியுள்ளது',
    'payment_reported': 'செலுத்தியதாகப் பதிவு செய்யப்பட்டது',
    'payment_confirmed': 'பெற்றதாக உறுதி செய்யப்பட்டது',
    'direct_upi_total': 'தொழிலாளர் உறுதிப்படுத்திய நேரடி UPI வரவுகள்',
    'direct_upi_total_note': 'இந்தத் தொகை app-ல் பதிவு செய்யப்பட்டது; வங்கி அல்லது payment gateway மூலம் சரிபார்க்கப்படவில்லை.',
    'payment_amount_mismatch': 'வேலைத் தொகை சரியில்லை. Employer-ஐ வேலை விவரத்தைச் சரிபார்க்கச் சொல்லுங்கள்.',
  },
  'hi': {
    'payout_jobs_title': 'UPI भुगतान सेटअप',
    'payout_jobs_hint':
        'स्वीकृत कामों के लिए UPI ID सेट करें और सीधे भुगतान देखें.',
    'upi_id': 'UPI ID (VPA)',
    'save_upi': 'UPI ID सहेजें',
    'payment_qr_title': 'UPI से कामगार को भुगतान करें',
    'payment_scan_hint':
        'किसी UPI ऐप से स्कैन करके प्राप्तकर्ता और राशि जाँचें.',
    'payment_direct_notice': 'पैसा सीधे कामगार के बैंक में जाता है। Mr. Coolie पैसा नहीं रखता और बैंक भुगतान सत्यापित नहीं करता.',
    'payment_mark_sent': 'मैंने UPI से भुगतान किया',
    'payment_reference': 'UPI reference / UTR (वैकल्पिक)',
    'payment_waiting_worker':
        'आपने भुगतान भेजने की सूचना दी। कामगार की पुष्टि की प्रतीक्षा है.',
    'payment_confirm_received': 'प्राप्ति की पुष्टि करें',
    'payment_worker_confirmed': 'कामगार ने प्राप्ति की पुष्टि की (बैंक भुगतान स्वतंत्र रूप से सत्यापित नहीं है).',
    'payment_profile_missing':
        'कामगार को पहले इस काम के लिए UPI ID जोड़नी होगी.',
    'payment_profile_saved': 'इस काम के लिए UPI ID सहेजी गई.',
    'payment_save_failed': 'UPI ID सहेजी नहीं जा सकी.',
    'payment_send_failed': 'भुगतान रिपोर्ट सहेजी नहीं जा सकी.',
    'payment_confirm_failed': 'भुगतान स्थिति अपडेट नहीं हुई.',
    'payment_no_jobs': 'अभी कोई स्वीकृत या पूरा काम नहीं है.',
    'payment_status': 'भुगतान स्थिति',
    'open_payment_qr': 'UPI भुगतान QR दिखाएँ',
    'payment_pending': 'भुगतान बाकी',
    'payment_reported': 'भेजने की सूचना दी',
    'payment_confirmed': 'प्राप्ति की पुष्टि हुई',
    'direct_upi_total': 'कामगार द्वारा पुष्टि की गई UPI प्राप्तियाँ',
    'direct_upi_total_note':
        'यह राशि ऐप में दर्ज है; बैंक या भुगतान गेटवे से सत्यापित नहीं है.',
    'payment_amount_mismatch':
        'काम की राशि गलत है। नियोक्ता से विवरण ठीक करने को कहें.',
  },
  'te': {
    'payout_jobs_title': 'UPI చెల్లింపు సెటప్',
    'payout_jobs_hint':
        'ఆమోదించిన పనులకు UPI ID సెట్ చేసి నేరుగా చెల్లింపులను చూడండి.',
    'upi_id': 'UPI ID (VPA)',
    'save_upi': 'UPI ID సేవ్ చేయండి',
    'payment_qr_title': 'UPI ద్వారా కార్మికుడికి చెల్లించండి',
    'payment_scan_hint':
        'ఏదైనా UPI యాప్‌తో స్కాన్ చేసి గ్రహీత, మొత్తాన్ని తనిఖీ చేయండి.',
    'payment_direct_notice': 'డబ్బు నేరుగా కార్మికుడి బ్యాంకుకు వెళ్తుంది. Mr. Coolie డబ్బును ఉంచదు లేదా బ్యాంకు చెల్లింపును ధృవీకరించదు.',
    'payment_mark_sent': 'UPI ద్వారా చెల్లించాను',
    'payment_reference': 'UPI reference / UTR (ఐచ్ఛికం)',
    'payment_waiting_worker':
        'చెల్లింపు పంపినట్లు నమోదు చేశారు. కార్మికుడి నిర్ధారణ కోసం వేచి ఉంది.',
    'payment_confirm_received': 'డబ్బు అందినట్లు నిర్ధారించండి',
    'payment_worker_confirmed': 'కార్మికుడు అందినట్లు నిర్ధారించారు (బ్యాంకు చెల్లింపు స్వతంత్రంగా ధృవీకరించబడలేదు).',
    'payment_profile_missing': 'ఈ పనికి కార్మికుడు ముందుగా UPI ID జోడించాలి.',
    'payment_profile_saved': 'ఈ పనికి UPI ID సేవ్ అయింది.',
    'payment_save_failed': 'UPI ID సేవ్ కాలేదు.',
    'payment_send_failed': 'చెల్లింపు నివేదిక నమోదు కాలేదు.',
    'payment_confirm_failed': 'చెల్లింపు స్థితి నవీకరించబడలేదు.',
    'payment_no_jobs': 'ఆమోదించిన లేదా పూర్తయిన పనులు లేవు.',
    'payment_status': 'చెల్లింపు స్థితి',
    'open_payment_qr': 'UPI చెల్లింపు QR చూపించండి',
    'payment_pending': 'చెల్లింపు కోసం వేచి ఉంది',
    'payment_reported': 'పంపినట్లు నివేదించారు',
    'payment_confirmed': 'అందినట్లు నిర్ధారించారు',
    'direct_upi_total': 'కార్మికుడు నిర్ధారించిన UPI చెల్లింపులు',
    'direct_upi_total_note': 'ఈ మొత్తం యాప్‌లో నమోదైంది; బ్యాంక్ లేదా చెల్లింపు గేట్‌వే ద్వారా ధృవీకరించబడలేదు.',
    'payment_amount_mismatch':
        'పని మొత్తం సరైంది కాదు. వివరాలను సరిచేయమని యజమానిని అడగండి.',
  },
  'kn': {
    'payout_jobs_title': 'UPI ಪಾವತಿ ಸೆಟಪ್',
    'payout_jobs_hint':
        'ಒಪ್ಪಿದ ಕೆಲಸಗಳಿಗೆ UPI ID ಹೊಂದಿಸಿ ಮತ್ತು ನೇರ ಪಾವತಿಗಳನ್ನು ನೋಡಿ.',
    'upi_id': 'UPI ID (VPA)',
    'save_upi': 'UPI ID ಉಳಿಸಿ',
    'payment_qr_title': 'UPI ಮೂಲಕ ಕಾರ್ಮಿಕರಿಗೆ ಪಾವತಿಸಿ',
    'payment_scan_hint': 'ಯಾವುದೇ UPI ಆ್ಯಪ್‌ನಿಂದ ಸ್ಕ್ಯಾನ್ ಮಾಡಿ ಸ್ವೀಕರಿಸುವವರು ಮತ್ತು ಮೊತ್ತ ಪರಿಶೀಲಿಸಿ.',
    'payment_direct_notice': 'ಹಣ ನೇರವಾಗಿ ಕಾರ್ಮಿಕರ ಬ್ಯಾಂಕ್‌ಗೆ ಹೋಗುತ್ತದೆ. Mr. Coolie ಹಣವನ್ನು ಹಿಡಿದಿಡುವುದಿಲ್ಲ ಅಥವಾ ಬ್ಯಾಂಕ್ ಪಾವತಿಯನ್ನು ಪರಿಶೀಲಿಸುವುದಿಲ್ಲ.',
    'payment_mark_sent': 'UPI ಮೂಲಕ ಪಾವತಿಸಿದ್ದೇನೆ',
    'payment_reference': 'UPI reference / UTR (ಐಚ್ಛಿಕ)',
    'payment_waiting_worker': 'ಪಾವತಿ ಕಳುಹಿಸಿದ್ದಾಗಿ ದಾಖಲಿಸಲಾಗಿದೆ. ಕಾರ್ಮಿಕರ ದೃಢೀಕರಣಕ್ಕಾಗಿ ಕಾಯಲಾಗುತ್ತಿದೆ.',
    'payment_confirm_received': 'ಹಣ ಬಂದಿರುವುದನ್ನು ದೃಢೀಕರಿಸಿ',
    'payment_worker_confirmed': 'ಕಾರ್ಮಿಕರು ಹಣ ಬಂದಿರುವುದನ್ನು ದೃಢೀಕರಿಸಿದ್ದಾರೆ (ಬ್ಯಾಂಕ್ ಪಾವತಿಯನ್ನು ಸ್ವತಂತ್ರವಾಗಿ ಪರಿಶೀಲಿಸಿಲ್ಲ).',
    'payment_profile_missing': 'ಈ ಕೆಲಸಕ್ಕೆ ಕಾರ್ಮಿಕರು ಮೊದಲು UPI ID ಸೇರಿಸಬೇಕು.',
    'payment_profile_saved': 'ಈ ಕೆಲಸಕ್ಕೆ UPI ID ಉಳಿಸಲಾಗಿದೆ.',
    'payment_save_failed': 'UPI ID ಉಳಿಸಲಾಗಲಿಲ್ಲ.',
    'payment_send_failed': 'ಪಾವತಿ ವರದಿ ದಾಖಲಿಸಲಾಗಲಿಲ್ಲ.',
    'payment_confirm_failed': 'ಪಾವತಿ ಸ್ಥಿತಿ ನವೀಕರಿಸಲಾಗಲಿಲ್ಲ.',
    'payment_no_jobs': 'ಒಪ್ಪಿದ ಅಥವಾ ಪೂರ್ಣಗೊಂಡ ಕೆಲಸಗಳಿಲ್ಲ.',
    'payment_status': 'ಪಾವತಿ ಸ್ಥಿತಿ',
    'open_payment_qr': 'UPI ಪಾವತಿ QR ತೋರಿಸಿ',
    'payment_pending': 'ಪಾವತಿಗಾಗಿ ಕಾಯುತ್ತಿದೆ',
    'payment_reported': 'ಕಳುಹಿಸಿದುದಾಗಿ ವರದಿ',
    'payment_confirmed': 'ಸ್ವೀಕೃತಿ ದೃಢವಾಗಿದೆ',
    'direct_upi_total': 'ಕಾರ್ಮಿಕರು ದೃಢಪಡಿಸಿದ ನೇರ UPI ಪಾವತಿಗಳು',
    'direct_upi_total_note': 'ಈ ಮೊತ್ತ ಆ್ಯಪ್‌ನಲ್ಲಿ ದಾಖಲಾಗಿದೆ; ಬ್ಯಾಂಕ್ ಅಥವಾ ಪಾವತಿ ಗೇಟ್‌ವೇ ಪರಿಶೀಲಿಸಿಲ್ಲ.',
    'payment_amount_mismatch':
        'ಕೆಲಸದ ಮೊತ್ತ ಸರಿಯಿಲ್ಲ. ವಿವರ ಸರಿಪಡಿಸಲು ಉದ್ಯೋಗದಾತರನ್ನು ಕೇಳಿ.',
  },
  'ml': {
    'payout_jobs_title': 'UPI പേയ്‌മെന്റ് ക്രമീകരണം',
    'payout_jobs_hint': 'അംഗീകരിച്ച ജോലികൾക്കായി UPI ID ചേർത്ത് നേരിട്ടുള്ള പേയ്‌മെന്റുകൾ കാണുക.',
    'upi_id': 'UPI ID (VPA)',
    'save_upi': 'UPI ID സേവ് ചെയ്യുക',
    'payment_qr_title': 'UPI വഴി തൊഴിലാളിക്ക് പണം നൽകുക',
    'payment_scan_hint':
        'ഏതെങ്കിലും UPI ആപ്പിൽ സ്കാൻ ചെയ്ത് സ്വീകർത്താവും തുകയും പരിശോധിക്കുക.',
    'payment_direct_notice': 'പണം നേരിട്ട് തൊഴിലാളിയുടെ ബാങ്കിലേക്ക് പോകും. Mr. Coolie പണം കൈവശം വയ്ക്കുകയോ ബാങ്ക് പേയ്‌മെന്റ് സ്ഥിരീകരിക്കുകയോ ഇല്ല.',
    'payment_mark_sent': 'UPI വഴി പണം നൽകി',
    'payment_reference': 'UPI reference / UTR (ഐച്ഛികം)',
    'payment_waiting_worker': 'പണം അയച്ചതായി രേഖപ്പെടുത്തി. തൊഴിലാളിയുടെ സ്ഥിരീകരണത്തിനായി കാത്തിരിക്കുന്നു.',
    'payment_confirm_received': 'പണം ലഭിച്ചതായി സ്ഥിരീകരിക്കുക',
    'payment_worker_confirmed': 'ലഭിച്ചതായി തൊഴിലാളി സ്ഥിരീകരിച്ചു (ബാങ്ക് പേയ്‌മെന്റ് സ്വതന്ത്രമായി പരിശോധിച്ചിട്ടില്ല).',
    'payment_profile_missing': 'ഈ ജോലിക്കായി തൊഴിലാളി ആദ്യം UPI ID ചേർക്കണം.',
    'payment_profile_saved': 'ഈ ജോലിക്കായി UPI ID സേവ് ചെയ്തു.',
    'payment_save_failed': 'UPI ID സേവ് ചെയ്യാനായില്ല.',
    'payment_send_failed': 'പേയ്‌മെന്റ് റിപ്പോർട്ട് രേഖപ്പെടുത്താനായില്ല.',
    'payment_confirm_failed': 'പേയ്‌മെന്റ് നില പുതുക്കാനായില്ല.',
    'payment_no_jobs': 'അംഗീകരിച്ചോ പൂർത്തിയാക്കിയോ ജോലികളില്ല.',
    'payment_status': 'പേയ്‌മെന്റ് നില',
    'open_payment_qr': 'UPI പേയ്‌മെന്റ് QR കാണിക്കുക',
    'payment_pending': 'പേയ്‌മെന്റിനായി കാത്തിരിക്കുന്നു',
    'payment_reported': 'അയച്ചതായി റിപ്പോർട്ട് ചെയ്തു',
    'payment_confirmed': 'ലഭിച്ചതായി സ്ഥിരീകരിച്ചു',
    'direct_upi_total': 'തൊഴിലാളി സ്ഥിരീകരിച്ച നേരിട്ടുള്ള UPI വരവുകൾ',
    'direct_upi_total_note': 'ഈ തുക ആപ്പിൽ രേഖപ്പെടുത്തിയതാണ്; ബാങ്കോ പേയ്‌മെന്റ് ഗേറ്റ്‌വേയോ സ്ഥിരീകരിച്ചതല്ല.',
    'payment_amount_mismatch':
        'ജോലി തുക ശരിയല്ല. വിശദാംശങ്ങൾ തിരുത്താൻ തൊഴിലുടമയോട് പറയുക.',
  },
};

String tr(String key) =>
    appTranslations[appLanguage.value]?[key] ??
    extendedTranslations[appLanguage.value]?[key] ??
    workflowTranslations[appLanguage.value]?[key] ??
    employerTranslations[appLanguage.value]?[key] ??
    contactTranslations[appLanguage.value]?[key] ??
    contactPerspectiveTranslations[appLanguage.value]?[key] ??
    customerFlowTranslations[appLanguage.value]?[key] ??
    customerDashboardTranslations[appLanguage.value]?[key] ??
    departmentFlowTranslations[appLanguage.value]?[key] ??
    paymentFlowTranslations[appLanguage.value]?[key] ??
    contactTranslations['en']?[key] ??
    customerFlowTranslations['en']?[key] ??
    departmentFlowTranslations['en']?[key] ??
    paymentFlowTranslations['en']?[key] ??
    employerTranslations['en']?[key] ??
    extendedTranslations['en']?[key] ??
    appTranslations['en']![key] ??
    key;

const Map<String, Map<String, String>> catalogTranslations = {
  'ta': {
    'Construction & Civil': 'கட்டுமானம் மற்றும் சிவில்',
    'Construction': 'கட்டுமானம்',
    'Civil': 'சிவில் வேலை',
    'Electrical': 'மின்சாரம்',
    'Plumbing & Sanitary': 'குழாய் மற்றும் சுகாதாரப் பணிகள்',
    'Carpentry & Wood Work': 'தச்சு மற்றும் மரவேலை',
    'Carpentry': 'தச்சு வேலை',
    'Metal / Iron Work': 'உலோகம் மற்றும் இரும்பு வேலை',
    'Agriculture / Farming': 'விவசாயம்',
    'Automobile': 'வாகனப் பழுது மற்றும் பராமரிப்பு',
    'Home Services': 'வீட்டுப் பணிகள்',
    'Cleaning & Maintenance': 'சுத்தம் மற்றும் பராமரிப்பு',
    'Shops & Commercial': 'கடை மற்றும் வணிகப் பணிகள்',
    'Hotel / Food Services': 'ஹோட்டல் மற்றும் உணவுப் பணிகள்',
    'Transport / Loading': 'போக்குவரத்து மற்றும் ஏற்றுதல்',
    'Printing / Offset': 'அச்சகம் மற்றும் ஆஃப்செட்',
    'Packaging': 'பொதி செய்தல்',
    'Fireworks Industry': 'பட்டாசுத் தொழில்',
    'Match Industry': 'தீப்பெட்டித் தொழில்',
    'Tailoring & Clothing': 'தையல் மற்றும் ஆடை',
    'Electronics / Mobile': 'மின்னணு மற்றும் மொபைல்',
    'Gardening & Outdoor': 'தோட்டம் மற்றும் வெளிப்புறப் பணிகள்',
    'General Local Services': 'பொது உள்ளூர் சேவைகள்',
    'Cutting': 'வெட்டும் வேலை',
    'Mason': 'கொத்தனார்',
    'Construction Helper': 'கட்டுமான உதவியாளர்',
    'Shuttering Worker': 'சாரம் அமைக்கும் தொழிலாளர்',
    'Bar Bender': 'கம்பி வளைக்கும் தொழிலாளர்',
    'Tile Worker': 'டைல்ஸ் பதிக்கும் தொழிலாளர்',
    'Concrete Worker': 'கான்கிரீட் தொழிலாளர்',
    'Electrician': 'மின்சாரப் பணியாளர்',
    'Wireman': 'மின்கம்பி பணியாளர்',
    'Plumber': 'குழாய் பணியாளர்',
    'Pipe Fitter': 'குழாய் பொருத்துநர்',
    'Carpenter': 'தச்சர்',
    'Furniture Worker': 'மரச்சாமான் தொழிலாளர்',
    'Welder': 'வெல்டர்',
    'Farm Worker': 'விவசாயத் தொழிலாளர்',
    'Harvesting Worker': 'அறுவடைத் தொழிலாளர்',
    'Tractor Operator': 'டிராக்டர் ஓட்டுநர்',
    'Packing Worker': 'பொதி செய்யும் தொழிலாளர்',
    'Labeling Worker': 'லேபிள் ஒட்டும் தொழிலாளர்',
    'Sorting Worker': 'பொருள் வகைப்படுத்தும் தொழிலாளர்',
    'Cutting Worker': 'வெட்டும் தொழிலாளர்',
    'Printing Helper': 'அச்சக உதவியாளர்',
    'Machine Operator': 'இயந்திர இயக்குநர்',
    'Tailor': 'தையல்காரர்',
    'Stitching Worker': 'தையல் தொழிலாளர்',
    'Cook': 'சமையல்காரர்',
    'Gardener': 'தோட்டப் பணியாளர்',
    'House Cleaner': 'வீட்டு சுத்தம் செய்யும் பணியாளர்',
    'Loading Worker': 'சரக்கு ஏற்றும் தொழிலாளர்',
    'Delivery Worker': 'விநியோகப் பணியாளர்',
    'General Helper': 'பொது உதவியாளர்',
    'Daily Wage Worker': 'தினக்கூலி தொழிலாளர்',
  },
  'en': {},
  'hi': {
    'Construction & Civil': 'निर्माण और सिविल',
    'Electrical': 'बिजली का काम',
    'Plumbing & Sanitary': 'प्लंबिंग और सैनिटरी',
    'Carpentry & Wood Work': 'बढ़ईगीरी और लकड़ी का काम',
    'Metal / Iron Work': 'धातु और लोहे का काम',
    'Agriculture / Farming': 'कृषि और खेती',
    'Automobile': 'वाहन सेवा',
    'Home Services': 'घरेलू सेवाएँ',
    'Cleaning & Maintenance': 'सफाई और रखरखाव',
    'Shops & Commercial': 'दुकान और वाणिज्य',
    'Hotel / Food Services': 'होटल और भोजन सेवाएँ',
    'Transport / Loading': 'परिवहन और लोडिंग',
    'Printing / Offset': 'प्रिंटिंग और ऑफसेट',
    'Packaging': 'पैकेजिंग',
    'Fireworks Industry': 'पटाखा उद्योग',
    'Match Industry': 'माचिस उद्योग',
    'Tailoring & Clothing': 'सिलाई और कपड़े',
    'Electronics / Mobile': 'इलेक्ट्रॉनिक्स और मोबाइल',
    'Gardening & Outdoor': 'बागवानी और बाहरी काम',
    'General Local Services': 'सामान्य स्थानीय सेवाएँ',
    'Mason': 'राजमिस्त्री',
    'Construction Helper': 'निर्माण सहायक',
    'Electrician': 'इलेक्ट्रीशियन',
    'Plumber': 'प्लंबर',
    'Carpenter': 'बढ़ई',
    'Welder': 'वेल्डर',
    'Farm Worker': 'कृषि मजदूर',
    'Harvesting Worker': 'कटाई मजदूर',
    'Packing Worker': 'पैकिंग मजदूर',
    'Cutting Worker': 'कटाई मजदूर',
    'Tailor': 'दर्जी',
    'Cook': 'रसोइया',
    'Gardener': 'माली',
    'Delivery Worker': 'डिलीवरी कर्मचारी',
  },
  'te': {
    'Construction & Civil': 'నిర్మాణం మరియు సివిల్',
    'Electrical': 'విద్యుత్ పనులు',
    'Plumbing & Sanitary': 'ప్లంబింగ్ మరియు శానిటరీ',
    'Carpentry & Wood Work': 'వడ్రంగి మరియు కలప పనులు',
    'Metal / Iron Work': 'లోహం మరియు ఇనుప పనులు',
    'Agriculture / Farming': 'వ్యవసాయం',
    'Automobile': 'వాహన సేవలు',
    'Home Services': 'గృహ సేవలు',
    'Cleaning & Maintenance': 'శుభ్రత మరియు నిర్వహణ',
    'Shops & Commercial': 'దుకాణాలు మరియు వాణిజ్యం',
    'Hotel / Food Services': 'హోటల్ మరియు ఆహార సేవలు',
    'Transport / Loading': 'రవాణా మరియు లోడింగ్',
    'Printing / Offset': 'ప్రింటింగ్ మరియు ఆఫ్‌సెట్',
    'Packaging': 'ప్యాకేజింగ్',
    'Fireworks Industry': 'బాణసంచా పరిశ్రమ',
    'Match Industry': 'అగ్గిపెట్టెల పరిశ్రమ',
    'Tailoring & Clothing': 'కుట్టు మరియు దుస్తులు',
    'Electronics / Mobile': 'ఎలక్ట్రానిక్స్ మరియు మొబైల్',
    'Gardening & Outdoor': 'తోటపని మరియు బయట పనులు',
    'General Local Services': 'సాధారణ స్థానిక సేవలు',
    'Mason': 'మేస్త్రీ',
    'Construction Helper': 'నిర్మాణ సహాయకుడు',
    'Electrician': 'ఎలక్ట్రీషియన్',
    'Plumber': 'ప్లంబర్',
    'Carpenter': 'వడ్రంగి',
    'Welder': 'వెల్డర్',
    'Farm Worker': 'వ్యవసాయ కార్మికుడు',
    'Harvesting Worker': 'పంట కోత కార్మికుడు',
    'Packing Worker': 'ప్యాకింగ్ కార్మికుడు',
    'Cutting Worker': 'కటింగ్ కార్మికుడు',
    'Tailor': 'దర్జీ',
    'Cook': 'వంటవారు',
    'Gardener': 'తోటమాలి',
    'Delivery Worker': 'డెలివరీ కార్మికుడు',
  },
  'kn': {
    'Construction & Civil': 'ನಿರ್ಮಾಣ ಮತ್ತು ಸಿವಿಲ್',
    'Electrical': 'ವಿದ್ಯುತ್ ಕೆಲಸ',
    'Plumbing & Sanitary': 'ಕೊಳಾಯಿ ಮತ್ತು ನೈರ್ಮಲ್ಯ',
    'Carpentry & Wood Work': 'ಮರಗೆಲಸ ಮತ್ತು ಬಡಗಿತನ',
    'Metal / Iron Work': 'ಲೋಹ ಮತ್ತು ಕಬ್ಬಿಣದ ಕೆಲಸ',
    'Agriculture / Farming': 'ಕೃಷಿ ಮತ್ತು ಬೇಸಾಯ',
    'Automobile': 'ವಾಹನ ಸೇವೆ',
    'Home Services': 'ಮನೆ ಸೇವೆಗಳು',
    'Cleaning & Maintenance': 'ಸ್ವಚ್ಛತೆ ಮತ್ತು ನಿರ್ವಹಣೆ',
    'Shops & Commercial': 'ಅಂಗಡಿ ಮತ್ತು ವಾಣಿಜ್ಯ',
    'Hotel / Food Services': 'ಹೋಟೆಲ್ ಮತ್ತು ಆಹಾರ ಸೇವೆ',
    'Transport / Loading': 'ಸಾರಿಗೆ ಮತ್ತು ಲೋಡಿಂಗ್',
    'Printing / Offset': 'ಮುದ್ರಣ ಮತ್ತು ಆಫ್‌ಸೆಟ್',
    'Packaging': 'ಪ್ಯಾಕಿಂಗ್',
    'Fireworks Industry': 'ಪಟಾಕಿ ಉದ್ಯಮ',
    'Match Industry': 'ಬೆಂಕಿಪೊಟ್ಟಣ ಉದ್ಯಮ',
    'Tailoring & Clothing': 'ಹೊಲಿಗೆ ಮತ್ತು ಉಡುಪು',
    'Electronics / Mobile': 'ಎಲೆಕ್ಟ್ರಾನಿಕ್ಸ್ ಮತ್ತು ಮೊಬೈಲ್',
    'Gardening & Outdoor': 'ತೋಟಗಾರಿಕೆ ಮತ್ತು ಹೊರಾಂಗಣ ಕೆಲಸ',
    'General Local Services': 'ಸಾಮಾನ್ಯ ಸ್ಥಳೀಯ ಸೇವೆಗಳು',
    'Mason': 'ಗಾರೆ ಕೆಲಸಗಾರ',
    'Construction Helper': 'ನಿರ್ಮಾಣ ಸಹಾಯಕ',
    'Electrician': 'ಎಲೆಕ್ಟ್ರಿಷಿಯನ್',
    'Plumber': 'ಕೊಳಾಯಿ ಕೆಲಸಗಾರ',
    'Carpenter': 'ಬಡಗಿ',
    'Welder': 'ವೆಲ್ಡರ್',
    'Farm Worker': 'ಕೃಷಿ ಕಾರ್ಮಿಕ',
    'Harvesting Worker': 'ಕೊಯ್ಲು ಕಾರ್ಮಿಕ',
    'Packing Worker': 'ಪ್ಯಾಕಿಂಗ್ ಕಾರ್ಮಿಕ',
    'Cutting Worker': 'ಕತ್ತರಿಸುವ ಕೆಲಸಗಾರ',
    'Tailor': 'ದರ್ಜೀ',
    'Cook': 'ಅಡುಗೆ ಕೆಲಸಗಾರ',
    'Gardener': 'ತೋಟಗಾರ',
    'Delivery Worker': 'ವಿತರಣಾ ಕೆಲಸಗಾರ',
  },
  'ml': {
    'Construction & Civil': 'നിർമ്മാണവും സിവിൽ ജോലികളും',
    'Electrical': 'വൈദ്യുതി ജോലികൾ',
    'Plumbing & Sanitary': 'പ്ലംബിംഗ്, സാനിറ്ററി ജോലികൾ',
    'Carpentry & Wood Work': 'മരപ്പണിയും ആശാരിപ്പണിയും',
    'Metal / Iron Work': 'ലോഹ, ഇരുമ്പ് ജോലികൾ',
    'Agriculture / Farming': 'കൃഷിപ്പണികൾ',
    'Automobile': 'വാഹന സേവനങ്ങൾ',
    'Home Services': 'വീട്ടുസേവനങ്ങൾ',
    'Cleaning & Maintenance': 'ശുചീകരണവും പരിപാലനവും',
    'Shops & Commercial': 'കട, വാണിജ്യ ജോലികൾ',
    'Hotel / Food Services': 'ഹോട്ടൽ, ഭക്ഷണ സേവനങ്ങൾ',
    'Transport / Loading': 'ഗതാഗതവും ചരക്ക് കയറ്റലും',
    'Printing / Offset': 'അച്ചടിയും ഓഫ്‌സെറ്റും',
    'Packaging': 'പാക്കിംഗ്',
    'Fireworks Industry': 'പടക്ക വ്യവസായം',
    'Match Industry': 'തീപ്പെട്ടി വ്യവസായം',
    'Tailoring & Clothing': 'തയ്യലും വസ്ത്രങ്ങളും',
    'Electronics / Mobile': 'ഇലക്ട്രോണിക്സ്, മൊബൈൽ',
    'Gardening & Outdoor': 'തോട്ടം, പുറം ജോലികൾ',
    'General Local Services': 'പൊതു പ്രാദേശിക സേവനങ്ങൾ',
    'Mason': 'കൽപ്പണിക്കാരൻ',
    'Construction Helper': 'നിർമ്മാണ സഹായി',
    'Electrician': 'ഇലക്ട്രീഷ്യൻ',
    'Plumber': 'പ്ലംബർ',
    'Carpenter': 'ആശാരി',
    'Welder': 'വെൽഡർ',
    'Farm Worker': 'കൃഷിത്തൊഴിലാളി',
    'Harvesting Worker': 'വിളവെടുപ്പ് തൊഴിലാളി',
    'Packing Worker': 'പാക്കിംഗ് തൊഴിലാളി',
    'Cutting Worker': 'കട്ടിംഗ് തൊഴിലാളി',
    'Tailor': 'തയ്യൽക്കാരൻ',
    'Cook': 'പാചകക്കാരൻ',
    'Gardener': 'തോട്ടക്കാരൻ',
    'Delivery Worker': 'വിതരണ തൊഴിലാളി',
  },
};

const Map<String, Map<String, String>> workerUiTranslations = {
  'en': {
    'apply_for_job': 'Apply for this job',
    'applying': 'Applying…',
    'please_sign_in_apply': 'Please sign in before applying.',
    'firestore_job_required':
        'You can apply only to a job published in the app.',
    'workers_only_apply': 'Only worker accounts can apply for jobs.',
    'only_related_work':
        'This job is outside your registered department and skill.',
    'job_closed_apply': 'This job is no longer open.',
    'already_applied': 'You have already applied for this job.',
    'apply_permission_denied': "Permission denied. Check that you are signed in to a worker account, the job is still open, and its department matches your profile.",
    'apply_failed': 'Could not submit your application',
    'apply_notification_pending': 'Your application is saved, but the employer notification could not be sent.',
    'nearby_map': 'Nearby jobs and distance',
    'worker_map_location': 'Show me on worker maps',
    'map_nearby_workers': 'Map nearby workers',
    'map_share_location': 'Share approximate location',
    'map_stop_sharing': 'Stop sharing on worker maps',
    'map_privacy_note': 'This is optional. When enabled, customers and employers can see your approximate location while you are available. Your live location is not shared.',
    'map_no_workers':
        'No available workers have opted into map visibility nearby.',
    'map_location_saved': 'Your approximate map location is now shared.',
    'map_location_removed': 'Your location was removed from worker maps.',
    'map_workers_count': 'available workers on map',
    'next_jobs': 'Other open jobs near you',
    'location_permission_needed':
        'Allow location access to sort open jobs by distance.',
    'distance_unavailable': 'Distance unavailable',
    'department_skills_count': 'skills',
    'open_jobs_count': 'open jobs',
    'with_coordinates': 'with mapped locations',
    'within_50_km': 'Within 50 km',
    'jobs_load_failed': 'Could not load nearby jobs.',
    'map_jobs_list_fallback': 'Open jobs are still available as a list; mapped pins appear when a job has coordinates.',
  },
  'ta': {
    'apply_for_job': 'இந்த வேலைக்கு விண்ணப்பிக்கவும்',
    'applying': 'விண்ணப்பிக்கிறது…',
    'please_sign_in_apply': 'விண்ணப்பிக்க உள்நுழையுங்கள்.',
    'firestore_job_required':
        'இந்த app-ல் வெளியிடப்பட்ட வேலைக்கே விண்ணப்பிக்க முடியும்.',
    'workers_only_apply': 'தொழிலாளர் கணக்குகள் மட்டுமே விண்ணப்பிக்கலாம்.',
    'only_related_work': 'இந்த வேலை உங்கள் பதிவு செய்த துறை/திறனில் இல்லை.',
    'job_closed_apply': 'இந்த வேலைக்கு விண்ணப்பம் தற்போது ஏற்கப்படவில்லை.',
    'already_applied': 'இந்த வேலைக்கு நீங்கள் ஏற்கனவே விண்ணப்பித்துள்ளீர்கள்.',
    'apply_permission_denied': "அனுமதி மறுக்கப்பட்டது. Worker account-ல் login செய்துள்ளீர்களா, வேலை இன்னும் open-ஆக உள்ளதா, உங்கள் department பொருந்துகிறதா எனச் சரிபார்க்கவும்.",
    'apply_failed': 'விண்ணப்பத்தை அனுப்ப முடியவில்லை',
    'apply_notification_pending': 'உங்கள் விண்ணப்பம் சேமிக்கப்பட்டது; ஆனால் வேலை வழங்குநருக்கு அறிவிப்பு அனுப்ப முடியவில்லை.',
    'nearby_map': 'அருகிலுள்ள வேலைகள் மற்றும் தூரம்',
    'next_jobs': 'உங்களுக்கு அருகிலுள்ள பிற திறந்த வேலைகள்',
    'location_permission_needed':
        'அருகிலுள்ள வேலைகளை வரிசைப்படுத்த இருப்பிட அனுமதி வழங்கவும்.',
    'distance_unavailable': 'தூரம் கிடைக்கவில்லை',
    'department_skills_count': 'திறன்கள்',
    'open_jobs_count': 'திறந்த வேலைகள்',
    'with_coordinates': 'வரைபட இருப்பிடத்துடன்',
    'within_50_km': '50 கி.மீ.க்குள்',
    'jobs_load_failed': 'அருகிலுள்ள வேலைகளை ஏற்ற முடியவில்லை.',
    'map_jobs_list_fallback': 'திறந்த வேலைகள் பட்டியலாகக் கிடைக்கும்; வேலை இடத்தின் coordinates இருந்தால் வரைபடத்தில் குறி வரும்.',
  },
  'hi': {
    'apply_for_job': 'इस काम के लिए आवेदन करें',
    'applying': 'आवेदन हो रहा है…',
    'please_sign_in_apply': 'आवेदन करने के लिए लॉगिन करें।',
    'firestore_job_required':
        'आप केवल ऐप में प्रकाशित काम के लिए आवेदन कर सकते हैं।',
    'workers_only_apply': 'केवल कामगार खाते आवेदन कर सकते हैं।',
    'only_related_work': 'यह काम आपके पंजीकृत विभाग और कौशल से मेल नहीं खाता।',
    'job_closed_apply': 'यह काम अब खुला नहीं है।',
    'already_applied': 'आप पहले ही इस काम के लिए आवेदन कर चुके हैं।',
    'apply_permission_denied': "अनुमति नहीं मिली। Worker खाते से लॉग इन करें, जाँचें कि काम खुला है और आपका विभाग मेल खाता है।",
    'apply_failed': 'आवेदन भेजा नहीं जा सका',
    'apply_notification_pending':
        'आपका आवेदन सहेजा गया, लेकिन नियोक्ता को सूचना नहीं भेजी जा सकी।',
    'nearby_map': 'आसपास के काम और दूरी',
    'next_jobs': 'आपके पास के अन्य खुले काम',
    'location_permission_needed':
        'दूरी के अनुसार काम दिखाने के लिए स्थान अनुमति दें।',
    'distance_unavailable': 'दूरी उपलब्ध नहीं',
    'department_skills_count': 'कौशल',
    'open_jobs_count': 'खुले काम',
    'with_coordinates': 'मानचित्र स्थान सहित',
    'within_50_km': '50 किमी के भीतर',
    'jobs_load_failed': 'आसपास के काम लोड नहीं हो सके।',
    'map_jobs_list_fallback':
        'खुले काम सूची में दिखेंगे; निर्देशांक वाले काम मानचित्र पर दिखेंगे।',
  },
  'te': {
    'apply_for_job': 'ఈ పనికి దరఖాస్తు చేయండి',
    'applying': 'దరఖాస్తు చేస్తోంది…',
    'please_sign_in_apply': 'దరఖాస్తు చేయడానికి లాగిన్ అవ్వండి.',
    'firestore_job_required': 'యాప్‌లో ప్రచురించిన పనికే దరఖాస్తు చేయగలరు.',
    'workers_only_apply': 'కార్మిక ఖాతాలు మాత్రమే దరఖాస్తు చేయగలవు.',
    'only_related_work':
        'ఈ పని మీ నమోదైన విభాగం మరియు నైపుణ్యానికి సంబంధించినది కాదు.',
    'job_closed_apply': 'ఈ పని ఇప్పుడు తెరిచి లేదు.',
    'already_applied': 'మీరు ఇప్పటికే ఈ పనికి దరఖాస్తు చేశారు.',
    'apply_permission_denied': "అనుమతి నిరాకరించబడింది. Worker ఖాతాతో లాగిన్ అయ్యారా, పని ఇంకా తెరిచి ఉందా, మీ విభాగం సరిపోతుందా చూడండి.",
    'apply_failed': 'దరఖాస్తు పంపలేకపోయాం',
    'apply_notification_pending':
        'మీ దరఖాస్తు సేవ్ అయింది, కానీ యజమానికి నోటిఫికేషన్ పంపలేకపోయాం.',
    'nearby_map': 'దగ్గరలోని పనులు మరియు దూరం',
    'next_jobs': 'మీకు దగ్గరలోని ఇతర పనులు',
    'location_permission_needed':
        'దూరం ప్రకారం పనులు చూపడానికి స్థాన అనుమతి ఇవ్వండి.',
    'distance_unavailable': 'దూరం అందుబాటులో లేదు',
    'department_skills_count': 'నైపుణ్యాలు',
    'open_jobs_count': 'తెరిచి ఉన్న పనులు',
    'with_coordinates': 'మ్యాప్ స్థానంతో',
    'within_50_km': '50 కి.మీ. లోపు',
    'jobs_load_failed': 'దగ్గరలోని పనులను లోడ్ చేయలేకపోయాం.',
    'map_jobs_list_fallback': 'తెరిచి ఉన్న పనులు జాబితాలో కనిపిస్తాయి; కోఆర్డినేట్లు ఉన్నవి మ్యాప్‌లో కనిపిస్తాయి.',
  },
  'kn': {
    'apply_for_job': 'ಈ ಕೆಲಸಕ್ಕೆ ಅರ್ಜಿ ಸಲ್ಲಿಸಿ',
    'applying': 'ಅರ್ಜಿ ಸಲ್ಲಿಸಲಾಗುತ್ತಿದೆ…',
    'please_sign_in_apply': 'ಅರ್ಜಿ ಸಲ್ಲಿಸಲು ಲಾಗಿನ್ ಮಾಡಿ.',
    'firestore_job_required':
        'ಆ್ಯಪ್‌ನಲ್ಲಿ ಪ್ರಕಟಿಸಿದ ಕೆಲಸಕ್ಕೆ ಮಾತ್ರ ಅರ್ಜಿ ಸಲ್ಲಿಸಬಹುದು.',
    'workers_only_apply': 'ಕಾರ್ಮಿಕ ಖಾತೆಗಳು ಮಾತ್ರ ಅರ್ಜಿ ಸಲ್ಲಿಸಬಹುದು.',
    'only_related_work':
        'ಈ ಕೆಲಸ ನಿಮ್ಮ ನೋಂದಾಯಿತ ವಿಭಾಗ ಮತ್ತು ಕೌಶಲ್ಯಕ್ಕೆ ಹೊಂದಿಕೆಯಾಗುವುದಿಲ್ಲ.',
    'job_closed_apply': 'ಈ ಕೆಲಸ ಈಗ ತೆರೆದಿಲ್ಲ.',
    'already_applied': 'ನೀವು ಈಗಾಗಲೇ ಈ ಕೆಲಸಕ್ಕೆ ಅರ್ಜಿ ಸಲ್ಲಿಸಿದ್ದೀರಿ.',
    'apply_permission_denied': "ಅನುಮತಿ ನಿರಾಕರಿಸಲಾಗಿದೆ. Worker ಖಾತೆಯಲ್ಲಿ ಲಾಗಿನ್ ಆಗಿದ್ದೀರಾ, ಕೆಲಸ ಇನ್ನೂ ತೆರೆದಿದೆಯೇ ಮತ್ತು ನಿಮ್ಮ ವಿಭಾಗ ಹೊಂದುತ್ತದೆಯೇ ಪರಿಶೀಲಿಸಿ.",
    'apply_failed': 'ಅರ್ಜಿಯನ್ನು ಕಳುಹಿಸಲಾಗಲಿಲ್ಲ',
    'apply_notification_pending':
        'ನಿಮ್ಮ ಅರ್ಜಿ ಉಳಿಸಲಾಗಿದೆ, ಆದರೆ ಉದ್ಯೋಗದಾತರಿಗೆ ಅಧಿಸೂಚನೆ ಕಳುಹಿಸಲಾಗಲಿಲ್ಲ.',
    'nearby_map': 'ಹತ್ತಿರದ ಕೆಲಸಗಳು ಮತ್ತು ದೂರ',
    'next_jobs': 'ನಿಮ್ಮ ಹತ್ತಿರದ ಇತರ ತೆರೆದ ಕೆಲಸಗಳು',
    'location_permission_needed': 'ದೂರದಂತೆ ಕೆಲಸ ತೋರಿಸಲು ಸ್ಥಳ ಅನುಮತಿ ನೀಡಿ.',
    'distance_unavailable': 'ದೂರ ಲಭ್ಯವಿಲ್ಲ',
    'department_skills_count': 'ಕೌಶಲ್ಯಗಳು',
    'open_jobs_count': 'ತೆರೆದ ಕೆಲಸಗಳು',
    'with_coordinates': 'ನಕ್ಷೆ ಸ್ಥಳದೊಂದಿಗೆ',
    'within_50_km': '50 ಕಿ.ಮೀ. ಒಳಗೆ',
    'jobs_load_failed': 'ಹತ್ತಿರದ ಕೆಲಸಗಳನ್ನು ಲೋಡ್ ಮಾಡಲಾಗಲಿಲ್ಲ.',
    'map_jobs_list_fallback': 'ತೆರೆದ ಕೆಲಸಗಳು ಪಟ್ಟಿಯಲ್ಲಿ ಕಾಣುತ್ತವೆ; ನಿರ್ದೇಶಾಂಕಗಳಿರುವ ಕೆಲಸಗಳು ನಕ್ಷೆಯಲ್ಲಿ ಕಾಣುತ್ತವೆ.',
  },
  'ml': {
    'apply_for_job': 'ഈ ജോലിക്ക് അപേക്ഷിക്കുക',
    'applying': 'അപേക്ഷിക്കുന്നു…',
    'please_sign_in_apply': 'അപേക്ഷിക്കാൻ ലോഗിൻ ചെയ്യുക.',
    'firestore_job_required':
        'ആപ്പിൽ പ്രസിദ്ധീകരിച്ച ജോലിക്ക് മാത്രമേ അപേക്ഷിക്കാനാകൂ.',
    'workers_only_apply': 'തൊഴിലാളി അക്കൗണ്ടുകൾക്ക് മാത്രമേ അപേക്ഷിക്കാനാകൂ.',
    'only_related_work':
        'ഈ ജോലി നിങ്ങൾ രജിസ്റ്റർ ചെയ്ത വിഭാഗത്തിനും കഴിവിനും അനുയോജ്യമല്ല.',
    'job_closed_apply': 'ഈ ജോലി ഇപ്പോൾ തുറന്നിട്ടില്ല.',
    'already_applied': 'നിങ്ങൾ ഈ ജോലിക്ക് ഇതിനകം അപേക്ഷിച്ചിട്ടുണ്ട്.',
    'apply_permission_denied': "അനുമതി നിഷേധിച്ചു. Worker അക്കൗണ്ടിൽ ലോഗിൻ ചെയ്തിട്ടുണ്ടോ, ജോലി തുറന്നിട്ടുണ്ടോ, നിങ്ങളുടെ വിഭാഗം പൊരുത്തപ്പെടുന്നുണ്ടോ പരിശോധിക്കുക.",
    'apply_failed': 'അപേക്ഷ അയയ്ക്കാനായില്ല',
    'apply_notification_pending': 'നിങ്ങളുടെ അപേക്ഷ സേവ് ചെയ്തു, പക്ഷേ തൊഴിൽദാതാവിന് അറിയിപ്പ് അയയ്ക്കാനായില്ല.',
    'nearby_map': 'സമീപ ജോലികളും ദൂരവും',
    'next_jobs': 'നിങ്ങൾക്ക് സമീപമുള്ള മറ്റ് തുറന്ന ജോലികൾ',
    'location_permission_needed':
        'ദൂരം അനുസരിച്ച് ജോലികൾ കാണാൻ ലൊക്കേഷൻ അനുമതി നൽകുക.',
    'distance_unavailable': 'ദൂരം ലഭ്യമല്ല',
    'department_skills_count': 'കഴിവുകൾ',
    'open_jobs_count': 'തുറന്ന ജോലികൾ',
    'with_coordinates': 'മാപ്പ് സ്ഥലങ്ങളോടെ',
    'within_50_km': '50 കി.മീ. പരിധിയിൽ',
    'jobs_load_failed': 'സമീപ ജോലികൾ ലോഡ് ചെയ്യാനായില്ല.',
    'map_jobs_list_fallback':
        'തുറന്ന ജോലികൾ പട്ടികയിൽ കാണാം; കോഓർഡിനേറ്റുകളുള്ളവ മാപ്പിൽ കാണാം.',
  },
};

String workerTr(String key) =>
    workerUiTranslations[appLanguage.value]?[key] ??
    workerUiTranslations['en']![key]!;

const Map<String, Map<String, String>> voiceAssistantTranslations = {
  'en': {
    'voice_assistant': 'Voice assistant',
    'voice_assistant_hint': 'Tap the microphone and say what you want to open.',
    'voice_listening': 'Listening…',
    'voice_try_commands': 'Try a command',
    'voice_not_understood':
        'I could not match that command. Try one of the suggestions.',
    'voice_speech_unavailable': 'Speech recognition is unavailable. Check microphone permission or use the buttons below.',
    'voice_opening': 'Opening the requested section.',
    'voice_safe_actions': 'For posting, applying, accepting or paying, review the details and confirm in the app.',
    'voice_hear_help': 'Hear what I can do',
    'voice_help_worker': 'For a worker, I can open job search, applications, nearby jobs, payments, availability, live location sharing and profile. I will not apply or share your location without your action.',
    'voice_help_employer': 'For an employer, I can open job posting, your jobs, applicants, departments, worker search and notifications. Review and confirm job posts and applicant decisions in the app.',
    'voice_help_customer': 'For a customer, I can open worker search, departments and your profile. Review the worker details before sending a contact request.',
    'voice_audio_unavailable': 'Audio playback is unavailable on this device. The explanation is shown on screen.',
  },
  'ta': {
    'voice_assistant': 'குரல் உதவியாளர்',
    'voice_assistant_hint':
        'மைக்ரோஃபோனைத் தொட்டு, திறக்க வேண்டிய பகுதியைச் சொல்லுங்கள்.',
    'voice_listening': 'கேட்கிறது…',
    'voice_try_commands': 'இந்தக் கட்டளைகளை முயற்சிக்கவும்',
    'voice_not_understood': 'கட்டளையைப் புரிந்துகொள்ள முடியவில்லை. கீழே உள்ள பரிந்துரைகளை முயற்சிக்கவும்.',
    'voice_speech_unavailable': 'குரல் அறிதல் கிடைக்கவில்லை. மைக்ரோஃபோன் அனுமதியைச் சரிபார்க்கவும் அல்லது கீழே உள்ள பொத்தான்களைப் பயன்படுத்தவும்.',
    'voice_opening': 'நீங்கள் கேட்ட பகுதியைத் திறக்கிறேன்.',
    'voice_safe_actions': 'வேலை பதிவு, விண்ணப்பம், ஏற்றுக்கொள்வது அல்லது பணம் செலுத்துவது போன்றவற்றைச் செயல்படுத்தும் முன் விவரங்களைப் பார்த்து app-ல் உறுதிப்படுத்துங்கள்.',
    'voice_hear_help': 'என்ன செய்ய முடியும் என்று கேளுங்கள்',
    'voice_help_worker': 'தொழிலாளராக, வேலை தேடல், என் விண்ணப்பங்கள், அருகிலுள்ள வேலைகள், வருமானம், வேலை கிடைக்கும் நிலை, நேரடி இருப்பிடப் பகிர்வு மற்றும் சுயவிவரத்தைத் திறக்க முடியும். உங்கள் அனுமதியின்றி விண்ணப்பிக்கவோ இருப்பிடத்தைப் பகிரவோ மாட்டேன்.',
    'voice_help_employer': 'வேலை வழங்குநராக, வேலை பதிவு, என் வேலைகள், விண்ணப்பதாரர்கள், துறைகள், தொழிலாளர் தேடல் மற்றும் அறிவிப்புகளைத் திறக்க முடியும். வேலை விவரங்களையும் விண்ணப்ப முடிவுகளையும் app-ல் சரிபார்த்து உறுதிப்படுத்துங்கள்.',
    'voice_help_customer': 'வாடிக்கையாளராக, தொழிலாளர் தேடல், துறைகள் மற்றும் சுயவிவரத்தைத் திறக்க முடியும். தொடர்பு கோரிக்கை அனுப்பும் முன் தொழிலாளர் விவரங்களைச் சரிபார்க்கவும்.',
    'voice_audio_unavailable': 'இந்த சாதனத்தில் குரல் வாசிப்பு கிடைக்கவில்லை. விளக்கம் திரையில் உள்ளது.',
  },
  'hi': {
    'voice_assistant': 'वॉइस सहायक',
    'voice_assistant_hint': 'माइक दबाएँ और बताएं कि कौन-सा भाग खोलना है।',
    'voice_listening': 'सुन रहा है…',
    'voice_try_commands': 'इन आदेशों को आज़माएँ',
    'voice_not_understood': 'आदेश समझ नहीं आया। नीचे दिए सुझाव आज़माएँ।',
    'voice_speech_unavailable': 'वॉइस पहचान उपलब्ध नहीं है। माइक्रोफ़ोन अनुमति जाँचें या नीचे के बटन इस्तेमाल करें।',
    'voice_opening': 'आपका चुना हुआ भाग खोल रहा हूँ।',
    'voice_safe_actions': 'काम पोस्ट करने, आवेदन करने, स्वीकार करने या भुगतान से पहले विवरण देखें और ऐप में पुष्टि करें।',
    'voice_hear_help': 'मैं क्या कर सकता हूँ, सुनें',
    'voice_help_worker': 'कामगार के रूप में मैं काम खोज, आवेदन, नज़दीकी काम, भुगतान, उपलब्धता, लाइव लोकेशन साझा करना और प्रोफ़ाइल खोल सकता हूँ। आपकी कार्रवाई के बिना आवेदन या लोकेशन साझा नहीं करूँगा।',
    'voice_help_employer': 'नियोक्ता के रूप में मैं काम पोस्ट करना, आपके काम, आवेदक, विभाग, कामगार खोज और सूचनाएँ खोल सकता हूँ। पोस्ट और आवेदक के फैसले ऐप में जाँचकर पुष्टि करें।',
    'voice_help_customer': 'ग्राहक के रूप में मैं कामगार खोज, विभाग और आपकी प्रोफ़ाइल खोल सकता हूँ। संपर्क अनुरोध भेजने से पहले कामगार का विवरण जाँचें।',
    'voice_audio_unavailable':
        'इस डिवाइस पर आवाज़ में पढ़ना उपलब्ध नहीं है। विवरण स्क्रीन पर है।',
  },
  'te': {
    'voice_assistant': 'వాయిస్ సహాయకుడు',
    'voice_assistant_hint': 'మైక్‌ను నొక్కి, ఏ విభాగం తెరవాలో చెప్పండి.',
    'voice_listening': 'వింటోంది…',
    'voice_try_commands': 'ఈ ఆదేశాలను ప్రయత్నించండి',
    'voice_not_understood':
        'ఆ ఆదేశాన్ని గుర్తించలేకపోయాను. క్రింది సూచనలను ప్రయత్నించండి.',
    'voice_speech_unavailable': 'వాయిస్ గుర్తింపు అందుబాటులో లేదు. మైక్రోఫోన్ అనుమతిని తనిఖీ చేయండి లేదా క్రింది బటన్లను వాడండి.',
    'voice_opening': 'మీరు అడిగిన విభాగాన్ని తెరుస్తున్నాను.',
    'voice_safe_actions': 'పని పోస్ట్ చేయడం, దరఖాస్తు, అంగీకారం లేదా చెల్లింపుకు ముందు వివరాలు చూసి యాప్‌లో నిర్ధారించండి.',
    'voice_hear_help': 'నేను ఏమి చేయగలనో వినండి',
    'voice_help_worker': 'కార్మికుడిగా, పని శోధన, దరఖాస్తులు, దగ్గర పనులు, చెల్లింపులు, అందుబాటు, ప్రత్యక్ష స్థల భాగస్వామ్యం, ప్రొఫైల్ తెరవగలను. మీ చర్య లేకుండా దరఖాస్తు చేయను లేదా స్థలాన్ని పంచుకోను.',
    'voice_help_employer': 'యజమానిగా, పని పోస్ట్, మీ పనులు, దరఖాస్తుదారులు, విభాగాలు, కార్మికుల శోధన, నోటిఫికేషన్లు తెరవగలను. పని వివరాలు, దరఖాస్తుదారుల నిర్ణయాలు యాప్‌లో నిర్ధారించండి.',
    'voice_help_customer': 'కస్టమర్‌గా, కార్మికుల శోధన, విభాగాలు, మీ ప్రొఫైల్ తెరవగలను. సంప్రదింపు అభ్యర్థన పంపే ముందు కార్మికుడి వివరాలు చూడండి.',
    'voice_audio_unavailable':
        'ఈ పరికరంలో వాయిస్ చదవడం అందుబాటులో లేదు. వివరణ తెరపై ఉంది.',
  },
  'kn': {
    'voice_assistant': 'ಧ್ವನಿ ಸಹಾಯಕ',
    'voice_assistant_hint': 'ಮೈಕ್ ಒತ್ತಿ, ಯಾವ ವಿಭಾಗ ತೆರೆಯಬೇಕು ಎಂದು ಹೇಳಿ.',
    'voice_listening': 'ಕೇಳುತ್ತಿದೆ…',
    'voice_try_commands': 'ಈ ಆಜ್ಞೆಗಳನ್ನು ಪ್ರಯತ್ನಿಸಿ',
    'voice_not_understood':
        'ಆ ಆಜ್ಞೆಯನ್ನು ಗುರುತಿಸಲಾಗಲಿಲ್ಲ. ಕೆಳಗಿನ ಸಲಹೆಗಳನ್ನು ಪ್ರಯತ್ನಿಸಿ.',
    'voice_speech_unavailable': 'ಧ್ವನಿ ಗುರುತಿಸುವಿಕೆ ಲಭ್ಯವಿಲ್ಲ. ಮೈಕ್ರೊಫೋನ್ ಅನುಮತಿ ಪರಿಶೀಲಿಸಿ ಅಥವಾ ಕೆಳಗಿನ ಬಟನ್ ಬಳಸಿ.',
    'voice_opening': 'ನೀವು ಕೇಳಿದ ವಿಭಾಗ ತೆರೆಯುತ್ತಿದೆ.',
    'voice_safe_actions': 'ಕೆಲಸ ಪೋಸ್ಟ್, ಅರ್ಜಿ, ಸ್ವೀಕಾರ ಅಥವಾ ಪಾವತಿಗೆ ಮೊದಲು ವಿವರಗಳನ್ನು ಪರಿಶೀಲಿಸಿ ಆ್ಯಪ್‌ನಲ್ಲಿ ದೃಢೀಕರಿಸಿ.',
    'voice_hear_help': 'ನಾನು ಏನು ಮಾಡಬಲ್ಲೆ ಎಂದು ಕೇಳಿ',
    'voice_help_worker': 'ಕಾರ್ಮಿಕನಾಗಿ, ಕೆಲಸ ಹುಡುಕಾಟ, ಅರ್ಜಿಗಳು, ಹತ್ತಿರದ ಕೆಲಸಗಳು, ಪಾವತಿಗಳು, ಲಭ್ಯತೆ, ನೇರ ಸ್ಥಳ ಹಂಚಿಕೆ ಮತ್ತು ಪ್ರೊಫೈಲ್ ತೆರೆಯಬಲ್ಲೆ. ನಿಮ್ಮ ಕ್ರಮವಿಲ್ಲದೆ ಅರ್ಜಿ ಸಲ್ಲಿಸುವುದಿಲ್ಲ ಅಥವಾ ಸ್ಥಳ ಹಂಚುವುದಿಲ್ಲ.',
    'voice_help_employer': 'ಉದ್ಯೋಗದಾತನಾಗಿ, ಕೆಲಸ ಪೋಸ್ಟ್, ನಿಮ್ಮ ಕೆಲಸಗಳು, ಅರ್ಜಿದಾರರು, ವಿಭಾಗಗಳು, ಕಾರ್ಮಿಕರ ಹುಡುಕಾಟ ಮತ್ತು ಅಧಿಸೂಚನೆ ತೆರೆಯಬಲ್ಲೆ. ಕೆಲಸದ ವಿವರ ಮತ್ತು ಅರ್ಜಿದಾರರ ನಿರ್ಧಾರಗಳನ್ನು ಆ್ಯಪ್‌ನಲ್ಲಿ ಪರಿಶೀಲಿಸಿ ದೃಢೀಕರಿಸಿ.',
    'voice_help_customer': 'ಗ್ರಾಹಕರಾಗಿ, ಕಾರ್ಮಿಕರ ಹುಡುಕಾಟ, ವಿಭಾಗಗಳು ಮತ್ತು ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ತೆರೆಯಬಲ್ಲೆ. ಸಂಪರ್ಕ ಕೋರಿಕೆ ಕಳುಹಿಸುವ ಮೊದಲು ಕಾರ್ಮಿಕರ ವಿವರ ಪರಿಶೀಲಿಸಿ.',
    'voice_audio_unavailable':
        'ಈ ಸಾಧನದಲ್ಲಿ ಧ್ವನಿ ಓದು ಲಭ್ಯವಿಲ್ಲ. ವಿವರಣೆ ಪರದೆಯಲ್ಲಿದೆ.',
  },
  'ml': {
    'voice_assistant': 'വോയ്സ് സഹായി',
    'voice_assistant_hint': 'മൈക്ക് അമർത്തി തുറക്കേണ്ട വിഭാഗം പറയുക.',
    'voice_listening': 'കേൾക്കുന്നു…',
    'voice_try_commands': 'ഈ നിർദ്ദേശങ്ങൾ പരീക്ഷിക്കുക',
    'voice_not_understood':
        'നിർദ്ദേശം മനസ്സിലായില്ല. താഴെയുള്ള നിർദ്ദേശങ്ങൾ പരീക്ഷിക്കുക.',
    'voice_speech_unavailable': 'വോയ്സ് തിരിച്ചറിയൽ ലഭ്യമല്ല. മൈക്രോഫോൺ അനുമതി പരിശോധിക്കുക അല്ലെങ്കിൽ താഴെയുള്ള ബട്ടണുകൾ ഉപയോഗിക്കുക.',
    'voice_opening': 'നിങ്ങൾ ആവശ്യപ്പെട്ട വിഭാഗം തുറക്കുന്നു.',
    'voice_safe_actions': 'ജോലി പോസ്റ്റ് ചെയ്യുക, അപേക്ഷിക്കുക, സ്വീകരിക്കുക, പണം നൽകുക എന്നിവയ്ക്ക് മുമ്പ് വിശദാംശങ്ങൾ പരിശോധിച്ച് ആപ്പിൽ സ്ഥിരീകരിക്കുക.',
    'voice_hear_help': 'എനിക്ക് എന്ത് ചെയ്യാനാകുമെന്ന് കേൾക്കുക',
    'voice_help_worker': 'തൊഴിലാളിയായി ജോലി തിരയൽ, അപേക്ഷകൾ, സമീപ ജോലികൾ, പേയ്‌മെന്റുകൾ, ലഭ്യത, തത്സമയ ലൊക്കേഷൻ പങ്കിടൽ, പ്രൊഫൈൽ എന്നിവ തുറക്കാം. നിങ്ങളുടെ നടപടി കൂടാതെ അപേക്ഷിക്കുകയോ ലൊക്കേഷൻ പങ്കിടുകയോ ചെയ്യില്ല.',
    'voice_help_employer': 'തൊഴിൽദാതാവായി ജോലി പോസ്റ്റ്, നിങ്ങളുടെ ജോലികൾ, അപേക്ഷകർ, വിഭാഗങ്ങൾ, തൊഴിലാളി തിരയൽ, അറിയിപ്പുകൾ എന്നിവ തുറക്കാം. ജോലി വിവരങ്ങളും അപേക്ഷക തീരുമാനങ്ങളും ആപ്പിൽ പരിശോധിച്ച് സ്ഥിരീകരിക്കുക.',
    'voice_help_customer': 'ഉപഭോക്താവായി തൊഴിലാളി തിരയൽ, വിഭാഗങ്ങൾ, പ്രൊഫൈൽ എന്നിവ തുറക്കാം. ബന്ധപ്പെടാനുള്ള അഭ്യർത്ഥന അയയ്ക്കുന്നതിന് മുമ്പ് തൊഴിലാളിയുടെ വിവരങ്ങൾ പരിശോധിക്കുക.',
    'voice_audio_unavailable':
        'ഈ ഉപകരണത്തിൽ ശബ്ദ വായന ലഭ്യമല്ല. വിശദീകരണം സ്ക്രീനിൽ കാണാം.',
  },
};

String voiceAssistantTr(String key) =>
    voiceAssistantTranslations[appLanguage.value]?[key] ??
    voiceAssistantTranslations['en']![key]!;

bool workerJobMatchesProfile(
  Map<String, dynamic> job, {
  required String? department,
  required String? skill,
}) {
  final workerDepartment = department?.trim().toLowerCase() ?? '';
  final workerSkill = skill?.trim().toLowerCase() ?? '';
  final jobDepartment =
      job['department']?.toString().trim().toLowerCase() ?? '';
  final jobSkill = job['skill']?.toString().trim().toLowerCase() ?? '';
  if (workerDepartment.isNotEmpty) {
    // Older posts without a department can still match by the worker's exact skill.
    return jobDepartment.isNotEmpty
        ? jobDepartment == workerDepartment
        : workerSkill.isNotEmpty && jobSkill == workerSkill;
  }
  return workerSkill.isNotEmpty && jobSkill == workerSkill;
}

String catalogLabel(Object? value) {
  final label = value?.toString() ?? '';
  return catalogTranslations[appLanguage.value]?[label] ?? label;
}

const Map<String, String> appLanguageNames = {
  'ta': 'தமிழ்',
  'en': 'English',
  'hi': 'हिन्दी',
  'te': 'తెలుగు',
  'kn': 'ಕನ್ನಡ',
  'ml': 'മലയാളം',
};

class LanguagePickerButton extends StatelessWidget {
  final Color foregroundColor;
  const LanguagePickerButton({super.key, this.foregroundColor = navy});

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: () => chooseAppLanguage(context),
    icon: Icon(Icons.translate, color: foregroundColor),
    label: Text(
      appLanguageNames[appLanguage.value] ?? 'English',
      style: TextStyle(color: foregroundColor),
    ),
    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
  );
}

class MrCoolieBrandMark extends StatelessWidget {
  final double size;
  const MrCoolieBrandMark({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: navy,
      borderRadius: BorderRadius.circular(size * 0.28),
      border: Border.all(color: orange, width: size * 0.045),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.handyman, color: Colors.white, size: size * 0.58),
        Positioned(
          right: size * 0.08,
          bottom: size * 0.08,
          child: Container(
            width: size * 0.2,
            height: size * 0.2,
            decoration: const BoxDecoration(
              color: orange,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    ),
  );
}

mixin LanguageAwareState<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    appLanguage.addListener(_refreshForLanguageChange);
  }

  void _refreshForLanguageChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    appLanguage.removeListener(_refreshForLanguageChange);
    super.dispose();
  }
}

Future<void> chooseAppLanguage(BuildContext context) async {
  final selected = await showDialog<String>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: Text(tr('language')),
      children: appLanguageNames.entries
          .map(
            (e) => SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, e.key),
              child: Row(
                children: [
                  if (appLanguage.value == e.key)
                    const Icon(Icons.check_circle, color: green),
                  if (appLanguage.value == e.key) const SizedBox(width: 8),
                  Text(e.value),
                ],
              ),
            ),
          )
          .toList(),
    ),
  );
  if (selected != null) {
    appLanguage.value = selected;
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('preferredLanguage', selected);
    } catch (_) {
      // Keep the in-memory selection even if local storage is unavailable.
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'preferredLanguage': selected});
      } catch (_) {}
    }
  }
}

String currentUserDisplayName() {
  final user = FirebaseAuth.instance.currentUser;
  final displayName = user?.displayName?.trim();

  if (displayName != null && displayName.isNotEmpty) {
    return displayName;
  }

  final email = user?.email?.trim();
  if (email != null && email.isNotEmpty && email.contains('@')) {
    final prefix = email.split('@').first.trim();
    if (prefix.isNotEmpty) return prefix;
  }

  return 'User';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final savedLanguage = preferences.getString('preferredLanguage');
  if (savedLanguage != null && appTranslations.containsKey(savedLanguage)) {
    appLanguage.value = savedLanguage;
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Enable Firestore cache on web; native platforms already use persistent cache.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  runApp(const MrCoolieApp());
}

Future<Position> requestCurrentDevicePosition() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    throw StateError(
      'Turn on Location Services on your device, then try again.',
    );
  }
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied)
    permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied)
    throw StateError('Location permission was denied.');
  if (permission == LocationPermission.deniedForever) {
    throw StateError(
      'Location permission is blocked. Enable it in system settings to continue.',
    );
  }
  return Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
  );
}
// ============================================================
// APP
// ============================================================

class MrCoolieApp extends StatelessWidget {
  const MrCoolieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguage,
      builder: (context, language, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mr. கூலி',
        locale: Locale(language),
        supportedLocales: const [
          Locale('ta'),
          Locale('en'),
          Locale('hi'),
          Locale('te'),
          Locale('kn'),
          Locale('ml'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF8F4EC),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFF28C28),
            primary: const Color(0xFFF28C28),
          ),
          fontFamily: 'Roboto',
        ),
        home: const LoginScreen(),
      ),
    );
  }
}

// ============================================================
// COLORS
// ============================================================

const Color navy = Color(0xFF102A43);
const Color darkNavy = Color(0xFF0B1F33);
const Color orange = Color(0xFFF28C28);
const Color cream = Color(0xFFF8F4EC);
const Color lightOrange = Color(0xFFFFE8CC);
const Color green = Color(0xFF2E7D32);
const Color red = Color(0xFFC62828);
const Color greyText = Color(0xFF667085);

// ============================================================
// DATA
// ============================================================

final List<Map<String, dynamic>> departments = [
  {
    'name': 'Construction & Civil',
    'icon': Icons.construction,
    'skills': [
      'Mason',
      'Construction Helper',
      'Shuttering Worker',
      'Bar Bender',
      'Tile Worker',
      'Concrete Worker',
    ],
  },
  {
    'name': 'Electrical',
    'icon': Icons.electrical_services,
    'skills': [
      'Electrician',
      'Wireman',
      'Electrical Technician',
      'Electrical Helper',
      'Motor Technician',
    ],
  },
  {
    'name': 'Plumbing & Sanitary',
    'icon': Icons.plumbing,
    'skills': [
      'Plumber',
      'Pipe Fitter',
      'Bathroom Fitting Worker',
      'Water Tank Worker',
    ],
  },
  {
    'name': 'Carpentry & Wood Work',
    'icon': Icons.handyman,
    'skills': [
      'Carpenter',
      'Furniture Worker',
      'Door/Window Worker',
      'Wood Polishing Worker',
    ],
  },
  {
    'name': 'Metal / Iron Work',
    'icon': Icons.hardware,
    'skills': [
      'Iron Worker',
      'Welder',
      'Grill Worker',
      'Gate Worker',
      'Steel Fabricator',
      'Sheet Metal Worker',
    ],
  },
  {
    'name': 'Agriculture / Farming',
    'icon': Icons.agriculture,
    'skills': [
      'Farm Worker',
      'Harvesting Worker',
      'Irrigation Worker',
      'Tractor Operator',
      'Agricultural Machine Operator',
      'Field Worker',
    ],
  },
  {
    'name': 'Automobile',
    'icon': Icons.car_repair,
    'skills': [
      'Two-Wheeler Mechanic',
      'Auto Mechanic',
      'Tyre Worker',
      'Battery Technician',
      'Vehicle Washing Worker',
    ],
  },
  {
    'name': 'Home Services',
    'icon': Icons.home_repair_service,
    'skills': [
      'House Cleaner',
      'Cook',
      'Gardener',
      'Ironing Worker',
      'Home Maintenance Worker',
    ],
  },
  {
    'name': 'Cleaning & Maintenance',
    'icon': Icons.cleaning_services,
    'skills': [
      'House Cleaner',
      'Office Cleaner',
      'Shop Cleaner',
      'Building Maintenance Worker',
    ],
  },
  {
    'name': 'Shops & Commercial',
    'icon': Icons.store,
    'skills': [
      'Shop Helper',
      'Sales Assistant',
      'Billing Assistant',
      'Stock Worker',
      'Packing Worker',
    ],
  },
  {
    'name': 'Hotel / Food Services',
    'icon': Icons.restaurant,
    'skills': [
      'Cook',
      'Kitchen Helper',
      'Server',
      'Catering Worker',
      'Tea/Coffee Worker',
    ],
  },
  {
    'name': 'Transport / Loading',
    'icon': Icons.local_shipping,
    'skills': [
      'Loading Worker',
      'Unloading Worker',
      'Lorry Helper',
      'Delivery Worker',
      'Warehouse Worker',
    ],
  },
  {
    'name': 'Printing / Offset',
    'icon': Icons.print,
    'skills': [
      'Offset Machine Operator',
      'Printing Helper',
      'Binding Worker',
      'Cutting Worker',
      'Printing Packing Worker',
    ],
  },
  {
    'name': 'Packaging',
    'icon': Icons.inventory_2,
    'skills': [
      'Packing Worker',
      'Labeling Worker',
      'Sorting Worker',
      'Warehouse Packing Worker',
    ],
  },
  {
    'name': 'Fireworks Industry',
    'icon': Icons.celebration,
    'skills': [
      'Production Worker',
      'Packing Worker',
      'Quality Worker',
      'General Factory Worker',
    ],
  },
  {
    'name': 'Match Industry',
    'icon': Icons.factory,
    'skills': [
      'Production Worker',
      'Packing Worker',
      'Machine Operator',
      'Quality Worker',
    ],
  },
  {
    'name': 'Tailoring & Clothing',
    'icon': Icons.checkroom,
    'skills': [
      'Tailor',
      'Stitching Worker',
      'Embroidery Worker',
      'Cutting Worker',
      'Alteration Worker',
    ],
  },
  {
    'name': 'Electronics / Mobile',
    'icon': Icons.phone_android,
    'skills': [
      'Mobile Technician',
      'Electronics Repair Worker',
      'TV Repair Worker',
      'Computer Technician',
      'CCTV Technician',
    ],
  },
  {
    'name': 'Gardening & Outdoor',
    'icon': Icons.grass,
    'skills': [
      'Gardener',
      'Tree Worker',
      'Grass Cutting Worker',
      'Landscaping Worker',
      'Garden Maintenance Worker',
    ],
  },
  {
    'name': 'General Local Services',
    'icon': Icons.people,
    'skills': [
      'General Helper',
      'Daily Wage Worker',
      'Event Helper',
      'Moving Helper',
      'Temporary Worker',
    ],
  },
];

final List<Map<String, dynamic>> demoJobs = [
  {
    'title': 'House Wiring Work',
    'department': 'Electrical',
    'skill': 'Electrician',
    'location': 'Sivakasi',
    'payment': 800,
    'duration': '1 Day',
    'employer': 'Ravi',
    'description':
        'Need an electrician for house wiring and switch installation.',
  },
  {
    'title': 'House Construction Helper',
    'department': 'Construction & Civil',
    'skill': 'Construction Helper',
    'location': 'Virudhunagar',
    'payment': 700,
    'duration': '1 Day',
    'employer': 'Kumar',
    'description':
        'Construction helper required for residential building work.',
  },
  {
    'title': 'Farm Harvesting Worker',
    'department': 'Agriculture / Farming',
    'skill': 'Harvesting Worker',
    'location': 'Sattur',
    'payment': 900,
    'duration': '2 Days',
    'employer': 'Selvam',
    'description': 'Workers required for harvesting and field activities.',
  },
  {
    'title': 'Plumbing Repair',
    'department': 'Plumbing & Sanitary',
    'skill': 'Plumber',
    'location': 'Sivakasi',
    'payment': 750,
    'duration': '1 Day',
    'employer': 'Arun',
    'description': 'Bathroom and pipeline repair work.',
  },
  {
    'title': 'Offset Printing Helper',
    'department': 'Printing / Offset',
    'skill': 'Printing Helper',
    'location': 'Sivakasi',
    'payment': 650,
    'duration': '1 Day',
    'employer': 'Prakash',
    'description': 'Helper required for offset printing and packing.',
  },
];

// ============================================================
// LOGIN / FIREBASE AUTHENTICATION
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with LanguageAwareState<LoginScreen> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? verificationId;
  ConfirmationResult? webConfirmationResult;
  bool isSubmitting = false;
  bool showPhoneLogin = true;
  bool showOtpField = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String _normalisePhone(String value) {
    var phone = value.trim().replaceAll(RegExp(r'[\s()-]'), '');

    if (phone.startsWith('0')) {
      phone = '+91${phone.substring(1)}';
    } else if (RegExp(r'^\d{10}$').hasMatch(phone)) {
      phone = '+91$phone';
    }

    return phone;
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(phone);
  }

  void _goHome() {
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
      (route) => false,
    );
  }

  Future<void> _sendOtp() async {
    final phone = _normalisePhone(phoneController.text);

    if (!_isValidPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid phone number with country code.'),
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      if (kIsWeb) {
        final languageCode =
            const {
              'ta': 'ta',
              'en': 'en',
              'hi': 'hi',
              'te': 'te',
              'kn': 'kn',
              'ml': 'ml',
            }[appLanguage.value] ??
            'en';
        await FirebaseAuth.instance.setLanguageCode(languageCode);
        webConfirmationResult = await FirebaseAuth.instance
            .signInWithPhoneNumber(phone);
        if (!mounted) return;
        setState(() {
          showOtpField = true;
          isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent. Complete the verification on this page.'),
          ),
        );
        return;
      }

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,

        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            if (mounted) {
              setState(() {
                showOtpField = false;
                isSubmitting = false;
              });
              _goHome();
            }
          } on FirebaseAuthException catch (e) {
            if (mounted) {
              setState(() => isSubmitting = false);
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(_firebaseError(e))));
            }
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;

          setState(() => isSubmitting = false);

          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(_firebaseError(e))));
        },

        codeSent: (String id, int? resendToken) {
          if (!mounted) return;

          setState(() {
            verificationId = id;
            showOtpField = true;
            isSubmitting = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP sent successfully. Check your SMS.'),
            ),
          );
        },

        codeAutoRetrievalTimeout: (String id) {
          verificationId = id;
        },
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() => isSubmitting = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_firebaseError(e))));
    } catch (e) {
      if (!mounted) return;

      setState(() => isSubmitting = false);

      final details = e.toString();
      final message = details.contains('billing-not-enabled')
          ? _billingNotEnabledMessage
          : 'Could not start phone verification: $details';

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _verifyOtp() async {
    final id = verificationId;
    final otp = otpController.text.trim();

    if (kIsWeb ? webConfirmationResult == null : id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please request OTP first.')),
      );
      return;
    }

    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter the 6-digit OTP.')));
      return;
    }

    setState(() => isSubmitting = true);

    try {
      if (kIsWeb) {
        await webConfirmationResult!.confirm(otp);
        webConfirmationResult = null;
      } else {
        final credential = PhoneAuthProvider.credential(
          verificationId: id!,
          smsCode: otp,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }

      if (!mounted) return;

      setState(() => isSubmitting = false);
      _goHome();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() => isSubmitting = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_firebaseError(e))));
    } catch (e) {
      if (!mounted) return;
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not verify OTP: $e')));
    }
  }

  Future<void> _loginWithEmail() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter email and password.')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      setState(() => isSubmitting = false);
      _goHome();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() => isSubmitting = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_firebaseError(e))));
    }
  }

  Future<void> _forgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter your email first.')));
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Check your inbox.'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_firebaseError(e))));
    }
  }

  String _firebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'billing-not-enabled':
      case 'auth/billing-not-enabled':
        return _billingNotEnabledMessage;
      case 'invalid-phone-number':
        return 'Invalid phone number. Use the full country code.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'invalid-verification-code':
        return 'Incorrect OTP. Please check the SMS and try again.';
      case 'session-expired':
        return 'OTP expired. Please request a new OTP.';
      case 'invalid-credential':
        return 'The login details are invalid.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
      case 'invalid-login-credentials':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled in Firebase.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  static const String _billingNotEnabledMessage =
      'Firebase billing is not enabled for phone OTP. Enable billing in Firebase Console; SMS charges may apply.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: const [LanguagePickerButton(foregroundColor: Colors.white)],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const MrCoolieBrandMark(size: 90),

              const SizedBox(height: 20),

              const Text(
                'Mr. கூலி',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Work • Earn • Grow',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),

              const SizedBox(height: 35),

              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('welcome_back'),
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: navy,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      tr('login_continue'),
                      style: TextStyle(color: greyText),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: Text('📱 ${tr('phone_otp')}'),
                            selected: showPhoneLogin,
                            onSelected: isSubmitting
                                ? null
                                : (_) {
                                    setState(() {
                                      showPhoneLogin = true;
                                      showOtpField = false;
                                    });
                                  },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: Text('📧 ${tr('email')}'),
                            selected: !showPhoneLogin,
                            onSelected: isSubmitting
                                ? null
                                : (_) {
                                    setState(() {
                                      showPhoneLogin = false;
                                    });
                                  },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    if (showPhoneLogin) ...[
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        enabled: !isSubmitting && !showOtpField,
                        decoration: InputDecoration(
                          labelText: tr('phone_number'),
                          hintText: '+91 9876543210',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      if (showOtpField)
                        TextField(
                          controller: otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          enabled: !isSubmitting,
                          decoration: InputDecoration(
                            labelText: tr('otp_code'),
                            prefixIcon: const Icon(Icons.sms_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: isSubmitting
                              ? null
                              : showOtpField
                              ? _verifyOtp
                              : _sendOtp,
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  showOtpField
                                      ? tr('verify_login')
                                      : tr('send_otp'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),

                      if (showOtpField)
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            children: [
                              TextButton(
                                onPressed: isSubmitting ? null : _sendOtp,
                                child: Text(tr('resend_otp')),
                              ),
                              TextButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () => setState(() {
                                        showOtpField = false;
                                        verificationId = null;
                                        webConfirmationResult = null;
                                        otpController.clear();
                                      }),
                                child: Text(tr('change_number')),
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          tr('sms_notice'),
                          style: const TextStyle(color: greyText, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ] else ...[
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !isSubmitting,
                        decoration: InputDecoration(
                          labelText: tr('email'),
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        enabled: !isSubmitting,
                        decoration: InputDecoration(
                          labelText: tr('password'),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isSubmitting ? null : _forgotPassword,
                          child: Text(tr('forgot_password')),
                        ),
                      ),

                      const SizedBox(height: 5),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: isSubmitting ? null : _loginWithEmail,
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  tr('login'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 15),

                    Center(
                      child: TextButton(
                        onPressed: isSubmitting
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );
                              },
                        child: Text(
                          tr('new_user_register'),
                          style: TextStyle(color: navy),
                        ),
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

// ============================================================
// REGISTER WITH FIREBASE EMAIL/PASSWORD
// ============================================================

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with LanguageAwareState<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final locationController = TextEditingController();

  String selectedRole = 'worker';
  String? selectedWorkerDepartment;
  String? selectedWorkerSkill;
  bool isSubmitting = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    final location = locationController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('complete_required_fields'))));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(tr('passwords_mismatch'))));
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password should be at least 6 characters.'),
        ),
      );
      return;
    }

    if (selectedRole == 'worker' &&
        (location.isEmpty ||
            selectedWorkerDepartment == null ||
            selectedWorkerSkill == null)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(tr('worker_profile_required'))));
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await credential.user?.updateDisplayName(name);
      final uid = credential.user!.uid;
      final profile = <String, dynamic>{
        'uid': uid,
        'name': name,
        'email': email,
        'role': selectedRole,
        'location': location,
        'department': selectedWorkerDepartment,
        'skill': selectedWorkerSkill,
        'preferredLanguage': appLanguage.value,
        'createdAt': FieldValue.serverTimestamp(),
      };
      final batch = FirebaseFirestore.instance.batch();
      batch.set(
        FirebaseFirestore.instance.collection('users').doc(uid),
        profile,
      );
      if (selectedRole == 'worker') {
        batch.set(
          FirebaseFirestore.instance.collection('publicWorkers').doc(uid),
          {
            'uid': uid,
            'name': name,
            'location': location,
            'department': selectedWorkerDepartment ?? '',
            'skill': selectedWorkerSkill ?? '',
            'available': true,
            'preferredLanguage': appLanguage.value,
            'createdAt': FieldValue.serverTimestamp(),
          },
        );
      }
      await batch.commit();

      if (!mounted) return;

      setState(() => isSubmitting = false);

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(tr('account_created')),
          content: Text(tr('registration_success')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(tr('continue')),
            ),
          ],
        ),
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() => isSubmitting = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_firebaseRegisterError(e))));
    } catch (e) {
      if (!mounted) return;
      setState(() => isSubmitting = false);
      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
          (_) => false,
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Registration failed: $e')));
      }
    }
  }

  String _firebaseRegisterError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password authentication is not enabled in Firebase.';
      default:
        return e.message ?? 'Registration failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: Text(tr('create_account')),
        actions: const [LanguagePickerButton(foregroundColor: Colors.white)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 15),

            const Icon(Icons.person_add, size: 70, color: orange),

            const SizedBox(height: 15),

            Text(
              tr('join_coolie'),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: nameController,
              enabled: !isSubmitting,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: tr('full_name'),
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: emailController,
              enabled: !isSubmitting,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: tr('email_address'),
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: selectedRole,
              decoration: InputDecoration(
                labelText: tr('account_type'),
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: 'worker',
                  child: Text(tr('worker_role')),
                ),
                DropdownMenuItem(
                  value: 'employer',
                  child: Text(tr('employer_role')),
                ),
                DropdownMenuItem(
                  value: 'customer',
                  child: Text(tr('customer_find_workers')),
                ),
              ],
              onChanged: isSubmitting
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => selectedRole = value);
                      }
                    },
            ),

            if (selectedRole == 'worker') ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedWorkerDepartment,
                decoration: InputDecoration(
                  labelText: tr('department_label'),
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: departments
                    .map(
                      (d) => DropdownMenuItem<String>(
                        value: d['name'] as String,
                        child: Text(catalogLabel(d['name'])),
                      ),
                    )
                    .toList(),
                onChanged: isSubmitting
                    ? null
                    : (value) => setState(() {
                        selectedWorkerDepartment = value;
                        selectedWorkerSkill = null;
                      }),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedWorkerSkill,
                decoration: InputDecoration(
                  labelText: tr('skill_label'),
                  prefixIcon: const Icon(Icons.handyman_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: departments
                    .where((d) => d['name'] == selectedWorkerDepartment)
                    .expand(
                      (d) => List<String>.from(d['skills'] as List).map(
                        (skill) => DropdownMenuItem<String>(
                          value: skill,
                          child: Text(catalogLabel(skill)),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: selectedWorkerDepartment == null || isSubmitting
                    ? null
                    : (value) => setState(() => selectedWorkerSkill = value),
              ),
            ],

            const SizedBox(height: 16),
            TextField(
              controller: locationController,
              enabled: !isSubmitting,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: '${tr('location_label')} *',
                hintText: tr('location_hint'),
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: passwordController,
              enabled: !isSubmitting,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                labelText: tr('password_label'),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                  icon: Icon(
                    obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: confirmPasswordController,
              enabled: !isSubmitting,
              obscureText: obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: tr('confirm_password'),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obscureConfirmPassword = !obscureConfirmPassword;
                    });
                  },
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: isSubmitting ? null : _register,
                child: isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        tr('save_continue'),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: Text(tr('already_have_account')),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MAIN NAVIGATION
// ============================================================

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with LanguageAwareState<MainNavigation> {
  int selectedIndex = 0;
  String? role;
  bool loadingRole = true;
  bool profileMissing = false;
  String? roleLoadError;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted)
        setState(() {
          role = null;
          loadingRole = false;
          roleLoadError = 'Please sign in to continue.';
        });
      return;
    }
    if (mounted)
      setState(() {
        loadingRole = true;
        roleLoadError = null;
      });
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!doc.exists) {
        if (mounted)
          setState(() {
            profileMissing = true;
            loadingRole = false;
          });
        return;
      }
      final savedRole = doc.data()?['role'];
      if (!['worker', 'employer', 'customer'].contains(savedRole)) {
        if (mounted)
          setState(() {
            roleLoadError = 'Your account role is missing or invalid. Please contact support.';
            loadingRole = false;
          });
        return;
      }
      // The device preference is loaded before runApp and may have been
      // changed from the login screen; do not overwrite it with an older
      // account preference during role loading.
      if (mounted)
        setState(() {
          role = savedRole as String;
          profileMissing = false;
          loadingRole = false;
        });
    } catch (_) {
      if (mounted)
        setState(() {
          roleLoadError = 'Could not load your account profile. Check your connection and try again.';
          loadingRole = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loadingRole)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (profileMissing) return RoleSetupScreen(onProfileSaved: _loadRole);
    if (roleLoadError != null || role == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.account_circle_outlined,
                  size: 56,
                  color: greyText,
                ),
                const SizedBox(height: 12),
                Text(
                  roleLoadError ?? 'Your account profile could not be loaded.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(onPressed: _loadRole, child: const Text('RETRY')),
                TextButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted)
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (_) => false,
                      );
                  },
                  child: const Text('SIGN OUT'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final isWorker = role == 'worker';
    final isEmployer = role == 'employer';
    // Create fresh widget configurations when language changes. Stateful tab
    // elements keep their state while their translated build methods rerun.
    final screens = isWorker
        ? [
            HomeScreen(role: role),
            FindWorkScreen(),
            NearbyJobsMapScreen(),
            FinanceScreen(),
            ProfileScreen(role: role!),
          ]
        : isEmployer
        ? [
            HomeScreen(role: role),
            PostJobScreen(),
            EmployerJobsScreen(),
            EmployerApplicantsScreen(),
            ProfileScreen(role: role!),
          ]
        : [
            HomeScreen(role: role),
            CustomerFindWorkersScreen(),
            DepartmentsScreen(),
            ProfileScreen(role: role!),
          ];
    final destinations = isWorker
        ? <NavigationDestination>[
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: tr('home'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.search),
              label: tr('find_work'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.map_outlined),
              label: tr('nearby_jobs'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: const Icon(Icons.account_balance_wallet),
              label: tr('finance'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: tr('profile'),
            ),
          ]
        : isEmployer
        ? <NavigationDestination>[
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              label: tr('home'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.add_box_outlined),
              label: tr('post_job'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.work_outline),
              label: tr('my_jobs'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.people_outline),
              label: tr('applicants'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              label: tr('profile'),
            ),
          ]
        : <NavigationDestination>[
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              label: tr('home'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.search),
              label: tr('find_workers'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.grid_view),
              label: tr('departments'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              label: tr('profile'),
            ),
          ];
    if (selectedIndex >= screens.length) selectedIndex = 0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktopLayout = constraints.maxWidth >= 900;
        final content = Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: screens[selectedIndex],
          ),
        );
        if (!desktopLayout) {
          return Scaffold(
            body: content,
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              backgroundColor: Colors.white,
              indicatorColor: lightOrange,
              onDestinationSelected: (index) =>
                  setState(() => selectedIndex = index),
              destinations: destinations,
            ),
          );
        }
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: selectedIndex,
                labelType: NavigationRailLabelType.all,
                backgroundColor: Colors.white,
                indicatorColor: lightOrange,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      const MrCoolieBrandMark(size: 48),
                      const SizedBox(height: 8),
                      const Text(
                        'Mr. Coolie',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: navy,
                        ),
                      ),
                    ],
                  ),
                ),
                onDestinationSelected: (index) =>
                    setState(() => selectedIndex = index),
                destinations: destinations
                    .map(
                      (d) => NavigationRailDestination(
                        icon: d.icon,
                        selectedIcon: d.selectedIcon ?? d.icon,
                        label: Text(d.label),
                      ),
                    )
                    .toList(),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: ColoredBox(color: cream, child: content),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RoleSetupScreen extends StatefulWidget {
  final Future<void> Function() onProfileSaved;
  const RoleSetupScreen({super.key, required this.onProfileSaved});
  @override
  State<RoleSetupScreen> createState() => _RoleSetupScreenState();
}

class _RoleSetupScreenState extends State<RoleSetupScreen>
    with LanguageAwareState<RoleSetupScreen> {
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  String selectedRole = 'worker';
  String? department;
  String? skill;
  bool saving = false;

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final name = nameController.text.trim();
    final location = locationController.text.trim();
    if (user == null) return;
    if (name.isEmpty ||
        location.isEmpty ||
        (selectedRole == 'worker' && (department == null || skill == null))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter your name and location; workers must also choose a department and skill.',
          ),
        ),
      );
      return;
    }
    setState(() => saving = true);
    try {
      final db = FirebaseFirestore.instance;
      final batch = db.batch();
      final profileRef = db.collection('users').doc(user.uid);
      batch.set(profileRef, {
        'uid': user.uid,
        'name': name,
        'email': user.email,
        'role': selectedRole,
        'location': location,
        'department': selectedRole == 'worker' ? department : null,
        'skill': selectedRole == 'worker' ? skill : null,
        'preferredLanguage': appLanguage.value,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (selectedRole == 'worker') {
        batch.set(db.collection('publicWorkers').doc(user.uid), {
          'uid': user.uid,
          'name': name,
          'location': location,
          'department': department,
          'skill': skill,
          'available': true,
          'preferredLanguage': appLanguage.value,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      await user.updateDisplayName(name);
      await widget.onProfileSaved();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save your profile: $e')),
        );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(tr('profile_complete_title')),
      actions: const [LanguagePickerButton(foregroundColor: Colors.white)],
      automaticallyImplyLeading: false,
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(tr('role_prompt'), style: const TextStyle(color: greyText)),
        const SizedBox(height: 18),
        TextField(
          controller: nameController,
          enabled: !saving,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: tr('full_name'),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: selectedRole,
          decoration: InputDecoration(
            labelText: tr('account_type'),
            border: const OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(value: 'worker', child: Text(tr('worker_role'))),
            DropdownMenuItem(
              value: 'employer',
              child: Text(tr('employer_role')),
            ),
            DropdownMenuItem(
              value: 'customer',
              child: Text(tr('customer_find_workers')),
            ),
          ],
          onChanged: saving
              ? null
              : (v) => setState(() {
                  selectedRole = v ?? 'worker';
                  department = null;
                  skill = null;
                }),
        ),
        if (selectedRole == 'worker') ...[
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: department,
            decoration: InputDecoration(
              labelText: tr('department_label'),
              border: const OutlineInputBorder(),
            ),
            items: departments
                .map(
                  (d) => DropdownMenuItem<String>(
                    value: d['name'] as String,
                    child: Text(catalogLabel(d['name'])),
                  ),
                )
                .toList(),
            onChanged: saving
                ? null
                : (v) => setState(() {
                    department = v;
                    skill = null;
                  }),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: skill,
            decoration: InputDecoration(
              labelText: tr('skill_label'),
              border: const OutlineInputBorder(),
            ),
            items: departments
                .where((d) => d['name'] == department)
                .expand(
                  (d) => List<String>.from(d['skills'] as List).map(
                    (s) => DropdownMenuItem<String>(
                      value: s,
                      child: Text(catalogLabel(s)),
                    ),
                  ),
                )
                .toList(),
            onChanged: saving || department == null
                ? null
                : (v) => setState(() => skill = v),
          ),
        ],
        const SizedBox(height: 14),
        TextField(
          controller: locationController,
          enabled: !saving,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: tr('city_area'),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: saving ? null : _saveProfile,
          child: saving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(tr('save_and_continue')),
        ),
        TextButton(
          onPressed: saving
              ? null
              : () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted)
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                },
          child: const Text('SIGN OUT'),
        ),
      ],
    ),
  );
}

Future<num?> _askAgreedWage(BuildContext context) async {
  final controller = TextEditingController();
  String? error;
  final amount = await showDialog<num>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(tr('agreed_wage_title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('agreed_wage_help')),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: tr('payment'),
                prefixText: '₹ ',
                errorText: error,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(tr('cancel')),
          ),
          FilledButton(
            onPressed: () {
              final value = num.tryParse(
                controller.text.trim().replaceAll(',', '').replaceAll('₹', ''),
              );
              if (value == null || value <= 0 || value > 10000000) {
                setDialogState(() => error = tr('agreed_wage_invalid'));
                return;
              }
              Navigator.pop(dialogContext, value);
            },
            child: Text(tr('continue')),
          ),
        ],
      ),
    ),
  );
  controller.dispose();
  return amount;
}

Future<void> _rateCompletedJob(
  BuildContext context,
  DocumentReference<Map<String, dynamic>> jobRef,
) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  try {
    final jobSnapshot = await jobRef.get();
    final job = jobSnapshot.data();
    if (job == null || job['status'] != 'completed') {
      throw StateError(
        'Ratings are available after both sides confirm a job as completed.',
      );
    }
    final employerUid = '${job['employerUid'] ?? ''}';
    final workerUid = '${job['acceptedWorkerUid'] ?? ''}';
    final ratedUid = user.uid == employerUid
        ? workerUid
        : user.uid == workerUid
        ? employerUid
        : '';
    if (ratedUid.isEmpty)
      throw StateError(
        'Only this job’s employer and worker can submit a rating.',
      );

    final ratingRef = jobRef.collection('ratings').doc(user.uid);
    if ((await ratingRef.get()).exists) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have already rated this completed job.'),
          ),
        );
      }
      return;
    }

    if (!context.mounted) return;
    final score = await showDialog<int>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Rate this completed job'),
        children: List.generate(5, (index) {
          final value = index + 1;
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, value),
            child: Row(
              children: [
                ...List.generate(
                  value,
                  (_) => const Icon(Icons.star, color: Colors.amber, size: 20),
                ),
                const SizedBox(width: 8),
                Text('$value out of 5'),
              ],
            ),
          );
        }),
      ),
    );
    if (score == null) return;
    await ratingRef.set({
      'raterUid': user.uid,
      'ratedUid': ratedUid,
      'score': score,
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Your rating was saved.')));
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save rating: $e')));
    }
  }
}

class EmployerJobsScreen extends StatelessWidget {
  const EmployerJobsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Center(child: Text('Please sign in.'));
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('my_jobs')),
        actions: const [LanguagePickerButton(foregroundColor: Colors.white)],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .where('employerUid', isEqualTo: uid)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError)
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '${tr('employer_jobs_error')}\n${snap.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          if (snap.data!.docs.isEmpty)
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.work_outline, size: 48, color: greyText),
                    const SizedBox(height: 12),
                    Text(
                      tr('employer_jobs_empty'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PostJobScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.add),
                      label: Text(tr('post_job')),
                    ),
                  ],
                ),
              ),
            );
          return ListView(
            children: snap.data!.docs.map((doc) {
              final j = doc.data();
              final status = '${j['status'] ?? 'open'}';
              final localizedStatus = tr('${status}_status');
              return Card(
                child: ListTile(
                  title: Text('${j['title'] ?? 'Job'}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${catalogLabel(j['department'])} • ${catalogLabel(j['skill'])} • ${j['location'] ?? ''}',
                      ),
                      const SizedBox(height: 4),
                      JobMetrics(jobRef: doc.reference),
                    ],
                  ),
                  trailing: status == 'assigned'
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'View worker location sharing',
                              icon: const Icon(Icons.location_on_outlined),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EmployerTrackWorkerScreen(
                                    jobId: doc.id,
                                    jobTitle: '${j['title'] ?? 'Assigned job'}',
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Mark work completed',
                              icon: const Icon(
                                Icons.task_alt_outlined,
                                color: green,
                              ),
                              onPressed: j['acceptedWorkerUid'] is String
                                  ? () => _completeAssignedJob(
                                      context,
                                      doc.reference,
                                      j['acceptedWorkerUid'] as String,
                                    )
                                  : null,
                            ),
                          ],
                        )
                      : status == 'completed'
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(label: Text(localizedStatus)),
                            if (j['acceptedWorkerUid'] is String) ...[
                              IconButton(
                                tooltip: tr('open_payment_qr'),
                                icon: const Icon(Icons.qr_code_2),
                                onPressed: () async {
                                  final workerUid =
                                      j['acceptedWorkerUid'] as String;
                                  var amount = j['wage'] ?? j['payment'];
                                  if (amount is! num || amount <= 0) {
                                    amount = await _askAgreedWage(context);
                                    if (amount == null || !context.mounted) {
                                      return;
                                    }
                                    try {
                                      await doc.reference.update({
                                        'wage': amount,
                                        'payment': amount,
                                        'updatedAt':
                                            FieldValue.serverTimestamp(),
                                      });
                                    } catch (error) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${tr('payment_send_failed')} $error',
                                            ),
                                          ),
                                        );
                                      }
                                      return;
                                    }
                                  }
                                  if (!context.mounted) return;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => JobPaymentQrScreen(
                                        jobRef: doc.reference,
                                        jobTitle: '${j['title'] ?? 'Job'}',
                                        workerUid: workerUid,
                                        employerUid: uid,
                                        amount: amount,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                tooltip: 'Rate the worker',
                                icon: const Icon(Icons.star_outline),
                                onPressed: () =>
                                    _rateCompletedJob(context, doc.reference),
                              ),
                            ],
                          ],
                        )
                      : status == 'open' || status == 'closed'
                      ? DropdownButton<String>(
                          value: status,
                          items: [
                            DropdownMenuItem(
                              value: 'open',
                              child: Text(tr('open_status')),
                            ),
                            DropdownMenuItem(
                              value: 'closed',
                              child: Text(tr('closed_status')),
                            ),
                          ],
                          onChanged: (value) async {
                            if (value == null) return;
                            try {
                              await doc.reference.update({
                                'status': value,
                                'updatedAt': FieldValue.serverTimestamp(),
                              });
                            } catch (e) {
                              if (context.mounted)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Could not update job: $e'),
                                  ),
                                );
                            }
                          },
                        )
                      : Chip(
                          label: Text(
                            localizedStatus == '${status}_status'
                                ? status
                                : localizedStatus,
                          ),
                        ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class JobMetrics extends StatelessWidget {
  final DocumentReference<Map<String, dynamic>> jobRef;
  const JobMetrics({super.key, required this.jobRef});

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: jobRef.collection('applications').snapshots(),
        builder: (context, applications) =>
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: jobRef.collection('views').snapshots(),
              builder: (context, views) {
                if (applications.hasError || views.hasError)
                  return Text(
                    tr('job_metrics_unavailable'),
                    style: const TextStyle(color: greyText),
                  );
                if (!applications.hasData || !views.hasData)
                  return const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                final uniqueApplicants = applications.data!.docs.length;
                return Wrap(
                  spacing: 14,
                  children: [
                    Text(
                      '${tr('job_views_count')}: ${views.data!.docs.length}',
                      style: const TextStyle(color: greyText),
                    ),
                    Text(
                      '${tr('application_count')}: $uniqueApplicants',
                      style: const TextStyle(color: greyText),
                    ),
                  ],
                );
              },
            ),
      );
}

class EmployerNotificationsScreen extends StatelessWidget {
  const EmployerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null)
      return const Scaffold(body: Center(child: Text('Please sign in.')));
    final notifications = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('notifications')),
        backgroundColor: navy,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: notifications.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '${tr('notifications_error')}\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty)
            return Center(child: Text(tr('notifications_empty')));
          return ListView(
            children: snapshot.data!.docs.map((notification) {
              final data = notification.data();
              final read = data['read'] == true;
              return ListTile(
                leading: Icon(
                  read ? Icons.notifications_none : Icons.notifications_active,
                  color: read ? greyText : orange,
                ),
                title: Text(
                  '${data['workerName'] ?? tr('worker_role')} • ${tr('new_job_application')}',
                  style: TextStyle(
                    fontWeight: read ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${data['jobTitle'] ?? tr('job_title')}\n${tr('notification_open_applicants')}',
                ),
                isThreeLine: true,
                onTap: () async {
                  if (!read)
                    await notification.reference.update({
                      'read': true,
                      'readAt': FieldValue.serverTimestamp(),
                    });
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EmployerApplicantsScreen(),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

Future<void> _completeAssignedJob(
  BuildContext context,
  DocumentReference<Map<String, dynamic>> jobRef,
  String workerUid,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(tr('mark_completed')),
      content: Text(tr('complete_job_message')),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(tr('cancel')),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(tr('complete_job')),
        ),
      ],
    ),
  );
  if (!context.mounted || confirmed != true) return;
  try {
    final applicationRef = jobRef.collection('applications').doc(workerUid);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final jobSnapshot = await transaction.get(jobRef);
      final applicationSnapshot = await transaction.get(applicationRef);
      if (jobSnapshot.data()?['status'] != 'assigned' ||
          jobSnapshot.data()?['acceptedWorkerUid'] != workerUid ||
          applicationSnapshot.data()?['status'] != 'accepted') {
        throw StateError(
          'The job or accepted application has changed. Refresh and try again.',
        );
      }
      transaction.update(jobRef, {
        'status': 'completed',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.update(applicationRef, {
        'status': 'completed',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Work marked completed.')));
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not complete this job: $e')),
      );
    }
  }
}

class EmployerTrackWorkerScreen extends StatelessWidget {
  final String jobId;
  final String jobTitle;

  const EmployerTrackWorkerScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(jobTitle),
      actions: const [LanguagePickerButton(foregroundColor: Colors.white)],
    ),
    body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('liveLocations')
          .doc(jobId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                '${tr('location_private')}\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data?.data();
        if (data == null ||
            data['sharing'] != true ||
            data['location'] is! GeoPoint) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                tr('worker_not_sharing'),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        final position = data['location'] as GeoPoint;
        final updatedAt = data['updatedAt'];
        final map = mapsEnabled
            ? GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 14,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('worker-$jobId'),
                    position: LatLng(position.latitude, position.longitude),
                    infoWindow: const InfoWindow(title: 'Worker location'),
                  ),
                },
              )
            : null;
        final statusCard = Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.my_location, size: 48, color: orange),
                const SizedBox(height: 12),
                const Text(
                  'Worker is sharing live location',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  '${position.latitude}, ${position.longitude}',
                  textAlign: TextAlign.center,
                ),
                if (updatedAt is Timestamp) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Updated ${updatedAt.toDate().toLocal()}',
                    style: const TextStyle(color: greyText),
                  ),
                ],
                const SizedBox(height: 10),
                if (!mapsEnabled)
                  const Text(
                    'Map view becomes available after Maps API keys are configured.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: greyText),
                  ),
              ],
            ),
          ),
        );
        return map == null
            ? Center(child: statusCard)
            : Stack(
                children: [
                  Positioned.fill(child: map),
                  Align(alignment: Alignment.bottomCenter, child: statusCard),
                ],
              );
      },
    ),
  );
}

class EmployerApplicantsScreen extends StatelessWidget {
  const EmployerApplicantsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Center(child: Text('Please sign in.'));
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('applicants')),
        actions: const [LanguagePickerButton(foregroundColor: Colors.white)],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .where('employerUid', isEqualTo: uid)
            .snapshots(),
        builder: (context, jobsSnap) {
          if (jobsSnap.hasError)
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '${tr('employer_jobs_error')}\n${jobsSnap.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          if (!jobsSnap.hasData)
            return const Center(child: CircularProgressIndicator());
          final jobs = jobsSnap.data!.docs;
          if (jobs.isEmpty)
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people_outline, size: 48, color: greyText),
                    const SizedBox(height: 12),
                    Text(
                      tr('employer_post_prompt'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PostJobScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.add),
                      label: Text(tr('post_job')),
                    ),
                  ],
                ),
              ),
            );
          return ListView(
            children: jobs
                .map(
                  (jobDoc) => ExpansionTile(
                    title: Text('${jobDoc.data()['title'] ?? 'Job'}'),
                    subtitle: Text(
                      '${tr('job_status')}: ${tr('${jobDoc.data()['status'] ?? 'open'}_status')}',
                    ),
                    children: [
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: jobDoc.reference
                            .collection('applications')
                            .snapshots(),
                        builder: (context, appSnap) {
                          if (appSnap.hasError)
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                '${tr('applications_error')}\n${appSnap.error}',
                                textAlign: TextAlign.center,
                              ),
                            );
                          if (!appSnap.hasData)
                            return const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(),
                            );
                          if (appSnap.data!.docs.isEmpty)
                            return ListTile(
                              title: Text(tr('applications_empty')),
                            );
                          return Column(
                            children: appSnap.data!.docs.map((appDoc) {
                              final a = appDoc.data();
                              return FutureBuilder<
                                DocumentSnapshot<Map<String, dynamic>>
                              >(
                                future: FirebaseFirestore.instance
                                    .collection('publicWorkers')
                                    .doc(appDoc.id)
                                    .get(),
                                builder: (context, workerSnap) {
                                  final w = workerSnap.data?.data() ?? {};
                                  final status = '${a['status'] ?? 'applied'}';
                                  final jobIsOpen =
                                      jobDoc.data()['status'] == 'open';
                                  return ListTile(
                                    leading: const CircleAvatar(
                                      child: Icon(Icons.person),
                                    ),
                                    title: Text(
                                      '${w['name'] ?? a['workerName'] ?? tr('worker_unavailable')}',
                                    ),
                                    subtitle: Text(
                                      '${catalogLabel(w['skill'] ?? a['skill'])} • ${catalogLabel(w['department'] ?? a['department'])} • $status',
                                    ),
                                    trailing: status == 'accepted'
                                        ? const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                          )
                                        : status != 'applied'
                                        ? Chip(label: Text(status))
                                        : Wrap(
                                            spacing: 4,
                                            children: [
                                              IconButton(
                                                tooltip: tr('accept_applicant'),
                                                icon: const Icon(
                                                  Icons.check_circle_outline,
                                                  color: Colors.green,
                                                ),
                                                onPressed: jobIsOpen
                                                    ? () async {
                                                        try {
                                                          await FirebaseFirestore.instance.runTransaction((
                                                            tx,
                                                          ) async {
                                                            final latest =
                                                                await tx.get(
                                                                  jobDoc
                                                                      .reference,
                                                                );
                                                            if ((latest
                                                                        .data()?['status'] ??
                                                                    'open') !=
                                                                'open')
                                                              throw Exception(
                                                                'This job is no longer open.',
                                                              );
                                                            tx.update(
                                                              jobDoc.reference,
                                                              {
                                                                'acceptedWorkerUid':
                                                                    appDoc.id,
                                                                'status':
                                                                    'assigned',
                                                                'updatedAt':
                                                                    FieldValue.serverTimestamp(),
                                                              },
                                                            );
                                                            tx.update(
                                                              appDoc.reference,
                                                              {
                                                                'status':
                                                                    'accepted',
                                                                'updatedAt':
                                                                    FieldValue.serverTimestamp(),
                                                              },
                                                            );
                                                          });
                                                        } catch (e) {
                                                          if (context.mounted)
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  '${tr('accept_failed')} $e',
                                                                ),
                                                              ),
                                                            );
                                                        }
                                                      }
                                                    : null,
                                              ),
                                              IconButton(
                                                tooltip: tr('reject_applicant'),
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () async {
                                                  try {
                                                    await appDoc.reference.update({
                                                      'status': 'rejected',
                                                      'updatedAt':
                                                          FieldValue.serverTimestamp(),
                                                    });
                                                  } catch (e) {
                                                    if (context.mounted)
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            '${tr('reject_failed')} $e',
                                                          ),
                                                        ),
                                                      );
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                  );
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class CustomerFindWorkersScreen extends StatefulWidget {
  final String? initialDepartment;
  final String? initialSkill;

  const CustomerFindWorkersScreen({
    super.key,
    this.initialDepartment,
    this.initialSkill,
  });
  @override
  State<CustomerFindWorkersScreen> createState() =>
      _CustomerFindWorkersScreenState();
}

class _CustomerFindWorkersScreenState extends State<CustomerFindWorkersScreen>
    with LanguageAwareState<CustomerFindWorkersScreen> {
  String query = '';
  late String department;
  String? skill;
  Position? _customerPosition;
  bool _nearbyOnly = false;
  double _workerRadiusKm = 10;

  @override
  void initState() {
    super.initState();
    department = widget.initialDepartment ?? 'All';
    skill = widget.initialSkill;
  }

  Future<void> _toggleNearbyWorkers(bool enabled) async {
    if (enabled && _customerPosition == null) {
      try {
        final position = await requestCurrentDevicePosition();
        if (!mounted) return;
        setState(() {
          _customerPosition = position;
          _nearbyOnly = true;
        });
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${tr('use_location')} $error')),
          );
        }
      }
      return;
    }
    if (mounted) setState(() => _nearbyOnly = enabled);
  }

  double? _workerDistanceKm(Map<String, dynamic> worker) {
    final position = _customerPosition;
    final latitude = worker['latitude'];
    final longitude = worker['longitude'];
    if (position == null || latitude is! num || longitude is! num) return null;
    return Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          latitude.toDouble(),
          longitude.toDouble(),
        ) /
        1000;
  }

  Future<Map<String, String>?> _describeService(
    BuildContext context, {
    String initialService = '',
  }) async {
    final serviceController = TextEditingController(text: initialService);
    final detailsController = TextEditingController();
    final locationController = TextEditingController();
    final budgetController = TextEditingController();
    String? validationMessage;
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(tr('service_request_title')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: serviceController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: tr('service_needed'),
                    hintText: tr('service_example'),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: detailsController,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(labelText: tr('service_details')),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: tr('service_location'),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: budgetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: tr('service_budget_optional'),
                    prefixText: '₹ ',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  tr('quote_first_note'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (validationMessage != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      validationMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(tr('cancel')),
            ),
            FilledButton(
              onPressed: () {
                final service = serviceController.text.trim();
                final location = locationController.text.trim();
                final budget = budgetController.text.trim();
                if (service.isEmpty || location.isEmpty) {
                  setDialogState(() {
                    validationMessage = tr('service_request_required');
                  });
                  return;
                }
                if (service.length > 80 ||
                    detailsController.text.trim().length > 500 ||
                    location.length > 160 ||
                    budget.length > 32) {
                  setDialogState(() {
                    validationMessage = tr('service_request_too_long');
                  });
                  return;
                }
                Navigator.pop(dialogContext, {
                  'serviceTitle': service,
                  'serviceDetails': detailsController.text.trim(),
                  'serviceLocation': location,
                  'budgetNote': budget,
                });
              },
              child: Text(tr('request_contact')),
            ),
          ],
        ),
      ),
    );
    serviceController.dispose();
    detailsController.dispose();
    locationController.dispose();
    budgetController.dispose();
    return result;
  }

  Future<void> _requestContact(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> workerDoc,
  ) async {
    final customer = FirebaseAuth.instance.currentUser;
    if (customer == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(tr('login_continue'))));
      }
      return;
    }
    final serviceRequest = await _describeService(
      context,
      initialService:
          widget.initialSkill ?? workerDoc.data()['skill']?.toString() ?? '',
    );
    if (serviceRequest == null || !context.mounted) return;
    try {
      final customerProfile = await FirebaseFirestore.instance
          .collection('users')
          .doc(customer.uid)
          .get();
      if (customerProfile.data()?['role'] != 'customer') {
        throw StateError(tr('contact_customer_role_required'));
      }
      final requestRef = workerDoc.reference
          .collection('contactRequests')
          .doc(customer.uid);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final workerSnapshot = await transaction.get(workerDoc.reference);
        final requestSnapshot = await transaction.get(requestRef);
        if (workerSnapshot.data()?['available'] != true) {
          throw StateError(tr('contact_request_error'));
        }
        if (requestSnapshot.exists) {
          if (requestSnapshot.data()?['status'] == 'rejected') {
            transaction.update(requestRef, {
              ...serviceRequest,
              'quoteRequired': true,
              'status': 'pending',
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
          return;
        }
        transaction.set(requestRef, {
          'workerUid': workerDoc.id,
          'customerUid': customer.uid,
          'customerName':
              customerProfile.data()?['name'] ??
              customer.displayName ??
              tr('customer'),
          ...serviceRequest,
          'quoteRequired': true,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(tr('contact_request_sent'))));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_contactErrorMessage(error))));
      }
    }
  }

  String _contactErrorMessage(Object error) {
    final message = error.toString();
    if (message.contains('permission-denied')) {
      return '${tr('contact_request_error')} ${tr('contact_permission_denied')}';
    }
    return '${tr('contact_request_error')} $message';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.initialSkill == null
            ? tr('find_workers_title')
            : tr('available_workers_title'),
      ),
      backgroundColor: navy,
      foregroundColor: Colors.white,
      actions: const [LanguagePickerButton(foregroundColor: Colors.white)],
    ),
    floatingActionButton: widget.initialSkill == null
        ? null
        : FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CustomerServiceRequestForm(
                  department: widget.initialDepartment ?? department,
                  skill: widget.initialSkill!,
                ),
              ),
            ),
            icon: const Icon(Icons.post_add),
            label: Text(tr('post_service_request')),
          ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: (v) => setState(() => query = v),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: tr('worker_search_hint'),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: DropdownButtonFormField<String>(
            initialValue: department,
            decoration: InputDecoration(
              labelText: tr('department_label'),
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(
                value: 'All',
                child: Text(tr('all_departments')),
              ),
              ...departments.map(
                (d) => DropdownMenuItem<String>(
                  value: d['name'] as String,
                  child: Text(catalogLabel(d['name'])),
                ),
              ),
            ],
            onChanged: (value) => setState(() {
              department = value ?? 'All';
              skill = null;
            }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          child: Row(
            children: [
              Expanded(
                child: FilterChip(
                  selected: _nearbyOnly,
                  avatar: const Icon(Icons.near_me_outlined, size: 18),
                  label: Text(tr('customer_nearby_filter')),
                  onSelected: _toggleNearbyWorkers,
                ),
              ),
              DropdownButton<double>(
                value: _workerRadiusKm,
                onChanged: _nearbyOnly
                    ? (value) {
                        if (value != null)
                          setState(() => _workerRadiusKm = value);
                      }
                    : null,
                items: [5, 10, 15, 20]
                    .map(
                      (radius) => DropdownMenuItem<double>(
                        value: radius.toDouble(),
                        child: Text(
                          tr('radius_within').replaceAll('{radius}', '$radius'),
                        ),
                      ),
                    )
                    .toList(),
              ),
              IconButton(
                tooltip: workerTr('map_nearby_workers'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const NearbyWorkersMapScreen(role: 'customer'),
                  ),
                ),
                icon: const Icon(Icons.map_outlined),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('publicWorkers')
                .where('available', isEqualTo: true)
                .snapshots(),
            builder: (context, snap) {
              if (snap.hasError)
                return Center(
                  child: Text('Could not load workers: ${snap.error}'),
                );
              if (!snap.hasData)
                return const Center(child: CircularProgressIndicator());
              final workers = snap.data!.docs.where((d) {
                final w = d.data();
                final hay =
                    '${w['name'] ?? ''} ${w['skill'] ?? ''} ${w['department'] ?? ''} ${w['location'] ?? ''}'
                        .toLowerCase();
                return hay.contains(query.toLowerCase()) &&
                    (department == 'All' ||
                        '${w['department'] ?? ''}'.toLowerCase() ==
                            department.toLowerCase()) &&
                    (skill == null ||
                        '${w['skill'] ?? ''}'.toLowerCase() ==
                            skill!.toLowerCase()) &&
                    (!_nearbyOnly ||
                        (_workerDistanceKm(w) != null &&
                            _workerDistanceKm(w)! <= _workerRadiusKm));
              }).toList();
              if (workers.isEmpty)
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tr('customer_no_workers_next_step'),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CustomerServiceRequestForm(
                                department: department == 'All'
                                    ? null
                                    : department,
                                skill: skill,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.post_add),
                          label: Text(tr('post_service_request')),
                        ),
                      ],
                    ),
                  ),
                );
              return ListView(
                children: workers.map((d) {
                  final w = d.data();
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.engineering),
                      ),
                      title: Text('${w['name'] ?? tr('worker_role')}'),
                      subtitle: Text(
                        '${catalogLabel(w['skill'])} • ${catalogLabel(w['department'])}\n${w['location'] ?? ''}',
                      ),
                      isThreeLine: true,
                      trailing: _CustomerContactAction(
                        workerRef: d.reference,
                        onRequest: () => _requestContact(context, d),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    ),
  );
}

class CustomerServiceRequestForm extends StatefulWidget {
  final String? department;
  final String? skill;

  const CustomerServiceRequestForm({super.key, this.department, this.skill});

  @override
  State<CustomerServiceRequestForm> createState() =>
      _CustomerServiceRequestFormState();
}

class _CustomerServiceRequestFormState extends State<CustomerServiceRequestForm>
    with LanguageAwareState<CustomerServiceRequestForm> {
  final SpeechToText _speech = SpeechToText();
  late final TextEditingController _title = TextEditingController(
    text: widget.skill ?? '',
  );
  final _details = TextEditingController();
  final _location = TextEditingController();
  final _budget = TextEditingController();
  Position? _workPosition;
  double _radiusKm = 10;
  bool _saving = false;
  bool _listeningToJob = false;
  bool _speechInitialized = false;

  Future<void> _dictateJobDetails() async {
    if (_listeningToJob) {
      await _speech.stop();
      if (mounted) setState(() => _listeningToJob = false);
      return;
    }
    try {
      if (!_speechInitialized) {
        _speechInitialized = await _speech.initialize(
          onStatus: (status) {
            if (mounted) setState(() => _listeningToJob = status == 'listening');
          },
          onError: (_) {
            if (mounted) setState(() => _listeningToJob = false);
          },
        );
      }
      if (!_speechInitialized) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(voiceAssistantTr('voice_speech_unavailable'))),
          );
        }
        return;
      }
      await _speech.listen(
        listenOptions: SpeechListenOptions(
          localeId: _speechLocaleFor(appLanguage.value),
          listenMode: ListenMode.dictation,
          partialResults: true,
          cancelOnError: true,
        ),
        onResult: (result) {
          final spoken = result.recognizedWords.trim();
          if (!mounted || spoken.isEmpty) return;
          setState(() {
            _details.text = spoken;
            if (_title.text.trim().isEmpty) {
              _title.text = spoken.length > 80
                  ? '${spoken.substring(0, 77)}…'
                  : spoken;
            }
          });
        },
      );
      if (mounted) setState(() => _listeningToJob = _speech.isListening);
    } catch (_) {
      if (mounted) setState(() => _listeningToJob = false);
    }
  }

  Future<void> _captureWorkLocation() async {
    try {
      final position = await requestCurrentDevicePosition();
      if (mounted) setState(() => _workPosition = position);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${tr('use_location')} $error')));
      }
    }
  }

  @override
  void dispose() {
    unawaited(_speech.cancel());
    _title.dispose();
    _details.dispose();
    _location.dispose();
    _budget.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    final title = _title.text.trim();
    final details = _details.text.trim();
    final location = _location.text.trim();
    final budget = _budget.text.trim();
    if (user == null) return;
    if (title.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('service_request_required'))));
      return;
    }
    if (title.length > 80 ||
        details.length > 500 ||
        location.length > 160 ||
        budget.length > 32) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('service_request_too_long'))));
      return;
    }
    if (_workPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('service_request_location_required'))),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final profile = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (profile.data()?['role'] != 'customer') {
        throw StateError(tr('contact_customer_role_required'));
      }
      await FirebaseFirestore.instance.collection('serviceRequests').add({
        'customerUid': user.uid,
        'customerName':
            profile.data()?['name'] ?? user.displayName ?? tr('customer'),
        'title': title,
        'description': details,
        'department': widget.department ?? '',
        'skill': widget.skill ?? title,
        'location': location,
        'budgetNote': budget,
        'latitude': double.parse(_workPosition!.latitude.toStringAsFixed(3)),
        'longitude': double.parse(_workPosition!.longitude.toStringAsFixed(3)),
        'radiusKm': _radiusKm,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(tr('service_request_posted'))));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CustomerServiceRequestsScreen(),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${tr('service_request_post_failed')} $error'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(tr('post_service_request')),
      backgroundColor: navy,
      foregroundColor: Colors.white,
    ),
    body: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (widget.department != null || widget.skill != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: Text(catalogLabel(widget.skill ?? widget.department)),
                  subtitle: Text(catalogLabel(widget.department)),
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: tr('service_needed'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _saving ? null : _dictateJobDetails,
              icon: Icon(_listeningToJob ? Icons.stop : Icons.mic_none),
              label: Text(_listeningToJob
                  ? voiceAssistantTr('voice_listening')
                  : voiceAssistantTr('voice_assistant')),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _saving ? null : _captureWorkLocation,
              icon: Icon(
                _workPosition == null ? Icons.my_location : Icons.location_on,
              ),
              label: Text(
                _workPosition == null
                    ? tr('service_pin_location')
                    : tr('service_location_pinned'),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<double>(
              initialValue: _radiusKm,
              decoration: InputDecoration(
                labelText: tr('radius_choose'),
                border: const OutlineInputBorder(),
              ),
              items: [5, 10, 15, 20]
                  .map(
                    (radius) => DropdownMenuItem<double>(
                      value: radius.toDouble(),
                      child: Text(
                        tr('radius_within').replaceAll('{radius}', '$radius'),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _saving
                  ? null
                  : (value) {
                      if (value != null) setState(() => _radiusKm = value);
                    },
            ),
            const SizedBox(height: 8),
            Text(
              tr('service_nearby_broadcast_note'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _details,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: tr('service_details'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _location,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: tr('service_location'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _budget,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: tr('service_budget_optional'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(tr('quote_first_note')),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _saving ? null : _submit,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(tr('post_service_request')),
            ),
          ],
        ),
      ),
    ),
  );
}

class CustomerServiceRequestsScreen extends StatelessWidget {
  const CustomerServiceRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null)
      return Scaffold(body: Center(child: Text(tr('login_continue'))));
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('posted_jobs')),
        backgroundColor: navy,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('serviceRequests')
            .where('customerUid', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(
              child: Text('${tr('contact_action_error')} ${snapshot.error}'),
            );
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty)
            return Center(child: Text(tr('no_posted_jobs')));
          return ListView(
            padding: const EdgeInsets.all(12),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data();
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.work_outline)),
                  title: Text('${data['title'] ?? ''}'),
                  subtitle: Text(
                    [
                      '${catalogLabel(data['department'])} · ${catalogLabel(data['skill'])}',
                      '${data['location'] ?? ''}',
                      data['status'] == 'assigned'
                          ? '${tr('contact_accepted')}: ${data['acceptedWorkerName'] ?? ''}'
                          : '${data['status'] ?? 'open'}',
                    ].where((line) => line.trim().isNotEmpty).join('\n'),
                  ),
                  isThreeLine: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CustomerServiceRequestApplicantsScreen(
                        requestRef: doc.reference,
                        request: data,
                      ),
                    ),
                  ),
                  trailing: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: doc.reference
                        .collection('applications')
                        .snapshots(),
                    builder: (context, applications) => Chip(
                      label: Text(
                        '${applications.data?.size ?? 0} ${tr('service_request_applicants')}',
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class CustomerServiceRequestApplicantsScreen extends StatelessWidget {
  final DocumentReference<Map<String, dynamic>> requestRef;
  final Map<String, dynamic> request;

  const CustomerServiceRequestApplicantsScreen({
    super.key,
    required this.requestRef,
    required this.request,
  });

  Future<void> _requestContact(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> application,
  ) async {
    final customer = FirebaseAuth.instance.currentUser;
    if (customer == null) return;
    final workerUid = application.id;
    final workerRef = FirebaseFirestore.instance
        .collection('publicWorkers')
        .doc(workerUid);
    final contactRef = workerRef
        .collection('contactRequests')
        .doc(customer.uid);
    try {
      final profile = await FirebaseFirestore.instance
          .collection('users')
          .doc(customer.uid)
          .get();
      final worker = await workerRef.get();
      if (worker.data()?['available'] != true) {
        throw StateError(tr('contact_request_error'));
      }
      final existing = await contactRef.get();
      final serviceData = {
        'serviceTitle': '${request['title'] ?? ''}',
        'serviceDetails': '${request['description'] ?? ''}',
        'serviceLocation': '${request['location'] ?? ''}',
        'budgetNote': '${request['budgetNote'] ?? ''}',
        'quoteRequired': true,
      };
      if (!existing.exists) {
        await contactRef.set({
          'customerUid': customer.uid,
          'customerName':
              profile.data()?['name'] ?? customer.displayName ?? tr('customer'),
          'workerUid': workerUid,
          ...serviceData,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else if (existing.data()?['status'] == 'rejected') {
        await contactRef.update({
          ...serviceData,
          'status': 'pending',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        throw StateError(tr('contact_pending'));
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(tr('contact_request_sent'))));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${tr('contact_request_error')} $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(tr('service_request_applicants')),
      backgroundColor: navy,
      foregroundColor: Colors.white,
    ),
    body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: requestRef.collection('applications').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(
            child: Text('${tr('contact_action_error')} ${snapshot.error}'),
          );
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final visibleApplications = snapshot.data!.docs
            .where((application) => application.data()['status'] != 'rejected')
            .toList();
        if (visibleApplications.isEmpty)
          return Center(child: Text(tr('service_requests_empty')));
        return ListView(
          padding: const EdgeInsets.all(12),
          children: visibleApplications.map((application) {
            final worker = application.data();
            return Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.engineering_outlined),
                ),
                title: Text('${worker['workerName'] ?? tr('worker_role')}'),
                subtitle: Text(
                  [
                    '${catalogLabel(worker['skill'])} · ${catalogLabel(worker['department'])}',
                    '${worker['location'] ?? ''}',
                  ].where((line) => line.trim().isNotEmpty).join('\n'),
                ),
                isThreeLine: true,
                trailing: _CustomerContactAction(
                  workerRef: FirebaseFirestore.instance
                      .collection('publicWorkers')
                      .doc(application.id),
                  onRequest: () => _requestContact(context, application),
                ),
              ),
            );
          }).toList(),
        );
      },
    ),
  );
}

class AvailableServiceRequestsScreen extends StatefulWidget {
  final String? requestId;
  final Position? initialPosition;

  const AvailableServiceRequestsScreen({
    super.key,
    this.requestId,
    this.initialPosition,
  });

  @override
  State<AvailableServiceRequestsScreen> createState() =>
      _AvailableServiceRequestsScreenState();
}

class _AvailableServiceRequestsScreenState
    extends State<AvailableServiceRequestsScreen>
    with LanguageAwareState<AvailableServiceRequestsScreen> {
  String? _department;
  String? _skill;
  Position? _workerPosition;

  bool _matchesRequest(Map<String, dynamic> request) {
    final requestDepartment = '${request['department'] ?? ''}'
        .trim()
        .toLowerCase();
    final requestSkill = '${request['skill'] ?? ''}'.trim().toLowerCase();
    final workerDepartment = (_department ?? '').trim().toLowerCase();
    final workerSkill = (_skill ?? '').trim().toLowerCase();
    final hasBothDepartments =
        requestDepartment.isNotEmpty && workerDepartment.isNotEmpty;
    if (hasBothDepartments) {
      if (workerDepartment != requestDepartment) return false;
    } else if (requestSkill.isEmpty || workerSkill != requestSkill) {
      return false;
    }
    final position = _workerPosition;
    final latitude = request['latitude'];
    final longitude = request['longitude'];
    if (position == null || latitude is! num || longitude is! num) return false;
    final distanceKm =
        Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          latitude.toDouble(),
          longitude.toDouble(),
        ) /
        1000;
    final radiusKm = request['radiusKm'];
    return distanceKm <= (radiusKm is num ? radiusKm.toDouble() : 10);
  }

  @override
  void initState() {
    super.initState();
    _workerPosition = widget.initialPosition;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final profile = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final publicProfile = await FirebaseFirestore.instance
          .collection('publicWorkers')
          .doc(uid)
          .get();
      if (mounted)
        setState(() {
          _department = profile.data()?['department']?.toString();
          _skill = profile.data()?['skill']?.toString();
          final data = publicProfile.data();
          if (data?['mapVisible'] == true &&
              data?['latitude'] is num &&
              data?['longitude'] is num) {
            _workerPosition = Position(
              longitude: (data!['longitude'] as num).toDouble(),
              latitude: (data['latitude'] as num).toDouble(),
              timestamp: DateTime.now(),
              accuracy: 100,
              altitude: 0,
              altitudeAccuracy: 0,
              heading: 0,
              headingAccuracy: 0,
              speed: 0,
              speedAccuracy: 0,
            );
          }
        });
    } catch (_) {}
  }

  Future<void> _locateForRequests() async {
    try {
      final position = await requestCurrentDevicePosition();
      if (mounted) setState(() => _workerPosition = position);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${tr('use_location')} $error')));
      }
    }
  }

  Future<void> _respondToRequest(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> request,
    String response,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final requestRef = request.reference;
    final applicationRef = requestRef.collection('applications').doc(user.uid);
    try {
      final profileRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      final profile = await profileRef.get();
      final person = profile.data() ?? <String, dynamic>{};
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final requestSnapshot = await transaction.get(requestRef);
        final application = await transaction.get(applicationRef);
        if (requestSnapshot.data()?['status'] != 'open')
          throw StateError('This request is no longer open.');
        if (application.exists)
          throw StateError(tr('service_request_already_applied'));
        final workerName = person['name'] ?? user.displayName ?? tr('worker_role');
        transaction.set(applicationRef, {
          'workerUid': user.uid,
          'workerName': workerName,
          'department': person['department'] ?? '',
          'skill': person['skill'] ?? '',
          'location': person['location'] ?? '',
          'status': response,
          'createdAt': FieldValue.serverTimestamp(),
        });
        if (response == 'accepted') {
          transaction.update(requestRef, {
            'status': 'assigned',
            'acceptedWorkerUid': user.uid,
            'acceptedWorkerName': workerName,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
      if (context.mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              tr(response == 'accepted'
                  ? 'contact_you_accepted'
                  : 'contact_status_declined'),
            ),
          ),
        );
    } catch (error) {
      if (context.mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_department == null && _skill == null) {
      return Scaffold(
        appBar: AppBar(title: Text(tr('open_service_requests'))),
        body: Center(child: Text(tr('service_request_role_needed'))),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('open_service_requests')),
        backgroundColor: navy,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('serviceRequests')
            .where('status', isEqualTo: 'open')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(
              child: Text('${tr('contact_action_error')} ${snapshot.error}'),
            );
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final requests = snapshot.data!.docs
              .where(
                (doc) =>
                    (widget.requestId == null || doc.id == widget.requestId) &&
                    _matchesRequest(doc.data()),
              )
              .toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _locateForRequests,
                    icon: const Icon(Icons.my_location),
                    label: Text(tr('worker_request_location')),
                  ),
                ),
              ),
              if (_workerPosition == null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Text(tr('worker_request_location_note')),
                ),
              Expanded(
                child: requests.isEmpty
                    ? Center(
                        child: Text(
                          _workerPosition == null
                              ? tr('worker_request_location_note')
                              : tr('service_requests_empty'),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(12),
                        children: requests.map((doc) {
                          final request = doc.data();
                          final applicationRef = doc.reference
                              .collection('applications')
                              .doc(FirebaseAuth.instance.currentUser!.uid);
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    leading: const CircleAvatar(
                                      child: Icon(Icons.handyman_outlined),
                                    ),
                                    title: Text('${request['title'] ?? ''}'),
                                    subtitle: Text(
                                      [
                                        '${catalogLabel(request['department'])} · ${catalogLabel(request['skill'])}',
                                        '${request['location'] ?? ''}',
                                        if ('${request['description'] ?? ''}'
                                            .isNotEmpty)
                                          '${request['description']}',
                                        if ('${request['budgetNote'] ?? ''}'
                                            .isNotEmpty)
                                          '${tr('service_budget_optional')}: ${request['budgetNote']}',
                                      ].join('\n'),
                                    ),
                                    isThreeLine: true,
                                  ),
                                  StreamBuilder<
                                    DocumentSnapshot<Map<String, dynamic>>
                                  >(
                                    stream: applicationRef.snapshots(),
                                    builder: (context, applicationSnapshot) {
                                      if (applicationSnapshot.hasData &&
                                          applicationSnapshot.data!.exists) {
                                        final status = applicationSnapshot
                                            .data!
                                            .data()?['status'];
                                        return Align(
                                          alignment: Alignment.centerRight,
                                          child: Chip(
                                            avatar: Icon(
                                              status == 'accepted'
                                                  ? Icons.check_circle_outline
                                                  : Icons.cancel_outlined,
                                            ),
                                            label: Text(
                                              tr(status == 'accepted'
                                                  ? 'contact_you_accepted'
                                                  : status == 'rejected'
                                                  ? 'contact_status_declined'
                                                  : 'service_request_applied_status'),
                                            ),
                                          ),
                                        );
                                      }
                                      return Wrap(
                                        alignment: WrapAlignment.end,
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          OutlinedButton.icon(
                                            onPressed: () =>
                                                _respondToRequest(
                                                  context,
                                                  doc,
                                                  'rejected',
                                                ),
                                            icon: const Icon(Icons.close),
                                            label: Text(tr('contact_decline')),
                                          ),
                                          FilledButton.icon(
                                            onPressed: () =>
                                                _respondToRequest(
                                                  context,
                                                  doc,
                                                  'accepted',
                                                ),
                                            icon: const Icon(Icons.check),
                                            label: Text(
                                              tr('contact_accept_no_phone'),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CustomerContactAction extends StatelessWidget {
  final DocumentReference<Map<String, dynamic>> workerRef;
  final VoidCallback onRequest;

  const _CustomerContactAction({
    required this.workerRef,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final customerUid = FirebaseAuth.instance.currentUser?.uid;
    if (customerUid == null) return const SizedBox.shrink();
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: workerRef
          .collection('contactRequests')
          .doc(customerUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return FilledButton.tonalIcon(
            onPressed: onRequest,
            icon: const Icon(Icons.refresh),
            label: Text(tr('retry')),
          );
        }
        if (!snapshot.hasData) {
          return const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }
        final request = snapshot.data!.data();
        if (request == null) {
          return FilledButton.tonalIcon(
            onPressed: onRequest,
            icon: const Icon(Icons.call_outlined),
            label: Text(tr('request_contact')),
          );
        }
        switch (request['status']) {
          case 'pending':
            return Chip(
              avatar: const Icon(Icons.schedule, size: 18),
              label: Text(tr('contact_pending')),
            );
          case 'accepted':
            final phone = request['sharedPhoneNumber'];
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(tr('contact_accepted')),
                if (phone is String && phone.isNotEmpty)
                  SelectableText('${tr('contact_phone_shared')}: $phone')
                else
                  Text(tr('contact_no_phone')),
              ],
            );
          default:
            return TextButton.icon(
              onPressed: onRequest,
              icon: const Icon(Icons.refresh),
              label: Text(tr('request_contact')),
            );
        }
      },
    );
  }
}

class WorkerContactRequestsScreen extends StatelessWidget {
  const WorkerContactRequestsScreen({super.key});

  Future<void> _setRequestStatus(
    BuildContext context,
    DocumentReference<Map<String, dynamic>> requestRef,
    String status, {
    bool sharePhone = true,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final data = <String, dynamic>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (status == 'accepted' && sharePhone) {
        final profile = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final phone = user.phoneNumber ?? profile.data()?['phoneNumber'];
        if (phone is String && phone.trim().isNotEmpty) {
          data['sharedPhoneNumber'] = phone.trim();
        }
      }
      await requestRef.update(data);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${tr('contact_action_error')} $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(body: Center(child: Text(tr('login_continue'))));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('contact_requests')),
        backgroundColor: navy,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('publicWorkers')
            .doc(uid)
            .collection('contactRequests')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '${tr('contact_action_error')}\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text(tr('contact_requests_empty')));
          }
          return ListView(
            children: snapshot.data!.docs.map((requestDoc) {
              final request = requestDoc.data();
              final status = '${request['status'] ?? 'pending'}';
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person_outline),
                  ),
                  title: Text('${request['customerName'] ?? tr('customer')}'),
                  subtitle: Text(
                    [
                      status == 'pending'
                          ? tr('contact_worker_pending')
                          : status == 'accepted'
                          ? tr('contact_you_accepted')
                          : tr('contact_status_declined'),
                      if ((request['serviceTitle'] ?? '').toString().isNotEmpty)
                        '${tr('service_needed')}: ${request['serviceTitle']}',
                      if ((request['serviceDetails'] ?? '')
                          .toString()
                          .isNotEmpty)
                        '${tr('service_details')}: ${request['serviceDetails']}',
                      if ((request['serviceLocation'] ?? '')
                          .toString()
                          .isNotEmpty)
                        '${tr('service_location')}: ${request['serviceLocation']}',
                      if ((request['budgetNote'] ?? '').toString().isNotEmpty)
                        '${tr('service_budget_optional')}: ₹${request['budgetNote']}',
                      if (request['quoteRequired'] == true) tr('quote_pending'),
                    ].join('\n'),
                  ),
                  isThreeLine: true,
                  trailing: status != 'pending'
                      ? null
                      : PopupMenuButton<String>(
                          tooltip: tr('contact_requests'),
                          onSelected: (choice) => _setRequestStatus(
                            context,
                            requestDoc.reference,
                            choice == 'rejected' ? 'rejected' : 'accepted',
                            sharePhone: choice == 'accept_with_phone',
                          ),
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'accept_with_phone',
                              child: Text(tr('contact_accept')),
                            ),
                            PopupMenuItem(
                              value: 'accepted',
                              child: Text(tr('contact_accept_no_phone')),
                            ),
                            PopupMenuItem(
                              value: 'rejected',
                              child: Text(tr('contact_decline')),
                            ),
                          ],
                        ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// ============================================================
// HOME
// ============================================================

class NearbyJobsMapScreen extends StatefulWidget {
  const NearbyJobsMapScreen({super.key});

  @override
  State<NearbyJobsMapScreen> createState() => _NearbyJobsMapScreenState();
}

class _NearbyJobsMapScreenState extends State<NearbyJobsMapScreen>
    with LanguageAwareState<NearbyJobsMapScreen> {
  static const ll.LatLng _defaultCenter = ll.LatLng(20.5937, 78.9629);
  final fm.MapController _mapController = fm.MapController();
  Position? _currentPosition;
  bool _nearbyOnly = false;
  double _radiusKm = 5;
  bool _locating = false;
  bool _workerProfileLoaded = false;
  String? _workerDepartment;
  String? _workerSkill;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _customerRequests = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _requestSubscription;

  @override
  void initState() {
    super.initState();
    _loadWorkerProfile();
    _requestSubscription = FirebaseFirestore.instance
        .collection('serviceRequests')
        .where('status', isEqualTo: 'open')
        .snapshots()
        .listen((snapshot) {
          if (mounted) setState(() => _customerRequests = snapshot.docs);
        });
  }

  @override
  void dispose() {
    _requestSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadWorkerProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final publicDoc = await FirebaseFirestore.instance
            .collection('publicWorkers')
            .doc(user.uid)
            .get();
        _workerDepartment = doc.data()?['department']?.toString();
        _workerSkill = doc.data()?['skill']?.toString();
        final publicData = publicDoc.data();
        if (publicData?['mapVisible'] == true &&
            publicData?['latitude'] is num &&
            publicData?['longitude'] is num) {
          _currentPosition = Position(
            longitude: (publicData!['longitude'] as num).toDouble(),
            latitude: (publicData['latitude'] as num).toDouble(),
            timestamp: DateTime.now(),
            accuracy: 100,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );
        }
      }
    } catch (_) {
      // Fail closed: do not show unrelated work if the worker profile cannot load.
    } finally {
      if (mounted) setState(() => _workerProfileLoaded = true);
    }
  }

  Future<void> _locateMe() async {
    setState(() => _locating = true);
    try {
      final position = await requestCurrentDevicePosition();
      if (!mounted) return;
      setState(() => _currentPosition = position);
      _mapController.move(ll.LatLng(position.latitude, position.longitude), 12);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${workerTr('location_permission_needed')} $e'),
          ),
        );
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  double? _distanceKm(Map<String, dynamic> job) {
    final position = _currentPosition;
    final latitude = job['latitude'];
    final longitude = job['longitude'];
    if (position == null || latitude is! num || longitude is! num) return null;
    return Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          latitude.toDouble(),
          longitude.toDouble(),
        ) /
        1000;
  }

  Future<void> _toggleNearbyOnly(bool value) async {
    if (value && _currentPosition == null) await _locateMe();
    if (!mounted) return;
    setState(() => _nearbyOnly = value && _currentPosition != null);
  }

  Future<void> _chooseCustomRadius() async {
    final controller = TextEditingController(
      text: _radiusKm.toStringAsFixed(0),
    );
    String? error;
    final radius = await showDialog<double>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(tr('radius_custom_title')),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: tr('radius_choose'),
              suffixText: 'km',
              errorText: error,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(tr('cancel')),
            ),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(controller.text.trim());
                if (value == null || value < 1 || value > 200) {
                  setDialogState(() => error = tr('radius_custom_invalid'));
                  return;
                }
                Navigator.pop(dialogContext, value);
              },
              child: Text(tr('continue')),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (radius == null || !mounted) return;
    setState(() => _radiusKm = radius);
    await _toggleNearbyOnly(true);
  }

  Future<void> _selectRadius(String value) async {
    if (value == 'custom') {
      await _chooseCustomRadius();
      return;
    }
    final radius = double.tryParse(value);
    if (radius == null || !mounted) return;
    setState(() => _radiusKm = radius);
    await _toggleNearbyOnly(true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(workerTr('nearby_map')),
      actions: [
        const LanguagePickerButton(foregroundColor: Colors.white),
        IconButton(
          tooltip: tr('use_location'),
          onPressed: _locating ? null : _locateMe,
          icon: _locating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location),
        ),
      ],
    ),
    body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .where('status', isEqualTo: 'open')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                '${tr('jobs_load_failed')}\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        if (!_workerProfileLoaded)
          return const Center(child: CircularProgressIndicator());
        final jobs = snapshot.data!.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .where((job) {
              if (!workerJobMatchesProfile(
                job,
                department: _workerDepartment,
                skill: _workerSkill,
              ))
                return false;
              final distance = _distanceKm(job);
              return !_nearbyOnly ||
                  (distance != null && distance <= _radiusKm);
            })
            .toList();
        jobs.sort((a, b) {
          final aDistance = _distanceKm(a);
          final bDistance = _distanceKm(b);
          if (aDistance == null) return bDistance == null ? 0 : 1;
          if (bDistance == null) return -1;
          return aDistance.compareTo(bDistance);
        });
        final mappableJobs = jobs
            .where((job) => job['latitude'] is num && job['longitude'] is num)
            .toList();
        final matchingRequests = _customerRequests.where((requestDoc) {
          final request = requestDoc.data();
          final requestSkill = '${request['skill'] ?? ''}'.trim().toLowerCase();
          final workerSkill = (_workerSkill ?? '').trim().toLowerCase();
          final requestDepartment = '${request['department'] ?? ''}'
              .trim()
              .toLowerCase();
          final workerDepartment = (_workerDepartment ?? '')
              .trim()
              .toLowerCase();
          final position = _currentPosition;
          final latitude = request['latitude'];
          final longitude = request['longitude'];
          final hasBothDepartments =
              requestDepartment.isNotEmpty && workerDepartment.isNotEmpty;
          if (hasBothDepartments) {
            if (requestDepartment != workerDepartment) return false;
          } else if (workerSkill.isEmpty || requestSkill != workerSkill) {
            return false;
          }
          if (position == null || latitude is! num || longitude is! num) {
            return false;
          }
          final distance = Geolocator.distanceBetween(
                position.latitude,
                position.longitude,
                latitude.toDouble(),
                longitude.toDouble(),
              ) /
              1000;
          final requestRadius = request['radiusKm'];
          return distance <=
                  (requestRadius is num ? requestRadius.toDouble() : 10) &&
              (!_nearbyOnly || distance <= _radiusKm);
        }).toList();
        final markers = <fm.Marker>[
          if (_currentPosition != null)
            fm.Marker(
              point: ll.LatLng(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
              ),
              width: 44,
              height: 48,
              child: const Icon(Icons.my_location, color: navy, size: 32),
            ),
          for (final job in mappableJobs)
            fm.Marker(
              point: ll.LatLng(
                (job['latitude'] as num).toDouble(),
                (job['longitude'] as num).toDouble(),
              ),
              width: 48,
              height: 54,
              child: Tooltip(
                message:
                    '${catalogLabel(job['title'] ?? tr('job_title'))} · ${job['location'] ?? ''}',
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JobDetailsScreen(job: job),
                    ),
                  ),
                  child: const Icon(Icons.location_on, color: red, size: 42),
                ),
              ),
            ),
          for (final requestDoc in matchingRequests)
            fm.Marker(
              point: ll.LatLng(
                (requestDoc.data()['latitude'] as num).toDouble(),
                (requestDoc.data()['longitude'] as num).toDouble(),
              ),
              width: 50,
              height: 56,
              child: Tooltip(
                message:
                    '${catalogLabel(requestDoc.data()['title'])} · ${tr('available_worker_requests')}',
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AvailableServiceRequestsScreen(
                        requestId: requestDoc.id,
                        initialPosition: _currentPosition,
                      ),
                    ),
                  ),
                  child: const Icon(
                    Icons.work_history,
                    color: green,
                    size: 42,
                  ),
                ),
              ),
            ),
        ];
        final mapCenter = _currentPosition != null
            ? ll.LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
            : mappableJobs.isNotEmpty
            ? ll.LatLng(
                (mappableJobs.first['latitude'] as num).toDouble(),
                (mappableJobs.first['longitude'] as num).toDouble(),
              )
            : _defaultCenter;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  FilterChip(
                    label: Text(
                      tr('radius_within').replaceAll(
                        '{radius}',
                        _radiusKm == _radiusKm.roundToDouble()
                            ? _radiusKm.toStringAsFixed(0)
                            : _radiusKm.toStringAsFixed(1),
                      ),
                    ),
                    selected: _nearbyOnly,
                    onSelected: _toggleNearbyOnly,
                  ),
                  PopupMenuButton<String>(
                    tooltip: tr('radius_choose'),
                    icon: const Icon(Icons.tune),
                    onSelected: _selectRadius,
                    itemBuilder: (context) => [
                      for (final radius in [5, 10, 15, 20])
                        PopupMenuItem(
                          value: '$radius',
                          child: Text(
                            tr('radius_within')
                                .replaceAll('{radius}', '$radius'),
                          ),
                        ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'custom',
                        child: Text(tr('radius_custom')),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${jobs.length} ${workerTr('open_jobs_count')} · ${mappableJobs.length} ${workerTr('with_coordinates')} · ${matchingRequests.length} ${tr('service_request_count')}',
                      style: const TextStyle(color: greyText),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: fm.FlutterMap(
                      mapController: _mapController,
                      options: fm.MapOptions(
                        initialCenter: mapCenter,
                        initialZoom:
                            _currentPosition != null || mappableJobs.isNotEmpty
                            ? 12
                            : 5,
                      ),
                      children: [
                        fm.TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.coolie',
                          maxZoom: 19,
                        ),
                        fm.MarkerLayer(markers: markers),
                        fm.RichAttributionWidget(
                          alignment: fm.AttributionAlignment.bottomRight,
                          attributions: [
                            fm.TextSourceAttribution(
                              '© OpenStreetMap contributors',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        workerTr('next_jobs'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: jobs.isEmpty && matchingRequests.isEmpty
                        ? Center(
                            child: Text(
                              (_workerDepartment == null ||
                                          _workerDepartment!.isEmpty) &&
                                      (_workerSkill == null ||
                                          _workerSkill!.isEmpty)
                                  ? tr('profile_complete_title')
                                  : tr('no_jobs'),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView(
                            children: jobs
                                .map(
                                  (job) => ListTile(
                                    leading: const Icon(Icons.work_outline),
                                    title: Text(
                                      catalogLabel(
                                        job['title'] ?? tr('job_title'),
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${job['location'] ?? tr('location_label')}${_distanceKm(job) == null ? '' : ' · ${_distanceKm(job)!.toStringAsFixed(1)} km'}',
                                    ),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            JobDetailsScreen(job: job),
                                      ),
                                    ),
                                  ),
                                )
                                .toList()
                              ..addAll(
                                matchingRequests.map((requestDoc) {
                                  final request = requestDoc.data();
                                  final distance = _distanceKm(request);
                                  return ListTile(
                                    leading: const Icon(
                                      Icons.work_history_outlined,
                                      color: green,
                                    ),
                                    title: Text(catalogLabel(request['title'])),
                                    subtitle: Text(
                                      '${request['location'] ?? tr('location_label')}${distance == null ? '' : ' · ${distance.toStringAsFixed(1)} km'}',
                                    ),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            AvailableServiceRequestsScreen(
                                              requestId: requestDoc.id,
                                              initialPosition: _currentPosition,
                                            ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}

class WorkerMapVisibilityScreen extends StatefulWidget {
  const WorkerMapVisibilityScreen({super.key});

  @override
  State<WorkerMapVisibilityScreen> createState() =>
      _WorkerMapVisibilityScreenState();
}

class _WorkerMapVisibilityScreenState extends State<WorkerMapVisibilityScreen>
    with LanguageAwareState<WorkerMapVisibilityScreen> {
  bool _saving = false;

  Future<void> _setVisible(bool visible) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      final ref = FirebaseFirestore.instance
          .collection('publicWorkers')
          .doc(uid);
      if (visible) {
        final position = await requestCurrentDevicePosition();
        // Round coordinates to roughly 100 m so a home address is not exposed.
        await ref.update({
          'mapVisible': true,
          'latitude': double.parse(position.latitude.toStringAsFixed(3)),
          'longitude': double.parse(position.longitude.toStringAsFixed(3)),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(workerTr('map_location_saved'))),
          );
        }
      } else {
        await ref.update({
          'mapVisible': false,
          'latitude': FieldValue.delete(),
          'longitude': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(workerTr('map_location_removed'))),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${workerTr('location_permission_needed')} $error'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null)
      return Scaffold(body: Center(child: Text(tr('login_continue'))));
    return Scaffold(
      appBar: AppBar(
        title: Text(workerTr('worker_map_location')),
        backgroundColor: navy,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('publicWorkers')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final visible = snapshot.data?.data()?['mapVisible'] == true;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Icon(Icons.location_searching, size: 64, color: navy),
              const SizedBox(height: 16),
              Text(workerTr('map_privacy_note'), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              if (visible)
                FilledButton.tonalIcon(
                  onPressed: _saving ? null : () => _setVisible(false),
                  icon: const Icon(Icons.location_disabled_outlined),
                  label: Text(workerTr('map_stop_sharing')),
                )
              else
                FilledButton.icon(
                  onPressed: _saving ? null : () => _setVisible(true),
                  icon: const Icon(Icons.location_on_outlined),
                  label: Text(workerTr('map_share_location')),
                ),
              if (_saving)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: LinearProgressIndicator(),
                ),
            ],
          );
        },
      ),
    );
  }
}

class NearbyWorkersMapScreen extends StatefulWidget {
  final String role;

  const NearbyWorkersMapScreen({super.key, required this.role});

  @override
  State<NearbyWorkersMapScreen> createState() => _NearbyWorkersMapScreenState();
}

class _NearbyWorkersMapScreenState extends State<NearbyWorkersMapScreen>
    with LanguageAwareState<NearbyWorkersMapScreen> {
  static const ll.LatLng _defaultCenter = ll.LatLng(20.5937, 78.9629);
  final fm.MapController _mapController = fm.MapController();
  Position? _position;
  bool _locating = false;
  double _radiusKm = 20;
  String _search = '';

  Future<void> _locate() async {
    setState(() => _locating = true);
    try {
      final position = await requestCurrentDevicePosition();
      if (!mounted) return;
      setState(() => _position = position);
      _mapController.move(ll.LatLng(position.latitude, position.longitude), 12);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${workerTr('location_permission_needed')} $error'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  double? _distance(Map<String, dynamic> worker) {
    final position = _position;
    final lat = worker['latitude'];
    final lng = worker['longitude'];
    if (position == null || lat is! num || lng is! num) return null;
    return Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          lat.toDouble(),
          lng.toDouble(),
        ) /
        1000;
  }

  void _openWorker(Map<String, dynamic> worker) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${worker['name'] ?? tr('worker_role')}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '${catalogLabel(worker['skill'])} · ${catalogLabel(worker['department'])}',
              ),
              if ('${worker['location'] ?? ''}'.isNotEmpty)
                Text('${worker['location']}'),
              if (_distance(worker) != null)
                Text('${_distance(worker)!.toStringAsFixed(1)} km'),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => widget.role == 'customer'
                          ? CustomerFindWorkersScreen(
                              initialDepartment: worker['department']
                                  ?.toString(),
                              initialSkill: worker['skill']?.toString(),
                            )
                          : PostJobScreen(
                              initialDepartment: worker['department']
                                  ?.toString(),
                              initialSkill: worker['skill']?.toString(),
                            ),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward),
                label: Text(tr('continue')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(workerTr('map_nearby_workers')),
      backgroundColor: navy,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          tooltip: tr('use_location'),
          onPressed: _locating ? null : _locate,
          icon: _locating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location),
        ),
      ],
    ),
    body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('publicWorkers')
          .where('mapVisible', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(
            child: Text('${workerTr('jobs_load_failed')} ${snapshot.error}'),
          );
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final workers =
            snapshot.data!.docs.map((doc) => {...doc.data(), 'id': doc.id}).where((
              worker,
            ) {
              if (worker['available'] != true) return false;
              final searchable =
                  '${worker['name'] ?? ''} ${worker['skill'] ?? ''} ${worker['department'] ?? ''} ${worker['location'] ?? ''}'
                      .toLowerCase();
              if (!searchable.contains(_search.trim().toLowerCase()))
                return false;
              final distance = _distance(worker);
              return distance == null || distance <= _radiusKm;
            }).toList()..sort(
              (a, b) => (_distance(a) ?? double.infinity).compareTo(
                _distance(b) ?? double.infinity,
              ),
            );
        final markers = <fm.Marker>[
          if (_position != null)
            fm.Marker(
              point: ll.LatLng(_position!.latitude, _position!.longitude),
              width: 42,
              height: 46,
              child: const Icon(Icons.my_location, color: navy, size: 30),
            ),
          for (final worker in workers)
            if (worker['latitude'] is num && worker['longitude'] is num)
              fm.Marker(
                point: ll.LatLng(
                  (worker['latitude'] as num).toDouble(),
                  (worker['longitude'] as num).toDouble(),
                ),
                width: 48,
                height: 56,
                child: Tooltip(
                  message:
                      '${worker['name'] ?? tr('worker_role')} · ${catalogLabel(worker['skill'])}',
                  child: InkWell(
                    onTap: () => _openWorker(worker),
                    child: const Icon(
                      Icons.location_on,
                      color: orange,
                      size: 42,
                    ),
                  ),
                ),
              ),
        ];
        final center = _position != null
            ? ll.LatLng(_position!.latitude, _position!.longitude)
            : workers.isNotEmpty
            ? ll.LatLng(
                (workers.first['latitude'] as num).toDouble(),
                (workers.first['longitude'] as num).toDouble(),
              )
            : _defaultCenter;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: TextField(
                onChanged: (value) => setState(() => _search = value),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: tr('worker_search_hint'),
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${workers.length} ${workerTr('map_workers_count')}',
                    ),
                  ),
                  DropdownButton<double>(
                    value: _radiusKm,
                    onChanged: (value) {
                      if (value != null) setState(() => _radiusKm = value);
                    },
                    items: [5, 10, 15, 20]
                        .map(
                          (radius) => DropdownMenuItem<double>(
                            value: radius.toDouble(),
                            child: Text(
                              tr('radius_within')
                                  .replaceAll('{radius}', '$radius'),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: fm.FlutterMap(
                mapController: _mapController,
                options: fm.MapOptions(
                  initialCenter: center,
                  initialZoom: _position != null || workers.isNotEmpty ? 12 : 5,
                ),
                children: [
                  fm.TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.coolie',
                    maxZoom: 19,
                  ),
                  fm.MarkerLayer(markers: markers),
                  fm.RichAttributionWidget(
                    alignment: fm.AttributionAlignment.bottomRight,
                    attributions: [
                      fm.TextSourceAttribution('© OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: workers.isEmpty
                  ? Center(child: Text(workerTr('map_no_workers')))
                  : ListView(
                      children: workers
                          .map(
                            (worker) => ListTile(
                              leading: const Icon(
                                Icons.engineering_outlined,
                                color: orange,
                              ),
                              title: Text(
                                '${worker['name'] ?? tr('worker_role')}',
                              ),
                              subtitle: Text(
                                '${catalogLabel(worker['skill'])} · ${catalogLabel(worker['department'])}${_distance(worker) == null ? '' : ' · ${_distance(worker)!.toStringAsFixed(1)} km'}',
                              ),
                              onTap: () => _openWorker(worker),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        );
      },
    ),
  );
}

class VoiceAssistantScreen extends StatefulWidget {
  final String role;

  const VoiceAssistantScreen({super.key, required this.role});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  final SpeechToText _speech = SpeechToText();
  String transcript = '';
  String? message;
  bool listening = false;
  bool initializing = false;
  bool _speechReady = false;
  bool _commandRunning = false;
  String? _handledResult;

  @override
  void dispose() {
    unawaited(_speech.cancel());
    unawaited(appTts.stop());
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (listening) {
      await _speech.stop();
      if (mounted) setState(() => listening = false);
      return;
    }
    if (mounted) {
      setState(() {
        initializing = true;
        message = null;
        transcript = '';
        _handledResult = null;
      });
    }
    try {
      if (!_speechReady) {
        _speechReady = await _speech.initialize(
          onStatus: (status) {
            if (mounted) setState(() => listening = status == 'listening');
          },
          onError: (_) {
            if (mounted) {
              setState(() {
                listening = false;
                initializing = false;
                message = voiceAssistantTr('voice_speech_unavailable');
              });
            }
          },
        );
      }
      if (!_speechReady) {
        if (mounted) {
          setState(() {
            initializing = false;
            message = voiceAssistantTr('voice_speech_unavailable');
          });
        }
        return;
      }
      await _speech.listen(
        listenOptions: SpeechListenOptions(
          localeId: _speechLocaleFor(appLanguage.value),
        ),
        onResult: (result) {
          if (!mounted) return;
          setState(() => transcript = result.recognizedWords);
          if (result.finalResult &&
              result.recognizedWords.trim().isNotEmpty &&
              _handledResult != result.recognizedWords) {
            _handledResult = result.recognizedWords;
            unawaited(_handleCommand(result.recognizedWords));
          }
        },
      );
      if (mounted) {
        setState(() {
          initializing = false;
          listening = _speech.isListening;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          initializing = false;
          listening = false;
          message = voiceAssistantTr('voice_speech_unavailable');
        });
      }
    }
  }

  bool _containsAny(String text, List<String> terms) =>
      terms.any(text.contains);

  Future<void> _speakHelp() async {
    final helpKey = switch (widget.role) {
      'employer' => 'voice_help_employer',
      'customer' => 'voice_help_customer',
      _ => 'voice_help_worker',
    };
    final helpText = voiceAssistantTr(helpKey);
    if (mounted) setState(() => message = helpText);
    try {
      await appTts.setLanguage(_speechLocaleFor(appLanguage.value));
      await appTts.speak(helpText);
    } catch (_) {
      if (mounted) {
        setState(() => message = voiceAssistantTr('voice_audio_unavailable'));
      }
    }
  }

  Widget? _pageForCommand(String command) {
    final text = command.toLowerCase().trim();
    if (text.isEmpty) return null;
    final asksToPost = _containsAny(text, [
      'post',
      'create',
      'பதிவு',
      'போடு',
      'போஸ்ட்',
      'पोस्ट',
      'प्रकाशित',
      'పోస్ట్',
      'ప్రచురించు',
      'ಪೋಸ್ಟ್',
      'ಪ್ರಕಟಿಸು',
      'പോസ്റ്റ്',
      'പ്രസിദ്ധീകരി',
    ]);
    final asksApplicants = _containsAny(text, [
      'applicant',
      'applications',
      'accept',
      'விண்ணப்ப',
      'ஏற்றுக்கொள்',
      'आवेदन',
      'स्वीकार',
      'దరఖాస్తు',
      'అంగీకరించు',
      'ಅರ್ಜಿ',
      'ಒಪ್ಪಿಕೊ',
      'അപേക്ഷ',
      'സ്വീകരിക്കു',
    ]);
    final asksDepartments = _containsAny(text, [
      'department',
      'துறை',
      'विभाग',
      'విభాగ',
      'ವಿಭಾಗ',
      'വിഭാഗ',
    ]);
    final asksMap = _containsAny(text, [
      'nearby',
      'map',
      'location',
      'அருகில்',
      'வரைபட',
      'இடம்',
      'पास',
      'नज़दीक',
      'मैप',
      'దగ్గర',
      'మ్యాప్',
      'స్థానం',
      'ಹತ್ತಿರ',
      'ನಕ್ಷೆ',
      'ಸ್ಥಳ',
      'അടുത്ത്',
      'മാപ്പ്',
      'സ്ഥലം',
    ]);
    final asksFinance = _containsAny(text, [
      'payment',
      'finance',
      'earning',
      'money',
      'பணம்',
      'கட்டணம்',
      'வருமான',
      'பேமெண்ட்',
      'भुगतान',
      'पैसा',
      'कमाई',
      'చెల్లింప',
      'ఆదాయం',
      'ಹಣ',
      'ಪಾವತಿ',
      'ಆದಾಯ',
      'പണം',
      'വരുമാനം',
    ]);
    final asksWorkers = _containsAny(text, [
      'find worker',
      'search worker',
      'workers',
      'தொழிலாள',
      'வேலைக்கார',
      'कामगार',
      'काम खोज',
      'కార్మిక',
      'కూలీల',
      'ಕಾರ್ಮಿಕ',
      'ಕೆಲಸಗಾರ',
      'തൊഴിലാള',
    ]);
    final asksRequests = _containsAny(text, [
      'notification',
      'request',
      'அறிவிப்ப',
      'தொடர்பு கோரிக்கை',
      'सूचना',
      'अनुरोध',
      'నోటిఫికేషన్',
      'అభ్యర్థన',
      'ಅಧಿಸೂಚನೆ',
      'ಕೋರಿಕೆ',
      'അറിയിപ്പ',
      'അഭ്യർത്ഥന',
    ]);
    final asksApplications = _containsAny(text, [
      'my application',
      'application status',
      'என் விண்ணப்ப',
      'என் விண்ணப்பம்',
      'मेरे आवेदन',
      'నా దరఖాస్తు',
      'ನನ್ನ ಅರ್ಜಿ',
      'എന്റെ അപേക്ഷ',
    ]);
    final asksAvailability = _containsAny(text, [
      'availability',
      'available for work',
      'வேலை கிடைக்க',
      'வேலைக்கு கிடைக்க',
      'उपलब्ध',
      'పని అందుబాటులో',
      'ಕೆಲಸಕ್ಕೆ ಲಭ್ಯ',
      'ജോലിക്ക് ലഭ്യ',
    ]);
    final asksTracking = _containsAny(text, [
      'share location',
      'live tracking',
      'live location',
      'இருப்பிடத்தை பகிர',
      'நேரடி இருப்பிடம்',
      'स्थान साझा',
      'లైవ్ లొకేషన్',
      'ಸ್ಥಳ ಹಂಚಿ',
      'തത്സമയ സ്ഥലം',
    ]);
    final asksProfile = _containsAny(text, [
      'profile',
      'account',
      'சுயவிவர',
      'கணக்கு',
      'प्रोफ़ाइल',
      'खाता',
      'ప్రొఫైల్',
      'ఖాతా',
      'ಪ್ರೊಫೈಲ್',
      'ಖಾತೆ',
      'പ്രൊഫൈൽ',
      'അക്കൗണ്ട്',
    ]);
    final asksJobs = _containsAny(text, [
      'job',
      'jobs',
      'work',
      'வேலை',
      'வேலைகள்',
      'काम',
      'नौकरी',
      'పని',
      'ఉద్యోగ',
      'ಕೆಲಸ',
      'ಕೆಲಸಗಳು',
      'ಜೋಲಿ',
      'ജോലി',
      'ജോലികൾ',
    ]);

    if (asksToPost && widget.role == 'employer') return const PostJobScreen();
    if (asksApplicants && widget.role == 'employer') {
      return const EmployerApplicantsScreen();
    }
    if (asksApplications && widget.role == 'worker') {
      return const MyApplicationsScreen();
    }
    if (asksDepartments) return const DepartmentsScreen();
    if (asksMap && widget.role == 'worker') return const NearbyJobsMapScreen();
    if (asksFinance && widget.role == 'worker') return const FinanceScreen();
    if (asksFinance && widget.role == 'employer') {
      return const EmployerJobsScreen();
    }
    if (asksTracking && widget.role == 'worker') {
      return const WorkerLiveLocationScreen();
    }
    if (asksAvailability && widget.role == 'worker') {
      return const WorkerAvailabilityScreen();
    }
    if (asksRequests && widget.role == 'worker') {
      return const WorkerContactRequestsScreen();
    }
    if (asksRequests && widget.role == 'employer') {
      return const EmployerNotificationsScreen();
    }
    if (asksProfile) return ProfileScreen(role: widget.role);
    if (asksWorkers && ['employer', 'customer'].contains(widget.role)) {
      return const CustomerFindWorkersScreen();
    }
    if (asksJobs && widget.role == 'worker') return const FindWorkScreen();
    if (asksJobs && widget.role == 'employer') {
      return const EmployerJobsScreen();
    }
    if (widget.role == 'customer' && (asksJobs || asksWorkers)) {
      return const CustomerFindWorkersScreen();
    }
    return null;
  }

  Future<void> _handleCommand(String command) async {
    if (_commandRunning) return;
    _commandRunning = true;
    final page = _pageForCommand(command);
    if (page == null) {
      if (mounted) {
        setState(() => message = voiceAssistantTr('voice_not_understood'));
      }
      _commandRunning = false;
      return;
    }
    if (mounted) setState(() => message = voiceAssistantTr('voice_opening'));
    try {
      await appTts.setLanguage(_speechLocaleFor(appLanguage.value));
      await appTts.speak(voiceAssistantTr('voice_opening'));
    } catch (_) {
      // Navigation remains available if this device cannot speak the response.
    }
    if (!mounted) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    _commandRunning = false;
  }

  @override
  Widget build(BuildContext context) {
    final commands = widget.role == 'employer'
        ? <(String, String)>[
            (tr('post_job'), 'post job'),
            (tr('applicants'), 'applicants'),
            (tr('my_jobs'), 'my jobs'),
            (tr('departments'), 'departments'),
            (tr('find_workers'), 'find workers'),
          ]
        : widget.role == 'customer'
        ? <(String, String)>[
            (tr('find_workers'), 'find workers'),
            (tr('departments'), 'departments'),
            (tr('profile'), 'profile'),
          ]
        : <(String, String)>[
            (tr('find_work'), 'jobs'),
            (tr('my_applications'), 'my applications'),
            (tr('finance'), 'payments'),
            (tr('nearby_jobs'), 'nearby jobs'),
          ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: Text(voiceAssistantTr('voice_assistant')),
        actions: const [LanguagePickerButton(foregroundColor: Colors.white)],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                voiceAssistantTr('voice_assistant_hint'),
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Center(
                child: OutlinedButton.icon(
                  onPressed: _speakHelp,
                  icon: const Icon(Icons.volume_up_outlined),
                  label: Text(voiceAssistantTr('voice_hear_help')),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 112,
                  height: 112,
                  child: FilledButton(
                    onPressed: initializing ? null : _toggleListening,
                    style: FilledButton.styleFrom(
                      backgroundColor: listening ? red : navy,
                      shape: const CircleBorder(),
                    ),
                    child: initializing
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Icon(listening ? Icons.stop : Icons.mic, size: 44),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                listening
                    ? voiceAssistantTr('voice_listening')
                    : voiceAssistantTr('voice_assistant'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: navy,
                ),
              ),
              if (transcript.isNotEmpty) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(transcript, textAlign: TextAlign.center),
                  ),
                ),
              ],
              if (message != null) ...[
                const SizedBox(height: 12),
                Text(message!, textAlign: TextAlign.center),
              ],
              const SizedBox(height: 28),
              Text(
                voiceAssistantTr('voice_try_commands'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: commands
                    .map(
                      (item) => ActionChip(
                        avatar: const Icon(Icons.arrow_outward, size: 16),
                        label: Text(item.$1),
                        onPressed: () => _handleCommand(item.$2),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: lightOrange,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(voiceAssistantTr('voice_safe_actions')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final String? role;
  const HomeScreen({super.key, this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8),
          child: MrCoolieBrandMark(size: 36),
        ),
        title: const Text(
          'Mr. Coolie',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          LanguagePickerButton(foregroundColor: Colors.white),
          if (role == 'employer') _EmployerNotificationButton(),
          if (role == 'worker') _WorkerContactRequestsButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VoiceAssistantScreen(role: role ?? 'worker'),
          ),
        ),
        icon: const Icon(Icons.mic),
        label: Text(voiceAssistantTr('voice_assistant')),
        backgroundColor: orange,
        foregroundColor: Colors.white,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.sizeOf(context).width < 600 ? 16 : 28,
              vertical: 22,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [navy, Color(0xFF1E4668)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22102A43),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const MrCoolieBrandMark(size: 54),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${tr('hello')}, ${currentUserDisplayName()}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              tr('tagline'),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                role == 'employer'
                                    ? tr('employer')
                                    : role == 'customer'
                                    ? tr('customer')
                                    : tr('worker'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                if (role == 'worker') ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WorkerContactRequestsScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.notifications_outlined),
                      label: Text(tr('contact_requests')),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const _WorkerServiceRequestButton(),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WorkerMapVisibilityScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.location_on_outlined),
                      label: Text(workerTr('worker_map_location')),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth < 640
                        ? 1
                        : constraints.maxWidth >= 900
                        ? 3
                        : 2;
                    final actionWidth = columns == 1
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 12 * (columns - 1)) / columns;
                    final firstAction = role == 'employer'
                        ? _actionCard(
                            context,
                            Icons.add_business,
                            tr('post_job'),
                            tr('find_right_worker'),
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PostJobScreen(),
                              ),
                            ),
                          )
                        : role == 'customer'
                        ? _actionCard(
                            context,
                            Icons.person_search,
                            tr('find_workers'),
                            tr('search_available_workers'),
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const CustomerFindWorkersScreen(),
                              ),
                            ),
                          )
                        : _actionCard(
                            context,
                            Icons.search,
                            tr('find_jobs_action'),
                            tr('browse_nearby_jobs'),
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FindWorkScreen(),
                              ),
                            ),
                          );
                    final secondAction = role == 'employer'
                        ? _actionCard(
                            context,
                            Icons.work_outline,
                            tr('my_jobs'),
                            tr('manage_job_posts'),
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EmployerJobsScreen(),
                              ),
                            ),
                          )
                        : role == 'customer'
                        ? _actionCard(
                            context,
                            Icons.grid_view,
                            tr('departments'),
                            tr('popular_departments'),
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DepartmentsScreen(),
                              ),
                            ),
                          )
                        : _actionCard(
                            context,
                            Icons.map_outlined,
                            tr('nearby_jobs'),
                            tr('browse_nearby_jobs'),
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NearbyJobsMapScreen(),
                              ),
                            ),
                          );
                    final customerPostJobAction = role == 'customer'
                        ? _actionCard(
                            context,
                            Icons.work_outline,
                            tr('post_job'),
                            tr('post_job_to_receive'),
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const CustomerServiceRequestForm(),
                              ),
                            ),
                          )
                        : null;
                    final customerPostedJobsAction = role == 'customer'
                        ? _actionCard(
                            context,
                            Icons.work_history_outlined,
                            tr('posted_jobs'),
                            tr('my_jobs'),
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const CustomerServiceRequestsScreen(),
                              ),
                            ),
                          )
                        : null;
                    final departmentAction = role == 'employer'
                        ? _actionCard(
                            context,
                            Icons.grid_view,
                            tr('departments'),
                            tr('popular_departments'),
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DepartmentsScreen(),
                              ),
                            ),
                          )
                        : null;
                    final workerMapAction =
                        role == 'employer' || role == 'customer'
                        ? _actionCard(
                            context,
                            Icons.map_outlined,
                            tr('find_workers'),
                            workerTr('map_nearby_workers'),
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    NearbyWorkersMapScreen(role: role!),
                              ),
                            ),
                          )
                        : null;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(width: actionWidth, child: firstAction),
                        SizedBox(width: actionWidth, child: secondAction),
                        if (customerPostJobAction != null)
                          SizedBox(
                            width: actionWidth,
                            child: customerPostJobAction,
                          ),
                        if (customerPostedJobsAction != null)
                          SizedBox(
                            width: actionWidth,
                            child: customerPostedJobsAction,
                          ),
                        if (departmentAction != null)
                          SizedBox(width: actionWidth, child: departmentAction),
                        if (workerMapAction != null)
                          SizedBox(width: actionWidth, child: workerMapAction),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                if (role == 'worker') _earningsCard(context),

                const SizedBox(height: 25),

                if (role != 'customer') ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        role == 'employer' ? tr('my_jobs') : tr('nearby_jobs'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: navy,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => role == 'employer'
                                  ? const EmployerJobsScreen()
                                  : const FindWorkScreen(),
                            ),
                          );
                        },
                        child: Text(tr('view_all')),
                      ),
                    ],
                  ),

                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: role == 'employer'
                        ? FirebaseFirestore.instance
                              .collection('jobs')
                              .where(
                                'employerUid',
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser?.uid,
                              )
                              .limit(3)
                              .snapshots()
                        : FirebaseFirestore.instance
                              .collection('jobs')
                              .where('status', isEqualTo: 'open')
                              .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError)
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'Unable to load jobs. Check connection and Firestore rules.',
                          ),
                        );
                      if (!snapshot.hasData)
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty)
                        return Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(tr('no_jobs')),
                        );
                      Widget jobCard(
                        QueryDocumentSnapshot<Map<String, dynamic>> doc,
                      ) {
                        final job = Map<String, dynamic>.from(doc.data())
                          ..['id'] = doc.id;
                        job['payment'] ??= job['wage'];
                        job['employer'] ??= job['employerName'] ?? 'Employer';
                        job['duration'] ??= 'Not specified';
                        job['description'] ??= '';
                        return JobCard(
                          job: job,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => JobDetailsScreen(job: job),
                            ),
                          ),
                        );
                      }

                      if (role != 'worker')
                        return Column(children: docs.map(jobCard).toList());
                      return FutureBuilder<
                        DocumentSnapshot<Map<String, dynamic>>
                      >(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .get(),
                        builder: (context, profileSnapshot) {
                          if (profileSnapshot.connectionState ==
                              ConnectionState.waiting)
                            return const Padding(
                              padding: EdgeInsets.all(12),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          final profile =
                              profileSnapshot.data?.data() ??
                              <String, dynamic>{};
                          final matchingDocs = docs
                              .where(
                                (doc) => workerJobMatchesProfile(
                                  doc.data(),
                                  department: profile['department']?.toString(),
                                  skill: profile['skill']?.toString(),
                                ),
                              )
                              .take(3)
                              .toList();
                          if (matchingDocs.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                (profile['department'] == null ||
                                            '${profile['department']}'
                                                .isEmpty) &&
                                        (profile['skill'] == null ||
                                            '${profile['skill']}'.isEmpty)
                                    ? tr('profile_complete_title')
                                    : tr('no_jobs'),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return Column(
                            children: matchingDocs.map(jobCard).toList(),
                          );
                        },
                      );
                    },
                  ),
                ],

                if (role != 'worker') ...[
                  const SizedBox(height: 20),

                  Text(
                    tr('popular_departments'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 115,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        final department = departments[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DepartmentDetailScreen(
                                  department: department,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  department['icon'],
                                  color: orange,
                                  size: 35,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  catalogLabel(department['name']),
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: navy,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(minHeight: 104),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE6E9ED)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D102A43),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: lightOrange,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: navy, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: greyText,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 16, color: greyText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _earningsCard(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();
    final paymentStream = FirebaseFirestore.instance
        .collectionGroup('payments')
        .where('workerUid', isEqualTo: uid)
        .snapshots();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: paymentStream,
      builder: (context, snapshot) {
        var weekTotal = 0.0;
        if (snapshot.hasData) {
          final now = DateTime.now();
          final weekStart = DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(Duration(days: now.weekday - 1));
          for (final doc in snapshot.data!.docs) {
            final data = doc.data();
            final paidAt = data['workerConfirmedAt'];
            final amount = data['amount'];
            if (data['status'] == 'worker_confirmed' &&
                amount is num &&
                paidAt is Timestamp &&
                !paidAt.toDate().isBefore(weekStart)) {
              weekTotal += amount.toDouble();
            }
          }
        }
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [navy, Color(0xFF1E4668)]),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('this_week_earnings'),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                snapshot.hasError
                    ? '?'
                    : snapshot.hasData
                    ? '?${weekTotal.toStringAsFixed(0)}'
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tr('direct_upi_total_note'),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FinanceScreen()),
                  ),
                  child: Text(
                    tr('finance'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmployerNotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();
    final stream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .snapshots();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        final unread = snapshot.data?.docs.length ?? 0;
        return IconButton(
          tooltip: tr('notifications'),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const EmployerNotificationsScreen(),
            ),
          ),
          icon: Badge(
            isLabelVisible: unread > 0,
            label: Text('$unread'),
            child: const Icon(Icons.notifications_outlined),
          ),
        );
      },
    );
  }
}

class _WorkerContactRequestsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();
    final requests = FirebaseFirestore.instance
        .collection('publicWorkers')
        .doc(uid)
        .collection('contactRequests')
        .where('status', isEqualTo: 'pending')
        .snapshots();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: requests,
      builder: (context, snapshot) {
        final pendingCount = snapshot.data?.docs.length ?? 0;
        return IconButton(
          tooltip: tr('contact_requests'),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const WorkerContactRequestsScreen(),
            ),
          ),
          icon: Badge(
            isLabelVisible: pendingCount > 0,
            label: Text('$pendingCount'),
            child: const Icon(Icons.notifications_outlined),
          ),
        );
      },
    );
  }
}

class _WorkerServiceRequestButton extends StatelessWidget {
  const _WorkerServiceRequestButton();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, profileSnapshot) {
        final profile = profileSnapshot.data?.data() ?? const <String, dynamic>{};
        final skill = '${profile['skill'] ?? ''}'.trim().toLowerCase();
        final department = '${profile['department'] ?? ''}'
            .trim()
            .toLowerCase();
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('serviceRequests')
              .where('status', isEqualTo: 'open')
              .snapshots(),
          builder: (context, requestSnapshot) {
            final count = (requestSnapshot.data?.docs ?? const [])
                    .where((doc) {
                      final request = doc.data();
                      final requestSkill =
                          '${request['skill'] ?? ''}'.trim().toLowerCase();
                      final requestDepartment =
                          '${request['department'] ?? ''}'
                              .trim()
                              .toLowerCase();
                      final hasBothDepartments =
                          requestDepartment.isNotEmpty && department.isNotEmpty;
                      if (hasBothDepartments) {
                        return requestDepartment == department;
                      }
                      return skill.isNotEmpty && requestSkill == skill;
                    })
                    .length;
            return SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AvailableServiceRequestsScreen(),
                  ),
                ),
                icon: Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: const Icon(Icons.notifications_active_outlined),
                ),
                label: Text(tr('available_worker_requests')),
              ),
            );
          },
        );
      },
    );
  }
}

// ============================================================
// FIND WORK
// ============================================================

class FindWorkScreen extends StatefulWidget {
  final String? initialSkill;

  const FindWorkScreen({super.key, this.initialSkill});

  @override
  State<FindWorkScreen> createState() => _FindWorkScreenState();
}

class _FindWorkScreenState extends State<FindWorkScreen>
    with LanguageAwareState<FindWorkScreen> {
  String search = '';
  String? workerDepartment;
  String? workerSkill;
  final SpeechToText _speech = SpeechToText();
  bool _speechInitialized = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    search = widget.initialSkill ?? '';
    _loadWorkerPreferences();
  }

  @override
  void dispose() {
    unawaited(_speech.cancel());
    super.dispose();
  }

  Future<void> _toggleVoiceSearch() async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }
    try {
      if (!_speechInitialized) {
        _speechInitialized = await _speech.initialize(
          onStatus: (status) {
            if (mounted) setState(() => _isListening = status == 'listening');
          },
          onError: (error) {
            if (mounted) {
              setState(() => _isListening = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Voice search error: ${error.errorMsg}'),
                ),
              );
            }
          },
        );
      }
      if (!_speechInitialized) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Speech recognition is unavailable. You can type to search.',
              ),
            ),
          );
        return;
      }
      await _speech.listen(
        listenOptions: SpeechListenOptions(
          localeId: _speechLocaleFor(appLanguage.value),
        ),
        onResult: (result) {
          if (mounted) setState(() => search = result.recognizedWords);
        },
      );
      if (mounted) setState(() => _isListening = _speech.isListening);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not start voice search: $e')),
        );
    }
  }

  Future<void> _loadWorkerPreferences() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final d = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (mounted)
        setState(() {
          workerDepartment = d.data()?['department']?.toString();
          workerSkill = d.data()?['skill']?.toString();
        });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: Text(tr('find_work')),
        actions: [
          const LanguagePickerButton(foregroundColor: Colors.white),
          IconButton(
            tooltip: tr('nearby_jobs_map'),
            icon: const Icon(Icons.map_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NearbyJobsMapScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AvailableServiceRequestsScreen(),
                  ),
                ),
                icon: const Icon(Icons.home_repair_service_outlined),
                label: Text(tr('open_service_requests')),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  search = value;
                });
              },
              decoration: InputDecoration(
                hintText: tr('search_jobs'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: _isListening
                      ? tr('stop_voice_search')
                      : tr('search_by_voice'),
                  onPressed: _toggleVoiceSearch,
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? red : navy,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('jobs')
                  .where('status', isEqualTo: 'open')
                  .snapshots(),
              builder: (context, snapshot) {
                final firestoreJobs = <Map<String, dynamic>>[];
                if (snapshot.hasData) {
                  for (final doc in snapshot.data!.docs) {
                    final job = Map<String, dynamic>.from(doc.data());
                    job['id'] = doc.id;
                    firestoreJobs.add(job);
                  }
                }
                // Only show real Firestore jobs. Demo jobs must never be presented as live opportunities.
                final allJobs = firestoreJobs;
                final filteredJobs = allJobs.where((job) {
                  if (!workerJobMatchesProfile(
                    job,
                    department: workerDepartment,
                    skill: workerSkill,
                  ))
                    return false;
                  final text =
                      '${job['title'] ?? ''} ${job['department'] ?? ''} ${job['skill'] ?? ''} ${job['location'] ?? ''}'
                          .toLowerCase();
                  final matchesSearch = text.contains(search.toLowerCase());
                  return matchesSearch;
                }).toList();
                filteredJobs.sort((a, b) {
                  int matchScore(Map<String, dynamic> job) {
                    return workerSkill != null &&
                            workerSkill!.isNotEmpty &&
                            '${job['skill'] ?? ''}'.trim().toLowerCase() ==
                                workerSkill!.trim().toLowerCase()
                        ? 1
                        : 0;
                  }

                  return matchScore(b).compareTo(matchScore(a));
                });
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Could not load jobs from Firestore. Check your Firestore rules and connection.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                if (filteredJobs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        (workerDepartment == null ||
                                    workerDepartment!.isEmpty) &&
                                (workerSkill == null || workerSkill!.isEmpty)
                            ? tr('profile_complete_title')
                            : tr('no_jobs'),
                        style: const TextStyle(fontSize: 18, color: greyText),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredJobs.length,
                  itemBuilder: (context, index) {
                    final job = filteredJobs[index];
                    return JobCard(
                      job: job,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JobDetailsScreen(job: job),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// JOB CARD
// ============================================================

class JobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final VoidCallback onTap;

  const JobCard({super.key, required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: lightOrange,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.work, color: orange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      job['title'] ?? 'Job',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: navy,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Read job details aloud',
                    onPressed: () async {
                      try {
                        await appTts.setLanguage(
                          _speechLocaleFor(appLanguage.value),
                        );
                        await appTts.speak(
                          '${job['title'] ?? 'Job'}. ${job['skill'] ?? ''}. ${job['location'] ?? ''}. ${job['payment'] ?? job['wage'] ?? tr('wage_to_be_discussed')}.',
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Text to speech is unavailable: $e',
                              ),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.volume_up_outlined, color: navy),
                  ),
                  Text(
                    job['payment'] is num || job['wage'] is num
                        ? '₹${job['payment'] ?? job['wage']}'
                        : tr('wage_to_be_discussed'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                catalogLabel(job['skill'] ?? tr('skill')),
                style: const TextStyle(
                  color: greyText,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: greyText,
                  ),
                  const SizedBox(width: 4),
                  Text('${job['location'] ?? 'Location not specified'}'),
                  const SizedBox(width: 16),
                  const Icon(Icons.schedule, size: 18, color: greyText),
                  const SizedBox(width: 4),
                  Text('${job['duration'] ?? 'Flexible'}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// JOB DETAILS
// ============================================================

class JobDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen>
    with LanguageAwareState<JobDetailsScreen> {
  bool applying = false;
  bool _viewRecorded = false;
  late final Future<bool> _isWorkerAccount = _loadWorkerAccount();
  Map<String, dynamic> get job => widget.job;

  Future<bool> _loadWorkerAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      final profile = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return profile.data()?['role'] == 'worker';
    } catch (_) {
      return false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_viewRecorded) {
      _viewRecorded = true;
      _recordWorkerView();
    }
  }

  Future<void> _recordWorkerView() async {
    final user = FirebaseAuth.instance.currentUser;
    final jobId = job['id']?.toString();
    if (user == null || jobId == null || jobId.isEmpty) return;
    try {
      final db = FirebaseFirestore.instance;
      final profile = await db.collection('users').doc(user.uid).get();
      if (profile.data()?['role'] != 'worker') return;
      final jobRef = db.collection('jobs').doc(jobId);
      final viewRef = jobRef.collection('views').doc(user.uid);
      await db.runTransaction((transaction) async {
        final jobSnapshot = await transaction.get(jobRef);
        final viewSnapshot = await transaction.get(viewRef);
        if (jobSnapshot.data()?['status'] == 'open' && !viewSnapshot.exists) {
          transaction.set(viewRef, {
            'workerUid': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (_) {
      // Opening job details should still work if view analytics are unavailable.
    }
  }

  Future<void> _applyForJob() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(workerTr('please_sign_in_apply'))));
      return;
    }
    final jobId = job['id']?.toString();
    if (jobId == null || jobId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(workerTr('firestore_job_required'))),
      );
      return;
    }
    setState(() => applying = true);
    try {
      final db = FirebaseFirestore.instance;
      final userDoc = await db.collection('users').doc(user.uid).get();
      final profile = userDoc.data() ?? <String, dynamic>{};
      if (profile['role'] != 'worker') {
        throw Exception(workerTr('workers_only_apply'));
      }
      final jobRef = db.collection('jobs').doc(jobId);
      final applicationRef = jobRef.collection('applications').doc(user.uid);
      final employerUid = '${job['employerUid'] ?? ''}';
      if (employerUid.isEmpty)
        throw StateError('This job has no employer account.');
      final notificationRef = db
          .collection('users')
          .doc(employerUid)
          .collection('notifications')
          .doc('${jobRef.id}_${user.uid}');
      final alreadyApplied = await db.runTransaction<bool>((transaction) async {
        final jobSnap = await transaction.get(jobRef);
        final appSnap = await transaction.get(applicationRef);
        // A previous attempt may have saved the application even if the UI
        // lost its connection before showing the success confirmation.
        if (appSnap.exists) return true;
        if (!jobSnap.exists) throw Exception('This job no longer exists.');
        final data = jobSnap.data()!;
        if (data['status'] != 'open')
          throw Exception(workerTr('job_closed_apply'));
        if (!workerJobMatchesProfile(
          data,
          department: profile['department']?.toString(),
          skill: profile['skill']?.toString(),
        )) {
          throw Exception(workerTr('only_related_work'));
        }
        transaction.set(applicationRef, {
          'workerUid': user.uid,
          'workerName': profile['name'] ?? user.displayName ?? 'Worker',
          'department': profile['department'] ?? '',
          'skill': profile['skill'] ?? '',
          'location': profile['location'] ?? '',
          'jobTitle': data['title'] ?? 'Job',
          'jobLocation': data['location'] ?? '',
          if (data['wage'] is num || data['payment'] is num)
            'wage': data['wage'] ?? data['payment'],
          'status': 'applied',
          'createdAt': FieldValue.serverTimestamp(),
        });
        return false;
      });
      var notificationFailed = false;
      try {
        if (!alreadyApplied) {
          await notificationRef.set({
            'type': 'job_application',
            'jobId': jobRef.id,
            'jobTitle': job['title'] ?? 'Job',
            'workerUid': user.uid,
            'workerName': profile['name'] ?? user.displayName ?? 'Worker',
            'employerUid': employerUid,
            'createdAt': FieldValue.serverTimestamp(),
            'read': false,
          });
        }
      } catch (_) {
        // The application is already saved and appears in applicant management.
        // Do not tell the worker their application failed because a notification
        // could not be written.
        notificationFailed = true;
      }
      if (!mounted) return;
      if (alreadyApplied) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(workerTr('already_applied'))));
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(tr('app_submitted')),
          content: Text(
            '${tr('application_saved')}'
            '${notificationFailed ? '\n\n${workerTr('apply_notification_pending')}' : ''}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr('ok')),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        final message = e is FirebaseException && e.code == 'permission-denied'
            ? '${workerTr('apply_permission_denied')} (permission-denied)'
            : '${workerTr('apply_failed')}: ${e.toString().replaceFirst('Exception: ', '')}';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => applying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: Text(tr('job_details')),
        actions: const [LanguagePickerButton(foregroundColor: Colors.white)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: navy,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.work, color: orange, size: 45),
                  const SizedBox(height: 15),
                  Text(
                    catalogLabel(job['title'] ?? tr('job_title')),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    catalogLabel(job['department'] ?? 'General'),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _detailRow(
              Icons.person,
              tr('employer'),
              (job['employer'] ?? job['employerName'] ?? 'Employer').toString(),
            ),

            _detailRow(
              Icons.location_on,
              tr('location'),
              (job['location'] ?? 'Location not specified').toString(),
            ),

            _detailRow(
              Icons.work_outline,
              tr('skill'),
              catalogLabel(job['skill'] ?? tr('skill')),
            ),

            _detailRow(
              Icons.schedule,
              tr('duration'),
              (job['duration'] ?? 'Not specified').toString(),
            ),

            _detailRow(
              Icons.currency_rupee,
              tr('payment'),
              job['payment'] is num || job['wage'] is num
                  ? '₹${job['payment'] ?? job['wage']}'
                  : tr('wage_to_be_discussed'),
            ),

            const SizedBox(height: 20),

            Text(
              tr('description'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              (job['description'] ?? 'No description provided.'),
              style: const TextStyle(
                color: greyText,
                fontSize: 15,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            FutureBuilder<bool>(
              future: _isWorkerAccount,
              builder: (context, snapshot) {
                if (snapshot.data != true) return const SizedBox.shrink();
                return SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: const Icon(Icons.send),
                    label: Text(
                      applying
                          ? workerTr('applying')
                          : workerTr('apply_for_job'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: applying ? null : _applyForJob,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, color: orange),
          const SizedBox(width: 12),
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold, color: navy),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: greyText)),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DEPARTMENTS
// ============================================================

class DepartmentsScreen extends StatelessWidget {
  const DepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: Text(tr('departments')),
        actions: const [LanguagePickerButton(foregroundColor: Colors.white)],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: departments.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),
        itemBuilder: (context, index) {
          final department = departments[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      DepartmentDetailScreen(department: department),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 58,
                    width: 58,
                    decoration: BoxDecoration(
                      color: lightOrange,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(department['icon'], color: orange, size: 32),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    catalogLabel(department['name']),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: navy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '${department['skills'].length} skills',
                    style: const TextStyle(color: greyText, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// DEPARTMENT DETAILS
// ============================================================

class DepartmentDetailScreen extends StatelessWidget {
  final Map<String, dynamic> department;

  const DepartmentDetailScreen({super.key, required this.department});

  Future<void> _openSkillFlow(BuildContext context, String skill) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(tr('login_continue'))));
      return;
    }
    try {
      final profile = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!context.mounted) return;
      final role = profile.data()?['role']?.toString();
      final departmentName = department['name']?.toString();
      final Widget nextPage;
      switch (role) {
        case 'customer':
          nextPage = CustomerFindWorkersScreen(
            initialDepartment: departmentName,
            initialSkill: skill,
          );
        case 'employer':
          nextPage = PostJobScreen(
            initialDepartment: departmentName,
            initialSkill: skill,
          );
        case 'worker':
          nextPage = FindWorkScreen(initialSkill: skill);
        default:
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(tr('profile_complete_title'))));
          return;
      }
      await Navigator.push<void>(
        context,
        MaterialPageRoute(builder: (_) => nextPage),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${tr('contact_action_error')} $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List skills = department['skills'];
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final Future<DocumentSnapshot<Map<String, dynamic>>>? roleFuture =
        uid == null
        ? null
        : FirebaseFirestore.instance.collection('users').doc(uid).get();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: Text(catalogLabel(department['name'])),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: roleFuture,
        builder: (context, snapshot) {
          final role = snapshot.data?.data()?['role']?.toString();
          final hint = switch (role) {
            'customer' => tr('department_skill_customer'),
            'employer' => tr('department_skill_employer'),
            'worker' => tr('department_skill_worker'),
            _ => tr('department_skill_hint'),
          };
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(hint),
              ),
              ...List.generate(skills.length, (index) {
                final skill = skills[index].toString();
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: lightOrange,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: navy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      catalogLabel(skill),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: navy,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _openSkillFlow(context, skill),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// POST JOB
// ============================================================

class PostJobScreen extends StatefulWidget {
  final String? initialDepartment;
  final String? initialSkill;

  const PostJobScreen({super.key, this.initialDepartment, this.initialSkill});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen>
    with LanguageAwareState<PostJobScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final paymentController = TextEditingController();

  String? selectedDepartment;
  String? selectedSkill;
  String selectedDuration = '1 Day';
  Position? jobSitePosition;
  bool isPosting = false;

  @override
  void initState() {
    super.initState();
    selectedDepartment = widget.initialDepartment;
    selectedSkill = widget.initialSkill;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    paymentController.dispose();
    super.dispose();
  }

  Future<void> _submitJob() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in before posting a job.')),
      );
      return;
    }
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final location = locationController.text.trim();
    final wageText = paymentController.text.trim();
    final wage = num.tryParse(wageText.replaceAll(',', '').replaceAll('₹', ''));
    if (title.isEmpty ||
        selectedDepartment == null ||
        selectedSkill == null ||
        location.isEmpty ||
        (wageText.isNotEmpty && (wage == null || wage <= 0))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a title, department, skill, location and valid wage.',
          ),
        ),
      );
      return;
    }
    setState(() => isPosting = true);
    try {
      final profileDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final role = profileDoc.data()?['role'];
      if (role != 'employer') {
        throw Exception(
          'Only an employer account can post jobs. Register or sign in with an employer account.',
        );
      }
      await FirebaseFirestore.instance.collection('jobs').add({
        'title': title,
        'description': description,
        'location': location,
        'department': selectedDepartment,
        'skill': selectedSkill,
        if (wage != null) 'wage': wage,
        if (wage != null) 'payment': wage,
        'duration': selectedDuration,
        'employerUid': user.uid,
        'employerName':
            profileDoc.data()?['name'] ?? user.displayName ?? 'Employer',
        'status': 'open',
        'applicants': <String>[],
        'acceptedWorkerUid': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (jobSitePosition != null) 'latitude': jobSitePosition!.latitude,
        if (jobSitePosition != null) 'longitude': jobSitePosition!.longitude,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(tr('job_saved'))));
      titleController.clear();
      descriptionController.clear();
      locationController.clear();
      paymentController.clear();
      setState(() {
        selectedDepartment = null;
        selectedSkill = null;
        selectedDuration = '1 Day';
        jobSitePosition = null;
      });
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Job was not saved: $e')));
    } finally {
      if (mounted) setState(() => isPosting = false);
    }
  }

  List<String> get skills {
    final department = departments.firstWhere(
      (item) => item['name'] == selectedDepartment,
      orElse: () => {'skills': <String>[]},
    );

    return List<String>.from(department['skills']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: Text(tr('post_job')),
        actions: const [LanguagePickerButton(foregroundColor: Colors.white)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('post_job_title'),
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),

            const SizedBox(height: 5),

            Text(tr('find_right_worker'), style: TextStyle(color: greyText)),

            const SizedBox(height: 25),

            _label(tr('job_title')),

            TextField(
              controller: titleController,
              decoration: _inputDecoration(tr('job_title_hint'), Icons.work),
            ),

            const SizedBox(height: 18),

            _label(tr('department')),

            DropdownButtonFormField<String>(
              initialValue: selectedDepartment,
              decoration: _inputDecoration(
                tr('select_department'),
                Icons.category,
              ),
              items: departments.map((department) {
                return DropdownMenuItem<String>(
                  value: department['name'],
                  child: Text(catalogLabel(department['name'])),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDepartment = value;
                  selectedSkill = null;
                });
              },
            ),

            const SizedBox(height: 18),

            _label(tr('skill')),

            DropdownButtonFormField<String>(
              initialValue: selectedSkill,
              decoration: _inputDecoration(tr('select_skill'), Icons.handyman),
              items: skills.map((skill) {
                return DropdownMenuItem<String>(
                  value: skill,
                  child: Text(catalogLabel(skill)),
                );
              }).toList(),
              onChanged: selectedDepartment == null
                  ? null
                  : (value) {
                      setState(() {
                        selectedSkill = value;
                      });
                    },
            ),

            const SizedBox(height: 18),

            _label(tr('description')),

            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: _inputDecoration(
                tr('job_description_hint'),
                Icons.description,
              ),
            ),

            const SizedBox(height: 18),

            _label(tr('location')),

            TextField(
              controller: locationController,
              decoration: _inputDecoration(
                tr('location_hint'),
                Icons.location_on,
              ),
            ),

            const SizedBox(height: 8),

            OutlinedButton.icon(
              onPressed: isPosting
                  ? null
                  : () async {
                      try {
                        final position = await requestCurrentDevicePosition();
                        if (!mounted) return;
                        setState(() => jobSitePosition = position);
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${tr('job_location_error')} $e'),
                          ),
                        );
                      }
                    },
              icon: Icon(
                jobSitePosition == null
                    ? Icons.my_location
                    : Icons.check_circle,
                color: jobSitePosition == null ? navy : green,
              ),
              label: Text(
                jobSitePosition == null
                    ? tr('job_location_use_device')
                    : tr('job_location_saved'),
              ),
            ),

            const SizedBox(height: 18),

            _label(tr('payment')),

            TextField(
              controller: paymentController,
              keyboardType: TextInputType.number,
              decoration:
                  _inputDecoration(
                    tr('payment_hint'),
                    Icons.currency_rupee,
                  ).copyWith(
                    labelText: tr('payment'),
                    helperText: tr('wage_optional_hint'),
                  ),
            ),

            const SizedBox(height: 18),

            _label(tr('duration')),

            DropdownButtonFormField<String>(
              initialValue: selectedDuration,
              decoration: _inputDecoration(
                tr('select_duration'),
                Icons.schedule,
              ),
              items: const [
                DropdownMenuItem(value: '1 Day', child: Text('1 Day')),
                DropdownMenuItem(value: '2 Days', child: Text('2 Days')),
                DropdownMenuItem(value: '3 Days', child: Text('3 Days')),
                DropdownMenuItem(value: '1 Week', child: Text('1 Week')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedDuration = value ?? '1 Day';
                });
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: isPosting ? null : _submitJob,
                child: isPosting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        tr('post'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, color: navy),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}

// ============================================================
// FINANCE
// ============================================================

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: Text(tr('finance')),
        actions: const [LanguagePickerButton(foregroundColor: Colors.white)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _financeOverview(),

            const SizedBox(height: 25),

            Text(
              tr('finance'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),

            const SizedBox(height: 12),

            _financeAction(
              context,
              Icons.receipt_long,
              tr('transactions'),
              tr('payment_status'),
              const TransactionsScreen(),
            ),

            _financeAction(
              context,
              Icons.savings,
              tr('savings_goals'),
              tr('savings_goals'),
              const SavingsScreen(),
            ),

            _financeAction(
              context,
              Icons.auto_awesome,
              tr('financial_insights'),
              tr('direct_upi_total_note'),
              const AIInsightsScreen(),
            ),

            _financeAction(
              context,
              Icons.badge,
              tr('digital_work_id'),
              tr('identity_not_verified'),
              const DigitalWorkIDScreen(),
            ),

            _financeAction(
              context,
              Icons.payment,
              tr('payout_jobs_title'),
              tr('payout_jobs_hint'),
              const WorkerPayoutJobsScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _financeOverview() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Text('Please sign in to view payment records.');
    }
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collectionGroup('payments')
          .where('workerUid', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Could not load payment records: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var total = 0.0;
        var weeklyTotal = 0.0;
        var confirmedCount = 0;
        final now = DateTime.now();
        final weekStart = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));
        for (final payment in snapshot.data!.docs) {
          final data = payment.data();
          final amount = data['amount'];
          final confirmedAt = data['workerConfirmedAt'];
          if (data['status'] != 'worker_confirmed' || amount is! num) continue;
          total += amount.toDouble();
          confirmedCount++;
          if (confirmedAt is Timestamp &&
              !confirmedAt.toDate().isBefore(weekStart)) {
            weeklyTotal += amount.toDouble();
          }
        }
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: navy,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('direct_upi_total'),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '?${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$confirmedCount app-confirmed payment(s)',
                    style: const TextStyle(color: Colors.greenAccent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _financeSmallCard(
                    tr('this_week_earnings'),
                    '?${weeklyTotal.toStringAsFixed(0)}',
                    Icons.calendar_today,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _financeSmallCard(
                    tr('transactions'),
                    '$confirmedCount',
                    Icons.receipt_long,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(tr('direct_upi_total_note')),
          ],
        );
      },
    );
  }

  Widget _financeSmallCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: orange),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: greyText)),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _financeAction(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget page,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: CircleAvatar(
          backgroundColor: lightOrange,
          child: Icon(icon, color: orange),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: navy),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
      ),
    );
  }
}

// ============================================================
// TRANSACTIONS
// ============================================================

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: Text(tr('transactions')),
        actions: const [LanguagePickerButton(foregroundColor: Colors.white)],
      ),
      body: uid == null
          ? const Center(child: Text('Please sign in to view transactions.'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collectionGroup('payments')
                  .where('workerUid', isEqualTo: uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Could not load payment records: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final payments = [...snapshot.data!.docs]
                  ..sort((a, b) {
                    final aData = a.data();
                    final bData = b.data();
                    final aTime =
                        aData['workerConfirmedAt'] ?? aData['createdAt'];
                    final bTime =
                        bData['workerConfirmedAt'] ?? bData['createdAt'];
                    final aDate = aTime is Timestamp
                        ? aTime.toDate()
                        : DateTime(0);
                    final bDate = bTime is Timestamp
                        ? bTime.toDate()
                        : DateTime(0);
                    return bDate.compareTo(aDate);
                  });
                if (payments.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No UPI payment records are available yet.'),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final payment = payments[index].data();
                    final amount = payment['amount'];
                    final timestamp =
                        payment['workerConfirmedAt'] ?? payment['createdAt'];
                    final confirmed = payment['status'] == 'worker_confirmed';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: lightOrange,
                          child: Icon(
                            Icons.receipt_long,
                            color: confirmed ? green : orange,
                          ),
                        ),
                        title: Text(
                          '${payment['jobTitle'] ?? 'Work payment'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: navy,
                          ),
                        ),
                        subtitle: Text(
                          '${confirmed ? tr('payment_worker_confirmed') : tr('payment_waiting_worker')}\n'
                          '${timestamp is Timestamp ? timestamp.toDate().toLocal() : ''}',
                        ),
                        isThreeLine: true,
                        trailing: amount is num
                            ? Text(
                                '?${amount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: confirmed ? green : greyText,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              )
                            : const Text('Amount unavailable'),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: Text(tr('savings_goals')),
        actions: const [LanguagePickerButton(foregroundColor: Colors.white)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Preview only: these example goals are not saved to your account and do not represent real balances.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          _goalCard('Buy New Tools', 10000, 6500, Icons.build),
          _goalCard('Emergency Fund', 15000, 7200, Icons.health_and_safety),
          _goalCard('New Mobile Phone', 20000, 8500, Icons.phone_android),
        ],
      ),
    );
  }

  Widget _goalCard(String title, double target, double saved, IconData icon) {
    final progress = saved / target;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: lightOrange,
                  child: Icon(icon, color: orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              borderRadius: BorderRadius.circular(10),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saved ₹${saved.toInt()}',
                  style: const TextStyle(color: greyText),
                ),
                Text(
                  'Target ₹${target.toInt()}',
                  style: const TextStyle(color: greyText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// AI INSIGHTS
// ============================================================

class AIInsightsScreen extends StatelessWidget {
  const AIInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: Text(tr('financial_insights')),
        actions: const [LanguagePickerButton(foregroundColor: Colors.white)],
      ),
      body: uid == null
          ? const Center(child: Text('Please sign in to view payment records.'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collectionGroup('payments')
                  .where('workerUid', isEqualTo: uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Could not load payment records: ${snapshot.error}',
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var receivedTotal = 0.0;
                var pendingTotal = 0.0;
                var receivedCount = 0;
                var pendingCount = 0;
                for (final payment in snapshot.data!.docs) {
                  final data = payment.data();
                  final amount = data['amount'];
                  if (amount is! num) continue;
                  if (data['status'] == 'worker_confirmed') {
                    receivedTotal += amount.toDouble();
                    receivedCount++;
                  } else if (data['status'] == 'payer_reported') {
                    pendingTotal += amount.toDouble();
                    pendingCount++;
                  }
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final contentWidth = constraints.maxWidth > 900
                        ? 900.0
                        : constraints.maxWidth;
                    final cardWidth = contentWidth < 560
                        ? contentWidth
                        : (contentWidth - 16) / 2;
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            Text(
                              tr('financial_insights'),
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: navy,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tr('direct_upi_total_note'),
                              style: const TextStyle(color: greyText),
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                SizedBox(
                                  width: cardWidth,
                                  child: _paymentInsightCard(
                                    title: tr('payment_worker_confirmed'),
                                    amount: receivedTotal,
                                    count: receivedCount,
                                    icon: Icons.account_balance_wallet_outlined,
                                    color: green,
                                  ),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: _paymentInsightCard(
                                    title: tr('payment_waiting_worker'),
                                    amount: pendingTotal,
                                    count: pendingCount,
                                    icon: Icons.hourglass_empty,
                                    color: orange,
                                  ),
                                ),
                              ],
                            ),
                            if (snapshot.data!.docs.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 24),
                                child: Text(
                                  tr('payment_no_jobs'),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _paymentInsightCard({
    required String title,
    required double amount,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(color: greyText)),
            const SizedBox(height: 8),
            Text(
              '?${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: navy,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count ${tr('transactions')}',
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkerRatingsScreen extends StatelessWidget {
  const WorkerRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null)
      return const Scaffold(body: Center(child: Text('Please sign in.')));
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('work_ratings')),
        actions: const [LanguagePickerButton(foregroundColor: Colors.white)],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collectionGroup('applications')
            .where('workerUid', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(
              child: Text('Could not load ratings: ${snapshot.error}'),
            );
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final completed = snapshot.data!.docs
              .where((doc) => doc.data()['status'] == 'completed')
              .toList();
          if (completed.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Ratings will appear after completed work is recorded.',
                ),
              ),
            );
          }
          return ListView(
            children: completed.map((application) {
              final jobRef = application.reference.parent.parent!;
              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: jobRef.get(),
                builder: (context, jobSnapshot) {
                  if (jobSnapshot.hasError)
                    return ListTile(
                      title: Text(
                        '${application.data()['jobTitle'] ?? 'Completed job'}',
                      ),
                      subtitle: Text(
                        'Could not load job: ${jobSnapshot.error}',
                      ),
                    );
                  if (!jobSnapshot.hasData)
                    return const ListTile(title: Text('Loading rating…'));
                  final employerUid =
                      '${jobSnapshot.data?.data()?['employerUid'] ?? ''}';
                  if (employerUid.isEmpty)
                    return const ListTile(
                      title: Text('Employer rating unavailable.'),
                    );
                  return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: jobRef
                        .collection('ratings')
                        .doc(employerUid)
                        .snapshots(),
                    builder: (context, ratingSnapshot) {
                      final rating = ratingSnapshot.data?.data();
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.star, color: Colors.amber),
                          title: Text(
                            '${application.data()['jobTitle'] ?? 'Completed job'}',
                          ),
                          subtitle: ratingSnapshot.hasError
                              ? Text(
                                  'Could not load employer rating: ${ratingSnapshot.error}',
                                )
                              : rating == null
                              ? const Text(
                                  'Employer has not rated this job yet.',
                                )
                              : Text('Employer rating: ${rating['score']}/5'),
                        ),
                      );
                    },
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class DigitalWorkIDScreen extends StatelessWidget {
  const DigitalWorkIDScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null)
      return const Scaffold(body: Center(child: Text('Please sign in.')));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: Text(tr('work_profile_id')),
        actions: const [LanguagePickerButton(foregroundColor: Colors.white)],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(
              child: Text('Could not load your profile: ${snapshot.error}'),
            );
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final profile = snapshot.data?.data();
          if (profile == null)
            return const Center(
              child: Text(
                'Complete your profile to view your work profile ID.',
              ),
            );
          final name = '${profile['name'] ?? currentUserDisplayName()}';
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Card(
                color: navy,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(Icons.badge_outlined, size: 56, color: orange),
                      const SizedBox(height: 12),
                      const Text(
                        'MR. COOLIE WORK PROFILE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      CircleAvatar(
                        radius: 38,
                        backgroundColor: orange,
                        child: Text(
                          name.isEmpty ? '?' : name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if ((profile['skill'] ?? '').toString().isNotEmpty)
                        Text(
                          catalogLabel(profile['skill']),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      if ((profile['department'] ?? '').toString().isNotEmpty)
                        Text(
                          catalogLabel(profile['department']),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      if ((profile['location'] ?? '').toString().isNotEmpty)
                        Text(
                          '${profile['location']}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'This is your in-app profile summary. It is not an official identity document and does not verify work, ratings, or income.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SelectableText(
                'Account reference: ${uid.substring(0, uid.length < 8 ? uid.length : 8)}',
              ),
            ],
          );
        },
      ),
    );
  }
}
// ============================================================
// DIRECT UPI PAYMENTS
// ============================================================

class WorkerPayoutJobsScreen extends StatelessWidget {
  const WorkerPayoutJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(body: Center(child: Text(tr('login_continue'))));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('payout_jobs_title')),
        backgroundColor: navy,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .where('acceptedWorkerUid', isEqualTo: uid)
            .where('status', whereIn: ['assigned', 'completed'])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('${tr('payment_status')}: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final jobs = snapshot.data!.docs;
          if (jobs.isEmpty) {
            return Center(child: Text(tr('payment_no_jobs')));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              final jobRef = job.reference;
              final data = job.data();
              final title = '${data['title'] ?? tr('job_title')}';
              final paymentRef = jobRef.collection('payments').doc('upi');
              final payoutRef = jobRef.collection('payoutProfiles').doc(uid);
              return Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(title),
                        subtitle: Text(
                          '${tr('job_status')}: ${tr('${data['status']}_status')}',
                        ),
                        trailing: IconButton(
                          tooltip: tr('upi_id'),
                          icon: const Icon(Icons.qr_code_2),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WorkerPayoutSetupScreen(
                                jobRef: jobRef,
                                jobTitle: title,
                                workerUid: uid,
                              ),
                            ),
                          ),
                        ),
                      ),
                      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: paymentRef.snapshots(),
                        builder: (context, paymentSnapshot) {
                          if (paymentSnapshot.hasError) {
                            return Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text('${paymentSnapshot.error}'),
                            );
                          }
                          final payment = paymentSnapshot.data?.data();
                          if (payment == null) {
                            return ListTile(
                              leading: const Icon(Icons.hourglass_empty),
                              title: Text(tr('payment_pending')),
                            );
                          }
                          if (payment['status'] == 'payer_reported') {
                            return ListTile(
                              title: Text(tr('payment_waiting_worker')),
                              trailing: FilledButton.tonal(
                                onPressed: () async {
                                  try {
                                    await paymentRef.update({
                                      'status': 'worker_confirmed',
                                      'workerConfirmedAt':
                                          FieldValue.serverTimestamp(),
                                      'updatedAt': FieldValue.serverTimestamp(),
                                    });
                                  } catch (error) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${tr('payment_confirm_failed')} $error',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Text(tr('payment_confirm_received')),
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(tr('payment_worker_confirmed')),
                          );
                        },
                      ),
                      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: payoutRef.snapshots(),
                        builder: (context, payoutSnapshot) {
                          final vpa = payoutSnapshot.data?.data()?['upiId'];
                          return ListTile(
                            leading: const Icon(
                              Icons.account_balance_wallet_outlined,
                            ),
                            title: Text(
                              vpa is String && vpa.isNotEmpty
                                  ? '${tr('upi_id')}: $vpa'
                                  : tr('payment_profile_missing'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class WorkerPayoutSetupScreen extends StatefulWidget {
  final DocumentReference<Map<String, dynamic>> jobRef;
  final String jobTitle;
  final String workerUid;

  const WorkerPayoutSetupScreen({
    super.key,
    required this.jobRef,
    required this.jobTitle,
    required this.workerUid,
  });

  @override
  State<WorkerPayoutSetupScreen> createState() =>
      _WorkerPayoutSetupScreenState();
}

class _WorkerPayoutSetupScreenState extends State<WorkerPayoutSetupScreen> {
  late final TextEditingController upiController;
  bool loading = false;
  late final DocumentReference<Map<String, dynamic>> payoutRef;

  @override
  void initState() {
    super.initState();
    upiController = TextEditingController();
    payoutRef = widget.jobRef
        .collection('payoutProfiles')
        .doc(widget.workerUid);
  }

  @override
  void dispose() {
    upiController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final upiId = upiController.text.trim();
    if (uid == null || uid != widget.workerUid) return;
    if (!RegExp(r'^[A-Za-z0-9._-]{2,256}@[A-Za-z0-9._-]{2,64}$')
        .hasMatch(upiId)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(tr('upi_id'))));
      return;
    }
    setState(() => loading = true);
    try {
      await payoutRef.set({
        'workerUid': uid,
        'upiId': upiId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(tr('payment_profile_saved'))));
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${tr('payment_save_failed')} $error')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr('payout_jobs_title'))),
    body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: payoutRef.snapshots(),
      builder: (context, snapshot) {
        final savedUpi = snapshot.data?.data()?['upiId'];
        if (upiController.text.isEmpty && savedUpi is String) {
          upiController.text = savedUpi;
        }
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              widget.jobTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(tr('payment_direct_notice')),
            const SizedBox(height: 20),
            TextField(
              controller: upiController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: tr('upi_id'),
                hintText: 'name@bank',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: loading ? null : _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(tr('save_upi')),
            ),
          ],
        );
      },
    ),
  );
}

class JobPaymentQrScreen extends StatefulWidget {
  final DocumentReference<Map<String, dynamic>> jobRef;
  final String jobTitle;
  final String workerUid;
  final String employerUid;
  final num amount;

  const JobPaymentQrScreen({
    super.key,
    required this.jobRef,
    required this.jobTitle,
    required this.workerUid,
    required this.employerUid,
    required this.amount,
  });

  @override
  State<JobPaymentQrScreen> createState() => _JobPaymentQrScreenState();
}

class _JobPaymentQrScreenState extends State<JobPaymentQrScreen> {
  final referenceController = TextEditingController();
  bool submitting = false;
  late final DocumentReference<Map<String, dynamic>> paymentRef;
  late final DocumentReference<Map<String, dynamic>> payoutRef;

  @override
  void initState() {
    super.initState();
    paymentRef = widget.jobRef.collection('payments').doc('upi');
    payoutRef = widget.jobRef
        .collection('payoutProfiles')
        .doc(widget.workerUid);
  }

  @override
  void dispose() {
    referenceController.dispose();
    super.dispose();
  }

  Future<void> _reportPayment() async {
    if (widget.amount <= 0 || !widget.amount.isFinite) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(tr('payment_amount_mismatch'))));
      return;
    }
    setState(() => submitting = true);
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final jobSnapshot = await transaction.get(widget.jobRef);
        final paymentSnapshot = await transaction.get(paymentRef);
        final job = jobSnapshot.data();
        if (!jobSnapshot.exists ||
            job?['status'] != 'completed' ||
            job?['employerUid'] != widget.employerUid ||
            job?['acceptedWorkerUid'] != widget.workerUid ||
            (job?['wage'] ?? job?['payment']) != widget.amount) {
          throw StateError(tr('payment_amount_mismatch'));
        }
        if (paymentSnapshot.exists) {
          throw StateError(tr('payment_reported'));
        }
        transaction.set(paymentRef, {
          'jobId': widget.jobRef.id,
          'jobTitle': widget.jobTitle,
          'workerUid': widget.workerUid,
          'employerUid': widget.employerUid,
          'payerUid': widget.employerUid,
          'amount': widget.amount,
          'method': 'direct_upi_qr',
          'paymentReference': referenceController.text.trim(),
          'status': 'payer_reported',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${tr('payment_send_failed')} $error')),
        );
      }
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(tr('payment_qr_title')),
      backgroundColor: navy,
      foregroundColor: Colors.white,
    ),
    body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: payoutRef.snapshots(),
      builder: (context, payoutSnapshot) {
        if (payoutSnapshot.hasError) {
          return Center(child: Text('${payoutSnapshot.error}'));
        }
        if (!payoutSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final upiId = payoutSnapshot.data?.data()?['upiId'];
        if (upiId is! String || upiId.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(tr('payment_profile_missing')),
            ),
          );
        }
        final payee = Uri.encodeQueryComponent(widget.jobTitle);
        final upiUri =
            'upi://pay?pa=${Uri.encodeQueryComponent(upiId)}'
            '&pn=${Uri.encodeQueryComponent('Mr Coolie Worker')}'
            '&am=${widget.amount.toStringAsFixed(2)}&cu=INR'
            '&tn=$payee&tr=${Uri.encodeQueryComponent(widget.jobRef.id)}';
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: paymentRef.snapshots(),
          builder: (context, paymentSnapshot) {
            if (paymentSnapshot.hasError) {
              return Center(child: Text('${paymentSnapshot.error}'));
            }
            final payment = paymentSnapshot.data?.data();
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  widget.jobTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${widget.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(color: navy, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(12),
                    child: QrImageView(data: upiUri, size: 230),
                  ),
                ),
                const SizedBox(height: 12),
                Text('${tr('upi_id')}: $upiId', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(tr('payment_scan_hint'), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(
                  tr('payment_direct_notice'),
                  style: const TextStyle(color: greyText),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (payment == null)
                  TextField(
                    controller: referenceController,
                    decoration: InputDecoration(
                      labelText: tr('payment_reference'),
                      border: const OutlineInputBorder(),
                    ),
                  )
                else
                  Text(
                    payment['status'] == 'worker_confirmed'
                        ? tr('payment_worker_confirmed')
                        : tr('payment_waiting_worker'),
                    textAlign: TextAlign.center,
                  ),
                if (payment == null) ...[
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: submitting ? null : _reportPayment,
                    icon: submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: Text(tr('payment_mark_sent')),
                  ),
                ],
              ],
            );
          },
        );
      },
    ),
  );
}

// The old local-only payment demo remains available for reference, but is no
// longer linked from the worker Finance screen.

class PaymentDemoScreen extends StatefulWidget {
  const PaymentDemoScreen({super.key});

  @override
  State<PaymentDemoScreen> createState() => _PaymentDemoScreenState();
}

class _PaymentDemoScreenState extends State<PaymentDemoScreen>
    with LanguageAwareState<PaymentDemoScreen> {
  bool paid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: Text(tr('digital_payment_demo')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.electrical_services,
                    size: 55,
                    color: orange,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Electrical Wiring',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Job Completed ✓',
                    style: TextStyle(color: green, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    '₹700',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            if (paid)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.check_circle, color: green, size: 60),
                    SizedBox(height: 10),
                    Text(
                      'Demo simulation complete',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: green,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'No real payment was made and no transaction was recorded.',
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      paid = true;
                    });
                  },
                  child: const Text(
                    'PAY ₹700',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            const Text(
              'This is a prototype payment simulation for demonstration purposes.',
              textAlign: TextAlign.center,
              style: TextStyle(color: greyText),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PROFILE
// ============================================================

class ProfileScreen extends StatelessWidget {
  final String role;

  const ProfileScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: Text(tr('my_profile')),
        actions: const [LanguagePickerButton(foregroundColor: Colors.white)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: navy,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: orange,
                    child: Icon(Icons.person, size: 55, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentUserDisplayName(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    FirebaseAuth.instance.currentUser?.email ?? '',
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  if (role == 'worker')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.amber),
                        SizedBox(width: 5),
                        Text(
                          tr('ratings'),
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (role == 'worker') ...[
              _profileItem(
                context,
                Icons.badge,
                tr('digital_work_id'),
                tr('identity_not_verified'),
                const DigitalWorkIDScreen(),
              ),

              _profileItem(
                context,
                Icons.handyman,
                tr('my_skills'),
                tr('skills_from_registration'),
                null,
              ),

              _profileItem(
                context,
                Icons.toggle_on_outlined,
                tr('work_availability'),
                tr('availability_description'),
                const WorkerAvailabilityScreen(),
              ),

              _profileItem(
                context,
                Icons.assignment_outlined,
                tr('my_applications'),
                tr('track_application_status'),
                const MyApplicationsScreen(),
              ),

              _profileItem(
                context,
                Icons.mark_chat_unread_outlined,
                tr('contact_requests'),
                tr('contact_requests_desc'),
                const WorkerContactRequestsScreen(),
              ),

              _profileItem(
                context,
                Icons.location_searching,
                tr('live_location_sharing'),
                tr('share_accepted_job'),
                const WorkerLiveLocationScreen(),
              ),

              _profileItem(
                context,
                Icons.history,
                tr('work_history'),
                tr('completed_applications'),
                const MyApplicationsScreen(),
              ),

              _profileItem(
                context,
                Icons.star,
                tr('ratings'),
                tr('completed_job_ratings'),
                const WorkerRatingsScreen(),
              ),
            ],

            if (role == 'employer') ...[
              _profileItem(
                context,
                Icons.work_outline,
                tr('my_jobs'),
                tr('manage_job_posts'),
                const EmployerJobsScreen(),
              ),
              _profileItem(
                context,
                Icons.people_outline,
                tr('applicants'),
                tr('review_applicants'),
                const EmployerApplicantsScreen(),
              ),
            ],

            if (role == 'customer')
              _profileItem(
                context,
                Icons.search,
                tr('find_workers'),
                tr('search_available_workers'),
                const CustomerFindWorkersScreen(),
              ),

            _profileItem(
              context,
              Icons.settings,
              tr('settings'),
              tr('account_preferences'),
              null,
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: red,
                  side: const BorderSide(color: red),
                  padding: const EdgeInsets.all(15),
                ),
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logout failed: $e')),
                    );
                    return;
                  }

                  if (!context.mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: Text(tr('logout')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget? page,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: lightOrange,
          child: Icon(icon, color: orange),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: navy),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: page == null
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => page),
                );
              },
      ),
    );
  }
}

class WorkerAvailabilityScreen extends StatefulWidget {
  const WorkerAvailabilityScreen({super.key});

  @override
  State<WorkerAvailabilityScreen> createState() =>
      _WorkerAvailabilityScreenState();
}

class _WorkerAvailabilityScreenState extends State<WorkerAvailabilityScreen>
    with LanguageAwareState<WorkerAvailabilityScreen> {
  bool saving = false;

  Future<void> _setAvailability(String uid, bool available) async {
    setState(() => saving = true);
    try {
      await FirebaseFirestore.instance
          .collection('publicWorkers')
          .doc(uid)
          .update({
            'available': available,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update availability: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please sign in.')));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('work_availability')),
        actions: const [LanguagePickerButton(foregroundColor: Colors.white)],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('publicWorkers')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(
              child: Text('Could not load availability: ${snapshot.error}'),
            );
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.data!.exists)
            return const Center(
              child: Text('Complete your worker profile to set availability.'),
            );
          final available = snapshot.data!.data()?['available'] == true;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'When you are available, employers and customers can see your public worker profile.',
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  available ? tr('available_for_work') : tr('not_available'),
                ),
                subtitle: Text(
                  available
                      ? tr('availability_public')
                      : tr('availability_hidden'),
                ),
                value: available,
                onChanged: saving
                    ? null
                    : (value) => _setAvailability(uid, value),
              ),
              if (saving) const LinearProgressIndicator(),
            ],
          );
        },
      ),
    );
  }
}

class WorkerLiveLocationScreen extends StatefulWidget {
  const WorkerLiveLocationScreen({super.key});

  @override
  State<WorkerLiveLocationScreen> createState() =>
      _WorkerLiveLocationScreenState();
}

class _WorkerLiveLocationScreenState extends State<WorkerLiveLocationScreen>
    with LanguageAwareState<WorkerLiveLocationScreen> {
  final Map<String, StreamSubscription<Position>> _locationSubscriptions = {};
  final Map<String, Timer> _heartbeatTimers = {};
  final Set<String> _busyJobs = {};

  @override
  void dispose() {
    for (final subscription in _locationSubscriptions.values) {
      unawaited(subscription.cancel());
    }
    for (final timer in _heartbeatTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  Future<Position> _currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw StateError(
        'Turn on Location Services on your device, then try again.',
      );
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw StateError('Location permission was denied.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw StateError(
        'Location permission is blocked. Enable it in system settings to share.',
      );
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<void> _setSharing({required String jobId, required bool share}) async {
    if (_busyJobs.contains(jobId)) return;
    setState(() => _busyJobs.add(jobId));
    final locationRef = FirebaseFirestore.instance
        .collection('liveLocations')
        .doc(jobId);
    try {
      if (share) {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        final jobSnapshot = await FirebaseFirestore.instance
            .collection('jobs')
            .doc(jobId)
            .get();
        final job = jobSnapshot.data();
        if (!jobSnapshot.exists ||
            job?['status'] != 'assigned' ||
            job?['acceptedWorkerUid'] != uid) {
          throw StateError('This job is no longer assigned to your account.');
        }
        final employerUid = '${job?['employerUid'] ?? ''}';
        if (employerUid.isEmpty)
          throw StateError('The job has no employer account.');
        final position = await _currentPosition();
        await locationRef.set({
          'workerUid': uid,
          'employerUid': employerUid,
          'location': GeoPoint(position.latitude, position.longitude),
          'sharing': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        await _locationSubscriptions[jobId]?.cancel();
        _heartbeatTimers.remove(jobId)?.cancel();
        _heartbeatTimers[jobId] = Timer.periodic(const Duration(minutes: 1), (
          _,
        ) async {
          try {
            final current = await _currentPosition();
            await locationRef.update({
              'location': GeoPoint(current.latitude, current.longitude),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Live location heartbeat failed: $e')),
              );
            }
          }
        });
        _locationSubscriptions[jobId] =
            Geolocator.getPositionStream(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
                distanceFilter: 20,
              ),
            ).listen(
              (next) {
                locationRef
                    .update({
                      'location': GeoPoint(next.latitude, next.longitude),
                      'updatedAt': FieldValue.serverTimestamp(),
                    })
                    .catchError((Object error) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Location update failed: $error'),
                          ),
                        );
                      }
                    });
              },
              onError: (Object error) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Location service stopped: $error')),
                  );
                }
              },
            );
      } else {
        _heartbeatTimers.remove(jobId)?.cancel();
        await _locationSubscriptions.remove(jobId)?.cancel();
        await locationRef.update({
          'sharing': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not ${share ? 'start' : 'stop'} location sharing: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busyJobs.remove(jobId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null)
      return const Scaffold(body: Center(child: Text('Please sign in.')));
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('live_location_sharing')),
        actions: const [LanguagePickerButton(foregroundColor: Colors.white)],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, profileSnapshot) {
          if (profileSnapshot.hasError)
            return Center(
              child: Text(
                'Could not load your profile: ${profileSnapshot.error}',
              ),
            );
          if (!profileSnapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          if (profileSnapshot.data?.data()?['role'] != 'worker') {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Live location sharing is available to workers for accepted jobs.',
                ),
              ),
            );
          }
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Your location is shared only with the employer of an accepted job, and only while sharing is on. You can stop sharing at any time.',
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collectionGroup('applications')
                      .where('workerUid', isEqualTo: uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError)
                      return Center(
                        child: Text(
                          'Could not load accepted jobs: ${snapshot.error}',
                        ),
                      );
                    if (!snapshot.hasData)
                      return const Center(child: CircularProgressIndicator());
                    final acceptedJobs = snapshot.data!.docs
                        .where(
                          (application) =>
                              application.data()['status'] == 'accepted' ||
                              application.data()['status'] == 'completed',
                        )
                        .toList();
                    if (acceptedJobs.isEmpty)
                      return const Center(
                        child: Text(
                          'Live sharing is available after an employer accepts one of your applications.',
                        ),
                      );
                    return ListView(
                      children: acceptedJobs.map((application) {
                        final jobId = application.reference.parent.parent?.id;
                        if (jobId == null) return const SizedBox.shrink();
                        final applicationData = application.data();
                        final jobTitle =
                            '${applicationData['jobTitle'] ?? 'Accepted job'}';
                        return StreamBuilder<
                          DocumentSnapshot<Map<String, dynamic>>
                        >(
                          stream: FirebaseFirestore.instance
                              .collection('liveLocations')
                              .doc(jobId)
                              .snapshots(),
                          builder: (context, locationSnapshot) {
                            final locationData = locationSnapshot.data?.data();
                            final isSharing = locationData?['sharing'] == true;
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: SwitchListTile(
                                title: Text(jobTitle),
                                subtitle: Text(
                                  locationSnapshot.hasError
                                      ? 'Could not load sharing status: ${locationSnapshot.error}'
                                      : isSharing
                                      ? 'Sharing with the employer for this job'
                                      : 'Location sharing is off',
                                ),
                                value: isSharing,
                                onChanged:
                                    _busyJobs.contains(jobId) ||
                                        locationSnapshot.hasError ||
                                        (applicationData['status'] ==
                                                'completed' &&
                                            !isSharing)
                                    ? null
                                    : (value) => _setSharing(
                                        jobId: jobId,
                                        share: value,
                                      ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null)
      return const Scaffold(
        body: Center(child: Text('Please sign in to view applications.')),
      );
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('my_applications_title')),
        backgroundColor: navy,
        foregroundColor: Colors.white,
        actions: const [LanguagePickerButton(foregroundColor: Colors.white)],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, profileSnap) {
          if (profileSnap.hasError)
            return Center(
              child: Text('Could not load your profile: ${profileSnap.error}'),
            );
          if (!profileSnap.hasData)
            return const Center(child: CircularProgressIndicator());
          if (profileSnap.data?.data()?['role'] != 'worker')
            return const Center(
              child: Text(
                'Application tracking is available for worker accounts.',
              ),
            );
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collectionGroup('applications')
                .where('workerUid', isEqualTo: uid)
                .snapshots(),
            builder: (context, applicationsSnap) {
              if (applicationsSnap.hasError)
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Could not load applications. Check your connection and Firestore rules.\n${applicationsSnap.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              if (!applicationsSnap.hasData)
                return const Center(child: CircularProgressIndicator());
              final applications = applicationsSnap.data!.docs;
              if (applications.isEmpty)
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'You have not applied for any jobs yet. Your applications will appear here.',
                    ),
                  ),
                );
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  final applicationDoc = applications[index];
                  final application = applicationDoc.data();
                  final jobRef = applicationDoc.reference.parent.parent;
                  final status = '${application['status'] ?? 'applied'}';
                  final statusColor =
                      status == 'accepted' || status == 'completed'
                      ? green
                      : status == 'rejected'
                      ? red
                      : orange;
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: lightOrange,
                        child: Icon(Icons.work_outline, color: navy),
                      ),
                      title: Text(
                        '${application['jobTitle'] ?? 'Job application'}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${application['jobLocation'] ?? ''}  •  ${application['department'] ?? ''} / ${application['skill'] ?? ''}',
                      ),
                      trailing: status == 'completed' && jobRef != null
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Chip(label: Text('COMPLETED')),
                                IconButton(
                                  tooltip: 'Rate employer',
                                  icon: const Icon(Icons.star_outline),
                                  onPressed: () =>
                                      _rateCompletedJob(context, jobRef),
                                ),
                              ],
                            )
                          : Chip(
                              label: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              side: BorderSide(
                                color: statusColor.withValues(alpha: 0.4),
                              ),
                            ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
