import 'package:flutter/material.dart';

// ignore_for_file: must_be_immutable
class CinemaFormatChip {
  CinemaFormatChip({
    this.label,
    this.textColor,
    this.backgroundColor,
    this.borderColor,
  }) {
    label = label ?? '';
    textColor = textColor ?? Color(0xFFFFDF9E);
    backgroundColor = backgroundColor ?? Color(0x19FABD00);
    borderColor = borderColor ?? Color(0x4CFFDF9E);
  }

  String? label;
  Color? textColor;
  Color? backgroundColor;
  Color? borderColor;
}

class CinemaModel {
  CinemaModel({this.name, this.distance, this.formats, this.id}) {
    name = name ?? '';
    distance = distance ?? '';
    formats = formats ?? [];
    id = id ?? '';
  }

  String? name;
  String? distance;
  List<CinemaFormatChip>? formats;
  String? id;

  CinemaModel copyWith({
    String? name,
    String? distance,
    List<CinemaFormatChip>? formats,
    String? id,
  }) {
    return CinemaModel(
      name: name ?? this.name,
      distance: distance ?? this.distance,
      formats: formats ?? this.formats,
      id: id ?? this.id,
    );
  }
}
