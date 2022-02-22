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

// Getting filename from user
$filename = $obj['filename'];

// Back up file direction
$dir = 'Backups/'.$filename;

$command = "mysql -h$HostName -u$HostUser -p$HostPass < $dir";

exec($command);


?>