import 'dart:core';


class PrivilegesConstants{   

    // App privileges
    static var SEE_SETTINGS_SECTION = true;
    static var ADD_NEW_USER = true;
    static var SEE_USERS_LIST = true;
    static var CHANGE_USERS_PRIVILEGES = true;
    static var BACKUP_DATA = true;
    static var RESTORE_DATA = true;
    static var CHANGE_USERS_PASSWORD = true;

    // Warehouse privileges 
    static var SEE_WAREHOUSE_CONTENT = true;
    static var ADD_ITEM_TO_WAREHOUSE = true;
    static var SEE_ITEM_DETAILS = true;
    static var CHANGE_WAREHOUSE_ITEM = true;
    static var DELETE_WAREHOUSE_ITEM = true;

    // Brigades privileges
    static var ADD_BRIGADE = true;
    static var CHANGE_BRIGADE = true;
    static var DELETE_BRIGADE = true;

    // Issued items privileges
    static var ISSUE_ITEM = true;
    static var CHANGE_ISSUED_ITEM = true;
    static var DELETE_ISSUED_ITEM = true;

    // Returned privileges
    static var ADD_RETURNED_ITEM = true;
    static var CHANGE_RETURNED_ITEM = true;
    static var DELETE_RETURNED_ITEM = true;

    //Item report privileges
    static var SEE_ITEMS_REPORT = true;
    static var CHANGE_ITEMS_REPORT = true;
    static var DELETE_ITEMS_REPORT = true;

    // Suppliers privileges
    static var ADD_SUPPLIER = true;
    static var DELETE_SUPPLIER = true;

    // See reports privileges
    static var SEE_REPORTS = true;

    // See logs privileges
    static var SEE_LOGS = true;


  static void clear(){
      // App privileges
    SEE_SETTINGS_SECTION = true;
    ADD_NEW_USER = true;
    SEE_USERS_LIST = true;
    CHANGE_USERS_PRIVILEGES = true;
    BACKUP_DATA = true;
    RESTORE_DATA = true;
    CHANGE_USERS_PASSWORD = true;
    SEE_ITEMS_REPORT = true;

    // Warehouse privileges 
    SEE_WAREHOUSE_CONTENT = true;
    ADD_ITEM_TO_WAREHOUSE = true;
    SEE_ITEM_DETAILS = true;
    CHANGE_WAREHOUSE_ITEM = true;
    DELETE_WAREHOUSE_ITEM = true;

    // Brigades privileges
    ADD_BRIGADE = true;
    CHANGE_BRIGADE = true;
    DELETE_BRIGADE = true;

    // Issued items privileges
    ISSUE_ITEM = true;
    CHANGE_ISSUED_ITEM = true;
    DELETE_ISSUED_ITEM = true;

    // Returned privileges
    ADD_RETURNED_ITEM = true;
    CHANGE_RETURNED_ITEM = true;
    DELETE_RETURNED_ITEM = true;

    //Item report privileges
    SEE_ITEMS_REPORT = true;
    CHANGE_ITEMS_REPORT = true;
    DELETE_ITEMS_REPORT = true;

    // Suppliers privileges
    ADD_SUPPLIER = true;
    DELETE_SUPPLIER = true;

    // See reports privileges
    SEE_REPORTS = true;

    // See logs privileges
    SEE_LOGS = true;
  }
}