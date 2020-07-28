import 'package:flutter/material.dart';
import 'package:socially/widgets/header.dart';
import 'package:socially/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final CollectionReference usersRef =  Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}
 
class _TimelineState extends State<Timeline> {

  
   @override
   Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle : true   ),       
      body: Text('timeline'),   
    );
  }
}