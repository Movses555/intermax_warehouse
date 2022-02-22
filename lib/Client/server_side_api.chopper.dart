// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_side_api.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations
class _$ServerSideApi extends ServerSideApi {
  _$ServerSideApi([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = ServerSideApi;

  @override
  Future<Response<Users>> loginUser(dynamic data) {
    final $url = '/login_user.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<Users, Users>($request);
  }

  @override
  Future<Response<dynamic>> registerNewUser(dynamic data) {
    final $url = '/register_user.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> addItem(dynamic data) {
    final $url = '/add_item_to_warehouse.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> editItem(dynamic data) {
    final $url = '/edit_warehouse_item.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteItem(dynamic data) {
    final $url = '/delete_item_from_warehouse.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> addSupplier(dynamic data) {
    final $url = '/add_new_supplier.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteSupplier(dynamic data) {
    final $url = '/delete_supplier.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> addBrigade(dynamic data) {
    final $url = '/add_new_brigade.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> editBrigade(dynamic data) {
    final $url = '/edit_brigade.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteBrigade(dynamic data) {
    final $url = '/delete_brigade.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> issueItem(dynamic data) {
    final $url = '/issue_item.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> editIssuedItem(dynamic data) {
    final $url = '/edit_issued_item.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteIssuedItem(dynamic data) {
    final $url = '/delete_issued_item.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> backupData(dynamic data) {
    final $url = '/create_backup.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> addReturnedItem(dynamic data) {
    final $url = '/add_returned_item.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> editReturnedItem(dynamic data) {
    final $url = '/edit_returned_item.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteReturnedItem(dynamic data) {
    final $url = '/delete_returned_item.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> restoreBackup(dynamic data) {
    final $url = '/restore_backup.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> changePassword(dynamic data) {
    final $url = '/change_password.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> updatePrivileges(dynamic data) {
    final $url = '/update_privileges.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> reorderItems(dynamic data) {
    final $url = '/reorder_items.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> clearReports(dynamic data) {
    final $url = '/clear_reports.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> clearReturned(dynamic data) {
    final $url = '/clear_returned.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> clearLogs(dynamic data) {
    final $url = '/clear_logs.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<List<Users>>> getUsers(dynamic data) {
    final $url = '/get_users.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<List<Users>, Users>($request);
  }

  @override
  Future<Response<List<IssuedItems>>> getIssuedItems(dynamic data) {
    final $url = '/get_issued_items.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<List<IssuedItems>, IssuedItems>($request);
  }

  @override
  Future<Response<List<IssuedItems>>> createReport(dynamic data) {
    final $url = '/create_report.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<List<IssuedItems>, IssuedItems>($request);
  }

  @override
  Future<Response<List<WarehouseItemDetails>>> getItems(dynamic data) {
    final $url = '/get_items_in_warehouse.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client
        .send<List<WarehouseItemDetails>, WarehouseItemDetails>($request);
  }

  @override
  Future<Response<List<Suppliers>>> getSuppliers(dynamic data) {
    final $url = '/get_suppliers.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<List<Suppliers>, Suppliers>($request);
  }

  @override
  Future<Response<List<Brigades>>> getBrigades(dynamic data) {
    final $url = '/get_brigades.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<List<Brigades>, Brigades>($request);
  }

  @override
  Future<Response<List<ReturnedItem>>> getReturnedItems(dynamic data) {
    final $url = '/get_returned_items.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<List<ReturnedItem>, ReturnedItem>($request);
  }

  @override
  Future<Response<List<Log>>> getLogs(dynamic data) {
    final $url = '/get_logs.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<List<Log>, Log>($request);
  }

  @override
  Future<Response<List<BackupFile>>> getBackupFiles() {
    final $url = '/get_backup_files.php';
    final $request = Request('POST', $url, client.baseUrl);
    return client.send<List<BackupFile>, BackupFile>($request);
  }

  @override
  Future<Response<List<WarehousePrivileges>>> getWarehousePrivileges(
      dynamic data) {
    final $url = '/get_warehouse_privileges.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client
        .send<List<WarehousePrivileges>, WarehousePrivileges>($request);
  }

  @override
  Future<Response<List<SuppliersPrivileges>>> getSuppliersPrivileges(
      dynamic data) {
    final $url = '/get_suppliers_privileges.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client
        .send<List<SuppliersPrivileges>, SuppliersPrivileges>($request);
  }

  @override
  Future<Response<List<BrigadesPrivileges>>> getBrigadesPrivileges(
      dynamic data) {
    final $url = '/get_brigades_privileges.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<List<BrigadesPrivileges>, BrigadesPrivileges>($request);
  }

  @override
  Future<Response<List<IssuedItemsPrivileges>>> getIssuedItemsPrivileges(
      dynamic data) {
    final $url = '/get_issued_items_privileges.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client
        .send<List<IssuedItemsPrivileges>, IssuedItemsPrivileges>($request);
  }

  @override
  Future<Response<List<ReportsPrivileges>>> getReportsPrivileges(dynamic data) {
    final $url = '/get_reports_privileges.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<List<ReportsPrivileges>, ReportsPrivileges>($request);
  }

  @override
  Future<Response<List<ReturnedPrivileges>>> getReturnedPrivileges(
      dynamic data) {
    final $url = '/get_returned_privileges.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<List<ReturnedPrivileges>, ReturnedPrivileges>($request);
  }

  @override
  Future<Response<List<LogsPrivileges>>> getLogsPrivileges(dynamic data) {
    final $url = '/get_logs_privileges.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<List<LogsPrivileges>, LogsPrivileges>($request);
  }

  @override
  Future<Response<List<AppPrivileges>>> getAppPrivileges(dynamic data) {
    final $url = '/get_app_privileges.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<List<AppPrivileges>, AppPrivileges>($request);
  }
}
