import 'dart:convert';
import 'dart:developer';
import 'dart:html';
import 'dart:typed_data';
import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intermax_warehouse_app/BrigadeDetails/brigade_details.dart';
import 'package:intermax_warehouse_app/Client/server_side_api.dart';
import 'package:intermax_warehouse_app/IssuedItemsDetails/issued_items.dart';
import 'package:intermax_warehouse_app/UserState/user_state.dart';
import 'package:intermax_warehouse_app/WarehouseItemDetails/warehouse_item_details.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../privileges_const.dart';


class Brigade extends StatefulWidget {
  const Brigade({Key? key}) : super(key: key);

  @override
  _BrigadeState createState() => _BrigadeState();
}

class _BrigadeState extends State<Brigade> {
  int? _itemIndex = 0;
  int? sortColumnIndex;
  bool isAscending = false;
  String? _selectedItemName;

  List<WarehouseItemDetails>? _warehouseItems;

  TextEditingController itemNameController = TextEditingController();

  StateSetter? _updateIssuedItems;

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    document.onContextMenu.listen((event) => event.preventDefault());
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text('Мои бригады', style: TextStyle(fontSize: 5.sp)),
            centerTitle: true,
            backgroundColor: Colors.lightBlue,
            actions: [
              Align(
                alignment: Alignment.center,
                child: IconButton(
                    icon: const Icon(Icons.add),
                    disabledColor: Colors.grey,
                    iconSize: 5.sp,
                    onPressed: PrivilegesConstants.ADD_BRIGADE == true
                        ? () => _showAddBrigadeDialog()
                        : null),
              )
            ],
          ),
          body: getBrigades(),
        );
      },
    );
  }

  // Getting brigade from server
  FutureBuilder<Response<List<Brigades>>> getBrigades() {
    var data = {'ip': UserState.getIP()};
    return FutureBuilder<Response<List<Brigades>>>(
      future: ServerSideApi.create(UserState.getIP()!, 5).getBrigades(data),
      builder: (context, snapshot) {
        while (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          List<Brigades>? brigadesList = snapshot.data!.body;
          return createGridList(brigadesList);
        } else {
          return Center(child: Text('Список бригад пуст', style: TextStyle(fontSize: 8.sp)));
        }
      },
    );
  }

  // Getting items from server
  FutureBuilder<Response<List<WarehouseItemDetails>>> getItems() {
    var data = {'ip': UserState.getIP()};
    return FutureBuilder<Response<List<WarehouseItemDetails>>>(
      future: ServerSideApi.create(UserState.getIP()!, 3).getItems(data),
      builder: (context, snapshot) {
        while (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          var warehouseItemsList = snapshot.data?.body;
          return createItemsList(warehouseItemsList);
        } else {
          return Center(child: Text('Склад пуст'));
        }
      },
    );
  }

  // Getting issued items from server
  FutureBuilder<Response<List<IssuedItems>>> getIssuedItems(String brigadeNumber) {
    var formatter = DateFormat('dd.MM.yyyy');
    String formattedDate = formatter.format(selectedDate);
    var data = {'ip': UserState.getIP(), 'brigade': brigadeNumber, 'date' : formattedDate};

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
          return Center(child: Text('Нет выданных товаров'));
        }
      },
    );
  }

  // Creating list for warehouse items
  StatefulBuilder createItemsList(List<WarehouseItemDetails>? warehouseItems) {
    _warehouseItems = warehouseItems;
    return StatefulBuilder(
      builder: (context, setState) {
        return SizedBox.expand(
            child: SingleChildScrollView(
          child: DataTable(
              columnSpacing: 5.sp,
              columns: const [
                DataColumn(label: Text('Фото')),
                DataColumn(label: Text('Имя товара')),
                DataColumn(label: Text('Количество')),
                DataColumn(label: Text(''))
              ],
              rows: List<DataRow>.generate(warehouseItems!.length, (index) {
                WarehouseItemDetails items = warehouseItems[index];
                return DataRow(cells: [
                  DataCell(Container(
                    height: 5.h,
                    width: 5.w,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: Image.memory(const Base64Decoder()
                                    .convert(items.itemPhoto.toString()))
                                .image)),
                  )),
                  DataCell(Text(items.itemName)),
                  DataCell(
                      Text(items.itemCount + ' ' + items.itemCountOptions)),
                  DataCell(Radio<int>(
                    value: index,
                    groupValue: _itemIndex,
                    onChanged: (value) {
                      setState(() {
                        _itemIndex = value!;
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
    return StatefulBuilder(
      builder: (context, setState) {
        return SizedBox.expand(
            child: SingleChildScrollView(
                child: DataTable(
                    sortColumnIndex: sortColumnIndex,
                    sortAscending: isAscending,
                    columnSpacing: 5.sp,
                    columns: [
                      DataColumn(
                          label: Text('Фото',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Имя товара',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Описание',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Дата выдачи',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Количество',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('')),
                      DataColumn(label: Text('')),
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
                        DataCell(Text(
                            issuedItem.count + ' ' + issuedItem.countOption)),
                        DataCell(IconButton(
                            icon: const Icon(Icons.edit),
                            disabledColor: Colors.grey,
                            onPressed: PrivilegesConstants.CHANGE_ISSUED_ITEM ==
                                    true
                                ? () => _showEditIssuedItemDialog(issuedItem)
                                : null)),
                        DataCell(IconButton(
                            icon: const Icon(Icons.delete),
                            disabledColor: Colors.grey,
                            onPressed: PrivilegesConstants.DELETE_ISSUED_ITEM ==
                                    true
                                ? () => _showDeleteIssuedItemDialog(issuedItem)
                                : null))
                      ]);
                    }))));
      },
    );
  }

  // Creating grid view for brigade data
  GridView createGridList(List<Brigades>? brigadesList) {
    return GridView.count(
      crossAxisCount: 6,
      children: List.generate(brigadesList!.length, (index) {
        Brigades brigade = brigadesList[index];
        Uint8List _bytes =
            const Base64Decoder().convert(brigade.brigadePhoto.toString());
        return GestureDetector(
            onTap: () => _showIssuedItemDialog(brigade),
            onSecondaryTapDown: (TapDownDetails tapDownDetails) =>
                _showPopupMenuForBrigade(
                    brigade, tapDownDetails.globalPosition),
            child: Container(
              child: Card(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(1.0.sp),
                    child: Container(
                      height: 5.h,
                      width: 5.w,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: Image.memory(_bytes).image,
                              fit: BoxFit.contain)),
                    ),
                  ),
                  Text(brigade.brigadeNumber.toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 5.0.sp)),
                  Text(brigade.brigadeMembers.toString(),
                      style: TextStyle(fontSize: 5.0.sp)),
                  Text(brigade.brigadePhoneNumber.toString(),
                      style: TextStyle(fontSize: 4.0.sp))
                ],
              )),
            ));
      }),
    );
  }

  // Showing add brigade dialog
  void _showAddBrigadeDialog() {
    TextEditingController brigadeNumber = TextEditingController();
    TextEditingController brigadeMembers = TextEditingController();
    TextEditingController brigadePhoneNumber = TextEditingController();
    List<TextEditingController> listOfTextEditingControllers = [
      brigadeNumber,
      brigadeMembers,
      brigadePhoneNumber
    ];

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SimpleDialog(
                title: const Text('Добавить бригаду'),
                contentPadding: EdgeInsets.all(5.0.sp),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0.sp)),
                backgroundColor: Colors.white,
                children: [
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: brigadeNumber,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0.sp)),
                      label: const Text('Номер бригады'),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: brigadeMembers,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0.sp)),
                      label: const Text('Состав бригады'),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: brigadePhoneNumber,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0.sp)),
                      label: const Text('Номер телефона'),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  FloatingActionButton.extended(
                    onPressed: () => _addBrigade(listOfTextEditingControllers),
                    label: const Text('Завершить'),
                  )
                ],
              );
            },
          );
        });
  }

  // Adding Brigade details to server
  void _addBrigade(List<TextEditingController> listOfTextEditingControllers) async {
    String brigadeNumber = listOfTextEditingControllers[0].text;
    String brigadeMembers = listOfTextEditingControllers[1].text;
    String brigadePhoneNumber = listOfTextEditingControllers[2].text;
    String base64Image;

    ByteData bytes = await rootBundle.load('assets/images/helmet.png');
    var buffer = bytes.buffer;
    base64Image = base64Encode(Uint8List.view(buffer));

    var data = {
      'ip': UserState.getIP(),
      'brigade_number': brigadeNumber,
      'brigade_members': brigadeMembers,
      'brigade_phone_number': brigadePhoneNumber,
      'brigade_photo': base64Image
    };

    Response response =
        await ServerSideApi.create(UserState.getIP()!, 1).addBrigade(data);
    if (response.body == 'brigade_added') {
      setState(() {
        getBrigades();
      });
      _showToast(1);
      Navigator.pop(context);
    } else if (response.body == 'brigade_exists') {
      _showToast(2);
    }
  }

  // Showing delete brigade dialog
  void _showDeleteBrigadeDialog(Brigades brigade) {
    Widget _deleteButton = TextButton(
      child: const Text('Удалить бригаду', style: TextStyle(color: Colors.red)),
      onPressed: () => _deleteBrigade(brigade.brigadeNumber),
    );

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
              title: const Text('Удалить бригаду'),
              content: Text('Вы действительно хотите удалить бригаду '
                  '${brigade.brigadeMembers}'),
              actions: [_cancelButton, _deleteButton]);
        });
  }

  // Showing dialog to attach item to brigade
  void _showIssuedItemDialog(Brigades brigade) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            var formatter = DateFormat('dd.MM.yyyy');
            String formattedDate = formatter.format(selectedDate);
            _updateIssuedItems = setState;
            return SimpleDialog(
                title: const Text('Выданные товары'),
                contentPadding: EdgeInsets.all(5.0.sp),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0.sp)),
                backgroundColor: Colors.white,
                children: [
                  Text('Бригада: ' + brigade.brigadeNumber,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 5.sp)),
                  Text('Состав бригады: ' + brigade.brigadeMembers),
                  Row(
                    children: [
                      Text('День: ${formattedDate}', style: TextStyle(fontWeight: FontWeight.bold)),
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
                            _updateIssuedItems!(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      )
                    ],
                  ),
                  Divider(thickness: 0.5.sp),
                  SizedBox(
                      height: 100.sp,
                      child: getIssuedItems(brigade.brigadeNumber)),
                  SizedBox(height: 1.h),
                  FloatingActionButton.extended(
                    label: const Text('Выдать товар'),
                    backgroundColor: PrivilegesConstants.ISSUE_ITEM == true
                        ? Colors.lightBlue
                        : Colors.grey,
                    onPressed: PrivilegesConstants.ISSUE_ITEM == true
                        ? () => _showIssueItemDialog(brigade)
                        : null,
                  )
                ]);
          });
        });
  }

  // Show issue item dialog
  void _showIssueItemDialog(Brigades brigade) {
    String? dropDownItemName = 'штук';
    TextEditingController itemDateController = TextEditingController();
    TextEditingController itemCountController = TextEditingController();
    TextEditingController itemDescriptionController = TextEditingController();

    List<TextEditingController> listOfTextEditingController = [
      itemNameController,
      itemDescriptionController,
      itemDateController,
      itemCountController
    ];

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return SimpleDialog(
              title: const Text('Выдать товар'),
              contentPadding: EdgeInsets.all(5.0.sp),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0.sp)),
              backgroundColor: Colors.white,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        enabled: false,
                        controller: itemNameController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0.sp)),
                            hintText: 'Товар не выбран'),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    FloatingActionButton.extended(
                      label: const Text('Выбрать товар'),
                      onPressed: () => _showItemsDialog(),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                TextFormField(
                  keyboardType: TextInputType.datetime,
                  controller: itemDescriptionController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0.sp)),
                      label: const Text('Описание товара')),
                ),
                SizedBox(height: 2.h),
                TextFormField(
                  keyboardType: TextInputType.datetime,
                  controller: itemDateController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0.sp)),
                      label: const Text('Дата выдачи'),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () {
                          var now = DateTime.now();
                          var formatter = DateFormat('dd.MM.yyyy');
                          String formattedDate = formatter.format(now);
                          itemDateController.value = itemDateController.value
                              .copyWith(text: formattedDate);
                        },
                      )),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
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
                  ],
                ),
                SizedBox(height: 2.h),
                FloatingActionButton.extended(
                    label: const Text('Выдать'),
                    onPressed: () => _issueItem(brigade, _itemIndex!,
                        dropDownItemName!, listOfTextEditingController))
              ],
            );
          });
        });
  }

  // Show items dialog
  void _showItemsDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return SimpleDialog(
              title: const Text('Товары'),
              contentPadding: EdgeInsets.all(5.0.sp),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0.sp)),
              backgroundColor: Colors.white,
              children: [
                SizedBox(height: 100.sp, child: getItems()),
                FloatingActionButton.extended(
                  label: const Text('Выбрать'),
                  onPressed: () => _selectItem(_itemIndex!),
                )
              ],
            );
          });
        });
  }

  // Show dialog to edit brigade
  void _showEditBrigadeDialog(Brigades brigade) {
    TextEditingController brigadeNumber = TextEditingController();
    TextEditingController brigadeMembers = TextEditingController();
    TextEditingController brigadePhoneNumber = TextEditingController();

    brigadeNumber.value =
        brigadeNumber.value.copyWith(text: brigade.brigadeNumber);
    brigadeMembers.value =
        brigadeMembers.value.copyWith(text: brigade.brigadeMembers);
    brigadePhoneNumber.value =
        brigadePhoneNumber.value.copyWith(text: brigade.brigadePhoneNumber);

    List<TextEditingController> controllers = [
      brigadeNumber,
      brigadeMembers,
      brigadePhoneNumber
    ];

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
                    controller: brigadeNumber,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0.sp)),
                      label: const Text('Номер бригады'),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: brigadeMembers,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0.sp)),
                      label: const Text('Состав бригады'),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: brigadePhoneNumber,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0.sp)),
                      label: const Text('Номер телефона'),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  FloatingActionButton.extended(
                    onPressed: () => _editBrigade(controllers, brigade),
                    label: const Text('Изменить'),
                  )
                ],
              );
            },
          );
        });
  }

  // Show delete issued item dialog
  void _showDeleteIssuedItemDialog(IssuedItems issuedItem) {
    Widget _deleteButton = TextButton(
        child: const Text('Удалить (Выдан по ошибке)',
            style: TextStyle(color: Colors.red)),
        onPressed: () => setState(() {
              _deleteIssuedItem(issuedItem, 'issued_by_mistake');
            }));

    Widget _deleteItem = TextButton(
        child: const Text('Удалить (Нет возврата)',
            style: TextStyle(color: Colors.red)),
        onPressed: () => setState(() {
          _deleteIssuedItem(issuedItem, 'no_returned');
        }));

    Widget _cancelButton = TextButton(
      child: const Text('Отмена', style: TextStyle(color: Colors.deepPurple)),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Text('Удалить товар'),
              content: const Text(
                  'Вы действительно хотите удалить выданный товар ?'),
              actions: [_cancelButton, _deleteButton, _deleteItem]);
        });
  }

  // Show dialog to edit issued item
  void _showEditIssuedItemDialog(IssuedItems issuedItem) {
    TextEditingController itemDateController = TextEditingController();
    TextEditingController itemDescriptionController = TextEditingController();
    TextEditingController itemCountController = TextEditingController();

    itemDateController.value =
        itemDateController.value.copyWith(text: issuedItem.date);
    itemDescriptionController.value =
        itemDescriptionController.value.copyWith(text: issuedItem.description);
    itemCountController.value =
        itemCountController.value.copyWith(text: issuedItem.count);

    List<TextEditingController> controllers = [
      itemDateController,
      itemDescriptionController,
      itemCountController
    ];

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return SimpleDialog(
              title: const Text('Изменить выданный товар'),
              contentPadding: EdgeInsets.all(5.0.sp),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0.sp)),
              backgroundColor: Colors.white,
              children: [
                TextFormField(
                  keyboardType: TextInputType.text,
                  controller: itemDescriptionController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0.sp)),
                    label: const Text('Описание'),
                  ),
                ),
                SizedBox(height: 2.h),
                TextFormField(
                  keyboardType: TextInputType.datetime,
                  controller: itemDateController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0.sp)),
                      label: const Text('Дата выдачи'),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () {
                          var now = DateTime.now();
                          var formatter = DateFormat('dd.MM.yyyy');
                          String formattedDate = formatter.format(now);
                          itemDateController.value = itemDateController.value
                              .copyWith(text: formattedDate);
                        },
                      )),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
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
                    Text(issuedItem.countOption)
                  ],
                ),
                SizedBox(height: 2.h),
                FloatingActionButton.extended(
                    label: const Text('Изменить'),
                    onPressed: () => _editIssuedItem(issuedItem, controllers))
              ],
            );
          });
        });
  }

  // Select item to issue
  void _selectItem(int index) {
    _selectedItemName = _warehouseItems![index].itemName;
    itemNameController.value =
        itemNameController.value.copyWith(text: _selectedItemName);
    Navigator.pop(context);
  }

  // Issue item
  void _issueItem(Brigades brigade, int itemIndex, String countOptions, List<TextEditingController> textControllers) async {
    String itemPhoto = _warehouseItems![itemIndex].itemPhoto;

    String itemName = textControllers[0].text.toString();
    String description = textControllers[1].text.toString();
    String date = textControllers[2].text.toString();
    int count = int.parse(textControllers[3].text.toString());

    var data = {
      'ip': UserState.getIP(),
      'brigade': brigade.brigadeNumber,
      'members': brigade.brigadeMembers,
      'item': itemName,
      'description': description,
      'date': date,
      'count': count,
      'count_options': countOptions,
      'photo': itemPhoto,
      'user': UserState.getUserName()
    };

    if (itemName != '' && description != '' && date != '') {
      Response response =
          await ServerSideApi.create(UserState.getIP()!, 1).issueItem(data);
      Navigator.pop(context);
      switch (response.body) {
        case 'not_enough_items':
          _showToast(4);
          break;
        case 'count_option_error':
          _showToast(5);
          break;
        case 'item_already_issued':
          _showToast(6);
          break;
        case 'item_issued_successfully':
          _showToast(7);
          _updateIssuedItems!(() {
            getIssuedItems(brigade.brigadeNumber);
          });
          itemNameController.clear();
          break;
      }
    } else {
      _showToast(9);
    }
  }

  // Edit brigade
  void _editBrigade(List<TextEditingController> controllers, Brigades brigade) async {
    String brigadeNumber = controllers[0].text;
    String brigadeMembers = controllers[1].text;
    String brigadePhoneNumber = controllers[2].text;

    var data = {
      'ip': UserState.getIP(),
      'id': brigade.id,
      'brigade_number': brigadeNumber,
      'brigade_members': brigadeMembers,
      'brigade_phone_number': brigadePhoneNumber
    };

    if (brigadeNumber == '' ||
        brigadeMembers == '' ||
        brigadePhoneNumber == '') {
      _showToast(9);
    } else {
      Response response =
          await ServerSideApi.create(UserState.getIP()!, 1).editBrigade(data);
      if (response.body == 'brigade_edited') {
        _showToast(8);
        Navigator.pop(context);
        setState(() {
          getBrigades();
        });
      } else if (response.body == 'nothing_edited') {
        Navigator.pop(context);
      } else if (response.body == 'brigade_exists') {
        _showToast(2);
      }
    }
  }

  // Deleting issued item
  void _deleteIssuedItem(IssuedItems issuedItems, String filter) async {
    String brigade = issuedItems.brigade;
    String item = issuedItems.item;
    String description = issuedItems.description;
    int count = int.parse(issuedItems.count);

    var data = {
      'ip': UserState.getIP(),
      'id' : issuedItems.id,
      'brigade': brigade,
      'item': item,
      'description': description,
      'filter' : filter,
      'count': count,
      'user': UserState.getUserName()
    };

    Response response = await ServerSideApi.create(UserState.getIP()!, 1)
        .deleteIssuedItem(data);
    switch (response.body) {
      case 'issued_item_deleted':
        Navigator.pop(context);
        _updateIssuedItems!(() {
          getIssuedItems(brigade);
        });
        break;
    }
  }

  // Editing issued item
  void _editIssuedItem(IssuedItems issuedItem, List<TextEditingController> controllers) async {
    String date = controllers[0].text;
    String description = controllers[1].text;
    int count = int.parse(controllers[2].text);

    var data = {
      'ip': UserState.getIP(),
      'id': issuedItem.id,
      'brigade': issuedItem.brigade,
      'item_name': issuedItem.item,
      'description': description,
      'date': date,
      'count': count,
      'user': UserState.getUserName()
    };

    // ignore: unrelated_type_equality_checks
    if (date == '' || description == '' || count == '') {
      _showToast(9);
    } else {
      Response response = await ServerSideApi.create(UserState.getIP()!, 1).editIssuedItem(data);
      log(response.body);
      if (response.body == 'issued_item_edited') {
        Navigator.pop(context);
        _showToast(1);
        _updateIssuedItems!(() {
          getIssuedItems(issuedItem.brigade);
        });
      } else if (response.body == 'not_enough_items') {
        _showToast(4);
      } else if (response.body == 'item_already_issued') {
        _showToast(6);
      }
    }
  }

  // Deletes brigade from server
  void _deleteBrigade(String brigadeNumber) async {
    var data = {'ip': UserState.getIP(), 'brigade_number': brigadeNumber};

    Response response =
        await ServerSideApi.create(UserState.getIP()!, 1).deleteBrigade(data);
    if (response.body == 'brigade_deleted') {
      setState(() {
        getBrigades();
      });
      _showToast(3);
      Navigator.pop(context);
    }
  }

  // Showing popup menu for suppliers
  void _showPopupMenuForBrigade(Brigades brigade, Offset offset) {
    double left = offset.dx;
    double top = offset.dy;
    double right = offset.distance;
    double bottom = offset.direction;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, right, bottom),
      items: [
        PopupMenuItem(
            child: ListTile(
                enabled:
                    PrivilegesConstants.CHANGE_BRIGADE == true ? true : false,
                title: Text('Изменить', style: TextStyle(fontSize: 4.sp)),
                leading: const Icon(Icons.edit),
                onTap: () {
                  Navigator.pop(context);
                  _showEditBrigadeDialog(brigade);
                })),
        PopupMenuItem(
            child: ListTile(
                enabled:
                    PrivilegesConstants.DELETE_BRIGADE == true ? true : false,
                title: Text('Удалить', style: TextStyle(fontSize: 4.sp)),
                leading: const Icon(Icons.delete),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteBrigadeDialog(brigade);
                })),
      ],
    );
  }

  // Showing toast by given number
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
              const Icon(Icons.error),
              SizedBox(
                width: 5.0.w,
              ),
              const Text("Бригада существует"),
            ],
          ),
        );
        break;
      case 3:
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
              const Text("Бригада удалена"),
            ],
          ),
        );
        break;
      case 4:
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
      case 5:
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
              const Text("Неверно указана единица измерения"),
            ],
          ),
        );
        break;
      case 6:
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
              const Text("Товар уже выдан"),
            ],
          ),
        );
        break;
      case 7:
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
              const Text("Товар успешно выдан"),
            ],
          ),
        );
        break;
      case 8:
        toast = Container(
          padding: EdgeInsets.symmetric(horizontal: 5.0.sp, vertical: 5.0.sp),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0.sp),
              color: Colors.greenAccent),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check),
              SizedBox(
                width: 5.0.w,
              ),
              const Text("Бригада успешно изменена"),
            ],
          ),
        );
        break;
      case 9:
        toast = Container(
          padding: EdgeInsets.symmetric(horizontal: 5.0.sp, vertical: 5.0.sp),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0.sp),
              color: Colors.redAccent),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error),
              SizedBox(
                width: 5.0.w,
              ),
              const Text("Пожалуйста заполните все поля"),
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
