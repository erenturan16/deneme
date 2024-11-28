import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);

    // Timezone verilerini başlatma
    tz.initializeTimeZones();
  }

  Future<void> scheduleNotification(
      int id, String title, String body, DateTime scheduledDateTime) async {
    tz.initializeTimeZones(); // Burada da zaman dilimlerini başlatmayı unutmayın
    final tz.TZDateTime scheduledNotificationDateTime =
        tz.TZDateTime.from(scheduledDateTime, tz.local);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'Channel description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.zonedSchedule(
      id,
      'Görev Hatırlatıcısı',
      body,
      scheduledNotificationDateTime,
      platformChannelSpecifics,
      androidAllowWhileIdle:
          true, // Eğer `deprecated` uyarısı alıyorsanız, bu satırı kaldırabilirsiniz
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
