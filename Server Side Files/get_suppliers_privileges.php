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

//Getting records
$records = mysqli_query($conn, "SELECT * FROM privileges WHERE user = '$name'");


if(mysqli_num_rows($records) > 0){
    while($row = mysqli_fetch_assoc($records)){
        echo $row['suppliers'];
    }
}

mysqli_close($conn);
?>