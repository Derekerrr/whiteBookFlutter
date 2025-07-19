import 'package:flutter/material.dart';

InputDecoration roundedInputDecoration(String placeholder) {
  return InputDecoration(
    hintText: placeholder,
    hintStyle: const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.grey,
    ),
    filled: true,
    fillColor: Colors.grey.shade200,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
}
