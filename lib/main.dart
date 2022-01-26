import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_zoom_sdk/zoom_options.dart';
import 'package:flutter_zoom_sdk/zoom_view.dart';
import 'package:flutter_zoom_sdk_example/services/push_notification.dart';
import 'meeting_screen.dart';

// for complete example see https://github.com/evilrat/flutter_zoom_sdk/tree/master/example

void main() async {
  print('algo');

  WidgetsFlutterBinding.ensureInitialized();

  await PushNotification.initializeApp();
  runApp(ExampleApp());
}

class ExampleApp extends StatelessWidget {
  @override
  late Timer timer;

  Widget build(BuildContext context) {
    PushNotification.llamada.listen((data) {
      print('estamos llammado');
      print(data);
      joinMeeting(context, data[0], data[1]);
    });

    return MaterialApp(
      title: 'Example Zoom SDK',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: [],
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => MeetingWidget(),
      },
    );
  }

  joinMeeting(BuildContext context, idmeting, password) {
    bool _isMeetingEnded(String status) {
      var result = false;

      if (Platform.isAndroid)
        result = status == "MEETING_STATUS_DISCONNECTING" ||
            status == "MEETING_STATUS_FAILED";
      else
        result = status == "MEETING_STATUS_IDLE";

      return result;
    }

    ZoomOptions zoomOptions = new ZoomOptions(
      domain: "zoom.us",
      appKey: "XKE4uWfeLwWEmh78YMbC6mqKcF8oM4YHTr9I", //API KEY FROM ZOOM
      appSecret: "bT7N61pQzaLXU6VLj9TVl7eYuLbqAiB0KAdb", //API SECRET FROM ZOOM
    );
    var meetingOptions = new ZoomMeetingOptions(
        userId:
            'username', //pass username for join meeting only --- Any name eg:- EVILRATT.
        meetingId: idmeting, //pass meeting id for join meeting only
        meetingPassword: password, //pass meeting password for join meeting only
        disableDialIn: "true",
        disableDrive: "true",
        disableInvite: "true",
        disableShare: "true",
        disableTitlebar: "false",
        viewOptions: "true",
        noAudio: "false",
        noDisconnectAudio: "false");

    var zoom = ZoomView();
    zoom.initZoom(zoomOptions).then((results) {
      if (results[0] == 0) {
        zoom.onMeetingStatus().listen((status) {
          print("[Meeting Status Stream] : " + status[0] + " - " + status[1]);
          if (_isMeetingEnded(status[0])) {
            print("[Meeting Status] :- Ended");
            timer.cancel();
          }
        });
        print("listen on event channel");
        zoom.joinMeeting(meetingOptions).then((joinMeetingResult) {
          timer = Timer.periodic(new Duration(seconds: 2), (timer) {
            zoom.meetingStatus(meetingOptions.meetingId!).then((status) {
              print("[Meeting Status Polling] : " +
                  status[0] +
                  " - " +
                  status[1]);
            });
          });
        });
      }
    }).catchError((error) {
      print("[Error Generated] : " + error);
    });
    /* } else {
      if (meetingIdController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Enter a valid meeting id to continue."),
        ));
      } else if (meetingPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Enter a meeting password to start."),
        ));
      }
    } */
  }
}
