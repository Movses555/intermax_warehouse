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
 
// Creating MySQL Connection.
$conn = mysqli_connect($HostName,$HostUser,$HostPass,$DatabaseName);

$name = $obj['name'];
$newPassword = $obj['password'];

$query = mysqli_query($conn, "UPDATE users SET password = '$newPassword' WHERE name = '$name'");

if($query){
	echo json_encode('password_changed');
}else{
	echo json_encode('error_while_changing_password');
}


mysqli_close($conn);
?>