const String GEMINI_API_KEY = "AIzaSyAcwPzpZoCEPi04hnrnXhPhoUl6YUq0weU";

// دالة تتحقق إذا النص يحتوي على أحرف عربية
bool _isArabic(String text) {
  final arabicRegex = RegExp(r'[\u0600-\u06FF]');
  return arabicRegex.hasMatch(text);
}
//  دالة تتحقق إذا النص يحتوي على معادلة رياضية
bool _isMathEquation(String text) {
  final mathRegex = RegExp(r'[\d\+\-\*\/=]');
  return mathRegex.hasMatch(text);
}

// دالة ترجع البرومبت المناسب حسب اللغة
String getBotanyPrompt(String userText) {
  if (_isArabic(userText)) {
    // إذا كان النص باللغة العربية
    return "أنت خبير في علم النباتات الداخلية بشكل خاص. يجب أن تكون إجاباتك مقتصرة فقط على المواضيع المتعلقة بالنباتات الداخلية، مثل أنواعها، زراعتها، تركيبها، أو العمليات الحيوية فيها. "
           "إذا لم يكن السؤال عن النباتات، أجب بـ: (هذا السؤال خارج نطاق تخصصي في علم النباتات الداخلية).";
  } else if (_isMathEquation(userText)) {
    // إذا كان النص يحتوي على معادلة رياضية
    return "عذرًا، لا أستطيع الإجابة عن المعادلات الرياضية. يمكنك سؤالي عن النباتات الداخلية.";
  } else {
    // إذا كان النص ليس بالعربية ولا يحتوي على معادلة رياضية
    return "أعتذر، أنا متخصص في علم النباتات الداخلية باللغة العربية فقط. الرجاء طرح سؤالك باللغة العربية.";
  }
}