import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socially/models/user.dart';
import 'package:socially/pages/home.dart';
import 'package:socially/widgets/progress.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;
  
  EditProfile({this.currentUserId});
  @override
  _EditProfileState createState() => _EditProfileState();
}
TextStyle op = TextStyle(color: Colors.white,
                fontSize: 25.0,
                fontFamily: "Signatra");

TextStyle ops = TextStyle(color: Colors.black,
                fontSize: 18.0,
                );     

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  User user;
  bool _displayNameValid = true;
  bool _bioValid =true;

  @override
  void initState() {
    
    super.initState();
    getUser();
  }

  getUser() async{
    setState(() {
      isLoading = true;
    });
   DocumentSnapshot doc = await usersRef.document(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayNameController.text=user.displayName;
    bioController.text =user.bio;
    setState(() {
      isLoading = false;
    });
  }

  Column  buildDisplayNameField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
          Padding(padding:EdgeInsets.only(top: 12.0),
          child: Text("Display Name" , style: ops),

          
          ),
          TextField(
            controller: displayNameController,
            decoration: InputDecoration(
              hintText: "Update Display Name",
              hintStyle: TextStyle(fontSize:15.0,color: Colors.grey[400]),
              errorText: _displayNameValid ? null: "Display Name should be of 3 characters"
            )
          )
      ],
    );
  }
 
 Column  buildBioField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
          Padding(padding:EdgeInsets.only(top: 12.0),
          child: Text("Bio" , style: ops),

          
          ),
          TextField(
            controller: bioController,
            decoration: InputDecoration(
              hintText: "Update Bio",
              hintStyle: TextStyle(fontSize:15.0,color: Colors.grey[400]),
              errorText: _bioValid ? null: "Bio should be of less than 150 characters"
           
            )
          )
      ],
    );
  }

 updateProfileData(){
    setState(() {
      displayNameController.text.trim().length < 3 ||
       displayNameController.text.isEmpty ? _displayNameValid = false :
       _displayNameValid = true;
      
       bioController.text.isEmpty ? _bioValid = false :
       _bioValid = true;

    });

    if(_displayNameValid && _bioValid){
      usersRef.document(widget.currentUserId).updateData({
        "displayName": displayNameController.text,
        "bio": bioController.text,
      });
      SnackBar snackbar = SnackBar(content: Text("Profile updated!"));
      _scaffoldKey.currentState.showSnackBar(snackbar);
    }
  }

logout() async{
  await googleSignIn.signOut();
  Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "Edit Profile",style: op,
        ),
        actions: <Widget>[
          
          IconButton(
            onPressed: ()=> Navigator.pop(context),
            icon: Icon(Icons.done,
            size:30.0,
            color: Colors.green)
          )
        ],
      ),

      body: isLoading ? circularProgress():
      ListView(
        children: <Widget>[
          Container(
            child: Column(children: <Widget>[
             Padding(padding: EdgeInsets.only(top: 16.0,
             bottom:8.0,
             ),
             child: CircleAvatar(
               radius: 50.0,
               backgroundImage: CachedNetworkImageProvider(user.photoUrl),
               )
             ),
             Padding(
               padding: EdgeInsets.all(16.0),
               child: Column(children: <Widget>[
                 buildDisplayNameField(),
                 buildBioField(),
               ],)
             ),
             RaisedButton(onPressed:updateProfileData,
             child: Text(
               "Update Profile",
               style: op,   
              ),
             color: Colors.blue,
             ) ,

             Padding(padding: EdgeInsets.all(12.0),
             child: RaisedButton(onPressed: logout ,
             
             child: Text(
               "Log out",
               style: op,   
              ),
             color: Colors.blue,
             )  
             )   
            ],
            )

          )
          
        ]

      )
    );
  }
}