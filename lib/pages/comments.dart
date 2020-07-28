
import 'package:flutter/material.dart';
import 'package:socially/pages/home.dart';
import 'package:socially/widgets/header.dart';
import 'package:socially/widgets/progress.dart';

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  Comments({
  this.postId,
  this.postOwnerId,
  this.postMediaUrl,
  });

  @override
  _CommentsState createState() => _CommentsState(
    postId: this.postId,
    postOwnerId: this.postOwnerId,
    postMediaUrl: this.postMediaUrl,
  );
}

class _CommentsState extends State<Comments> {
    TextEditingController commentController = TextEditingController();


    final String postId;
    final String postOwnerId;
    final String postMediaUrl;

    _CommentsState({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
    });

  buildComments(){
      return StreamBuilder(
      stream: commentsRef.document(postId).collection('thoughts').
      orderBy("timestamp",descending: false).snapshots(),
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        
      }
      );
  }
  addComment(){
    commentsRef.document(postId).
    collection("comments").
    add({
      "username": currentUser.username,
      "comment" : commentController.text,
      "timestamp": timestamp,
      "avatarUrl": currentUser.photoUrl,
      "userId" : currentUser.id,
      
    });
    commentController.clear();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,titleText: "Comments"),
      body: Column(children: <Widget>[
        Expanded(child: buildComments()),
        Divider(),
        ListTile(
          title: TextFormField(
            controller: commentController,
            decoration: InputDecoration(
              labelText: "Write a comment.."), ),       
            trailing: OutlineButton(
              onPressed: addComment,
              borderSide: BorderSide.none,
              child: Text("Post"),          
            ),         
        ),
      ],
      )
      
    );
  }
}