import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routers/router.dart';

import 'provider/CartProvider.dart';
import 'provider/CheckOut.dart';

void main() => runApp(MyApp());

// 入口主页面
class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MultiProvider(

      // 注册provider
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CheckOut())
      ],

      child: MaterialApp(
        //home: Tabs(),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        onGenerateRoute: onGenerateRoute,
        theme: ThemeData(primaryColor: Colors.white),
      ),
    );
  }
}
