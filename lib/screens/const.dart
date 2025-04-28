const String GEMINI_API_KEY = "AIzaSyAcwPzpZoCEPi04hnrnXhPhoUl6YUq0weU";

bool _isArabic(String text) {
  final arabicRegex = RegExp(r'[\u0600-\u06FF]');
  return arabicRegex.hasMatch(text);
}

// دالة ترجع البرومبت المناسب حسب اللغة
String getBotanyPrompt(String userText) {
  if (_isArabic(userText)) {
    // إذا كان النص باللغة العربية
    return "أنت خبير في علم النباتات الداخلية بشكل خاص. يجب أن تكون إجاباتك مقتصرة فقط على المواضيع المتعلقة بالنباتات الداخلية، مثل أنواعها، زراعتها، تركيبها، أو العمليات الحيوية فيها. "
        "إذا لم يكن السؤال عن النباتات، أجب بـ: (هذا السؤال خارج نطاق تخصصي في علم النباتات الداخلية).";
  } else {
    //إذا كان النص ليس بالعربية
    return "أعتذر، أنا متخصص في علم النباتات الداخلية باللغة العربية فقط. الرجاء طرح سؤالك باللغة العربية.";
  }
}

String detectLanguage(String text) {
  return _isArabic(text) ? 'ar-SA' : 'en-US';
}
