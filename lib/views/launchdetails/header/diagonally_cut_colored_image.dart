import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class DiagonallyCutColoredImage extends StatelessWidget {
  DiagonallyCutColoredImage({@required this.screenWidth, @required this.image});

  final double screenWidth;
  final String image;

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return new ClipPath(

        clipper: new DiagonalClipper(),
        child: new DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: new BoxDecoration(color: Theme.of(context).primaryColor),
          child: new Image.network(
            '',
            width: screenWidth,
            height: 240.0,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return new ClipPath(
        clipper: new DiagonalClipper(),
        child: Stack(
          children: <Widget>[
            Image.network(
              image,
              width: screenWidth,
              height: 240.0,
              fit: BoxFit.fill,
            ),
            Positioned(
              top: 10,
              bottom: 150,
              left: 30,
              right: 100,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0),
                ),
              ),
            )
          ],
        ),
      );
    }
  }
}

class DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = new Path();
    path.lineTo(0.0, size.height - 40);

    var firstControlPoint = Offset(size.width / 2, size.height);
    var firstEndPoint = Offset(size.width, size.height - 40.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width / 2, size.height);
    var secondEndPoint = Offset(size.width, size.height - 40.0);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
