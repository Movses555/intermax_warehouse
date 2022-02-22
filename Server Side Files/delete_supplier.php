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

$supplier_name = $obj['supplier_name'];
$deleteQuery = "DELETE FROM suppliers WHERE supplier_name = '$supplier_name'";

if(mysqli_query($conn, $deleteQuery)){
	$MSG = 'supplier_deleted';
	echo json_encode($MSG);
}else{
        $MSG = 'error';
	echo json_encode($MSG);
}
mysqli_close($conn);
?>