<?php

// Storing the received JSON into $json variable.
$json = file_get_contents('php://input');
 
// Decode the received JSON and Store into $obj variable.
$obj = json_decode($json,true);
 
//Define your Server host name here.
$HostName = $obj['ip'];
 
//Define your MySQL Database Name here.
$DatabaseName = "intermax_warehouse_db";
 
//Define your Database User Name here.
$HostUser = "AdminYerevan";
 
//Define your Database Password here.
$HostPass = "Intermax1072"; 

// Creating MySQL Connection.
$conn = mysqli_connect($HostName,$HostUser,$HostPass,$DatabaseName);

$item_name = $obj['item_name'];
$user = $obj['user'];

mysqli_query($conn, "UPDATE warehouse_items SET user = '$user' WHERE item_name = '$item_name'");
$deleteQuery = "DELETE FROM warehouse_items WHERE item_name = '$item_name'";

if(mysqli_query($conn, $deleteQuery)){
	$MSG = 'item_deleted';
	echo json_encode($MSG);
}else{
    $MSG = 'error';
	echo json_encode($MSG);
}
mysqli_close($conn);
?>