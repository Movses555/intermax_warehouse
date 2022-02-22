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

$records = mysqli_query($conn, "SELECT * FROM suppliers");

if(mysqli_num_rows($records) > 0){
	while($row = mysqli_fetch_assoc($records)){  
            $json_array[] = array('supplier_name' => $row['supplier_name']);
}
   echo json_encode($json_array, JSON_UNESCAPED_UNICODE);
}	
mysqli_close($conn);
?>