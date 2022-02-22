import 'package:chopper/chopper.dart';
import 'package:intermax_warehouse_app/BackupFileDetails/back_up_file_details.dart';
import 'package:intermax_warehouse_app/BrigadeDetails/brigade_details.dart';
import 'package:intermax_warehouse_app/IssuedItemsDetails/issued_items.dart';
import 'package:intermax_warehouse_app/Items%20Report%20Model/items_report_model.dart';
import 'package:intermax_warehouse_app/JsonConverter/converter.dart';
import 'package:intermax_warehouse_app/LogsDetails/log_details.dart';
import 'package:intermax_warehouse_app/Privileges/app_privileges.dart';
import 'package:intermax_warehouse_app/Privileges/brigades_privileges.dart';
import 'package:intermax_warehouse_app/Privileges/issued_items_privileges.dart';
import 'package:intermax_warehouse_app/Privileges/logs_privileges.dart';
import 'package:intermax_warehouse_app/Privileges/reports_privileges.dart';
import 'package:intermax_warehouse_app/Privileges/returned_privileges.dart';
import 'package:intermax_warehouse_app/Privileges/suppliers_privileges.dart';
import 'package:intermax_warehouse_app/Privileges/warehouse_privileges.dart';
import 'package:intermax_warehouse_app/ReturnedItemDetails/returned_item_details.dart';
import 'package:intermax_warehouse_app/SuppliersDetails/suppliers_details.dart';
import 'package:intermax_warehouse_app/Users/user_details.dart';
import 'package:intermax_warehouse_app/WarehouseItemDetails/warehouse_item_details.dart';

part 'server_side_api.chopper.dart';

@ChopperApi()
abstract class ServerSideApi extends ChopperService {

  @Post(path: '/login_user.php')
  Future<Response<Users>> loginUser(@Body() var data);

  @Post(path: '/register_user.php')
  Future<Response> registerNewUser(@Body() var data);

  @Post(path: '/add_item_to_warehouse.php')
  Future<Response> addItem(@Body() var data);

  @Post(path: '/add_existing_item.php')
  Future<Response> addExistingItem(@Body() var data);

  @Post(path: '/edit_warehouse_item.php')
  Future<Response> editItem(@Body() var data);

  @Post(path: '/delete_item_from_warehouse.php')
  Future<Response> deleteItem(@Body() var data);

  @Post(path: '/add_new_supplier.php')
  Future<Response> addSupplier(@Body() var data);

  @Post(path: '/delete_supplier.php')
  Future<Response> deleteSupplier(@Body() var data);

  @Post(path: '/add_new_brigade.php')
  Future<Response> addBrigade(@Body() var data);

  @Post(path: '/edit_brigade.php')
  Future<Response> editBrigade(@Body() var data);

  @Post(path: '/delete_brigade.php')
  Future<Response> deleteBrigade(@Body() var data);

  @Post(path: '/issue_item.php')
  Future<Response> issueItem(@Body() var data);

  @Post(path: '/edit_issued_item.php')
  Future<Response> editIssuedItem(@Body() var data);

  @Post(path: '/delete_issued_item.php')
  Future<Response> deleteIssuedItem(@Body() var data);

  @Post(path: '/create_backup.php')
  Future<Response> backupData(@Body() var data);

  @Post(path: '/add_returned_item.php')
  Future<Response> addReturnedItem(@Body() var data);

  @Post(path: '/edit_returned_item.php')
  Future<Response> editReturnedItem(@Body() var data);

  @Post(path: '/delete_returned_item.php')
  Future<Response> deleteReturnedItem(@Body() var data);

  @Post(path: '/restore_backup.php')
  Future<Response> restoreBackup(@Body() var data);
  
  @Post(path: '/change_password.php')
  Future<Response> changePassword(@Body() var data);
  
  @Post(path: '/update_privileges.php')
  Future<Response> updatePrivileges(@Body() var data);

  @Post(path: '/reorder_items.php')
  Future<Response> reorderItems(@Body() var data);

  @Post(path: '/clear_reports.php')
  Future<Response> clearReports(@Body() var data);

  @Post(path: '/clear_returned.php')
  Future<Response> clearReturned(@Body() var data);

  @Post(path: '/clear_logs.php')
  Future<Response> clearLogs(@Body() var data);

  @Post(path: '/get_users.php')
  Future<Response<List<Users>>> getUsers(@Body() var data);

  @Post(path: '/get_issued_items.php')
  Future<Response<List<IssuedItems>>> getIssuedItems(@Body() var data);

  @Post(path: '/create_report.php')
  Future<Response<List<IssuedItems>>> createReport(@Body() var data);

  @Post(path: '/get_items_in_warehouse.php')
  Future<Response<List<WarehouseItemDetails>>> getItems(@Body() var data);

  @Post(path: '/get_items_report.php')
  Future<Response<List<ItemReport>>> getItemsReport(@Body() var data);

  @Post(path: '/get_suppliers.php')
  Future<Response<List<Suppliers>>> getSuppliers(@Body() var data);

  @Post(path: '/get_brigades.php')
  Future<Response<List<Brigades>>> getBrigades(@Body() var data);

  @Post(path: '/get_returned_items.php')
  Future<Response<List<ReturnedItem>>> getReturnedItems(@Body() var data);

  @Post(path: '/get_logs.php')
  Future<Response<List<Log>>> getLogs(@Body() var data);

  @Post(path: '/get_backup_files.php')
  Future<Response<List<BackupFile>>> getBackupFiles();

  @Post(path: '/get_warehouse_privileges.php')
  Future<Response<List<WarehousePrivileges>>> getWarehousePrivileges(@Body() var data);
  
  @Post(path: '/get_suppliers_privileges.php')
  Future<Response<List<SuppliersPrivileges>>> getSuppliersPrivileges(@Body() var data);
  
  @Post(path: '/get_brigades_privileges.php')
  Future<Response<List<BrigadesPrivileges>>> getBrigadesPrivileges(@Body() var data);
  
  @Post(path: '/get_issued_items_privileges.php')
  Future<Response<List<IssuedItemsPrivileges>>> getIssuedItemsPrivileges(@Body() var data);
  
  @Post(path: '/get_reports_privileges.php')
  Future<Response<List<ReportsPrivileges>>> getReportsPrivileges(@Body() var data);
  
  @Post(path: '/get_returned_privileges.php')
  Future<Response<List<ReturnedPrivileges>>> getReturnedPrivileges(@Body() var data);
  
  @Post(path: '/get_logs_privileges.php')
  Future<Response<List<LogsPrivileges>>> getLogsPrivileges(@Body() var data);

  @Post(path: '/get_app_privileges.php') 
  Future<Response<List<AppPrivileges>>> getAppPrivileges(@Body() var data);


  static ServerSideApi create(String ip, int code) {
    JsonConverter? converter;
    switch (code) {
      case 1:
        converter = const JsonConverter();
        break;
      case 2:
        converter = JsonToTypeConverter(
          {Users: (jsonData) => Users.fromJson(jsonData)});
        break;
      case 3:
        converter = JsonToTypeConverter({
          WarehouseItemDetails: (jsonData) =>
              WarehouseItemDetails.fromJson(jsonData)
        });
        break;
      case 4:
        converter = JsonToTypeConverter(
            {Suppliers: (jsonData) => Suppliers.fromJson(jsonData)});
        break;
      case 5:
        converter = JsonToTypeConverter(
            {Brigades: (jsonData) => Brigades.fromJson(jsonData)});
        break;
      case 6:
        converter = JsonToTypeConverter(
            {IssuedItems: (jsonData) => IssuedItems.fromJson(jsonData)});
        break;
      case 7:
        converter = JsonToTypeConverter(
            {ReturnedItem: (jsonData) => ReturnedItem.fromJson(jsonData)});
        break;
      case 8:
        converter = JsonToTypeConverter(
          {Log: (jsonData) => Log.fromJson(jsonData)});
        break;
      case 9:
        converter = JsonToTypeConverter(
            {BackupFile: (jsonData) => BackupFile.fromJson(jsonData)});
        break;
      case 10:
        converter = JsonToTypeConverter({
          Users: (jsonData) => Users.fromJson(jsonData)
        });
        break;  
      case 11:
        converter = JsonToTypeConverter({
          WarehousePrivileges: (jsonData) => WarehousePrivileges.fromJson(jsonData)
        });
        break;  
      case 12:
        converter = JsonToTypeConverter({
          SuppliersPrivileges: (jsonData) => SuppliersPrivileges.fromJson(jsonData)
        });
        break;  
      case 13:
        converter = JsonToTypeConverter({
          BrigadesPrivileges: (jsonData) => BrigadesPrivileges.fromJson(jsonData)
        });
        break;  
      case 14:
        converter = JsonToTypeConverter({
          IssuedItemsPrivileges: (jsonData) => IssuedItemsPrivileges.fromJson(jsonData)
        });
        break;  
      case 15:
        converter = JsonToTypeConverter({
          ReportsPrivileges: (jsonData) => ReportsPrivileges.fromJson(jsonData)
        });
        break;  
      case 16:
        converter = JsonToTypeConverter({
          ReturnedPrivileges: (jsonData) => ReturnedPrivileges.fromJson(jsonData)
        });
        break;  
      case 17:
        converter = JsonToTypeConverter({
          LogsPrivileges: (jsonData) => LogsPrivileges.fromJson(jsonData)
        });
        break;  
      case 18:
        converter = JsonToTypeConverter({
          AppPrivileges: (jsonData) => AppPrivileges.fromJson(jsonData)
        });
        break;
      case 19:
        converter = JsonToTypeConverter({
          ItemReport: (jsonData) => ItemReport.fromJson(jsonData)
        });
        break;
    }

    final client = ChopperClient(
      baseUrl: 'http://$ip:1072/Склад',
      services: [_$ServerSideApi()],
      converter: converter,
    );

    return _$ServerSideApi(client);
  }
}
