import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ItemsReportPage extends StatefulWidget{
  const ItemsReportPage({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<ItemsReportPage>{
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType){
      return Scaffold(
        appBar: AppBar(
          title: Text('Отчёты товаров', style: TextStyle(fontSize: 5.sp)),
          centerTitle: true,
          backgroundColor: Colors.lightBlue,
        ),
      );
    });
  }
}