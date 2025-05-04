from flask import Flask, request, jsonify
import speech_recognition as sr
import os
import difflib
import logging

# إعداد سجل الأخطاء
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

# إعداد Flask
app = Flask(__name__)


AUDIO_PATH = "/mnt/data/sounds"


if not os.path.exists(AUDIO_PATH):
    logging.error("❌ المجلد الخاص بالأوامر الصوتية غير موجود!")
    os.makedirs(AUDIO_PATH)
    logging.info("✅ تم إنشاء المجلد الخاص بالأوامر الصوتية!")


command_list = [file.replace(".wav", "") for file in os.listdir(AUDIO_PATH) if file.endswith(".wav")]


recognizer = sr.Recognizer()

# قاموس الأوامر وردود الفعل
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
    "خروج": "👋 يتم إيقاف النظام!",
    
    "أضف إلى جدول الري": "💧 تمت إضافة النبات إلى جدول الري!",
    "أضف للري": "💧 تمت إضافة النبات إلى جدول الري!",
    "إضافة للري": "💧 تمت إضافة النبات إلى جدول الري!",
    "أضف للجدول": "💧 تمت إضافة النبات إلى جدول الري!",
    "إضافة لجدول الري": "💧 تمت إضافة النبات إلى جدول الري!",
    "أضفه للري": "💧 تمت إضافة النبات إلى جدول الري!",
    "أضيف للري": "💧 تمت إضافة النبات إلى جدول الري!",
    "سقي النبات": "💧 تمت إضافة النبات إلى جدول الري!",
    "جدولة الري": "💧 تمت إضافة النبات إلى جدول الري!"
}

@app.route("/command", methods=["POST"])
def handle_command():
    """يستقبل الأمر الصوتي من Flutter وينفذه."""
    command = request.form.get("command")
    plant_info = request.form.get("plant_info", "")  

    if not command:
        logging.warning("⚠️ لم يتم استقبال أي أمر!")
        return jsonify({"error": "❌ لم يتم استقبال أي أمر!"}), 400

    logging.info(f"📢 استقبلت الأمر الصوتي: {command}")
    if plant_info:
        logging.info(f"🌱 معلومات النبات: {plant_info}")

    
    watering_commands = [
        "أضف إلى جدول الري", "أضف للري", "إضافة للري", 
        "أضف للجدول", "جدول الري", "إضافة لجدول الري", 
        "أضفه للري", "أضيف للري", "سقي النبات", "جدولة الري"
    ]
    
    
    is_watering_command = any(cmd in command for cmd in watering_commands)
    
    if is_watering_command:
        response = {
            "action": "navigate_to_watering_schedule",
            "message": "💧 تمت إضافة النبات إلى جدول الري!",
            "plant_info": plant_info
        }
        logging.info("🚀 تنفيذ أمر إضافة النبات إلى جدول الري")
        return jsonify(response), 200
    
    
    best_match = difflib.get_close_matches(command, command_map.keys(), n=1, cutoff=0.5)

    if best_match:
        response_text = command_map[best_match[0]]
        action = best_match[0]
        
        response = {
            "action": action.replace(" ", "_"),
            "message": response_text
        }
        
        logging.info(f"✅ تم تنفيذ الأمر: {best_match[0]} - {response_text}")
        return jsonify(response), 200
    else:
        logging.warning("❌ لم يتم التعرف على الأمر!")
        return jsonify({"error": "❌ لم يتم التعرف على الأمر!"}), 400

def recognize_command():
    """يستمع إلى صوت المستخدم ويقارن بالأوامر الصوتية المتاحة."""
    with sr.Microphone() as source:
        logging.info("🎤 تحدث الآن...")
        recognizer.adjust_for_ambient_noise(source)  
        audio = recognizer.listen(source)

    try:
        # استخدام Google Speech Recognition لتحويل الصوت إلى نص
        recognized_text = recognizer.recognize_google(audio, language="ar-SA").strip()
        logging.info(f"✅ تم التعرف على الأمر: {recognized_text}")

        # البحث عن أقرب تطابق بين الأوامر المسجلة
        best_match = difflib.get_close_matches(recognized_text, command_map.keys(), n=1, cutoff=0.5)

        if best_match:
            return execute_command(best_match[0])  
        else:
            logging.warning("❌ لم يتم التعرف على الأمر، حاول مرة أخرى.")
            return "❌ لم يتم التعرف على الأمر، حاول مرة أخرى."
    
    except sr.UnknownValueError:
        logging.warning("🔇 لم أفهم الصوت، حاول مرة أخرى.")
        return "🔇 لم أفهم الصوت، حاول مرة أخرى."
    except sr.RequestError:
        logging.error("⚠️ حدث خطأ في الاتصال بالإنترنت.")
        return "⚠️ حدث خطأ في الاتصال بالإنترنت."

def execute_command(command):
    """تنفيذ الأوامر بناءً على الأوامر الصوتية المسجلة"""
    logging.info(f"🚀 تنفيذ الأمر: {command}")

    if command in command_map:
        response = command_map[command]
        logging.info(f"✅ {response}")

        if command == "فتح الكاميرا":
            os.system("start camera")  
        elif command == "إغلاق الكاميرا":
            os.system("taskkill /IM camera.exe /F")  
        elif command == "خروج":
            exit()

        return response

    logging.warning("🤔 الأمر غير معروف!")
    return "❌ الأمر غير معروف!"


if __name__ == "__main__":
    logging.info("🔊 نظام التعرف على الأوامر الصوتية جاهز!")
    app.run(host="0.0.0.0", debug=True, port=5000)