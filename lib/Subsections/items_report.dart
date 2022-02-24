import 'dart:convert';
import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:intermax_warehouse_app/Client/server_side_api.dart';
import 'package:intermax_warehouse_app/Items%20Report%20Model/items_report_model.dart';
import 'package:intermax_warehouse_app/UserState/user_state.dart';
import 'package:sizer/sizer.dart';

class ItemsReportPage extends StatefulWidget {
  const ItemsReportPage({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<ItemsReportPage>  {

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType){
      return Scaffold(
        appBar: AppBar(
          title: Text('Отчёты товаров', style: TextStyle(fontSize: 5.sp)),
          centerTitle: true,
          backgroundColor: Colors.lightBlue,
        ),

        body: Center(child: getItemsReport())
      );
    });
  }

  //Getting items report
  FutureBuilder<Response<List<ItemReport>>> getItemsReport() {
    var data = {'ip' : UserState.getIP};
    return FutureBuilder<Response<List<ItemReport>>>(
      future: ServerSideApi.create(UserState.getIP()!, 19).getItemsReport(data),
      builder: (context, snapshot) {
        while(snapshot.connectionState == ConnectionState.waiting){
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
          List<ItemReport>? reports = snapshot.data!.body;
          return buildItemsReportTable(reports);
        }else{
          return Center(
            child: Text('Список пуст', style: TextStyle(fontSize: 8.sp)),
          );
        }
      },
    );
  }

  Widget buildItemsReportTable(List<ItemReport>? reports) {
    return SingleChildScrollView(
      child: DataTable(
        columns: [
          DataColumn(label: Text('')),
          DataColumn(label: Text('Товар')),
          DataColumn(label: Text('Дата поступления')),
          DataColumn(label: Text('Количество')),
          DataColumn(label: Text('Поставщик')),
          DataColumn(label: Text('Цена')),
          DataColumn(label: Text('')),
          DataColumn(label: Text(''))
        ],
        rows: List<DataRow>.generate(reports!.length, (index) {
          ItemReport itemReport = reports[index];
          return DataRow(
            cells: [
              DataCell(Container(
                height: 5.h,
                width: 5.w,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: Image.memory(const Base64Decoder()
                            .convert(itemReport.photo.toString()))
                            .image)),
              )),
              DataCell(Text(itemReport.item)),
              DataCell(Text(itemReport.date)),
              DataCell(Text(itemReport.count + ' ' + itemReport.count_option)),
              DataCell(Text(itemReport.supplier)),
              DataCell(Text(itemReport.price)),
              DataCell(IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => null,
              )),
              DataCell(IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => null,
              ))
            ]
          );
        }),
      )
    );
  }
}