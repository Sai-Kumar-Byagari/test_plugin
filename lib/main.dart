import 'package:flutter/material.dart';
import 'src/screens/mpin_login_page.dart';

export 'src/screens/mpin_login_page.dart';
export 'src/utils/user_authentication.dart';
export 'src/screens/card_details_page.dart';

void main() => runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MPinLoginPage(),
    )
);



