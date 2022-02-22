import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:intermax_warehouse_app/Client/server_side_api.dart';
import 'package:intermax_warehouse_app/Items%20Report%20Model/items_report_model.dart';
import 'package:intermax_warehouse_app/UserState/user_state.dart';
import 'package:sizer/sizer.dart';

class ItemsReportPage extends StatefulWidget{
  const ItemsReportPage({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<ItemsReportPage>{


  Future<Response<List<ItemReport>>>? _future;
  List<ItemReport>? reports;

  @override
  void initState() {
    super.initState();

    var data = {'ip' : UserState.getIP};
    _future = ServerSideApi.create(UserState.getIP()!, 19).getItemsReport(data);
    _future!.then((value) => reports = value.body);
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType){
      return Scaffold(
        appBar: AppBar(
          title: Text('Отчёты товаров', style: TextStyle(fontSize: 5.sp)),
          centerTitle: true,
          backgroundColor: Colors.lightBlue,
        ),

        body: getItemsReport(),
      );
    });
  }

  //Getting items report
  FutureBuilder<Response<List<ItemReport>>> getItemsReport(){
    return FutureBuilder<Response<List<ItemReport>>>(
      future: _future,
      builder: (context, snapshot){
        while(snapshot.connectionState == ConnectionState.done){
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
          return Container();
        }else{
          return Container();
        }
      },
    );
  }

  Widget buildItemsReportTable(){
    return SingleChildScrollView(

    );
  }
}