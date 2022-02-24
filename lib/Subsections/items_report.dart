import 'dart:convert';
import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intermax_warehouse_app/Client/server_side_api.dart';
import 'package:intermax_warehouse_app/Items%20Report%20Model/items_report_model.dart';
import 'package:intermax_warehouse_app/SuppliersDetails/suppliers_details.dart';
import 'package:intermax_warehouse_app/UserState/user_state.dart';
import 'package:intermax_warehouse_app/privileges_const.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class ItemsReportPage extends StatefulWidget {
  const ItemsReportPage({Key? key}) : super(key: key);

  @override
  _ItemsReportPageState createState() => _ItemsReportPageState();
}

class _ItemsReportPageState extends State<ItemsReportPage> {

  int? _supplierIndex = 0;

  TextEditingController itemSupplierController = TextEditingController();

  String? _selectedSupplierName;

  List<Suppliers>? _suppliers;

  StateSetter? _updateSuppliers;

  DateTime selectedDate = DateTime.now();

  var formatter = DateFormat('dd.MM.yyyy');
  String? formattedDate;

  @override
  Widget build(BuildContext context) {
    String formattedDate = formatter.format(selectedDate);
    return Sizer(builder: (context, orientation, deviceType){
      return Scaffold(
        appBar: AppBar(
          title: Text('Отчёты товаров', style: TextStyle(fontSize: 5.sp)),
          centerTitle: true,
          backgroundColor: Colors.lightBlue,
          actions: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [Text('${formattedDate}', style: TextStyle(fontWeight: FontWeight.bold)),
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
                ),],
            )
          ],
        ),

        body: Center(child: getItemsReport())
      );
    });
  }

  //Getting items report
  FutureBuilder<Response<List<ItemReport>>> getItemsReport() {
    formattedDate = formatter.format(selectedDate);
    var data = {'ip' : UserState.getIP(), 'date' : formattedDate};

    return FutureBuilder<Response<List<ItemReport>>>(
      future: ServerSideApi.create(UserState.getIP()!, 19).getItemReport(data),
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
          _suppliers = snapshot.data!.body;
          return showSuppliersList(_suppliers);
        } else {
          return Center(child: Text('Список поставщиков пуст'));
        }
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


  // Building report item table
  Widget buildItemsReportTable(List<ItemReport>? reports) {
    return SizedBox.expand(
      child: SingleChildScrollView(
          child: DataTable(
            columnSpacing: 0.2.sp,
            dataRowHeight: 10.sp,
            columns: [
              DataColumn(label: Text('')),
              DataColumn(label: Text('Товар', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Дата поступления', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Количество', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Поставщик', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Цена', style: TextStyle(fontWeight: FontWeight.bold))),
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
                        disabledColor: Colors.grey,
                        onPressed: PrivilegesConstants.CHANGE_ITEMS_REPORT == true ?
                            () => _showEditItemReportDialog(itemReport) : null
                    )),
                    DataCell(IconButton(
                      icon: Icon(Icons.delete),
                      disabledColor: Colors.grey,
                      onPressed: PrivilegesConstants.DELETE_ITEMS_REPORT == true ? () {
                        Widget _deleteButton = TextButton(
                            child: const Text('Удалить товар', style: TextStyle(color: Colors.red)),
                            onPressed: () async {
                              var data = {
                                'ip' : UserState.getIP(),
                                'id' : itemReport.id,
                                'item' : itemReport.item,
                                'count' : itemReport.count,
                              };
                              Response response = await ServerSideApi.create(UserState.getIP()!, 1).deleteItemReport(data);
                              if(response.body == 'report_deleted'){
                                Navigator.pop(context);
                                _showToast(1);
                                setState(() {});
                              }
                            }
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
                                  content: const Text('Вы действительно хотите удалить товар ?'),
                                  actions: [_cancelButton, _deleteButton]);
                            });
                      } : null,
                    ))
                  ]
              );
            }),
          )
      ),
    );
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

  // Showing menu to edit report item
  void _showEditItemReportDialog(ItemReport? report){

    TextEditingController itemPriceController = TextEditingController();
    TextEditingController itemDateController = TextEditingController();
    TextEditingController itemCountController = TextEditingController();


    itemSupplierController.value = itemSupplierController.value.copyWith(text: report!.supplier);

    itemPriceController.value = itemPriceController.value.copyWith(text: report.price);
    itemDateController.value = itemDateController.value.copyWith(text: report.date);
    itemCountController.value = itemCountController.value.copyWith(text: report.count);


    List<TextEditingController> controllers  = [
      itemPriceController,
      itemDateController,
      itemCountController
    ];

    showDialog(
        context: context,
        builder: (context){
          return StatefulBuilder(
            builder: (context, setState){
              return SimpleDialog(
                title: const Text('Изменить товар'),
                contentPadding: EdgeInsets.all(5.0.sp),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0.sp)),
                backgroundColor: Colors.white,
                children: [
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: itemPriceController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0.sp)),
                      label: const Text('Цена'),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: itemDateController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0.sp)),
                        label: const Text('Дата вступления'),
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
                        )
                    ),
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
                      Text(report.count_option, style: TextStyle(fontSize: 3.sp))
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
                          label: const Text('Выбрать')),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  FloatingActionButton.extended(
                      onPressed: () => _editReportItem(controllers, report.item),
                      label: const Text('Изменить товар'),
                      backgroundColor: Colors.lightBlue),
                ],
              );
            },
          );
        }
    );
  }

  // Edit report item
  void _editReportItem(List<TextEditingController> controllers, String itemName) async {
    String? item = itemName;
    String? supplier = itemSupplierController.text;

    String? price = controllers[0].text;
    String? date = controllers[1].text;
    String? count = controllers[2].text;


    if(item == '' || price == '' || date == '' || count == '' || supplier == ''){
      _showToast(2);
    }else{
      var data = {
        'item' : item,
        'price' : price,
        'date' : date,
        'supplier' : supplier,
        'count' : int.parse(count),
      };

      Response response = await ServerSideApi.create(UserState.getIP()!, 1).changeItemReport(data);
      switch(response.body){
        case 'success':
          Navigator.pop(context);

          itemSupplierController.clear();

          _showToast(1);

          setState(() {});
          break;
      }
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

  // Select supplier
  void _selectSupplier(int index) {
    _selectedSupplierName = _suppliers![index].supplierName;
    itemSupplierController.value = itemSupplierController.value.copyWith(text: _selectedSupplierName);
    Navigator.pop(context);
  }

  // Shows toasts by given id
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