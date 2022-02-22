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
   

$id = $obj['id'];
$item = $obj['item'];
$description = $obj['description'];
$brigade = $obj['brigade'];
$brigade_members = $obj['brigade_members'];
$date = $obj['date'];
$count = $obj['count'];
$count_option = $obj['count_option'];
$user = $obj['user'];

$warehouseItemRecords = mysqli_fetch_assoc(mysqli_query($conn, "SELECT * FROM warehouse_items WHERE item_name = '$item'"));
$issuedItemsRecords = mysqli_fetch_assoc(mysqli_query($conn, "SELECT * FROM issued_items WHERE id = '$id'"));

$itemCount = $warehouseItemRecords['item_count'];
$updateCount = $itemCount + $count;
	    
if($issuedItemsRecords['count'] < $count){
    echo json_encode('not_enough_items');
}else{
    

  
$query = mysqli_query($conn, "INSERT INTO returned_items (item, description, brigade, brigade_members, date, count, count_options, user) values ('$item', '$description', '$brigade', '$brigade_members', '$date', '$count', '$count_option', '$user')");
mysqli_query($conn, "DELETE FROM issued_items WHERE id = '$id'");
mysqli_query($conn, "UPDATE warehouse_items SET item_count = '$updateCount' WHERE item_name = '$item'");


  if($query){
   
  // Echo the message.
   echo json_encode('returned_item_added') ;

}else{

  echo $conn -> error;

}
}

mysqli_close($conn);
?>