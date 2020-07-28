import 'package:flutter/material.dart';
import 'package:socially/widgets/custom_image.dart';
import 'package:socially/widgets/post.dart';

class PostTile extends StatelessWidget {
  final Post post;
  PostTile(this.post);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> print('showing post'),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}