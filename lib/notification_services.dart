import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'message_screen.dart';

class NotificationServices{

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();



  void requestNotificationPermission() async{

    NotificationSettings settings = await messaging.requestPermission(

      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,


    );
//android
    if(settings.authorizationStatus == AuthorizationStatus.authorized){

      print("User granted permission");


    }
    //iphone
    else if(settings.authorizationStatus == AuthorizationStatus.authorized){

      print("User Granted provisional permission");


    }else{

      print("User Denied permission");
    }
  }

  Future<void> initLocalNotifications(BuildContext context, RemoteMessage message) async{

    var androidInitialization = AndroidInitializationSettings('@mipmap-mdpi/ic_launcher.png');
    var iosInitialization = DarwinInitializationSettings();

    var initializeSettings = InitializationSettings(

        android: androidInitialization,
        iOS: iosInitialization

    );

    await _flutterLocalNotificationsPlugin.initialize(initializeSettings,

      onDidReceiveNotificationResponse: (payload){


      handleMessage(context, message);

      }

    );







  }

  void firebaseInit(BuildContext context){

    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        print(message.notification!.title.toString());
        print(message.notification!.body.toString());
        print(message.data.toString());
        print(message.data['type']);
        print(message.data['id']);
      }

      if (Platform.isAndroid){
        initLocalNotifications(context, message);
        showNotifications(message);
    }else{

        showNotifications(message);
      }







    });

  }

  Future<void> showNotifications(RemoteMessage message) async{

    AndroidNotificationChannel channel = AndroidNotificationChannel(

        Random.secure().nextInt(1000).toString(),

      'High Importance Notifications',
      importance: Importance.max,


    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(

      channel.id.toString(),
      channel.name.toString(),
      channelDescription: 'Your Channel Description',
      importance: Importance.high,
      priority: Priority.high,

      ticker: 'ticker'


    );
    DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(

      presentAlert: true,
      presentBadge: true,
      presentSound: true


    );

    NotificationDetails notificationDetails = NotificationDetails(

      android: androidNotificationDetails,
      iOS: darwinNotificationDetails

    );

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(

       0,


         message.notification!.title.toString(),

          message.notification!.body.toString(),


          notificationDetails

      );



    });












  }

  Future<String> getDeviceToken() async{

  String? token = await messaging.getToken();
    return token!;


  }


  void isTokenRefresh() async{

    messaging.onTokenRefresh.listen((event) {

      event.toString();
      print('refresh');

    });


  }


  Future<void> setupInteractMessage(BuildContext context) async{
//when app is terminated
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if(initialMessage != null){

      handleMessage(context, initialMessage);


    }

    //When app is in background


    FirebaseMessaging.onMessageOpenedApp.listen((event) {

      handleMessage(context, event);



    });





  }

  void handleMessage(BuildContext context, RemoteMessage message){


       if(message.data['type'] == 'msj'){

         Navigator.push(context, MaterialPageRoute(builder: (context) => MessageScreen(
           id: message.data['id'],
         )));

       }





  }



}