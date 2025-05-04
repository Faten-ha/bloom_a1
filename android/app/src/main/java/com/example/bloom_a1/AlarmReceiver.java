package com.example.bloom_a1;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.speech.tts.TextToSpeech;
import android.speech.tts.UtteranceProgressListener;
import android.util.Log;
import androidx.core.app.NotificationCompat;
import java.util.Locale;

public class AlarmReceiver extends BroadcastReceiver {
    private static final String CHANNEL_ID = "main_channel_id";
    private TextToSpeech tts;

    @Override
    public void onReceive(Context context, Intent intent) {
        final String message = intent.getStringExtra("message");
        final String title = intent.getStringExtra("title");

        initializeTTS(context, message, title);
        showNotification(context, message, title);

    }

    private void showNotification(Context context, String message, String title) {
        NotificationManager notificationManager =
                (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);

        createNotificationChannel(notificationManager);

        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, CHANNEL_ID)
                .setContentTitle(title)
                .setContentText(message)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setAutoCancel(true)
                .setContentIntent(createNotificationTapIntent(context));  // Set tap action

        notificationManager.notify((int) System.currentTimeMillis(), builder.build());
    }

    // Method specifically for creating the notification tap intent
    private PendingIntent createNotificationTapIntent(Context context) {
        // Create intent to launch MainActivity
        Intent launchIntent = new Intent(context, MainActivity.class);

        // Clear the activity stack so it starts fresh
        launchIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);

        // Create pending intent with immutable flag for Android 12+
        return PendingIntent.getActivity(
                context,
                0,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );
    }

    private void createNotificationChannel(NotificationManager notificationManager) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    "Main Channel",
                    NotificationManager.IMPORTANCE_HIGH
            );
            channel.setDescription("Used for important scheduled notifications.");
            notificationManager.createNotificationChannel(channel);
        }
    }

    private void initializeTTS(Context context, final String message, String title) {
        tts = new TextToSpeech(context.getApplicationContext(), status -> {
            if (status == TextToSpeech.SUCCESS) {

                // Set language with error handling
                int langResult = tts.setLanguage(new Locale("ar"));
                if (langResult == TextToSpeech.LANG_MISSING_DATA ||
                        langResult == TextToSpeech.LANG_NOT_SUPPORTED) {
                     // Fallback to default language
                    tts.setLanguage(Locale.getDefault());
                }

                tts.setSpeechRate(1.0f);

                String text = ((message == null && title == null) || (message.isEmpty() && title.isEmpty()))
                        ? "Default TTS message"
                        : title + "." + message;

                // For Android 14+, we need to use a handler to ensure TTS works
                new Handler(Looper.getMainLooper()).postDelayed(() -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                        tts.speak(text, TextToSpeech.QUEUE_FLUSH, null, "TTS_ID");
                    } else {
                        // Legacy method for older Android versions
                        tts.speak(text, TextToSpeech.QUEUE_FLUSH, null);
                    }
                   }, 300); // Small delay to ensure proper initialization
            } else {
             }
        }, "com.google.android.tts"); // Specify the TTS engine explicitly
    }
}