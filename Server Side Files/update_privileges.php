<?php

// Storing the received JSON into $json variable.
$json = file_get_contents('php://input');
 
// Decode the received JSON and Store into $obj variable.
$obj = json_decode($json, true);
 
//Define your Server host name here.
$HostName = $obj['ip'];
 
//Define your MySQL Database Name here.
$DatabaseName = "intermax_warehouse_db";
 
//Define your Database User Name here.
$HostUser = "AdminYerevan";
 
//Define your Database Password here.
$HostPass = "Intermax1072"; 
 
//Creating MySQL Connection.
$conn = mysqli_connect($HostName,$HostUser,$HostPass,$DatabaseName);

//Getting user email
$name = $obj['name'];

//App privileges
$see_settings_section = $obj['see_settings_section'];
$add_new_user = $obj['add_new_user'];
$see_users_list = $obj['see_users_list'];
$change_users_privileges = $obj['change_users_privileges'];
$backup_data = $obj['backup_data'];
$restore_data = $obj['restore_data'];
$change_users_password = $obj['change_users_password'];

//Warehouse privileges
$see_warehouse_content = $obj['see_warehouse_content'];
$add_item_to_warehouse = $obj['add_item_to_warehouse'];
$see_item_details = $obj['see_item_details'];
$change_warehouse_item = $obj['change_warehouse_item']; 
$delete_warehouse_item = $obj['delete_warehouse_item'];

//Brigades privileges
$add_brigade = $obj['add_brigade'];
$change_brigade = $obj['change_brigade'];
$delete_brigade = $obj['delete_brigade'];

//Issued item privileges
$issue_item = $obj['issue_item'];
$change_issued_item = $obj['change_issued_item'];
$delete_issued_item = $obj['delete_issued_item'];

//Returned privileges
$add_returned_item = $obj['add_returned_item'];
$change_returned_item = $obj['change_returned_item'];
$delete_returned_item = $obj['delete_returned_item'];

//Suppliers privileges
$add_supplier = $obj['add_supplier'];
$delete_supplier = $obj['delete_supplier'];

//Reports privileges
$see_reports = $obj['see_reports'];

//Logs privileges
$see_logs = $obj['see_logs'];

$app_privileges_json_data[] = array(
    'see_settings_section' => $see_settings_section,
    'add_new_user' => $add_new_user,
    'see_users_list' => $see_users_list,
    'change_users_privileges' => $change_users_privileges,
    'backup_data' => $backup_data,
    'restore_data' => $restore_data,
    'change_users_password' => $change_users_password
);

$warehouse_json_data[] = array(
    'see_warehouse_content' => $see_warehouse_content,
    'add_item_to_warehouse' => $add_item_to_warehouse,
    'see_item_details' => $see_item_details,
    'change_warehouse_item' => $change_warehouse_item,
    'delete_warehouse_item' => $delete_warehouse_item
);

$suppliers_json_data[] = array(
    'add_supplier' => $add_supplier,
    'delete_supplier' => $delete_supplier
);

$brigades_json_data[] = array(
    'add_brigade' => $add_brigade,
    'change_brigade' => $change_brigade,
    'delete_brigade' => $delete_brigade
);

$issued_items_data[] = array(
    'issue_item' => $issue_item,
    'change_issued_item' => $change_issued_item,
    'delete_issued_item' => $delete_issued_item
);

$returned_json_data[] = array(
    'add_returned_item' => $add_returned_item,
    'change_returned_item' => $change_returned_item,
    'delete_returned_item' => $delete_returned_item
);

$reports_json_data[] = array(
    'see_reports' => $see_reports
);

$logs_json_data[] = array(
    'see_logs' => $see_logs
);

$warehousePrivileges = json_encode($warehouse_json_data);
$suppliersPrivileges = json_encode($suppliers_json_data);
$brigadesPrivileges = json_encode($brigades_json_data);
$issuedItemsPrivileges = json_encode($issued_items_data);
$returnedPrivileges = json_encode($returned_json_data);
$reportsPrivileges = json_encode($reports_json_data);
$logsPrivileges = json_encode($logs_json_data);
$appPrivileges = json_encode($app_privileges_json_data);

$records = mysqli_query($conn, "SELECT * FROM privileges WHERE user = '$name'");
$query;

if(mysqli_num_rows($records) > 0){
    $query = mysqli_query($conn, "UPDATE privileges SET warehouse = '$warehousePrivileges', suppliers = '$suppliersPrivileges',
                                  brigades = '$brigadesPrivileges', issued_items = '$issuedItemsPrivileges', reports = '$reportsPrivileges', returned = '$returnedPrivileges', logs = '$logsPrivileges', app = '$appPrivileges'
                                  WHERE user = '$name'");
}else{
    $query = mysqli_query($conn, "INSERT INTO privileges (user, warehouse, suppliers, brigades, issued_items, reports, returned, logs, app) 
              VALUES ('$name', '$warehousePrivileges', '$suppliersPrivileges', '$brigadesPrivileges', '$issuedItemsPrivileges', '$reportsPrivileges', '$returnedPrivileges', '$logsPrivileges', '$appPrivileges')");
}


if($query){
    echo "privileges_successfully_updated";
}else{
    echo $conn -> error;
}

mysqli_close($conn);
?>