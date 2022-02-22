import 'package:chopper/chopper.dart';
import 'package:intermax_warehouse_app/Client/server_side_api.dart';
import 'package:intermax_warehouse_app/Privileges/app_privileges.dart';
import 'package:intermax_warehouse_app/Privileges/brigades_privileges.dart';
import 'package:intermax_warehouse_app/Privileges/issued_items_privileges.dart';
import 'package:intermax_warehouse_app/Privileges/logs_privileges.dart';
import 'package:intermax_warehouse_app/Privileges/reports_privileges.dart';
import 'package:intermax_warehouse_app/Privileges/returned_privileges.dart';
import 'package:intermax_warehouse_app/Privileges/suppliers_privileges.dart';
import 'package:intermax_warehouse_app/Privileges/warehouse_privileges.dart';
import 'package:intermax_warehouse_app/privileges_const.dart';

class Privileges{

  static var privileges; 
  static var _ip;
  
  // Creating instance
  static Privileges createInstance(){
    privileges ??= Privileges();

    return privileges;
  }
  
  // Getting all privileges
  Future getPrivileges(String ip, String name) async {
    _ip = ip;
    var data = {'ip' : ip, 'name' : name};
    return Future.wait([
       _getWarehousePrivileges(data),
       _getSuppliersPrivileges(data),
       _getBrigadesPrivileges(data),
       _getIssuedItemsPrivileges(data),
       _getReportsPrivileges(data),
       _getReturnedPrivileges(data),
       _getLogsPrivileges(data),
       _getAppPrivileges(data)
    ]);
  }

  // Getting warehouse privileges
  Future _getWarehousePrivileges(var data) async {
    Response<List<WarehousePrivileges>> response = await ServerSideApi.create(_ip, 11).getWarehousePrivileges(data);
    
    if(response.body != null){
      List<WarehousePrivileges>? warehousePrivileges = response.body;

      PrivilegesConstants.SEE_WAREHOUSE_CONTENT = warehousePrivileges![0].seeWarehouseContent;
      PrivilegesConstants.ADD_ITEM_TO_WAREHOUSE = warehousePrivileges[0].addItemToWarehouse;
      PrivilegesConstants.SEE_ITEM_DETAILS = warehousePrivileges[0].seeItemDetails;
      PrivilegesConstants.CHANGE_WAREHOUSE_ITEM = warehousePrivileges[0].changeWarehouseItem;
      PrivilegesConstants.DELETE_WAREHOUSE_ITEM = warehousePrivileges[0].deleteWarehouseItem;
      PrivilegesConstants.SEE_ITEMS_REPORT = warehousePrivileges[0].seeItemsReport;
    }else{
      PrivilegesConstants.clear();
    }
  }
  
  // Getting suppliers privileges
  Future _getSuppliersPrivileges(var data) async {
    Response<List<SuppliersPrivileges>> response = await ServerSideApi.create(_ip, 12).getSuppliersPrivileges(data);
    
    if(response.body != null){
      List<SuppliersPrivileges>? suppliersPrivileges = response.body;

      PrivilegesConstants.ADD_SUPPLIER = suppliersPrivileges![0].addSupplier;
      PrivilegesConstants.DELETE_SUPPLIER = suppliersPrivileges[0].deleteSupplier;
    }else{
      PrivilegesConstants.clear();
    }
  }
 
  // Getting brigades privileges
  Future _getBrigadesPrivileges(var data) async {
    Response<List<BrigadesPrivileges>> response = await ServerSideApi.create(_ip, 13).getBrigadesPrivileges(data);
    
    if(response.body != null){
      List<BrigadesPrivileges>? brigadesPrivileges = response.body;

      PrivilegesConstants.ADD_BRIGADE = brigadesPrivileges![0].addBrigade;
      PrivilegesConstants.CHANGE_BRIGADE = brigadesPrivileges[0].changeBrigade;
      PrivilegesConstants.DELETE_BRIGADE = brigadesPrivileges[0].deleteBrigade;
    }else{
      PrivilegesConstants.clear();
    }
  }
  
  // Getting issued items privileges
  Future _getIssuedItemsPrivileges(var data) async {
    Response<List<IssuedItemsPrivileges>> response = await ServerSideApi.create(_ip, 14).getIssuedItemsPrivileges(data);
    
    if(response.body != null) {
      List<IssuedItemsPrivileges>? issuedItemsPrivileges = response.body;

      PrivilegesConstants.ISSUE_ITEM = issuedItemsPrivileges![0].issueItem;
      PrivilegesConstants.CHANGE_ISSUED_ITEM = issuedItemsPrivileges[0].changeIssuedItem;
      PrivilegesConstants.DELETE_ISSUED_ITEM = issuedItemsPrivileges[0].deleteIssuedItem;
    }else{
      PrivilegesConstants.clear();
    }
  }
  
  // Getting reports privileges
  Future _getReportsPrivileges(var data) async {
    Response<List<ReportsPrivileges>> response = await ServerSideApi.create(_ip, 15).getReportsPrivileges(data);
    
    if(response.body != null){
      List<ReportsPrivileges>? reportsPrivileges = response.body;

      PrivilegesConstants.SEE_REPORTS = reportsPrivileges![0].seeReports;
    }else{
      PrivilegesConstants.clear();
    }
  }

  // Getting returned privileges
  Future _getReturnedPrivileges(var data) async {
    Response<List<ReturnedPrivileges>> response = await ServerSideApi.create(_ip, 16).getReturnedPrivileges(data);
    
    if(response.body != null){
      List<ReturnedPrivileges>? returnedPrivileges = response.body;

      PrivilegesConstants.ADD_RETURNED_ITEM = returnedPrivileges![0].addReturnedItem;
      PrivilegesConstants.CHANGE_RETURNED_ITEM = returnedPrivileges[0].changeReturnedItem;
      PrivilegesConstants.DELETE_RETURNED_ITEM = returnedPrivileges[0].changeReturnedItem; 
    }else{
      PrivilegesConstants.clear();
    }
  }

  // Getting logs privileges
  Future _getLogsPrivileges(var data) async {
    Response<List<LogsPrivileges>> response = await ServerSideApi.create(_ip, 17).getLogsPrivileges(data);
    
    if(response.body != null){
      List<LogsPrivileges>? logsPrivileges = response.body;

      PrivilegesConstants.SEE_LOGS = logsPrivileges![0].seeLogs;
    }else{
      PrivilegesConstants.clear();
    }
  }
  
  // Getting app privileges
  Future _getAppPrivileges(var data) async {
    Response<List<AppPrivileges>> response = await ServerSideApi.create(_ip, 18).getAppPrivileges(data);
    
    if(response.body != null){
      List<AppPrivileges>? appPrivileges = response.body;

      PrivilegesConstants.SEE_SETTINGS_SECTION = appPrivileges![0].seeSettingsSection;
      PrivilegesConstants.ADD_NEW_USER = appPrivileges[0].addNewUser;
      PrivilegesConstants.SEE_USERS_LIST = appPrivileges[0].seeUsersList;
      PrivilegesConstants.CHANGE_USERS_PRIVILEGES = appPrivileges[0].changeUsersPrivileges;
      PrivilegesConstants.BACKUP_DATA = appPrivileges[0].backupData;
      PrivilegesConstants.RESTORE_DATA = appPrivileges[0].restoreData;
      PrivilegesConstants.CHANGE_USERS_PASSWORD = appPrivileges[0].changeUsersPassword;
    }else{
      PrivilegesConstants.clear();
    }
  }
}