import 'dart:convert';

import 'package:fcm_notify/notification_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationServices.requestNotificationPermission();

    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);

   // notificationServices.isTokenRefresh();
    notificationServices.getDeviceToken().then((value) {

      print("Device Token");

      print(value);



    }).onError((error, stackTrace) {


      print(error.toString());

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(

        title: Text("Flutter Notifications"),
      ),
      body: Center(

        child: TextButton(
          onPressed: (){

            notificationServices.getDeviceToken().then((value) async{
              var data = {

                'to' : value.toString(),
                'priority' : 'high',
                'notification' : {

                  'title' : 'SIkander',
                  'body' : 'Subscribe to my channel',


                },
                'data' : 'msj',
                'id' : 'sikand1245',



              };
              await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),



                body: jsonEncode(data),
                headers: {


                'Content-Type' : 'application/json; charset=UTF-8',
                  'Authorization' : 'key=your-server-key'


                }

              );


            });


          },
          child: Text("Send Notificatiobn"),
        ),
      ),

    );
  }
}
