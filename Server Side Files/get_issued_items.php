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

// Getting brigade number from $obj object
$brigade = $obj['brigade'];

$records = mysqli_query($conn, "SELECT * FROM issued_items WHERE brigade = '$brigade'");


if(mysqli_num_rows($records) > 0) {
	while($row = mysqli_fetch_assoc($records)) {  
            $json_array[] = array('id' => $row['id'],
                                  'brigade' => $row['brigade'],
                                  'item' => $row['item'],
                                  'description' => $row['description'],
                                  'date' => $row['date'],
                                  'count' => $row['count'],
								  'user' => $row['user'],
                                  'count_option' => $row['count_options'],
                                  'photo' => $row['photo']);
                                 
}
   echo json_encode($json_array, JSON_UNESCAPED_UNICODE);
}	
mysqli_close($conn);
?>