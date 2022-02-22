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

$filename = $obj['filename'];

$backup_file = $filename .'_'. date("d-m-Y"). '.sql';

$command = "C:/xampp/mysql/bin/mysqldump --routines -h$HostName -u$HostUser -p$HostPass --databases $DatabaseName > Backups/$backup_file";

system($command);

mysqli_close($conn);
?>