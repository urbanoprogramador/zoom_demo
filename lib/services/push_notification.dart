//23:AF:0D:F4:8D:F6:DD:8E:3B:B1:21:C6:AB:ED:49:D1:95:0F:67:0A
// segunda aunque parece la misma
//23:AF:0D:F4:8D:F6:DD:8E:3B:B1:21:C6:AB:ED:49:D1:95:0F:67:0A

import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:http/http.dart' as http;

import 'package:qr/qr.dart';

class PushNotification {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String? token;

  static String get eltoken => token ?? '';

  static StreamController<List<String>> _llamdaStringController =
      new StreamController.broadcast();

  static Stream<List<String>> get llamada => _llamdaStringController.stream;

  static closeStream() {
    _llamdaStringController.close();
  }

  static Future initializeApp() async {
    //
    print('no se qeu paso ');
    await Firebase.initializeApp();

    token = await FirebaseMessaging.instance.getToken();

    print(token);

    //handels
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
    FirebaseMessaging.onMessage.listen(_onMessageHandle);
    FirebaseMessaging.onMessageOpenedApp.listen(_onOpenMessageApp);
  }

  static Future _backgroundHandler(RemoteMessage message) async {
    print('mensaje 1 ${message.messageId}');
    print('mensaje 1 ${message.toString()}');
    _llamdaStringController.add([
      message.notification?.title ?? 'no',
      message.notification?.body ?? 'no'
    ]);
  }

  static Future _onMessageHandle(RemoteMessage message) async {
    print('mensaje 2 ${message.messageId}');
    print(
        'mensaje 2 ${message.notification?.title} ${message.notification?.body}');
    _llamdaStringController.add([
      message.notification?.title ?? 'no',
      message.notification?.body ?? 'no'
    ]);
  }

  static Future _onOpenMessageApp(RemoteMessage message) async {
    print('mensaje 3 ${message.messageId}');
    print('mensaje 3 ${message.toString()}');
    _llamdaStringController.add([
      message.notification?.title ?? 'no',
      message.notification?.body ?? 'no'
    ]);
  }

  static String constructFCMPayload(String token, List<String> data) {
    print('to: ${token}');
    print('title: ${data[0]}');
    print('body: ${data[1]}');
    return jsonEncode({
      'to': token,
      'notification': {
        'title': data[0],
        'body': data[1],
      },
    });
  }

  static Future<void> sendPushMessage(token1, meetingDetailsResult) async {
    print(meetingDetailsResult);
    try {
      dynamic res = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'key=AAAAcsYlqb8:APA91bG5fgJl-b-3LjejHkX358Ua3onNtnA54hXoofHlEnSYJTmQZcpwd7z2CSYZt7EAGJnYXWjUcKThEnHpuVXNGk42j8jFm6YqyQS99cC4F4DtaEg_Bu9syFikN1DQARYdGaxHge0J'
        },
        body: constructFCMPayload(token1,
            ['${meetingDetailsResult[0]}', '${meetingDetailsResult[1]}']),
      );
      print('respuesta ${res.body}');
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }
}
