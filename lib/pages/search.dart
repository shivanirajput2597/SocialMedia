import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:socially/models/user.dart';
import 'package:socially/pages/home.dart';
import 'package:socially/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;

  handleSearch(String query){
   Future<QuerySnapshot> users = usersRef.
   where( "username", isGreaterThanOrEqualTo: query).getDocuments();

    setState((){
      searchResultsFuture = users;
    });
  }
  
  clearSearch(){
    searchController.clear();
  }
  
  
  
  AppBar buildSearchField(){

    return AppBar(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      title: TextFormField(
      controller : searchController,
      decoration: InputDecoration(
        hintText: " Search for a user.." ,
        filled: true,
        prefixIcon: Icon(
          Icons.account_box,
          size: 28.0,
          color: Colors.white,
        ),
        suffixIcon: IconButton(
          icon: Icon(Icons.clear,color: Colors.white,),
          onPressed: clearSearch,
        ),
      ),
      onFieldSubmitted: handleSearch,
      )
    );

  }

  Container buildNoContent(){
    final orientation = MediaQuery.of(context).orientation;
    return Container(
      child:Center(
        child:ListView( 
          children: <Widget>[
            SvgPicture.asset('assets/images/search.svg',
            height: orientation == Orientation.portrait? 250.0 : 150.0,
            
            ),
            Text("Find Users" , textAlign: TextAlign.center, style: 
            TextStyle(
              color: Theme.of(context).primaryColor,
              fontFamily: "Signatra",
              fontStyle: FontStyle.italic,
              fontWeight : FontWeight.w600,
              fontSize: 60.0,
            ))
          ],
        )
      )

    );

   }

  buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,    
      builder: (context, snapshot) { 
        if(!snapshot.hasData){
          return circularProgress();
        }
      
      List<UserResult> searchResults = [];
      snapshot.data.documents.forEach((DocumentSnapshot doc){
       User user = User.fromDocument(doc);
      UserResult searchResult= UserResult(user);
      searchResults.add(searchResult);
       
      });

      return ListView(
        children: searchResults,
        
      );
      });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildSearchField(),
        body: searchResultsFuture == null? buildNoContent() : 
        buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;
   UserResult(this.user);
  @override
  Widget build(BuildContext context) {
    return Container(
      color:Theme.of(context).primaryColor,
      child: Column(children: <Widget>[
        GestureDetector(
          onTap: ()=> print('tapped'),
          child:ListTile(
            leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            ),
            title: Text(user.displayName, style: TextStyle(
              color:Colors.white,
              fontWeight:FontWeight.bold
              ),),
              subtitle: Text(user.username,style:TextStyle(
                color:Colors.white),
                  
                ),
            
            )
          ),
          Divider(
            height: 2.0,
            color: Colors.white54
          ),
        ],
      ),
    );
  }
}