import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

class ParallaxHero extends StatelessWidget {
  const ParallaxHero({required this.tag, required this.imageUrl, super.key});

  final String tag;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
