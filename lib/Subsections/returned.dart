import 'dart:convert';
import 'dart:developer';
import 'dart:html';
import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intermax_warehouse_app/BrigadeDetails/brigade_details.dart';
import 'package:intermax_warehouse_app/Client/server_side_api.dart';
import 'package:intermax_warehouse_app/IssuedItemsDetails/issued_items.dart';
import 'package:intermax_warehouse_app/ReturnedItemDetails/returned_item_details.dart';
import 'package:intermax_warehouse_app/UserState/user_state.dart';
import 'package:intermax_warehouse_app/privileges_const.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';


class Returned extends StatefulWidget {
  const Returned({Key? key}) : super(key: key);

  @override
  _ReturnedState createState() => _ReturnedState();
}

class _ReturnedState extends State<Returned> {

  var formatter = DateFormat('dd.MM.yyyy');

  int? brigadeIndex = 0;
  int? issuedItemsIndex = 0;

  int? sortColumnIndex;
  bool isAscending = false;

  List<Brigades>? brigadesList;
  List<IssuedItems>? issuedItemsList;
  List<ReturnedItem>? returnedItems;
  List<ReturnedItem>? filtered;

  TextEditingController brigadeController = TextEditingController();
  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemDescriptionController = TextEditingController();

  Future<Response<List<Brigades>>>? _brigadesFuture;

  DateTime selectedDate = DateTime.now();
  DateTime selectedDateForItems = DateTime.now();

  String? formattedDate;
  String? formattedDateForItems;

  String? dropDownItemName = 'Последние 7 дней';

  StateSetter? updateIssuedItems;


  @override
  void initState() {
    super.initState();
    document.onContextMenu.listen((event) => event.preventDefault());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    var data = {'ip': UserState.getIP()};
    _brigadesFuture = ServerSideApi.create(UserState.getIP()!, 5).getBrigades(data);
    _brigadesFuture!.then((value) => {brigadesList = value.body});
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      String formattedDate = formatter.format(selectedDate);
      return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
              title: Text('Возвраты', style: TextStyle(fontSize: 5.sp)),
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
                                        title: const Text('Очистить возвраты'),
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
                                                      data = {'ip': UserState.getIP(), 'days' : '7'};
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
                                                  Response response = await ServerSideApi.create(UserState.getIP()!, 1).clearReturned(data);
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
                              filtered = returnedItems!
                                  .where((item) =>
                                      item.item
                                          .toLowerCase()
                                          .contains(value.toLowerCase()) ||
                                      item.description
                                          .toLowerCase()
                                          .contains(value.toLowerCase()) ||
                                      item.brigade.contains(value) ||
                                      item.brigadeMembers
                                          .toLowerCase()
                                          .contains(value.toLowerCase()) ||
                                      item.date.contains(value) ||
                                      item.count.contains(value))
                                  .toList();
                            });
                          },
                        ),
                      ),
                    )),
                Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    disabledColor: Colors.grey,
                    iconSize: 5.sp,
                    onPressed: PrivilegesConstants.ADD_RETURNED_ITEM == true
                    ? () => _showAddReturnedItemDialog()
                    : null,
                  ),
                )
              ]),
          body: getReturnedItems());
    });
  }

  // Getting returned items from server
  FutureBuilder<Response<List<ReturnedItem>>> getReturnedItems() {
    formattedDate = formatter.format(selectedDate);
    var data = {'ip': UserState.getIP(), 'date' : formattedDate};

    return FutureBuilder<Response<List<ReturnedItem>>>(
        future: ServerSideApi.create(UserState.getIP()!, 7).getReturnedItems(data),
        builder: (context, snapshot) {
          while (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            returnedItems = snapshot.data!.body;
            filtered = returnedItems;
            return createReturnedItemsList();
          } else {
            return Center(child: Text('Нет товаров', style: TextStyle(fontSize: 8.sp)));
          }
        });
  }

  // Getting brigades from server
  FutureBuilder<Response<List<Brigades>>> getBrigades() {
    return FutureBuilder<Response<List<Brigades>>>(
        future: _brigadesFuture,
        builder: (context, snapshot) {
          while (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            List<Brigades>? brigadesList = snapshot.data!.body;
            return createBrigadesList(brigadesList);
          } else {
            return Center(child: Text('Список бригад пуст', style: TextStyle(fontSize: 5.sp)));
          }
        });
  }

  // Getting issued items by brigade number
  FutureBuilder<Response<List<IssuedItems>>> getIssuedItems(String brigadeNumber) {
    formattedDateForItems = formatter.format(selectedDateForItems);
    var data = {'ip': UserState.getIP(), 'brigade': brigadeNumber, 'date': formattedDateForItems};
    return FutureBuilder<Response<List<IssuedItems>>>(
      future: ServerSideApi.create(UserState.getIP()!, 6).getIssuedItems(data),
      builder: (context, snapshot) {
        while (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          var issuedItems = snapshot.data!.body;
          return createIssuedItemsList(issuedItems);
        } else {
          return Center(child: Text('Нет выданных товаров', style: TextStyle(fontSize: 5.sp)));
        }
      },
    );
  } 

  // Creating list for brigades data
  StatefulBuilder createBrigadesList(List<Brigades>? brigades) {
    brigadesList = brigades;
    return StatefulBuilder(
      builder: (context, setState) {
        return SizedBox.expand(
            child: SingleChildScrollView(
          child: DataTable(
              columnSpacing: 10.sp,
              columns: const [
                DataColumn(label: Text('Номер', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Состав', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(''))
              ],
              rows: List<DataRow>.generate(brigades!.length, (index) {
                Brigades brigade = brigades[index];
                return DataRow(cells: [
                  DataCell(Text(brigade.brigadeNumber)),
                  DataCell(Text(brigade.brigadeMembers)),
                  DataCell(Radio<int>(
                    value: index,
                    groupValue: brigadeIndex,
                    onChanged: (value) {
                      setState(() {
                        brigadeIndex = value;
                      });
                    },
                  ))
                ]);
              })),
        ));
      },
    );
  }

  // Creating list for issued items
  StatefulBuilder createIssuedItemsList(List<IssuedItems>? issuedItems) {
    issuedItemsList = issuedItems;
    return StatefulBuilder(
      builder: (context, setState) {
        return SizedBox.expand(
            child: SingleChildScrollView(
                child: DataTable(
          columnSpacing: 5.sp,
          columns: const [
            DataColumn(label: Text('Фото', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Имя', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Описание', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Дата выдачи', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Количество', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(''))
          ],
          rows: List<DataRow>.generate(issuedItems!.length, (index) {
            IssuedItems issuedItem = issuedItems[index];
            return DataRow(cells: [
              DataCell(Container(
                height: 5.h,
                width: 5.w,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: Image.memory(const Base64Decoder()
                                .convert(issuedItem.photo.toString()))
                            .image)),
              )),
              DataCell(Text(issuedItem.item)),
              DataCell(Text(issuedItem.description)),
              DataCell(Text(issuedItem.date)),
              DataCell(Text(issuedItem.count + ' ' + issuedItem.countOption)),
              DataCell(Radio<int>(
                value: index,
                groupValue: issuedItemsIndex,
                onChanged: (value) {
                  setState(() {
                    issuedItemsIndex = value;
                  });
                },
              ))
            ]);
          }),
        )));
      },
    );
  }

  // Creating list for returned items
  Widget createReturnedItemsList() {
    return SizedBox.expand(
        child: SingleChildScrollView(
      child: DataTable(
        sortColumnIndex: sortColumnIndex,
        sortAscending: isAscending,
        columnSpacing: 5.sp,
        columns: [
          DataColumn(
              label: Text('Название',
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
              label: Text('Дата возврата',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onSort: onSort),
          DataColumn(
              label: Text('Количество',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onSort: onSort),
          DataColumn(label: Text('')),
          DataColumn(label: Text('')),
        ],
        rows: List<DataRow>.generate(filtered!.length, (index) {
          return DataRow(cells: [
            DataCell(Text(filtered![index].item)),
            DataCell(Text(filtered![index].description)),
            DataCell(Text(filtered![index].brigade +
                ' (' +
                filtered![index].brigadeMembers +
                ') ')),
            DataCell(Text(filtered![index].date)),
            DataCell(Text(
                filtered![index].count + ' ' + filtered![index].countOption)),
            DataCell(IconButton(
              icon: Icon(Icons.edit),
              disabledColor: Colors.grey,
              onPressed: PrivilegesConstants.CHANGE_RETURNED_ITEM == true
              ? () => _showEditReturnedItemDialog(filtered![index])
              : null
            )),
            DataCell(IconButton(
              icon: Icon(Icons.delete),
              disabledColor: Colors.grey,
              onPressed: PrivilegesConstants.DELETE_RETURNED_ITEM == true
              ? () => _showDeleteReturnedItemDialog(filtered![index])
              : null
            ))
          ]);
        }),
      ),
    ));
  }

  // Showing add returned dialog
  void _showAddReturnedItemDialog() {
    String? dropDownItemName = 'штук';

    TextEditingController itemDateController = TextEditingController();
    TextEditingController itemCountController = TextEditingController();

    List<TextEditingController> controllers = [
      brigadeController,
      itemNameController,
      itemDescriptionController,
      itemDateController,
      itemCountController,
    ];

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SimpleDialog(
                  title: const Text('Оформить возврат товара'),
                  contentPadding: EdgeInsets.all(5.0.sp),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0.sp)),
                  backgroundColor: Colors.white,
                  children: [
                    Row(children: [
                      Flexible(
                        child: TextFormField(
                          enabled: false,
                          controller: brigadeController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0.sp)),
                              hintText: 'Бригада не выбрано'),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      FloatingActionButton.extended(
                        label: const Text('Выбрать бригаду'),
                        onPressed: () => _showBrigadesDialog(),
                      )
                    ]),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Flexible(
                          child: TextFormField(
                            enabled: false,
                            controller: itemNameController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(15.0.sp)),
                                hintText: 'Товар не выбран'),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        FloatingActionButton.extended(
                          label: const Text('Выбрать товар'),
                          onPressed: () =>
                              _showIssuedItemsDialog(brigadeController.text),
                        )
                      ],
                    ),
                    SizedBox(height: 2.h),
                    TextFormField(
                      controller: itemDescriptionController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0.sp)),
                          hintText: 'Описание'),
                    ),
                    SizedBox(height: 2.h),
                    TextFormField(
                      keyboardType: TextInputType.datetime,
                      controller: itemDateController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0.sp)),
                          label: const Text('Дата возврата'),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () {
                              var now = DateTime.now();
                              var formatter = DateFormat('dd.MM.yyyy');
                              String formattedDate = formatter.format(now);
                              setState(() {
                                itemDateController.value = itemDateController
                                    .value
                                    .copyWith(text: formattedDate);
                              });
                            },
                          )),
                    ),
                    SizedBox(height: 2.h),
                    Row(children: [
                      Flexible(
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: itemCountController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0.sp)),
                            label: const Text('Количество'),
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      DropdownButton(
                          value: dropDownItemName,
                          icon: const Icon(Icons.arrow_drop_down),
                          onChanged: (String? value) {
                            setState(() {
                              dropDownItemName = value;
                            });
                          },
                          items: <String>['штук', 'метр']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            );
                          }).toList())
                    ]),
                    SizedBox(height: 2.h),
                    FloatingActionButton.extended(
                      label: const Text('Оформить'),
                      onPressed: () =>
                          _addReturnedItem(controllers, dropDownItemName),
                    )
                  ]);
            },
          );
        });
  }

  // Add returned item
  void _addReturnedItem(List<TextEditingController> controllers, String? countOption) async {
    String brigadeNumber = controllers[0].text;
    String item = controllers[1].text;
    String description = controllers[2].text;
    String date = controllers[3].text;

    String members = brigadesList![brigadeIndex!].brigadeMembers;

    IssuedItems issuedItem = issuedItemsList![issuedItemsIndex!];

    int count = int.parse(controllers[4].text);

    var data = {
      'ip': UserState.getIP(),
      'id': issuedItem.id,
      'item': item,
      'description': description,
      'brigade': brigadeNumber,
      'brigade_members': members,
      'date': date,
      'count': count,
      'count_option': countOption,
      'user': UserState.getUserName()
    };

    Response response =
        await ServerSideApi.create(UserState.getIP()!, 1).addReturnedItem(data);
    log(response.body);
    if (response.body == 'returned_item_added') {
      Navigator.pop(context);
      _showToast(1);
      brigadeController.clear();
      itemNameController.clear();
      setState(() {});
    } else if (response.body == 'not_enough_items') {
      _showToast(3);
    }
  }

  // Showing brigades dialog
  void _showBrigadesDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SimpleDialog(
                title: const Text('Бригады'),
                contentPadding: EdgeInsets.all(5.0.sp),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0.sp)),
                backgroundColor: Colors.white,
                children: [
                  SizedBox(height: 100.sp, child: getBrigades()),
                  SizedBox(height: 2.h),
                  FloatingActionButton.extended(
                    label: const Text('Выбрать'),
                    onPressed: () => _selectBrigade(),
                  )
                ],
              );
            },
          );
        });
  }

  // Show edit returned item dialog
  void _showEditReturnedItemDialog(ReturnedItem item) {
    TextEditingController descriptionController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    TextEditingController countController = TextEditingController();

    descriptionController.value = descriptionController.value.copyWith(text: item.description);
    dateController.value = dateController.value.copyWith(text: item.date);
    countController.value = countController.value.copyWith(text: item.count);

    List<TextEditingController> controllers = [descriptionController, dateController, countController];

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SimpleDialog(
                  title: const Text('Изменить'),
                  contentPadding: EdgeInsets.all(5.0.sp),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0.sp)),
                  backgroundColor: Colors.white,
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: descriptionController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0.sp)),
                        label: const Text('Описание'),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    TextFormField(
                      keyboardType: TextInputType.datetime,
                      controller: dateController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0.sp)),
                          label: const Text('Дата поступления'),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () {
                              var now = DateTime.now();
                              var formatter = DateFormat('dd.MM.yyyy');
                              String formattedDate = formatter.format(now);
                              setState(() {
                                dateController.value = dateController.value
                                    .copyWith(text: formattedDate);
                              });
                            },
                          )),
                    ),
                    SizedBox(height: 2.h),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: countController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0.sp)),
                        label: const Text('Количество'),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    FloatingActionButton.extended(
                      label: Text('Изменить'),
                      onPressed: () => _editReturnedItem(controllers, item),
                    )
                  ]);
            },
          );
        });
  }

  // Show delete returned item dialog
  void _showDeleteReturnedItemDialog(ReturnedItem item) {
    Widget _deleteButton = TextButton(
        child: const Text('Удалить товар', style: TextStyle(color: Colors.red)),
        onPressed: () => _deleteReturnedItem(item));

    Widget _cancelButton = TextButton(
      child: const Text('Отмена'),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Text('Удалить товар'),
              content: const Text('Вы действительно хотите удалить товар ?'),
              actions: [_cancelButton, _deleteButton]);
        });
  }

  // Showing issued items dialog
  void _showIssuedItemsDialog(String brigade) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              updateIssuedItems = setState;
              var formatter = DateFormat('dd.MM.yyyy');
              String formattedDate = formatter.format(selectedDateForItems);
              return SimpleDialog(
                title: Text('Выданные товары бригады: ' + brigade),
                contentPadding: EdgeInsets.all(5.0.sp),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0.sp)),
                backgroundColor: Colors.white,
                children: [
                  Row(
                    children: [
                      Text('День: ${formattedDate}', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 1.w),
                      IconButton(
                        icon: Icon(Icons.calendar_today_outlined),
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDateForItems,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null && picked != selectedDateForItems) {
                            updateIssuedItems!(() {
                              selectedDateForItems = picked;
                            });
                          }
                        },
                      )
                    ],
                  ),
                  SizedBox(height: 100.sp, child: getIssuedItems(brigade)),
                  FloatingActionButton.extended(
                    label: const Text('Выбрать'),
                    onPressed: () => _selectItem(),
                  )
                ],
              );
            },
          );
        });
  }

  // Edit returned item
  void _editReturnedItem(List<TextEditingController> controllers, ReturnedItem item) async {
    String description = controllers[0].text;
    String date = controllers[1].text;
    int count = int.parse(controllers[2].text);

    var data = {
      'ip': UserState.getIP(),
      'id': item.id,
      'item': item.item,
      'description': description,
      'date': date,
      'count': count,
      'user' : UserState.getUserName()
    };

    Response response = await ServerSideApi.create(UserState.getIP()!, 1)
        .editReturnedItem(data);
    if (response.body == 'updated') {
      Navigator.pop(context);
      _showToast(1);
      setState(() {
        didChangeDependencies();
      });
    }
  }

  // Delete returned item
  void _deleteReturnedItem(ReturnedItem item) async {
    var data = {'ip': UserState.getIP(), 'id': item.id, 'user' : UserState.getUserName()};

    Response response = await ServerSideApi.create(UserState.getIP()!, 1)
        .deleteReturnedItem(data);
    if (response.body == 'deleted') {
      Navigator.pop(context);
      _showToast(1);
      setState(() {
        didChangeDependencies();
      });
    }
  }

  // Select brigade from list
  void _selectBrigade() {
    brigadeController.value = brigadeController.value
        .copyWith(text: brigadesList![brigadeIndex!].brigadeNumber);
    Navigator.pop(context);
  }

  // Select item
  void _selectItem() {
    itemNameController.value = itemNameController.value
        .copyWith(text: issuedItemsList![issuedItemsIndex!].item);
    itemDescriptionController.value = itemDescriptionController.value
        .copyWith(text: issuedItemsList![issuedItemsIndex!].description);
    Navigator.pop(context);
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
      case 2:
        toast = Container(
          padding: EdgeInsets.symmetric(horizontal: 5.0.sp, vertical: 5.0.sp),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0.sp),
              color: Colors.redAccent),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning),
              SizedBox(
                width: 5.0.w,
              ),
              const Text("Пожалуйста заполните все поля"),
            ],
          ),
        );
        break;
      case 3:
        toast = Container(
          padding: EdgeInsets.symmetric(horizontal: 5.0.sp, vertical: 5.0.sp),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0.sp),
            color: Colors.redAccent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error),
              SizedBox(
                width: 5.0.w,
              ),
              const Text("Недостаточное количество"),
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

  // Sorting algorithm
  void onSort(int columnIndex, bool ascending) {
    if (filtered == null) {
      if (columnIndex == 0) {
        returnedItems!.sort((a, b) => compareString(ascending, a.item, b.item));
      } else if (columnIndex == 1) {
        returnedItems!.sort(
            (a, b) => compareString(ascending, a.description, b.description));
      } else if (columnIndex == 2) {
        returnedItems!
            .sort((a, b) => compareString(ascending, a.brigade, b.brigade));
      } else if (columnIndex == 3) {
        returnedItems!.sort((a, b) => compareString(ascending, a.date, b.date));
      } else if (columnIndex == 4) {
        returnedItems!
            .sort((a, b) => compareString(ascending, a.count, b.count));
      }
    } else {
      if (columnIndex == 0) {
        filtered!.sort((a, b) => compareString(ascending, a.item, b.item));
      } else if (columnIndex == 1) {
        filtered!.sort(
            (a, b) => compareString(ascending, a.description, b.description));
      } else if (columnIndex == 2) {
        filtered!
            .sort((a, b) => compareString(ascending, a.brigade, b.brigade));
      } else if (columnIndex == 3) {
        filtered!.sort((a, b) => compareString(ascending, a.date, b.date));
      } else if (columnIndex == 4) {
        filtered!.sort((a, b) => compareString(ascending, a.count, b.count));
      }
    }

    setState(() {
      this.sortColumnIndex = columnIndex;
      this.isAscending = ascending;
    });
  }

  // Compare string
  int compareString(bool ascending, String value1, String value2) {
    return ascending ? value1.compareTo(value2) : value2.compareTo(value1);
  }
}
