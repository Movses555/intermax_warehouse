import 'dart:html';
import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intermax_warehouse_app/Client/server_side_api.dart';
import 'package:intermax_warehouse_app/LogsDetails/log_details.dart';
import 'package:intermax_warehouse_app/UserState/user_state.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class Logs extends StatefulWidget {
  const Logs({Key? key}) : super(key: key);

  _LogsState createState() => _LogsState();
}

class _LogsState extends State<Logs> {
  List<Log>? logList;
  List<Log>? filtered;

  int? sortColumnIndex;
  bool isAscending = false;

  DateTime selectedDate = DateTime.now();

  var formatter = DateFormat('yyyy-MM-dd');
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
        var formatter = DateFormat('dd.MM.yyyy');
        String formatted = formatter.format(selectedDate);
        return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text('Логи', style: TextStyle(fontSize: 5.sp)),
              centerTitle: true,
              backgroundColor: Colors.lightBlue,
              actions: [
                Padding(
                  padding: EdgeInsets.only(top: 2.sp, bottom: 2.sp, right: 2.sp),
                  child: Align(
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Text('${formatted}', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                      title: const Text('Очистить логи'),
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
                                                Response response = await ServerSideApi.create(UserState.getIP()!, 1).clearLogs(data);
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
                        )
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
                              filtered = logList!
                                  .where((item) =>
                                      item.item
                                          .toLowerCase()
                                          .contains(value.toLowerCase()) ||
                                      item.subsection
                                          .toLowerCase()
                                          .contains(value.toLowerCase()) ||
                                      item.changedProperty
                                          .toLowerCase()
                                          .contains(value.toLowerCase()) ||
                                      item.oldValue
                                          .toLowerCase()
                                          .contains(value.toLowerCase()) ||
                                      item.newValue
                                          .toLowerCase()
                                          .contains(value.toLowerCase()) ||
                                      item.date.contains(value))
                                  .toList();
                            });
                          },
                        ),
                      ),
                    ))
              ],
            ),
            body: getLogs());
      },
    );
  }

  // Getting logs from server
  FutureBuilder<Response<List<Log>>> getLogs() {
    formattedDate = formatter.format(selectedDate);
    var data = {'ip': UserState.getIP(), 'date' : formattedDate};

    return FutureBuilder<Response<List<Log>>>(
      future: ServerSideApi.create(UserState.getIP()!, 8).getLogs(data),
      builder: (context, snapshot) {
        while (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          logList = snapshot.data!.body;
          filtered = logList;
          return createLogList();
        } else {
          return Center(child: Text('Нет логов', style: TextStyle(fontSize: 8.sp)));
        }
      },
    );
  }

  // Creating logs list
  Widget createLogList() {
    return SizedBox.expand(
        child: SingleChildScrollView(
      child: DataTable(
        sortColumnIndex: sortColumnIndex,
        sortAscending: isAscending,
        columnSpacing: 10.0.sp,
        columns: [
          DataColumn(
              label: Text('Подраздел',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onSort: onSort),
          DataColumn(
              label:
                  Text('Товар', style: TextStyle(fontWeight: FontWeight.bold)),
              onSort: onSort),
          DataColumn(
              label: Text('Бригада',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onSort: onSort),
          DataColumn(
              label: Text('Изм. свойство',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onSort: onSort),
          DataColumn(
              label: Text('Старое знач.',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onSort: onSort),
          DataColumn(
              label: Text('Новое знач.',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onSort: onSort),
          DataColumn(
              label:
                  Text('Дата', style: TextStyle(fontWeight: FontWeight.bold)),
              onSort: onSort),
          DataColumn(label: Text('Изменено пользователем', style: TextStyle(fontWeight: FontWeight.bold)), onSort: onSort)    
        ],
        rows: List.generate(
            filtered!.length,
            (index) => DataRow(cells: [
                  DataCell(Text(filtered![index].subsection)),
                  DataCell(Text(filtered![index].item)),
                  DataCell(Text(filtered![index].brigade != ''
                                ? filtered![index].brigade + ' (' + filtered![index].members + ')'
                                : '----')),
                  DataCell(filtered![index].changedProperty == 'Товар удалён'
                      ? Text(filtered![index].changedProperty,
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                      : Text(filtered![index].changedProperty)),
                  DataCell(Text(filtered![index].oldValue)),
                  DataCell(Text(filtered![index].newValue)),
                  DataCell(Text(filtered![index].date)),
                  DataCell(Text(filtered![index].user))
                ])),
      ),
    ));
  }

  // Sorting algorithm
  void onSort(int columnIndex, bool ascending) {
    if (filtered == null) {
      if (columnIndex == 0) {
        logList!.sort(
            (a, b) => compareString(ascending, a.subsection, b.subsection));
      } else if (columnIndex == 1) {
        logList!.sort((a, b) => compareString(ascending, a.item, b.item));
      } else if (columnIndex == 2) {
        logList!.sort((a, b) => compareString(ascending, a.brigade, b.brigade));
      } else if (columnIndex == 3) {
        logList!.sort((a, b) =>
            compareString(ascending, a.changedProperty, b.changedProperty));
      } else if (columnIndex == 4) {
        logList!
            .sort((a, b) => compareString(ascending, a.oldValue, b.oldValue));
      } else if (columnIndex == 5) {
        logList!
            .sort((a, b) => compareString(ascending, a.newValue, b.newValue));
      } else if (columnIndex == 6) {
        logList!.sort((a, b) => compareString(ascending, a.date, b.date));
      }else if(columnIndex == 7){
        logList!.sort((a, b) => compareString(ascending, a.user, b.user));
      }
    } else {
      if (columnIndex == 0) {
        filtered!.sort(
            (a, b) => compareString(ascending, a.subsection, b.subsection));
      } else if (columnIndex == 1) {
        filtered!.sort((a, b) => compareString(ascending, a.item, b.item));
      } else if (columnIndex == 2) {
        filtered!.sort((a, b) => compareString(ascending, a.brigade, b.brigade));
      } else if (columnIndex == 3) {
        filtered!.sort((a, b) =>
            compareString(ascending, a.changedProperty, b.changedProperty));
      } else if (columnIndex == 4) {
        filtered!
            .sort((a, b) => compareString(ascending, a.oldValue, b.oldValue));
      } else if (columnIndex == 5) {
        filtered!
            .sort((a, b) => compareString(ascending, a.newValue, b.newValue));
      } else if (columnIndex == 6) {
        filtered!.sort((a, b) => compareString(ascending, a.date, b.date));
      } else if(columnIndex == 7){
        filtered!.sort((a, b) => compareString(ascending, a.user, b.user));
      }
    }

    setState(() {
      this.sortColumnIndex = columnIndex;
      this.isAscending = ascending;
    });
  }

  // Compare strings
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
