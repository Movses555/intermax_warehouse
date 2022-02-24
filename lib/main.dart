import 'dart:html';
import 'dart:io';
import 'package:chopper/chopper.dart' as chopper;
import 'package:flutter/material.dart';
import 'package:intermax_warehouse_app/BackupFileDetails/back_up_file_details.dart';
import 'package:intermax_warehouse_app/Subsections/items_report.dart';
import 'package:intermax_warehouse_app/Subsections/logs.dart';
import 'package:intermax_warehouse_app/Subsections/reports.dart';
import 'package:intermax_warehouse_app/get_privileges.dart';
import 'package:intermax_warehouse_app/privileges_const.dart';
import 'package:sizer/sizer.dart';
import 'package:intermax_warehouse_app/Client/server_side_api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intermax_warehouse_app/Subsections/brigade.dart';
import 'package:intermax_warehouse_app/Subsections/returned.dart';
import 'package:intermax_warehouse_app/Subsections/warehouse.dart';
import 'package:intermax_warehouse_app/UserState/user_state.dart';

import 'Users/user_details.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserState.init();
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int? _backupFilesIndex = 0;
  int? _usersIndex = 0;

  List<BackupFile>? backupFileList;
  List<Users>? usersList;

  TextEditingController fileTextController = TextEditingController();
  TextEditingController ipController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  Privileges? privileges;

  @override
  void initState() {
    super.initState();
    privileges = Privileges.createInstance();
    document.onContextMenu.listen((event) => event.preventDefault());
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return Scaffold(
          appBar: AppBar(
            title: Text('Склад INTERMAX',
                style: TextStyle(
                  fontSize: 6.sp,
                )),
            centerTitle: false,
            backgroundColor:
                UserState.isSignedIn == false ? Colors.grey : Colors.lightBlue,
            actions: [
              Align(
                  alignment: Alignment.center,
                  child: UserState.isSignedIn == false
                      ? IconButton(
                          icon: Image.asset('assets/images/login.png'),
                          onPressed: () => _signInDialog(),
                          tooltip: 'Войти',
                        )
                      : Padding(
                          padding: EdgeInsets.all(1.0.sp),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Добро пожаловать, ${UserState.userName}',
                                style: TextStyle(
                                    fontSize: 6.0.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 2.0.w),
                              IconButton(
                                  icon: const Icon(Icons.logout),
                                  tooltip: 'Выйти',
                                  onPressed: () => _showSignOutDialog()),
                            ],
                          ))),
              Padding(
                  padding: EdgeInsets.all(1.0.sp),
                  child: UserState.isSignedIn != false && PrivilegesConstants.ADD_NEW_USER == true
                      ? IconButton(
                          icon: Image.asset('assets/images/add_user.png'),
                          disabledColor: Colors.grey,
                          onPressed: () => _registerDialog(),
                          tooltip: 'Зарегистрироваться')
                      : Container()),
              Padding(
                  padding: EdgeInsets.all(1.0.sp),
                  child: PrivilegesConstants.SEE_SETTINGS_SECTION == true
                  ? PopupMenuButton(
                      icon: const Icon(Icons.settings),
                      tooltip: 'Настройки',
                      itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 1,
                              child: Text('Сделать резервную копию'),
                              enabled: PrivilegesConstants.BACKUP_DATA == true && UserState.isSignedIn == true
                              ? true : false,
                            ),
                            PopupMenuItem(
                              value: 2,
                              child: Text('Восстановить из резервной копии'),
                              enabled: PrivilegesConstants.RESTORE_DATA == true
                              ? true : false
                            ),
                            PopupMenuItem(
                                value: 3, 
                                child: Text('Пользователи'),
                                enabled: PrivilegesConstants.SEE_USERS_LIST == true && UserState.isSignedIn == true
                                ? true : false
                            ),
                            PopupMenuItem(
                              value: 4,
                              child: Text('Изменить пароль'),
                              enabled: PrivilegesConstants.CHANGE_USERS_PASSWORD == true && UserState.isSignedIn == true
                              ? true : false
                            ),
                            PopupMenuItem(
                              value: 5,
                              child: Text('Логи'),
                              enabled: PrivilegesConstants.SEE_LOGS == true && UserState.isSignedIn == true
                                  ? true : false
                            ),
                          ],
                      onSelected: (result) {
                        if (result == 1) {
                          _showBackupDialog();
                        } else if (result == 2) {
                          _showRestoreBackupDialog();
                        } else if (result == 3) {
                          _showUsersDialog(1);
                        } else if (result == 4) {
                          _showChangePasswordDialog();
                        } else if(result == 5){
                          _openLogs();
                        }
                      })
                      : null)
            ],
          ),
          body: _mainBody());
    });
  }

  // Main body
  Widget _mainBody() {
    return Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Ink(
                    height: 20.h,
                    width: 20.w,
                    child: IconButton(
                      onPressed: UserState.isSignedIn == true && PrivilegesConstants.SEE_WAREHOUSE_CONTENT == true
                          ? () => _openMyWarehouse()
                          : null,
                      icon: Image.asset('assets/images/my_warehouse.png'),
                    ),
                    decoration: ShapeDecoration(
                        shape: const CircleBorder(),
                        color: UserState.isSignedIn == true && PrivilegesConstants.SEE_WAREHOUSE_CONTENT == true
                            ? Colors.lightBlue
                            : Colors.grey)),
                SizedBox(height: 2.h),
                Text('Мой склад', style: TextStyle(fontSize: 5.sp)),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Ink(
                  height: 20.h,
                  width: 20.w,
                  child: IconButton(
                    onPressed: UserState.isSignedIn == true
                        ? () => _openMyBrigade()
                        : null,
                    icon: Image.asset('assets/images/brigade.png'),
                  ),
                  decoration: ShapeDecoration(
                      shape: const CircleBorder(),
                      color: UserState.isSignedIn == true
                          ? Colors.lightBlue
                          : Colors.grey),
                ),
                SizedBox(height: 2.h),
                Text('Бригады', style: TextStyle(fontSize: 5.sp)),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Ink(
                  height: 20.h,
                  width: 20.w,
                  child: IconButton(
                    onPressed: UserState.isSignedIn == true && PrivilegesConstants.SEE_REPORTS == true
                        ? () => _openReports()
                        : null,
                    icon: Image.asset('assets/images/reports.png'),
                  ),
                  decoration: ShapeDecoration(
                      shape: const CircleBorder(),
                      color: UserState.isSignedIn == true && PrivilegesConstants.SEE_REPORTS == true
                          ? Colors.lightBlue
                          : Colors.grey),
                ),
                SizedBox(height: 2.h),
                Text('Отчёты', style: TextStyle(fontSize: 5.sp)),
              ],
            ),
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Ink(
                  height: 20.h,
                  width: 20.w,
                  child: IconButton(
                    onPressed: UserState.isSignedIn == true
                        ? () => _openMyReturned()
                        : null,
                    icon: Image.asset('assets/images/returned.png'),
                  ),
                  decoration: ShapeDecoration(
                      shape: const CircleBorder(),
                      color: UserState.isSignedIn == true
                          ? Colors.lightBlue
                          : Colors.grey)),
              SizedBox(height: 2.h),
              Text('Возвраты', style: TextStyle(fontSize: 5.sp)),
            ]),
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Ink(
                  height: 20.h,
                  width: 20.w,
                  child: IconButton(
                    onPressed:
                        UserState.isSignedIn == true && PrivilegesConstants.SEE_ITEMS_REPORT == true
                        ? () => _openItemsReports() : null,
                    icon: Image.asset('assets/images/items_report.png'),
                  ),
                  decoration: ShapeDecoration(
                      shape: const CircleBorder(),
                      color: UserState.isSignedIn == true && PrivilegesConstants.SEE_ITEMS_REPORT == true
                          ? Colors.lightBlue
                          : Colors.grey)),
              SizedBox(height: 2.h),
              Text('Отчёты товаров', style: TextStyle(fontSize: 5.sp))
            ])
          ],
        ));
  }

  // Getting backup files
  FutureBuilder<chopper.Response<List<BackupFile>>> getBackupFiles() {
    return FutureBuilder<chopper.Response<List<BackupFile>>>(
      future: ServerSideApi.create(ipController.text, 9).getBackupFiles(),
      builder: (context, snapshot) {
        while (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          List<BackupFile>? backupFiles = snapshot.data!.body;
          return createBackupFilesDialogContent(backupFiles);
        } else {
          return Center(
              child: Text('Список пуст', style: TextStyle(fontSize: 5.sp)));
        }
      },
    );
  }

  // Getting users from server
  FutureBuilder<chopper.Response<List<Users>>> getUsers(int code) {
    var data = {'ip': UserState.getIP()};
    return FutureBuilder<chopper.Response<List<Users>>>(
      future: ServerSideApi.create(UserState.getIP()!, 10).getUsers(data),
      builder: (context, snapshot) {
        while (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return createUsersDialogContent(snapshot.data!.body, code);
        } else {
          return Center(
              child: Text('Список пуст', style: TextStyle(fontSize: 5.sp)));
        }
      },
    );
  }

  // Creating backup files dialog content
  StatefulBuilder createBackupFilesDialogContent(List<BackupFile>? backupFiles) {
    return StatefulBuilder(
      builder: (context, setState) {
        return SizedBox.expand(
            child: SingleChildScrollView(
          child: DataTable(
              columnSpacing: 80.sp,
              columns: const [
                DataColumn(label: Text('Имя файла')),
                DataColumn(label: Text(''))
              ],
              rows: List<DataRow>.generate(backupFiles!.length, (index) {
                backupFileList = backupFiles;
                BackupFile backupFile = backupFiles[index];
                return DataRow(cells: [
                  DataCell(Text(backupFile.filename)),
                  DataCell(Radio<int>(
                    value: index,
                    groupValue: _backupFilesIndex,
                    onChanged: (value) {
                      setState(() {
                        _backupFilesIndex = value;
                      });
                    },
                  ))
                ]);
              })),
        ));
      },
    );
  }

  // Creating users dialog content
  StatefulBuilder createUsersDialogContent(List<Users>? users, int code) {
    return StatefulBuilder(
      builder: (context, setState) {
        return SizedBox.expand(
          child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: 5.sp,
                columns: [
              DataColumn(
                  label: Text('Имя',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Пароль',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: code == 1
                      ? Text('')
                      : Text('Изменить привилегии',
                          style: TextStyle(fontWeight: FontWeight.bold)))
            ],
            rows: List<DataRow>.generate(users!.length, (index) {
              Users user = users[index];
              usersList = users;
              return DataRow(cells: [
                DataCell(Text(user.name)),
                DataCell(Text(user.password)),
                code == 1
                    ? DataCell(Radio<int>(
                        value: index,
                        groupValue: _usersIndex,
                        onChanged: (value) {
                          setState(() {
                            _usersIndex = value;
                          });
                        },
                      ))
                    : DataCell(user.name != UserState.userName
                    ? IconButton(
                        icon: Icon(Icons.edit),
                        disabledColor: Colors.grey,
                        onPressed: PrivilegesConstants.CHANGE_USERS_PRIVILEGES == true
                        ? () => _showPrivilegesDialog(user)
                        : null) : SizedBox())
              ]);
            }),
          )),
        );
      },
    );
  }

  // Page animation
  Route _route(int routeCode) {
    if (routeCode == 1) {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const Warehouse(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );
    } else if (routeCode == 2) {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const Brigade(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );
    } else if (routeCode == 3) {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const Returned(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );
    } else if (routeCode == 4) {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ReportsSection(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );
    } else if (routeCode == 5) {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const Logs(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );
    }else if (routeCode == 6) {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const ItemsReportPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );
    }
    throw {
      // throw block of code
    };
  }

  // User login 
  Future _loginUser(List<TextEditingController> controllersList, bool isChecked) async {
    var ip = controllersList[0].text;
    var name = controllersList[1].text;
    var password = controllersList[2].text;
    var data = {'ip': ip, 'name': name, 'password': password};
    Users? userDetails;

    return Future.wait([
      ServerSideApi.create(ip, 2).loginUser(data).then((value) => userDetails = value.body),
      privileges!.getPrivileges(ip, name)
    ]).whenComplete(() => {
      if (name == '' || password == '' || ip == '') {
      _showToast(3)
    } else {
      if (userDetails!.status == 'account_exists') {
          Navigator.pop(context),
          _showToast(4),
          if (isChecked == true) {
            setState(() {
              UserState.userName = userDetails!.name;
              UserState.isSignedIn = true;
              UserState.rememberUser(ip, userDetails!.name, password);
            })
          } else {
            setState(() {
              UserState.isSignedIn = true;
              UserState.temporaryIp = ip;
              UserState.userName = userDetails!.name;
            })
          }
        } else if (userDetails!.status == 'account_not_exists') {
          _showToast(5)
        }
    }
    });
  }

  // Show privileges dialog
  Future _showPrivilegesDialog(Users user) async {
    return Future.wait([
      privileges!.getPrivileges(UserState.getIP()!, user.name)
    ]).whenComplete(() => {
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SimpleDialog(
                title: Text('Изменить привилегии ${user.name}'),
                contentPadding: EdgeInsets.all(5.sp),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0.sp)),
                backgroundColor: Colors.white,
                children: [
                  SizedBox(
                      height: 50.h,
                      child: SingleChildScrollView(
                          child: Column(
                        children: [
                          Text('Склад', style: TextStyle(fontSize: 4.sp, fontWeight: FontWeight.bold)),
                          SizedBox(height: 3.h),
                          Row(
                            children: [
                              Checkbox(
                                value: PrivilegesConstants.SEE_WAREHOUSE_CONTENT,
                                onChanged: (value) {
                                  setState(() {
                                    PrivilegesConstants.SEE_WAREHOUSE_CONTENT = value!;
                                  });
                                },
                              ),
                              Text('Содержимое склада'),
                              SizedBox(width: 3.w),
                              Checkbox(
                                value: PrivilegesConstants.SEE_ITEM_DETAILS,
                                onChanged: (value) {
                                  setState(() {
                                    PrivilegesConstants.SEE_ITEM_DETAILS = value!;
                                  });
                                },
                              ),
                              Text('Информация о товаре')
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Row(children: [
                            Checkbox(
                              value: PrivilegesConstants.ADD_ITEM_TO_WAREHOUSE,
                              onChanged: (value) {
                                setState(() {
                                  PrivilegesConstants.ADD_ITEM_TO_WAREHOUSE = value!;
                                });
                              },
                            ),
                            Text('Добавить товар'),
                            SizedBox(width: 5.w),
                            Checkbox(
                                value: PrivilegesConstants.DELETE_WAREHOUSE_ITEM,
                                onChanged: (value) {
                                  setState(() {
                                    PrivilegesConstants.DELETE_WAREHOUSE_ITEM = value!;
                                  });
                                }),
                            Text('Удалить товар')
                          ]),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Checkbox(
                                value: PrivilegesConstants.CHANGE_WAREHOUSE_ITEM,
                                onChanged: (value) {
                                  setState(() {
                                    PrivilegesConstants.CHANGE_WAREHOUSE_ITEM = value!;
                                  });
                                },
                              ),
                              Text('Изменить товар'),
                            ],
                          ),
                          SizedBox(height: 3.h),
                          Divider(thickness: 0.5.sp),
                          Text('Бригады', style: TextStyle(fontSize: 4.sp, fontWeight: FontWeight.bold)),
                          SizedBox(height: 3.h),
                          Row(
                            children: [
                              Checkbox(
                                value: PrivilegesConstants.ADD_BRIGADE,
                                onChanged: (value) {
                                  setState(() {
                                    PrivilegesConstants.ADD_BRIGADE = value!;
                                  });
                                },
                              ),
                              Text('Добавить бригаду'),
                              SizedBox(width: 3.w),
                              Checkbox(
                                value: PrivilegesConstants.CHANGE_BRIGADE,
                                onChanged: (value) {
                                  setState(() {
                                    PrivilegesConstants.CHANGE_BRIGADE = value!;
                                  });
                                },
                              ),
                              Text('Изменить данные бригады'),
                            ],
                          ),
                          SizedBox(height: 3.h),
                          Row(
                            children: [
                              Checkbox(
                                value: PrivilegesConstants.DELETE_BRIGADE,
                                onChanged: (value) {
                                  setState(() {
                                    PrivilegesConstants.DELETE_BRIGADE = value!;
                                  });
                                },
                              ),
                              Text('Удалить бригаду'),
                            ],
                          ),
                          SizedBox(height: 3.h),   
                          Divider(thickness: 0.5.sp),
                          Text('Выданные товары', style: TextStyle(fontSize: 4.sp, fontWeight: FontWeight.bold)),
                          SizedBox(height: 3.h),
                          Row(
                            children: [
                              Checkbox(
                                value: PrivilegesConstants.ISSUE_ITEM,
                                onChanged: (value) {
                                  setState(() {
                                    PrivilegesConstants.ISSUE_ITEM = value!;
                                  });
                                },
                              ),
                              Text('Выдать товар'),
                              SizedBox(width: 3.w),
                              Checkbox(
                                value: PrivilegesConstants.CHANGE_ISSUED_ITEM,
                                onChanged: (value) {
                                  setState(() {
                                    PrivilegesConstants.CHANGE_ISSUED_ITEM = value!;
                                  });
                                },
                              ),
                              Text('Изменить выданный товар'),
                            ]
                          ),
                          SizedBox(height: 3.h),
                          Row(
                            children: [Checkbox(
                                value: PrivilegesConstants.DELETE_ISSUED_ITEM,
                                onChanged: (value) {
                                  setState(() {
                                    PrivilegesConstants.DELETE_ISSUED_ITEM = value!;
                                  });
                                },
                              ),
                              Text('Удалить выданный товар'),
                            ],
                          ),
                          Divider(thickness: 0.5.sp),
                          Text('Поставщики', style: TextStyle(fontSize: 4.sp, fontWeight: FontWeight.bold)),
                          SizedBox(height: 3.h),
                          Row(
                            children: [
                            Checkbox(
                                value: PrivilegesConstants.ADD_SUPPLIER,
                                onChanged: (value) {
                                  setState(() {
                                    PrivilegesConstants.ADD_SUPPLIER = value!;
                                  });
                                },
                              ),
                              Text('Добавить поставщика'),
                          ]),
                          SizedBox(height: 3.h),
                          Row(
                            children: [
                              Checkbox(
                                value: PrivilegesConstants.DELETE_SUPPLIER,
                                onChanged: (value) {
                                  setState(() {
                                    PrivilegesConstants.DELETE_SUPPLIER = value!;
                                  });
                                },
                              ),
                              Text('Удалить поставщика'),
                            ],
                          ),
                          SizedBox(height: 3.h),
                          Divider(thickness: 0.5.sp),
                          Text('Возвраты', style: TextStyle(fontSize: 4.sp, fontWeight: FontWeight.bold)),
                          SizedBox(height: 3.h),
                          Row(
                            children: [
                              Checkbox(
                                value: PrivilegesConstants.ADD_RETURNED_ITEM,
                                onChanged: (value) {
                                  setState(() {
                                    PrivilegesConstants.ADD_RETURNED_ITEM = value!;
                                  });
                                },
                              ),
                              Text('Добавить возврат'),  
                              SizedBox(width: 3.w),
                              Checkbox(
                                value: PrivilegesConstants.CHANGE_RETURNED_ITEM,
                                onChanged: (value) {
                                  setState(() {
                                    PrivilegesConstants.CHANGE_RETURNED_ITEM = value!;
                                  });
                                },
                              ),
                              Text('Изменить возврат'),  
                            ]
                          ),
                          SizedBox(height: 3.h),
                          Row(
                            children: [
                              Checkbox(
                                value: PrivilegesConstants.DELETE_RETURNED_ITEM,
                                onChanged: (value) {
                                  setState(() {
                                    PrivilegesConstants.DELETE_RETURNED_ITEM = value!;
                                  });
                                },
                              ),
                              Text('Удалить возврат'),
                            ]
                          ),
                          SizedBox(height: 3.h),
                          Divider(thickness: 0.5.sp),
                          Text('Отчёты товаров', style: TextStyle(fontSize: 4.sp, fontWeight: FontWeight.bold)),
                          SizedBox(height: 3.h),
                          Row(
                              children: [
                                Checkbox(
                                  value: PrivilegesConstants.SEE_ITEMS_REPORT,
                                  onChanged: (value) {
                                    setState(() {
                                      PrivilegesConstants.SEE_ITEMS_REPORT = value!;
                                    });
                                  },
                                ),
                                Text('Смотреть'),
                                SizedBox(width: 3.w),
                                Checkbox(
                                  value: PrivilegesConstants.CHANGE_ITEMS_REPORT,
                                  onChanged: (value) {
                                    setState(() {
                                      PrivilegesConstants.CHANGE_ITEMS_REPORT = value!;
                                    });
                                  },
                                ),
                                Text('Изменить'),
                              ]
                          ),
                          SizedBox(height: 3.h),
                          Row(
                              children: [
                                Checkbox(
                                  value: PrivilegesConstants.DELETE_ITEMS_REPORT,
                                  onChanged: (value) {
                                    setState(() {
                                      PrivilegesConstants.DELETE_ITEMS_REPORT = value!;
                                    });
                                  },
                                ),
                                Text('Удалить'),
                              ]
                          ),
                          SizedBox(height: 3.h), 
                          Divider(thickness: 0.5.sp),
                          Text('Отчёты', style: TextStyle(fontSize: 4.sp, fontWeight: FontWeight.bold)),
                          SizedBox(height: 3.h),
                          Row(
                            children: [
                              Checkbox(
                                value: PrivilegesConstants.SEE_REPORTS,
                                onChanged: (value) {
                                  setState(() {
                                    PrivilegesConstants.SEE_REPORTS = value!;
                                  });
                                },
                              ),
                              Text('Смотреть отчёты'),  
                            ]
                          ),
                          SizedBox(height: 3.h),
                          Divider(thickness: 0.5.sp),
                          Text('Логи', style: TextStyle(fontSize: 4.sp, fontWeight: FontWeight.bold)),
                          SizedBox(height: 3.h),
                          Row(
                            children: [
                              Checkbox(
                                value: PrivilegesConstants.SEE_LOGS,
                                onChanged: (value) {
                                  setState(() {
                                    PrivilegesConstants.SEE_LOGS = value!;
                                  });
                                },
                              ),
                              Text('Смотреть логи'), 
                            ],
                          ),
                          SizedBox(height: 3.h),
                          Divider(thickness: 0.5.sp),
                          Text('Настройки программы', style: TextStyle(fontSize: 4.sp, fontWeight: FontWeight.bold)),
                          SizedBox(height: 3.h),
                          Row(
                            children: [
                              Checkbox(
                                value: PrivilegesConstants.SEE_SETTINGS_SECTION,
                                onChanged: (value) {
                                  setState(() {
                                    PrivilegesConstants.SEE_SETTINGS_SECTION = value!;
                                  });
                                },
                              ),
                              Text('Настройки'), 
                              SizedBox(width: 13.w),
                              Checkbox(
                                value: PrivilegesConstants.ADD_NEW_USER,
                                onChanged: (value) {
                                  setState(() {
                                    PrivilegesConstants.ADD_NEW_USER = value!;
                                  });
                                },
                              ),
                              Text('Добавить пользователя'), 
                            ]
                          ),
                          SizedBox(height: 3.h),
                          Row(
                            children: [
                              Checkbox(
                                value: PrivilegesConstants.SEE_USERS_LIST,
                                onChanged: (value) {
                                  setState(() {
                                    PrivilegesConstants.SEE_USERS_LIST = value!;
                                  });
                                },
                              ),
                              Text('Смотреть список пользователей'), 
                              SizedBox(width: 3.w),
                              Checkbox(
                                value: PrivilegesConstants.CHANGE_USERS_PRIVILEGES,
                                onChanged: (value) {
                                  setState(() {
                                    PrivilegesConstants.CHANGE_USERS_PRIVILEGES = value!;
                                  });
                                },
                              ),
                              Text('Изменить привилегии'),                              
                            ]
                          ),
                          SizedBox(height: 3.h),
                          Row(
                            children: [
                              Checkbox(
                                value: PrivilegesConstants.BACKUP_DATA,
                                onChanged: (value) {
                                  setState(() {
                                    PrivilegesConstants.BACKUP_DATA = value!;
                                  });
                                },
                              ),
                              Text('Сделать резервную копию'), 
                              SizedBox(width: 5.8.w),
                              Checkbox(
                                value: PrivilegesConstants.RESTORE_DATA,
                                onChanged: (value) {
                                  setState(() {
                                    PrivilegesConstants.RESTORE_DATA = value!;
                                  });
                                },
                              ),
                              Text('Восстановить из резервной копии'),  
                            ]
                          ),
                          SizedBox(height: 3.h),
                          Row(
                            children: [
                              Checkbox(
                                value: PrivilegesConstants.CHANGE_USERS_PASSWORD,
                                onChanged: (value) {
                                  setState(() {
                                    PrivilegesConstants.CHANGE_USERS_PASSWORD = value!;
                                  });
                                },
                              ),
                              Text('Изменить пароля пользователей'), 
                            ]
                          )
                        ],
                      ))),
                  SizedBox(height: 2.h),
                  FloatingActionButton.extended(
                      label: Text('Подтвердить'), onPressed: () => _submitPrivileges(user.name))
                ],
              );
            },
          );
        })
    });
  } 

  // Showing sign in dialog
  void _signInDialog() {
    TextEditingController ipAddressTextController = TextEditingController();
    TextEditingController nameTextController = TextEditingController();
    TextEditingController passwordTextController = TextEditingController();

    List<TextEditingController> controllersList = [
      ipAddressTextController,
      nameTextController,
      passwordTextController,
    ];

    if (UserState.getIP() != null &&
        UserState.getUserName() != null &&
        UserState.getPassword() != null) {
      ipAddressTextController.value =
          ipAddressTextController.value.copyWith(text: UserState.getIP());
      nameTextController.value =
          nameTextController.value.copyWith(text: UserState.getUserName());
      passwordTextController.value =
          passwordTextController.value.copyWith(text: UserState.getPassword());
    }

    var _isHidden = true;
    var isChecked = false;

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SimpleDialog(
                title: Text(
                  'Войти',
                  style: TextStyle(color: Colors.black, fontSize: 5.sp),
                ),
                contentPadding: EdgeInsets.all(5.0.sp),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0.sp)),
                backgroundColor: Colors.white,
                children: [
                  Column(
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.text,
                        controller: ipAddressTextController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0.sp)),
                          label: const Text('IP Адрес'),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        controller: nameTextController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0.sp)),
                          label: const Text('Имя пользователя'),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        obscureText: _isHidden,
                        controller: passwordTextController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0.sp)),
                            label: const Text('Пароль'),
                            suffixIcon: IconButton(
                              icon: Icon(!_isHidden
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _isHidden = !_isHidden;
                                });
                              },
                            )),
                      ),
                      SizedBox(height: 2.h),
                      CheckboxListTile(
                          title: const Text('Запомнить меня'),
                          controlAffinity: ListTileControlAffinity.leading,
                          value: isChecked,
                          onChanged: (value) {
                            setState(() {
                              isChecked = value!;
                            });
                          }),
                      SizedBox(height: 4.h),
                      FloatingActionButton.extended(
                        backgroundColor: Colors.lightBlue,
                        label: const Text('Войти'),
                        onPressed: () => _loginUser(controllersList, isChecked),
                      )
                    ],
                  )
                ],
              );
            },
          );
        });
  }

  // Showing register dialog
  void _registerDialog() {
    TextEditingController ipAddressTextController = TextEditingController();
    TextEditingController newUserNameController = TextEditingController();
    TextEditingController newUserPasswordController = TextEditingController();

    List<TextEditingController> controllersList = [
      ipAddressTextController,
      newUserNameController,
      newUserPasswordController
    ];
    var _isHidden = true;

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return SimpleDialog(
              title: Text(
                'Регистрация',
                style: TextStyle(color: Colors.black, fontSize: 5.sp),
              ),
              contentPadding: EdgeInsets.all(5.0.sp),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0.sp)),
              backgroundColor: Colors.white,
              children: [
                Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: ipAddressTextController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0.sp)),
                        label: const Text('IP Адрес'),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: newUserNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0.sp)),
                        label: const Text('Ваше имя'),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: newUserPasswordController,
                      obscureText: _isHidden,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0.sp)),
                          label: const Text('Введите новый пароль'),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isHidden = !_isHidden;
                              });
                            },
                            icon: Icon(!_isHidden
                                ? Icons.visibility
                                : Icons.visibility_off),
                          )),
                    ),
                    SizedBox(height: 5.h),
                    FloatingActionButton.extended(
                      backgroundColor: Colors.lightBlue,
                      label: const Text('Зарегистрироваться'),
                      onPressed: () =>
                          _finishRegistration(context, controllersList),
                      elevation: 3,
                    ),
                  ],
                )
              ],
            );
          });
        });
  }

  // Showing sign out dialog
  void _showSignOutDialog() {
    Widget _signOutButton = TextButton(
      child: const Text(
        'Выйти',
        style: TextStyle(color: Colors.red),
      ),
      onPressed: () {
        Navigator.pop(context);
        setState(() {
          UserState.isSignedIn = false;
          PrivilegesConstants.clear();
        });
      },
    );

    Widget _cancelButton = TextButton(
        child: const Text('Отмена'), onPressed: () => Navigator.pop(context));

    AlertDialog dialog = AlertDialog(
        title: const Text('Выйти из аккаунта'),
        content: const Text('Вы действительно хотите выйти ?'),
        actions: [_cancelButton, _signOutButton]);

    showDialog(
        context: context,
        builder: (context) {
          return dialog;
        });
  }

  // Finish registration 
  void _finishRegistration(BuildContext context, List<TextEditingController> controllersList) async {
    FToast ftoast = FToast();
    ftoast.init(context);

    var ip = controllersList[0].text;
    var name = controllersList[1].text;
    var password = controllersList[2].text;

    if (name == '' || password == '' || ip == '') {
      _showToast(3);
    } else {
      try {
        var data = {
          'ip': ip,
          'name': name,
          'password': password
        };
        chopper.Response response =
            await ServerSideApi.create(ip, 1).registerNewUser(data);
        if (response.body == 'user_registered') {
          Navigator.pop(context);
          _showToast(1);
        } else if (response.body == 'user_already_exists') {
          _showToast(2);
        }
      } on SocketException catch (_) {
        _showToast(6);
      }
    }
  }

  // Open my warehouse handler
  void _openMyWarehouse() {
    Navigator.of(context).push(_route(1));
  }

  // Open my brigade handler
  void _openMyBrigade() {
    Navigator.of(context).push(_route(2));
  }

  // Open my returned handler
  void _openMyReturned() {
    Navigator.of(context).push(_route(3));
  }

  // Open reports
  void _openReports() {
    Navigator.of(context).push(_route(4));
  }

  // Open logs
  void _openLogs() {
    Navigator.of(context).push(_route(5));
  }

  // Open items report
  void _openItemsReports(){
    Navigator.of(context).push(_route(6));
  }

  // Show backup dialog
  void _showBackupDialog() {
    TextEditingController fileNameController = TextEditingController();
    TextEditingController ipController = TextEditingController();

    if (UserState.getIP() != null) {
      ipController.value = ipController.value.copyWith(text: UserState.getIP());
    }

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SimpleDialog(
                title: const Text('Сделать резервную копию'),
                contentPadding: EdgeInsets.all(5.0.sp),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0.sp)),
                backgroundColor: Colors.white,
                children: [
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: ipController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0.sp)),
                      label: const Text('IP'),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: fileNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0.sp)),
                      label: const Text('Имя файла'),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  FloatingActionButton.extended(
                    label: const Text('Сделать резервную копию'),
                    onPressed: () => _backupData(fileNameController.text),
                  )
                ],
              );
            },
          );
        });
  }

  // Show backup dialog
  void _showRestoreBackupDialog() {
    if (UserState.getIP() != null) {
      ipController.value = ipController.value.copyWith(text: UserState.getIP());
    }

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SimpleDialog(
                title: const Text('Восстановить из резервной копии'),
                contentPadding: EdgeInsets.all(5.0.sp),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0.sp)),
                backgroundColor: Colors.white,
                children: [
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: ipController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0.sp)),
                      label: const Text('IP'),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(children: [
                    Flexible(
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        controller: fileTextController,
                        enabled: false,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0.sp)),
                          label: const Text('Имя файла'),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    FloatingActionButton.extended(
                      label: const Text('Выбрать файл'),
                      onPressed: () => _showSelectBackupFileDialog(),
                    )
                  ]),
                  SizedBox(height: 2.h),
                  FloatingActionButton.extended(
                      label: const Text('Восстановить'),
                      onPressed: () => _restoreData(
                          fileTextController.text, ipController.text))
                ],
              );
            },
          );
        });
  }

  // Show users dialog
  void _showUsersDialog(int code) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SimpleDialog(
                title: const Text('Пользователи'),
                contentPadding: EdgeInsets.all(5.sp),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0.sp)),
                backgroundColor: Colors.white,
                children: [
                  SizedBox(height: 30.h, child: getUsers(2)),
                  code != 1
                  ? SizedBox(height: 2.h)
                  : SizedBox(height: 0.h),
                  
                  code != 1
                  ? FloatingActionButton.extended(
                      label: const Text('Выбрать'),
                      onPressed: () => _selectUser())
                  : SizedBox()
                ],
              );
            },
          );
        });
  }

  // Show change password dialog
  void _showChangePasswordDialog() {
    TextEditingController passwordController = TextEditingController();
    var _isHidden = true;

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SimpleDialog(
                title: Text('Изменить пароль'),
                contentPadding: EdgeInsets.all(5.0.sp),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0.sp)),
                backgroundColor: Colors.white,
                children: [
                  Row(children: [
                    Flexible(
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        controller: nameController,
                        enabled: false,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0.sp)),
                          label: const Text('Пользователь'),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    FloatingActionButton.extended(
                      label: const Text('Выбрать'),
                      onPressed: () => _showSelectUserDialog(),
                    ),
                  ]),
                  SizedBox(height: 2.h),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: passwordController,
                    obscureText: _isHidden,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0.sp)),
                        label: const Text('Введите новый пароль'),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isHidden = !_isHidden;
                            });
                          },
                          icon: Icon(!_isHidden
                              ? Icons.visibility
                              : Icons.visibility_off),
                        )),
                  ),
                  SizedBox(height: 2.h),
                  FloatingActionButton.extended(
                    label: Text('Изменить пароль'),
                    onPressed: () => _changePassword(passwordController.text),
                  )
                ],
              );
            },
          );
        });
  }

  // Show backup files dialog
  void _showSelectBackupFileDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SimpleDialog(
                title: const Text('Выберите резервный файл'),
                contentPadding: EdgeInsets.all(5.sp),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0.sp)),
                backgroundColor: Colors.white,
                children: [
                  SizedBox(height: 30.h, child: getBackupFiles()),
                  SizedBox(height: 2.h),
                  FloatingActionButton.extended(
                      label: const Text('Выбрать'),
                      onPressed: () => _selectBackupFile())
                ],
              );
            },
          );
        });
  }

  // Select backup file
  void _selectBackupFile() {
    fileTextController.value = fileTextController.value
        .copyWith(text: backupFileList![_backupFilesIndex!].filename);
    Navigator.pop(context);
  }

  // Select user
  void _selectUser() {
    nameController.value =
        nameController.value.copyWith(text: usersList![_usersIndex!].name);
    Navigator.pop(context);
  }

  // Show dialog to select user
  void _showSelectUserDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SimpleDialog(
                title: const Text('Выберите пользователя'),
                contentPadding: EdgeInsets.all(5.sp),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0.sp)),
                backgroundColor: Colors.white,
                children: [
                  SizedBox(height: 30.h, child: getUsers(1)),
                  SizedBox(height: 2.h),
                  FloatingActionButton.extended(
                      label: const Text('Выбрать'),
                      onPressed: () => _selectUser())
                ],
              );
            },
          );
        });
  }
  
  // Submit privileges for current user
  void _submitPrivileges(String name) async {
    var data = {
      'ip' : UserState.getIP(),
      'name' : name,

      // App privileges
      'see_settings_section' : PrivilegesConstants.SEE_SETTINGS_SECTION,
      'add_new_user' : PrivilegesConstants.ADD_NEW_USER,
      'see_users_list' : PrivilegesConstants.SEE_USERS_LIST,
      'change_users_privileges' : PrivilegesConstants.CHANGE_USERS_PRIVILEGES,
      'backup_data' : PrivilegesConstants.BACKUP_DATA,
      'restore_data' : PrivilegesConstants.RESTORE_DATA,
      'change_users_password' : PrivilegesConstants.CHANGE_USERS_PASSWORD,

      // Warehouse privileges
      'see_warehouse_content' : PrivilegesConstants.SEE_WAREHOUSE_CONTENT,
      'add_item_to_warehouse' : PrivilegesConstants.ADD_ITEM_TO_WAREHOUSE,
      'see_item_details' : PrivilegesConstants.SEE_ITEM_DETAILS,
      'change_warehouse_item' : PrivilegesConstants.CHANGE_WAREHOUSE_ITEM,
      'delete_warehouse_item' : PrivilegesConstants.DELETE_WAREHOUSE_ITEM,

      // Suppliers privileges
      'add_supplier' : PrivilegesConstants.ADD_SUPPLIER,
      'delete_supplier' : PrivilegesConstants.DELETE_SUPPLIER,

      // Brigades privileges
      'add_brigade' : PrivilegesConstants.ADD_BRIGADE,
      'change_brigade' : PrivilegesConstants.CHANGE_BRIGADE,
      'delete_brigade' : PrivilegesConstants.DELETE_BRIGADE,

      // Issued items privileges
      'issue_item' : PrivilegesConstants.ISSUE_ITEM,
      'change_issued_item' : PrivilegesConstants.CHANGE_ISSUED_ITEM,
      'delete_issued_item' : PrivilegesConstants.DELETE_ISSUED_ITEM,

      'see_items_report' : PrivilegesConstants.SEE_ITEMS_REPORT,
      'change_items_report' : PrivilegesConstants.CHANGE_ITEMS_REPORT,
      'delete_items_report' : PrivilegesConstants.DELETE_ITEMS_REPORT,

      // Returned privileges 
      'add_returned_item' : PrivilegesConstants.ADD_RETURNED_ITEM,
      'change_returned_item' : PrivilegesConstants.CHANGE_RETURNED_ITEM,
      'delete_returned_item' : PrivilegesConstants.DELETE_RETURNED_ITEM,

      // Reports privileges
      'see_reports' : PrivilegesConstants.SEE_REPORTS,

      // Logs privileges
      'see_logs' : PrivilegesConstants.SEE_LOGS,
      
    };
    chopper.Response response = await ServerSideApi.create(UserState.getIP()!, 1).updatePrivileges(data);

    if(response.body == 'privileges_successfully_updated'){
      _showToast(7);
      Navigator.pop(context);
      PrivilegesConstants.clear();
    }
  }

  // Backup app data
  void _backupData(String filename) async {
    var data = {
      'ip': UserState.getIP(),
      'filename': filename,
    };

    if (filename == '') {
      _showToast(3);
    } else {
      await ServerSideApi.create(UserState.getIP()!, 1).backupData(data);
      _showToast(7);
      Navigator.pop(context);
    }
  }

  // Restoring data
  void _restoreData(String filename, String ip) async {
    var data = {'ip': ip, 'filename': filename};

    if (filename == '') {
      _showToast(3);
    } else {
      await ServerSideApi.create(ip, 1).restoreBackup(data);
      _showToast(7);
      Navigator.pop(context);
    }
  }

  // Change password
  void _changePassword(String password) async {
    var data = {
      'ip': UserState.getIP(),
      'name': nameController.text,
      'password': password
    };

    chopper.Response response =
        await ServerSideApi.create(UserState.getIP()!, 1).changePassword(data);
    if (response.body == 'password_changed') {
      _showToast(7);
      Navigator.pop(context);
      nameController.clear();
    }
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
              const Text("Вы успешно зарегистрировались"),
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
              const Text("Аккаунт с таким именем уже существует"),
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
              const Icon(Icons.warning),
              SizedBox(
                width: 5.0.w,
              ),
              const Text("Пожалуйста заполните все поля"),
            ],
          ),
        );
        break;
      case 4:
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
              const Text("Добро пожаловать"),
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
              const Text("Неверное имя пользователя или пароль"),
            ],
          ),
        );
        break;
      case 6:
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
              const Text("Неверный хост"),
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
