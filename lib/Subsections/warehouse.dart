import 'dart:convert';
import 'dart:html' as document;
import 'dart:typed_data';
import 'package:chopper/chopper.dart';
import 'package:drag_and_drop_gridview/devdrag.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intermax_warehouse_app/Client/server_side_api.dart';
import 'package:intermax_warehouse_app/SuppliersDetails/suppliers_details.dart';
import 'package:intermax_warehouse_app/UserState/user_state.dart';
import 'package:intermax_warehouse_app/WarehouseItemDetails/warehouse_item_details.dart';
import 'package:intermax_warehouse_app/privileges_const.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';


class Warehouse extends StatefulWidget {
  const Warehouse({Key? key}) : super(key: key);

  @override
  _WarehouseState createState() => _WarehouseState();
}

class _WarehouseState extends State<Warehouse>{
  int? _supplierIndex = 0;
  String? _selectedSupplierName;

  List<Suppliers>? _suppliers;
  List<WarehouseItemDetails>? items;

  TextEditingController itemSupplierController = TextEditingController();
  StateSetter? _updateSuppliers;

  Future<Response<List<WarehouseItemDetails>>>? _future;


  @override
  void initState() {
    super.initState();
    document.document.onContextMenu.listen((event) => event.preventDefault());

    var data = {'ip': UserState.getIP()};
    _future = ServerSideApi.create(UserState.getIP()!, 3).getItems(data);
    _future!.then((value) => items = value.body);
  }

  @override
  Widget build(BuildContext context){
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text('Склад', style: TextStyle(fontSize: 5.sp)),
              centerTitle: true,
              backgroundColor: Colors.lightBlue,
              actions: [
                Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    iconSize: 5.sp,
                    disabledColor: Colors.grey,
                    tooltip: 'Добавить товар',
                    onPressed: PrivilegesConstants.ADD_ITEM_TO_WAREHOUSE == true
                        ? () => _showAddItemDialog()
                        : null,
                  ),
                )
              ],
            ),
            body: Center(child: getItems()));
      },
    );
  }

  // Getting photo from pc storage
  Future<Uint8List>? _getPhoto() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.image, withData: true);
    // ignore: prefer_typing_uninitialized_variables
    var file;
    if (result != null) {
      file = result.files.first.bytes;
    } else {
      // For example user closes the picker
    }
    return file;
  }

  // Getting items from server
  FutureBuilder<Response<List<WarehouseItemDetails>>> getItems() {
    return FutureBuilder<Response<List<WarehouseItemDetails>>>(
      future: _future,
      builder: (context, snapshot) {
        while (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return createGridList();
        } else {
          return Center(child: Text('Склад пуст', style: TextStyle(fontSize: 8.sp)));
        }
      },
    );
  }

  // Getting suppliers from server
  FutureBuilder<Response<List<Suppliers>>> _getSuppliers() {
    var data = {'ip': UserState.getIP()};
    return FutureBuilder<Response<List<Suppliers>>>(
      future: ServerSideApi.create(UserState.getIP()!, 4).getSuppliers(data),
      builder: (context, snapshot) {
        while (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          List<Suppliers>? suppliersList = snapshot.data!.body;
          return showSuppliersList(suppliersList);
        } else {
          return Center(child: Text('Список поставщиков пуст'));
        }
      },
    );
  }

  // Displaying items
  DragAndDropGridView createGridList() {
    return DragAndDropGridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        childAspectRatio: 3 / 4.5,
      ),
        onReorder: (oldIndex, newIndex) async {
          int indexOfFirstItem = items!.indexOf(items![oldIndex]);
          int indexOfSecondItem = items!.indexOf(items![newIndex]);
          var data = {
            'ip' : UserState.getIP(),
            'first_item_id' : int.parse(items![indexOfFirstItem].id),
            'second_item_id' : int.parse(items![indexOfSecondItem].id),
          };
        return Future.wait([
          ServerSideApi.create(UserState.getIP()!, 1).reorderItems(data)
        ]).whenComplete((){
          if (indexOfFirstItem > indexOfSecondItem) {
            for (int i = items!.indexOf(items![oldIndex]);
            i > items!.indexOf(items![newIndex]);
            i--) {
              var tmp = items![i - 1];
              items![i - 1] = items![i];
              items![i] = tmp;
            }
          } else {
            for (int i = items!.indexOf(items![oldIndex]);
            i < items!.indexOf(items![newIndex]);
            i++) {
              var tmp = items![i + 1];
              items![i + 1] = items![i];
              items![i] = tmp;
            }
          }
          setState(() {});
         });
        },
      onWillAccept: (oldIndex, newIndex) {
        return true;
      },
      itemCount: items!.length,
      itemBuilder: (context, index){
        WarehouseItemDetails warehouseItem = items![index];
        Uint8List _bytes = const Base64Decoder().convert(warehouseItem.itemPhoto.toString());
        return
          GestureDetector(
              onTap: PrivilegesConstants.SEE_ITEM_DETAILS == true
                  ? () => _showItemDetailsDialog(warehouseItem, _bytes)
                  : null,
              onSecondaryTapDown: (TapDownDetails details) =>
                  _showPopupMenuForItems(warehouseItem, details.globalPosition),
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                        alignment: Alignment.center,
                        child: Container(
                            height: 10.0.h,
                            width: 10.0.w,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: warehouseItem.itemPhoto != ""
                                        ? Image.memory(_bytes).image
                                        : Image.asset(
                                        'assets/images/image_alternative.png')
                                        .image,
                                    fit: BoxFit.contain)))),
                    SizedBox(height: 5.h),
                    Text(warehouseItem.itemName.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 5.0.sp)),
                    Text(
                      warehouseItem.itemCount + " " + warehouseItem.itemCountOptions,
                      style: TextStyle(fontSize: 4.0.sp),
                    )
                  ],
                ),
              )
          );
      },
    );
  }

  // Creating list from suppliers
  StatefulBuilder showSuppliersList(List<Suppliers>? suppliersList) {
    _suppliers = suppliersList;
    return StatefulBuilder(
      builder: (context, setState) {
        return ListView.separated(
            separatorBuilder: (context, index) => const Divider(),
            itemCount: suppliersList!.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onSecondaryTapDown: (TapDownDetails tapDownDetails) =>
                    _showPopupMenuForSuppliers(
                        _suppliers![index], tapDownDetails.globalPosition),
                child: RadioListTile<int>(
                  value: index,
                  groupValue: _supplierIndex,
                  title: Text(suppliersList[index].supplierName),
                  controlAffinity: ListTileControlAffinity.trailing,
                  onChanged: (value) {
                    setState(() {
                      _supplierIndex = value;
                    });
                  },
                ),
              );
            });
      },
    );
  }

  // Showing dialog with item details
  void _showItemDetailsDialog(WarehouseItemDetails itemDetails, Uint8List imageBytes) {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('О товаре'),
            contentPadding: EdgeInsets.all(5.0.sp),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0.sp)),
            backgroundColor: Colors.white,
            children: [
              Container(
                height: 20.h,
                width: 20.h,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: itemDetails.itemPhoto != null
                            ? Image.memory(imageBytes).image
                            : Image.asset('assets/images/image_alternative.png')
                                .image)),
              ),
              Divider(thickness: 0.5.sp),
              SizedBox(height: 2.h),
              Text('Имя товара: ' + itemDetails.itemName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 2.h),
              Text('Описание: ' + itemDetails.itemDescription),
              SizedBox(height: 2.h),
              Text('Количество: ' +
                  itemDetails.itemCount +
                  ' ' +
                  itemDetails.itemCountOptions),
              SizedBox(height: 2.h),
              Text('Дата поступления: ' + itemDetails.itemDate),
              SizedBox(height: 2.h),
              Text('Поставщик: ' + itemDetails.itemSupplier),
              SizedBox(height: 2.h),
              Text('Цена товара: ' + itemDetails.itemPrice + ' драм')
            ],
          );
        });
  }

  // Showing delete item dialog
  void _showDeleteItemDialog(WarehouseItemDetails itemDetails) {
    Widget _deleteButton = TextButton(
      child: const Text('Удалить товар', style: TextStyle(color: Colors.red)),
      onPressed: () => _deleteItemFromWarehouse(itemDetails),
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
              title: const Text('Удалить товар'),
              content: Text('Вы действительно хотите удалить товар '
                  '${itemDetails.itemName}'),
              actions: [_cancelButton, _deleteButton]);
        });
  }

  // Showing dialog to add an item
  void _showAddItemDialog() {
    String? dropDownItemName = 'штук';
    Uint8List? bytes;

    TextEditingController itemNameController = TextEditingController();
    TextEditingController itemDescriptionController = TextEditingController();
    TextEditingController itemPriceController = TextEditingController();
    TextEditingController itemDateController = TextEditingController();
    TextEditingController itemCountController = TextEditingController();

    List<TextEditingController> controllersList = [
      itemNameController,
      itemDescriptionController,
      itemPriceController,
      itemDateController,
      itemCountController,
      itemSupplierController
    ];

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SimpleDialog(
                  title: Text(
                    'Добавить новый товар',
                    style: TextStyle(color: Colors.black, fontSize: 5.sp),
                  ),
                  contentPadding: EdgeInsets.all(5.0.sp),
                  insetPadding: EdgeInsets.symmetric(horizontal: 100.sp),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0.sp)),
                  backgroundColor: Colors.white,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 15.0.h,
                        width: 20.0.w,
                        child: GestureDetector(onTap: () {
                          Future<Uint8List>? _bytes = _getPhoto();
                          _bytes!.then((value) {
                            setState(() {
                              bytes = value;
                            });
                          });
                        }),
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.rectangle,
                            image: DecorationImage(
                                image: bytes == null
                                    ? Image.asset('assets/images/add_photo.png')
                                        .image
                                    : Image.memory(bytes!, fit: BoxFit.fill)
                                        .image)),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: itemNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0.sp)),
                        label: const Text('Наименование'),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    TextFormField(
                      keyboardType: TextInputType.multiline,
                      controller: itemDescriptionController,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0.sp)),
                        label: const Text('Описание'),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: itemPriceController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0.sp)),
                        label: const Text('Цена'),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    TextFormField(
                      keyboardType: TextInputType.datetime,
                      controller: itemDateController,
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
                                itemDateController.value = itemDateController
                                    .value
                                    .copyWith(text: formattedDate);
                              });
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
                    Row(
                      children: [
                        Flexible(
                          child: TextFormField(
                            enabled: false,
                            controller: itemSupplierController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(15.0.sp)),
                                hintText: 'Поставщики не выбрано'),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        FloatingActionButton.extended(
                            onPressed: () => _showMySuppliers(),
                            label: const Text('Выбрать'))
                      ],
                    ),
                    SizedBox(height: 2.h),
                    FloatingActionButton.extended(
                        onPressed: () => _addItemToWarehouse(
                            controllersList, dropDownItemName, bytes),
                        label: const Text('Добавить предмет'),
                        backgroundColor: Colors.lightBlue)
                  ]);
            },
          );
        });
  }

  // Showing dialog to edit an item
  void _showEditItemDialog(WarehouseItemDetails itemDetails) async {
    bool _isPhotoDeleted = false;

    TextEditingController itemNameController = TextEditingController();
    TextEditingController itemDescriptionController = TextEditingController();
    TextEditingController itemPriceController = TextEditingController();
    TextEditingController itemDateController = TextEditingController();
    TextEditingController itemCountController = TextEditingController();
    itemNameController.value =
        itemNameController.value.copyWith(text: itemDetails.itemName);
    itemDescriptionController.value = itemDescriptionController.value
        .copyWith(text: itemDetails.itemDescription);
    itemPriceController.value =
        itemPriceController.value.copyWith(text: itemDetails.itemPrice);
    itemDateController.value =
        itemDateController.value.copyWith(text: itemDetails.itemDate);
    itemCountController.value =
        itemCountController.value.copyWith(text: itemDetails.itemCount);
    itemSupplierController.value =
        itemSupplierController.value.copyWith(text: itemDetails.itemSupplier);

    String oldItemName = itemNameController.text;
    Uint8List? _image = Base64Decoder().convert(itemDetails.itemPhoto.toString());
    Uint8List _bytes = const Base64Decoder().convert(itemDetails.itemPhoto.toString());
    ByteData bytes = await rootBundle.load('assets/images/no_image.png');

    List<TextEditingController> textControllers = [
      itemNameController,
      itemDescriptionController,
      itemPriceController,
      itemDateController,
      itemCountController,
      itemSupplierController
    ];

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SimpleDialog(
                  title: Text(
                    'Изменить товар',
                    style: TextStyle(color: Colors.black, fontSize: 5.sp),
                  ),
                  contentPadding: EdgeInsets.all(5.0.sp),
                  insetPadding: EdgeInsets.symmetric(horizontal: 100.sp),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0.sp)),
                  backgroundColor: Colors.white,
                  children: [
                    Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 15.0.h,
                              width: 20.0.w,
                              child: GestureDetector(onTap: () {
                                Future<Uint8List>? _bytes = _getPhoto();
                                _bytes?.then((value) {
                                  setState(() {
                                    _image = value;
                                  });
                                });
                              }),
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  shape: BoxShape.rectangle,
                                  image: DecorationImage(
                                      image: _image == null
                                          ? Image.memory(_bytes).image
                                          : Image.memory(_image!,
                                                  fit: BoxFit.fill)
                                              .image)),
                            ),
                            SizedBox(width: 2.w),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => {
                                setState(() {
                                  _image = null;

                                  var buffer = bytes.buffer;
                                  _bytes = const Base64Decoder().convert(
                                      base64Encode(Uint8List.view(buffer)));
                                  _isPhotoDeleted = true;
                                })
                              },
                            )
                          ],
                        )),
                    SizedBox(height: 2.h),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: itemNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0.sp)),
                        label: const Text('Наименование'),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    TextFormField(
                      keyboardType: TextInputType.multiline,
                      controller: itemDescriptionController,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0.sp)),
                        label: const Text('Описание'),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: itemPriceController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0.sp)),
                        label: const Text('Цена'),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    TextFormField(
                      keyboardType: TextInputType.datetime,
                      controller: itemDateController,
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
                                itemDateController.value = itemDateController
                                    .value
                                    .copyWith(text: formattedDate);
                              });
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
                        Text(itemDetails.itemCountOptions)
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Flexible(
                          child: TextFormField(
                            enabled: false,
                            controller: itemSupplierController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(15.0.sp)),
                                hintText: 'Поставщики не выбрано'),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        FloatingActionButton.extended(
                            onPressed: () => _showMySuppliers(),
                            label: const Text('Выбрать'))
                      ],
                    ),
                    SizedBox(height: 2.h),
                    FloatingActionButton.extended(
                        onPressed: () => _editWarehouseItem(textControllers,
                            _image, itemDetails.id, oldItemName, _isPhotoDeleted),
                        label: const Text('Изменить'),
                        backgroundColor: Colors.lightBlue)
                  ]);
            },
          );
        });
  }

  // Showing suppliers
  void _showMySuppliers() {
    TextEditingController supplierNameTextController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            _updateSuppliers = setState;
            return SimpleDialog(
                title: Text('Поставщики',
                    style: TextStyle(color: Colors.black, fontSize: 5.0.sp)),
                contentPadding: EdgeInsets.all(5.0.sp),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0.sp)),
                backgroundColor: Colors.white,
                children: [
                  Column(children: [
                    Row(children: [
                      Flexible(
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: supplierNameTextController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0.sp)),
                              label: Text('Имя поставшика')),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      FloatingActionButton.small(
                          backgroundColor:
                              PrivilegesConstants.ADD_SUPPLIER == true
                                  ? Colors.lightBlue
                                  : Colors.grey,
                          child: const Icon(Icons.add),
                          onPressed: PrivilegesConstants.ADD_SUPPLIER == true
                              ? () => setState(() {
                                    _addSupplier(supplierNameTextController);
                                  })
                              : null),
                    ]),
                    SizedBox(
                      height: 30.h,
                      child: _getSuppliers(),
                    ),
                    SizedBox(height: 1.h),
                    SizedBox(height: 2.h),
                    FloatingActionButton.extended(
                        label: const Text('Выбрать'),
                        backgroundColor: Colors.blue,
                        onPressed: () => _selectSupplier(_supplierIndex!))
                  ])
                ]);
          });
        });
  }

  // Adding item to server
  void _addItemToWarehouse(List<TextEditingController> controllersList,
      String? countOptions, Uint8List? photoBytes) async {
    String? base64Image;
    if (photoBytes != null) {
      base64Image = base64Encode(photoBytes);
    } else if (photoBytes == null) {
      ByteData bytes = await rootBundle.load('assets/images/no_image.png');
      var buffer = bytes.buffer;
      base64Image = base64Encode(Uint8List.view(buffer));
    }

    var data = {'ip' : UserState.getIP()};

    String itemName = controllersList[0].text;
    String itemDescription = controllersList[1].text;
    String itemPrice = controllersList[2].text;
    String itemDate = controllersList[3].text;
    String itemCount = controllersList[4].text;
    String itemSupplier = controllersList[5].text;

    var itemData = {
      'ip': UserState.getIP(),
      'item_name': itemName,
      'item_description': itemDescription,
      'item_price': itemPrice,
      'item_date': itemDate,
      'item_count': itemCount,
      'item_count_options': countOptions,
      'item_supplier': itemSupplier,
      'item_photo': base64Image,
      'user': UserState.getUserName()
    };


    if (itemName != '' &&
        itemDescription != '' &&
        itemPrice != '' &&
        itemDate != '' &&
        itemCount != '' &&
        itemSupplier != '') {
      Response response = await ServerSideApi.create(UserState.getIP()!, 1).addItem(itemData);
      if (response.body == "item_exists") {
        _showToast(3);
      } else {
        _showToast(1);
        Navigator.pop(context);
        Response response = await ServerSideApi.create(UserState.getIP()!, 3).getItems(data);
        items = response.body;
        itemSupplierController.dispose();
        setState(() {});
      }
    } else {
      _showToast(2);
    }
  }

  // Edit warehouse item
  void _editWarehouseItem(List<TextEditingController> controllersList,
      Uint8List? image, String id, String oldItemName, bool isDeleted) async {
    String? base64Image;
    if (image != null) {
      base64Image = base64Encode(image);
    } else if (isDeleted == true) {
      ByteData bytes = await rootBundle.load('assets/images/no_image.png');
      var buffer = bytes.buffer;
      base64Image = base64Encode(Uint8List.view(buffer));
    }

    String itemName = controllersList[0].text;
    String itemDescription = controllersList[1].text;
    String itemPrice = controllersList[2].text;
    String itemDate = controllersList[3].text;
    String itemCount = controllersList[4].text;
    String itemSupplier = controllersList[5].text;

    var itemData = {
      'ip': UserState.getIP(),
      'old_item_name' : oldItemName,
      'item_name': itemName,
      'item_description': itemDescription,
      'item_price': itemPrice,
      'item_date': itemDate,
      'item_count': itemCount,
      'item_supplier': itemSupplier,
      'item_photo': base64Image,
      'user': UserState.getUserName()
    };

    if (itemName != '' &&
        itemDescription != '' &&
        itemPrice != '' &&
        itemDate != '' &&
        itemCount != '' &&
        itemSupplier != '') {
      Response response = await ServerSideApi.create(UserState.getIP()!, 1).editItem(itemData);
      if (response.body == 'item_edited') {
        for(var i in items!){
          if(i.id == id){
            i.itemName = itemName;
            i.itemDescription = itemDescription;
            i.itemPrice = itemPrice;
            i.itemDate = itemDate;
            i.itemCount = itemCount;
            i.itemSupplier = itemSupplier;
            i.itemPhoto = base64Image;
            break;
          }
        }
        _showToast(9);
        Navigator.pop(context);
        setState(() {});
      } else if (response.body == 'item_exists') {
        _showToast(3);
      }
    } else {
      _showToast(2);
    }
  }

  // Add supplier script
  void _addSupplier(TextEditingController supplierNameTextController) async {
    var supplierName = supplierNameTextController.text;
    if (supplierName == '') {
      _showToast(5);
    } else {
      var data = {'ip': UserState.getIP(), 'supplier_name': supplierName};

      Response response =
          await ServerSideApi.create(UserState.getIP()!, 1).addSupplier(data);
      if (response.body == 'supplier_added') {
        _showToast(6);
        supplierNameTextController.value =
            supplierNameTextController.value.copyWith(text: '');
        _updateSuppliers!(() {
          _getSuppliers();
        });
      } else if (response.body == 'supplier_exists') {
        supplierNameTextController.value =
            supplierNameTextController.value.copyWith(text: '');
        _showToast(7);
      }
    }
  }

  // Showing popup menu for warehouse items
  void _showPopupMenuForItems(WarehouseItemDetails itemDetails, Offset offset) {
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
                enabled: PrivilegesConstants.CHANGE_WAREHOUSE_ITEM == true
                    ? true
                    : false,
                title: Text('Изменить', style: TextStyle(fontSize: 4.sp)),
                leading: const Icon(Icons.edit),
                onTap: () {
                  Navigator.pop(context);
                  _showEditItemDialog(itemDetails);
                })),
        PopupMenuItem(
            child: ListTile(
          enabled:
              PrivilegesConstants.DELETE_WAREHOUSE_ITEM == true ? true : false,
          title: Text('Удалить', style: TextStyle(fontSize: 4.sp)),
          leading: const Icon(Icons.delete),
          onTap: () {
            Navigator.pop(context);
            _showDeleteItemDialog(itemDetails);
          },
        )),
      ],
    );
  }

  // Showing popup menu for suppliers
  void _showPopupMenuForSuppliers(Suppliers suppliers, Offset offset) {
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
              enabled: PrivilegesConstants.DELETE_SUPPLIER == true
              ? true : false,
                title: Text('Удалить', style: TextStyle(fontSize: 4.sp)),
                leading: const Icon(Icons.delete),
                onTap: () {
                        Navigator.pop(context);
                        _deleteSupplier(suppliers);
                      }
                    )),
      ],
    );
  }

  // Select supplier
  void _selectSupplier(int index) {
    _selectedSupplierName = _suppliers![index].supplierName;
    itemSupplierController.value =
        itemSupplierController.value.copyWith(text: _selectedSupplierName);
    Navigator.pop(context);
  }

  // Deleting item from server
  void _deleteItemFromWarehouse(WarehouseItemDetails itemDetails) async {
    var data = {
      'ip': UserState.getIP(),
      'item_name': itemDetails.itemName,
      'user': UserState.getUserName()
    };


    Response response = await ServerSideApi.create(UserState.getIP()!, 1).deleteItem(data);
    if (response.body == 'item_deleted') {
      items!.remove(itemDetails);
      _showToast(4);
      Navigator.pop(context);
      setState(() {});
    }
  }

  // Delete selected supplier
  void _deleteSupplier(Suppliers supplier) async {
    var data = {
      'ip': UserState.getIP(),
      'supplier_name': supplier.supplierName
    };
    Response response =
        await ServerSideApi.create(UserState.getIP()!, 1).deleteSupplier(data);
    if (response.body == "supplier_deleted") {
      _showToast(8);
      _updateSuppliers!(() {
        _getSuppliers();
      });
    }
  }

  // Showing toasts
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
              const Text("Товар успешно добавлен"),
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
              color: Colors.redAccent),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error),
              SizedBox(
                width: 5.0.w,
              ),
              const Text("Товар с таким именем уже есть на складе"),
            ],
          ),
        );
        break;
      case 4:
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
              const Text("Товар успешно удален"),
            ],
          ),
        );
        break;
      case 5:
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
              const Text("Имя поставщика пуст"),
            ],
          ),
        );
        break;
      case 6:
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
              const Text("Поставщик успешно добавлен"),
            ],
          ),
        );
        break;
      case 7:
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
              const Text("Поставщик уже существует"),
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
              const Text("Поставщик удален"),
            ],
          ),
        );
        break;
      case 9:
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
              const Text("Товар успешно изменен"),
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
