import 'package:flutter/material.dart';

Icon favoriteIcon(bool alreadySaved) {
  return Icon(
    alreadySaved ? Icons.favorite : Icons.favorite_border,
    color: alreadySaved ? Colors.red : null,
  );
}