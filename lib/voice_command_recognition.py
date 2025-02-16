from flask import Flask, request, jsonify
import speech_recognition as sr
import os
import difflib
import logging

# إعداد سجل الأخطاء
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

# إعداد Flask
app = Flask(__name__)

# مسار المجلد الذي يحتوي على جميع الأوامر الصوتية
AUDIO_PATH = "/mnt/data/sounds"

# التحقق من أن المجلد موجود
if not os.path.exists(AUDIO_PATH):
    logging.error("❌ المجلد الخاص بالأوامر الصوتية غير موجود!")
    exit()

# تجميع جميع الأوامر الصوتية المسجلة
command_list = [file.replace(".wav", "") for file in os.listdir(AUDIO_PATH) if file.endswith(".wav")]

# تعريف الميكروفون والتعرف على الصوت
recognizer = sr.Recognizer()

@app.route("/command", methods=["POST"])
def handle_command():
    """يستقبل الأمر الصوتي من Flutter وينفذه."""
    command = request.form.get("command")

    if not command:
        logging.warning("⚠️ لم يتم استقبال أي أمر!")
        return jsonify({"error": "❌ لم يتم استقبال أي أمر!"}), 400

    logging.info(f"📢 استقبلت الأمر الصوتي: {command}")

    # البحث عن أقرب تطابق بين الأوامر المسجلة
    best_match = difflib.get_close_matches(command, command_map.keys(), n=1, cutoff=0.5)

    if best_match:
        response = execute_command(best_match[0])
        return jsonify({"response": response}), 200
    else:
        logging.warning("❌ لم يتم التعرف على الأمر!")
        return jsonify({"error": "❌ لم يتم التعرف على الأمر!"}), 400

def recognize_command():
    """يستمع إلى صوت المستخدم ويقارن بالأوامر الصوتية المتاحة."""
    with sr.Microphone() as source:
        logging.info("🎤 تحدث الآن...")
        recognizer.adjust_for_ambient_noise(source)  # تقليل الضوضاء
        audio = recognizer.listen(source)

    try:
        # استخدام Google Speech Recognition لتحويل الصوت إلى نص
        recognized_text = recognizer.recognize_google(audio, language="ar-SA").strip()
        logging.info(f"✅ تم التعرف على الأمر: {recognized_text}")

        # البحث عن أقرب تطابق بين الأوامر المسجلة
        best_match = difflib.get_close_matches(recognized_text, command_map.keys(), n=1, cutoff=0.5)

        if best_match:
            execute_command(best_match[0])  # تنفيذ الأمر
        else:
            logging.warning("❌ لم يتم التعرف على الأمر، حاول مرة أخرى.")
    
    except sr.UnknownValueError:
        logging.warning("🔇 لم أفهم الصوت، حاول مرة أخرى.")
    except sr.RequestError:
        logging.error("⚠️ حدث خطأ في الاتصال بالإنترنت.")

def execute_command(command):
    """تنفيذ الأوامر بناءً على الأوامر الصوتية المسجلة"""
    logging.info(f"🚀 تنفيذ الأمر: {command}")

    command_map = {
        "تسجيل دخول": "✅ تم تسجيل الدخول!",
        "تسجيل خروج": "✅ تم تسجيل الخروج!",
        "إضافة صورة": "📸 تم إضافة صورة جديدة!",
        "فتح الكاميرا": "📷 يتم فتح الكاميرا...",
        "إغلاق الكاميرا": "🚫 يتم إغلاق الكاميرا...",
        "إنشاء حساب": "🆕 يتم إنشاء الحساب!",
        "الصفحة الرئيسية": "🏠 يتم الانتقال إلى الصفحة الرئيسية!",
        "نباتاتي": "🌿 عرض قائمة نباتاتك!",
        "جدول الري": "💦 عرض جدول الري!",
        "ابحث عن نبتتك": "🔍 جاري البحث عن النبتة...",
        "مساعدة": "❓ عرض قائمة المساعدة!",
        "خروج": "👋 يتم إيقاف النظام!"
    }

    if command in command_map:
        response = command_map[command]
        logging.info(f"✅ {response}")

        if command == "فتح الكاميرا":
            os.system("start camera")  # استبدل بأمر مناسب إذا كنت تريد تشغيل الكاميرا
        elif command == "إغلاق الكاميرا":
            os.system("taskkill /IM camera.exe /F")  # إغلاق الكاميرا (حسب النظام)
        elif command == "خروج":
            exit()

        return response

    logging.warning("🤔 الأمر غير معروف!")
    return "❌ الأمر غير معروف!"

# تشغيل السيرفر
if __name__ == "__main__":
    logging.info("🔊 نظام التعرف على الأوامر الصوتية جاهز!")
    app.run(debug=True, port=5000)
