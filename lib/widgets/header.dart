import 'package:flutter/material.dart';

AppBar header(context , {bool isAppTitle = false , String titleText,
removeBackButton = false} ) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text (
      
      isAppTitle ? "Socially" : titleText , 
          style: TextStyle(
              color: isAppTitle ? Colors.white : Colors.white,
              fontFamily: isAppTitle ?"Signatra" :"Signatra",
              fontSize: isAppTitle ? 40.0 : 30.0,
          )
      ),
    centerTitle: true,
    backgroundColor: isAppTitle ? Theme.of(context).primaryColor : Theme.of(context).primaryColor ,
  );
  }
