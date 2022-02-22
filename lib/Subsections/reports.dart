import 'dart:html';
import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intermax_warehouse_app/Client/server_side_api.dart';
import 'package:intermax_warehouse_app/IssuedItemsDetails/issued_items.dart';
import 'package:intermax_warehouse_app/UserState/user_state.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';


class ReportsSection extends StatefulWidget {
  const ReportsSection({Key? key}) : super(key: key);

  @override
  _ReportsSectionState createState() => _ReportsSectionState();
}

class _ReportsSectionState extends State<ReportsSection> {
  List<IssuedItems>? _issuedItems;
  List<IssuedItems>? _filtered;

  int? sortColumnIndex;
  bool isAscending = false;

  DateTime selectedDate = DateTime.now();

  var formatter = DateFormat('dd.MM.yyyy');
  String? formattedDate;

  String? dropDownItemName = 'Последние 7 дней';

  @override
  void initState() {
    super.initState();
    document.onContextMenu.listen((event) => event.preventDefault());
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        String formattedDate = formatter.format(selectedDate);
        return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text('Отчёты', style: TextStyle(fontSize: 5.sp)),
              centerTitle: true,
              backgroundColor: Colors.lightBlue,
              actions: [
                Padding(
                  padding: EdgeInsets.only(top: 2.sp, bottom: 2.sp, right: 2.sp),
                  child: Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${formattedDate}', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(width: 1.w),
                        IconButton(
                          icon: Icon(Icons.calendar_today_outlined),
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null && picked != selectedDate) {
                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_forever_rounded),
                          onPressed: () async {
                            await showDialog(
                                context: context,
                                builder: (context){
                                  return StatefulBuilder(
                                    builder: (context, setState){
                                      return SimpleDialog(
                                        title: const Text('Очистить отчеты'),
                                        contentPadding: EdgeInsets.all(5.0.sp),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0.sp)),
                                        backgroundColor: Colors.white,
                                        children: [
                                          Row(
                                            children: [
                                              Text('Промежуток: ', style: TextStyle(fontSize: 3.sp)),
                                              SizedBox(width: 1.w),
                                              DropdownButton(
                                                  value: dropDownItemName,
                                                  icon: const Icon(Icons.arrow_drop_down),
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      dropDownItemName = value;
                                                    });
                                                  },
                                                  items: <String>[
                                                    'Последние 7 дней',
                                                    'Последние 14 дней',
                                                    'Последние 30 дней',
                                                    'Всё время']
                                                      .map<DropdownMenuItem<String>>((String value) {
                                                    return DropdownMenuItem(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList())
                                            ],
                                          ),
                                          SizedBox(height: 2.h),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              FloatingActionButton.extended(
                                                label: Text('Отмена'),
                                                backgroundColor: Colors.redAccent,
                                                onPressed: () => Navigator.pop(context),
                                              ),
                                              SizedBox(width: 1.w),
                                              FloatingActionButton.extended(
                                                label: Text('Очистить'),
                                                onPressed: () async {
                                                  var data;
                                                  switch(dropDownItemName){
                                                    case 'Последние 7 дней':
                                                      data = {'ip': UserState.getIP(), 'days' : 7};
                                                      break;
                                                    case 'Последние 14 дней':
                                                      data = {'ip': UserState.getIP(), 'days' : 14};
                                                      break;
                                                    case 'Последние 30 дней':
                                                      data = {'ip': UserState.getIP(), 'days' : 30};
                                                      break;
                                                    case 'Всё время':
                                                      data = {'ip': UserState.getIP(), 'days' : '*'};
                                                      break;
                                                  }
                                                  Response response = await ServerSideApi.create(UserState.getIP()!, 1).clearReports(data);
                                                  if(response.body == 'cleared'){
                                                    _showToast(1);
                                                    Navigator.pop(context);
                                                  }
                                                },
                                              ),
                                            ],
                                          )
                                        ],
                                      );
                                    },
                                  );
                                }
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                    padding:
                        EdgeInsets.only(top: 2.sp, bottom: 2.sp, right: 2.sp),
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 30.h,
                        child: TextFormField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3.0.sp)),
                            hintText: 'Поиск...',
                          ),
                          onChanged: (value) {
                            setState(() {
                              _filtered = _issuedItems!
                                  .where((item) =>
                                      item.item
                                          .toLowerCase()
                                          .contains(value.toLowerCase()) ||
                                      item.description
                                          .toLowerCase()
                                          .contains(value.toLowerCase()) ||
                                      item.brigade.contains(value) ||
                                      item.members
                                          .toLowerCase()
                                          .contains(value.toLowerCase()) ||
                                      item.date.contains(value) ||
                                      item.count.contains(value))
                                  .toList();
                            });
                          },
                        ),
                      ),
                    ))
              ],
            ),
            body: createReport());
      },
    );
  }

  // Getting issued items from database
  FutureBuilder<Response<List<IssuedItems>>> createReport() {
    formattedDate = formatter.format(selectedDate);
    var data = {'ip': UserState.getIP(), 'date' : formattedDate};

    return FutureBuilder<Response<List<IssuedItems>>>(
      future: ServerSideApi.create(UserState.getIP()!, 6).createReport(data),
      builder: (context, snapshot) {
        while (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          _issuedItems = snapshot.data!.body;
          _filtered = _issuedItems;
          return createReportList();
        } else {
          return Center(child: Text('Список отчётов пуст', style: TextStyle(fontSize: 8.sp)));
        }
      },
    );
  }

  // Creating reports list
  Widget createReportList() {
    return SizedBox.expand(
        child: SingleChildScrollView(
            child: DataTable(
                sortColumnIndex: sortColumnIndex,
                sortAscending: isAscending,
                columnSpacing: 10.sp,
                columns: [
                  DataColumn(
                      label: Text('Имя товара',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onSort: onSort),
                  DataColumn(
                      label: Text('Описание',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onSort: onSort),
                  DataColumn(
                      label: Text('Бригада',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onSort: onSort),
                  DataColumn(
                      label: Text('Дата выдачи',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onSort: onSort),
                  DataColumn(
                      label: Text('Количество',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onSort: onSort),
                  DataColumn(label: Text('Выдан пользователем', style: TextStyle(fontWeight: FontWeight.bold)), onSort: onSort)    
                ],
                rows: List<DataRow>.generate(
                  _filtered!.length,
                  (index) => DataRow(cells: [
                    DataCell(Text(_filtered![index].item)),
                    DataCell(Text(_filtered![index].description)),
                    DataCell(Text(_filtered![index].brigade +
                        ' (' +
                        _filtered![index].members +
                        ')')),
                    DataCell(Text(_filtered![index].date)),
                    DataCell(Text(_filtered![index].count +
                        ' ' +
                        _filtered![index].countOption)),
                    DataCell(Text(_filtered![index].user))    
                  ]),
                ))));
  }
 
  // Sorting algorithm
  void onSort(int columnIndex, bool ascending) {
    if (_filtered == null) {
      if (columnIndex == 0) {
        _issuedItems!.sort((a, b) => compareString(ascending, a.item, b.item));
      } else if (columnIndex == 1) {
        _issuedItems!.sort(
            (a, b) => compareString(ascending, a.description, b.description));
      } else if (columnIndex == 2) {
        _issuedItems!
            .sort((a, b) => compareString(ascending, a.brigade, b.brigade));
      } else if (columnIndex == 3) {
        _issuedItems!.sort((a, b) => compareString(ascending, a.date, b.date));
      } else if (columnIndex == 4) {
        _issuedItems!
            .sort((a, b) => compareString(ascending, a.count, b.count));
      } else if(columnIndex == 5){
        _issuedItems!
            .sort((a, b) => compareString(ascending, a.user, b.user));
      }
    } else {
      if (columnIndex == 0) {
        _filtered!.sort((a, b) => compareString(ascending, a.item, b.item));
      } else if (columnIndex == 1) {
        _filtered!.sort(
            (a, b) => compareString(ascending, a.description, b.description));
      } else if (columnIndex == 2) {
        _filtered!
            .sort((a, b) => compareString(ascending, a.brigade, b.brigade));
      } else if (columnIndex == 3) {
        _filtered!.sort((a, b) => compareString(ascending, a.date, b.date));
      } else if (columnIndex == 4) {
        _filtered!.sort((a, b) => compareString(ascending, a.count, b.count));
      } else if(columnIndex == 5){
        _filtered!.sort((a, b) => compareString(ascending, a.user, b.user));
      }
    }

    setState(() {
      this.sortColumnIndex = columnIndex;
      this.isAscending = ascending;
    });
  }
  
  // Compare string function
  int compareString(bool ascending, String value1, String value2) {
    return ascending ? value1.compareTo(value2) : value2.compareTo(value1);
  }

  //Shows toasts by given id
  void _showToast(int code) {
    FToast fToast = FToast();
    fToast.init(context);
    late Container toast;

    switch (code) {
      case 1:
        toast = Container(
          padding: EdgeInsets.symmetric(horizontal: 5.0.sp, vertical: 5.0.sp),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0.sp),
            color: Colors.greenAccent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check),
              SizedBox(
                width: 5.0.w,
              ),
              const Text("Успешно"),
            ],
          ),
        );
        break;
    }

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 3),
    );
  }
}
