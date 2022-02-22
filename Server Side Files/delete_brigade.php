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

$brigade_number = $obj['brigade_number'];
$deleteQuery = mysqli_query($conn, "DELETE FROM brigades WHERE brigade_number = '$brigade_number'");

if(isset($deleteQuery)){
	$MSG = 'brigade_deleted';
	echo json_encode($MSG);
}else{
    $MSG = 'error';
	echo json_encode($MSG);
}

mysqli_close($conn);
?>