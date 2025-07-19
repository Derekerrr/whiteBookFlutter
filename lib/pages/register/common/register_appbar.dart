import 'package:flutter/material.dart';

AppBar registerAppBar(BuildContext context) {
  return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context); // 返回登录页，自动带动画
        },
      ),
      title: Padding(
        padding: const EdgeInsets.only(top: 0.0),
        child: const Text(
          'Create new account',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      )
  );
}