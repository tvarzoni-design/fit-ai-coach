import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'api_service.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  debugPrint('[FCM] Mensagem em background: ${message.messageId}');
}

class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final ApiService _api;
  final NotificationService _notificationService;
  String? _currentToken;
  bool _initialized = false;

  FirebaseMessagingService({
    required ApiService api,
    required NotificationService notificationService,
  })  : _api = api,
        _notificationService = notificationService;

  String? get currentToken => _currentToken;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        criticalAlert: false,
      );

      debugPrint('[FCM] Permissão: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await _getToken();
        _listenToTokenRefresh();
        _listenToForegroundMessages();
      }

      FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

      _initialized = true;
    } catch (e) {
      debugPrint('[FCM] Erro na inicialização: $e');
    }
  }

  Future<void> _getToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        _currentToken = token;
        debugPrint('[FCM] Token: $token');
        await _saveTokenLocally(token);
        await _sendTokenToBackend(token);
      }
    } catch (e) {
      debugPrint('[FCM] Erro ao obter token: $e');
    }
  }

  void _listenToTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('[FCM] Token atualizado: $newToken');
      _currentToken = newToken;
      _saveTokenLocally(newToken);
      _sendTokenToBackend(newToken);
    }).onError((e) {
      debugPrint('[FCM] Erro ao atualizar token: $e');
    });
  }

  void _listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM] Mensagem em foreground: ${message.notification?.title}');

      final title = message.notification?.title ?? 'Notificação';
      final body = message.notification?.body ?? '';
      final data = message.data;

      _notificationService.showInAppNotification(
        title: title,
        message: body,
        data: data,
      );
    }).onError((e) {
      debugPrint('[FCM] Erro ao escutar mensagens: $e');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] App aberto via notificação: ${message.notification?.title}');
      _handleNotificationTap(message.data);
    }).onError((e) {
      debugPrint('[FCM] Erro ao escutar abertura: $e');
    });
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'];
    if (type == null) return;
    debugPrint('[FCM] Navegando para tipo: $type');
  }

  Future<void> _saveTokenLocally(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
    } catch (e) {
      debugPrint('[FCM] Erro ao salvar token localmente: $e');
    }
  }

  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString(AppConstants.tokenKey);
      if (authToken == null) {
        debugPrint('[FCM] Usuário não autenticado, ignorando envio do token');
        return;
      }

      _api.setToken(authToken);
      await _api.registerDeviceToken(token);
      debugPrint('[FCM] Token enviado ao backend com sucesso');
    } catch (e) {
      debugPrint('[FCM] Erro ao enviar token ao backend: $e');
    }
  }

  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _currentToken = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('fcm_token');
    } catch (e) {
      debugPrint('[FCM] Erro ao remover token: $e');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('[FCM] Inscrito no tópico: $topic');
    } catch (e) {
      debugPrint('[FCM] Erro ao inscrever no tópico: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('[FCM] Desinscrito do tópico: $topic');
    } catch (e) {
      debugPrint('[FCM] Erro ao desinscrever do tópico: $e');
    }
  }
}
