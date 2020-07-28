import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socially/models/user.dart';
import 'package:socially/pages/home.dart';
import 'package:socially/widgets/progress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';

class Upload extends StatefulWidget {  
  final User currentUser;
  Upload({
    this.currentUser,
    });
  @override
  _UploadState createState() => _UploadState();  
}

TextStyle op = TextStyle(color: Colors.white,
                fontSize: 25.0,
                fontFamily: "Signatra");

class _UploadState extends State<Upload> {
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();
 
  File file;
  bool isUploading = false;
  String postId = Uuid().v4();
  handleTakePhoto() async {
    Navigator.pop(context);
    // ignore: deprecated_member_use
    File file = await ImagePicker.pickImage(source: ImageSource.camera,
    maxHeight:675,
    maxWidth: 960,
    );
    setState((){
      this.file = file;
    });
     
  }

  handleChooseFromGallery() async{
    Navigator.pop(context);
    // ignore: deprecated_member_use
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState((){
      this.file = file;
    });
  }
 selectImage(parentContext){
   return showDialog(
     context: parentContext,
     builder:(context){
       return SimpleDialog(
         backgroundColor: Colors.blue,
         title:Text("CREATE POST",style: TextStyle(color: Colors.white,
                fontSize: 25.0,
                fontFamily: "Signatra"),),
         children: <Widget>[
           SimpleDialogOption(
             child: Text("Take photo from camera",style:op),
             onPressed: handleTakePhoto,
           ),
           SimpleDialogOption(
             child: Text("Upload from gallery",style:op),
             onPressed: handleChooseFromGallery,
           ),
           SimpleDialogOption(
             child: Text("Cancel",style:op),
             onPressed: () => Navigator.pop(context),
           ),
         ],
       );
     }
     );
 }
  Container buildSplashScreen() {

    return Container(
      color: Colors.white,
      child: Column
      (
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset('assets/images/upload.svg',height:200.0),
          Padding(
            padding: EdgeInsets.only(top:20.0) ,
            child:RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)
              ),
              child: Text("Upload Image" ,
              style:TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontFamily: "Signatra"
               ),
               ),
               color: Colors.blue,
               onPressed: () => selectImage(context),
            )
            )

      ],
      )
    );
  }
 
 clearImage(){
   setState((){
     file =null;
   });
 }

  Future<String> uploadImage(imageFile) async{
    StorageUploadTask uploadTask = storageRef.child("post_$postId.jpg")
    .putFile(imageFile);
    StorageTaskSnapshot storageSnap =await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  //compressing image
  compressImage() async {
    final tempDir= await getTemporaryDirectory();
   final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile =File('$path/image_$postId.jpg')..writeAsBytesSync(Im.encodeJpg(
      imageFile, quality: 85
    ));
    file = compressedImageFile;
  }

  createPostInFirestore({String mediaUrl , String location ,
  String description}){
    postsRef.document(widget.currentUser.id).
    collection("UserPosts")
    .document(postId).setData({
      "postId":postId,
      "ownerId": widget.currentUser.id,
      "username": widget.currentUser.username,
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp":timestamp,
      "likes":{},
    });
  }
  
 handleSubmit() async{
   setState((){
     isUploading =true;
     //1gb limit for firebase so we will compress image we wantto uoload
   });
   await compressImage();
   String mediaUrl = await uploadImage(file);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    setState((){
      file=null;
      isUploading = false;
      postId = Uuid().v4();
    });
 }
 Scaffold buildUploadForm(){
   return Scaffold(
     appBar: AppBar(
       backgroundColor: Colors.blue,
       leading: IconButton(icon: Icon(Icons.arrow_back),
       color: Colors.white,
        onPressed: clearImage),
        title: Text("New Post",
        style:op),
        actions:[
          FlatButton(
            onPressed: isUploading ? null : ()=> handleSubmit(),
            child: Text("Post",style:op) ,)
          
        ],
     ),
     body:ListView(
       children: <Widget>[
         isUploading ? linearProgress(): Text(""),
         Container(
           height: 220.0,
           width: MediaQuery.of(context).size.width,
           child: Center(
             child: AspectRatio(aspectRatio: 4 / 5 ,
             child: Container(
             decoration: BoxDecoration(
               image: DecorationImage(
                 fit: BoxFit.cover,
                 image: FileImage(file),
               )
             ),
             ),
             )
           ),
         ),
         Padding(
           padding: EdgeInsets.only(top:10.0),
         ),
         ListTile(
          leading: CircleAvatar(
             backgroundImage: CachedNetworkImageProvider
             (widget.currentUser.photoUrl),
           ),
           title: Container(
             child: TextField(
                  controller: captionController,
                  decoration: InputDecoration(
                  hintText: "Enter caption..",
                  border:InputBorder.none,

                  )
             )
           )
         ),
         Divider(),
         ListTile(
           leading: Icon(Icons.pin_drop , 
           color: Colors.orange,
           size : 35.0,
           ),
           title: Container(
             width: 250.0,
             child:TextField(
               controller: locationController,
             decoration: InputDecoration(
             hintText: "Enter Location..",
             border: InputBorder.none,
             )
           )
         ),
         ),

         Container(
           width: 200.0,
           height:100.0,
           alignment: Alignment.center,
           child: RaisedButton.icon(
           label: Text("Use Current Location",
           style:op),
         
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(30.0),
         ),
         color: Colors.blue,
         onPressed: getUserLocation,
         icon:Icon(Icons.my_location,
         color:Colors.white)
         )
         )
       ]
     )
   );
 }
 getUserLocation() async{
  Position position = await Geolocator().getCurrentPosition(desiredAccuracy:LocationAccuracy.high);
  List<Placemark> placemarks = await Geolocator().placemarkFromCoordinates
  (position.latitude,position.longitude);
  Placemark placemark = placemarks[0];
  String completeAddress = '${placemark.subThoroughfare} ${placemark.thoroughfare} ${placemark.subLocality} ${placemark.locality} ${placemark.subAdministrativeArea} ${placemark.administrativeArea} ${placemark.postalCode} ${placemark.country}';
  print(completeAddress);

  String formattedAddress="${placemark.locality} ${placemark.country} ";
   locationController.text = formattedAddress;
   }
  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildUploadForm();
      
    
  }
}