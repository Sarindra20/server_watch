import 'package:flutter/foundation.dart'; // Pour kIsWeb
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialisation du service
  static Future<void> init() async {
    // Ne rien faire sur le Web pour éviter les erreurs sur Chrome
    if (kIsWeb) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  // Fonction pour envoyer une alerte critique
  static Future<void> showServerAlert(String serverName, String reason) async {
    // Si on est sur le Web, on trace juste l'alerte dans la console
    if (kIsWeb) {
      debugPrint('[ALERTE NOTIFICATION] $serverName : $reason');
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'server_watch_alerts',
      'Alertes Serveurs',
      channelDescription: 'Notifications en cas de panne ou de surchauffe',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Alerte Serveur',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    // On utilise un entier simple (ex: 1) pour l'ID de la notification
    await _notificationsPlugin.show(
      1, 
      '⚠️ Alerte critique : $serverName',
      reason,
      notificationDetails,
    );
  }
}