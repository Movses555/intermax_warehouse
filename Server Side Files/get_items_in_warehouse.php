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

$records = mysqli_query($conn, "SELECT * FROM warehouse_items");

if(mysqli_num_rows($records) > 0){
	while($row = mysqli_fetch_assoc($records)){   
            $json_array[] = array('id' => $row['id'],
                                  'item_name' => $row['item_name'],
                                  'item_description' => $row['item_description'],
                                  'item_price' => $row['item_price'],
                                  'item_date' => $row['item_date'],
                                  'item_count' => $row['item_count'],
                                  'item_count_options' => $row['item_count_options'],
                                  'item_supplier' => $row['item_supplier'],
                                  'item_photo' => $row['item_photo']);
}
   echo json_encode($json_array, JSON_UNESCAPED_UNICODE);
}else{
	echo $conn -> error;
}
echo $conn -> error;
mysqli_close($conn);
?>