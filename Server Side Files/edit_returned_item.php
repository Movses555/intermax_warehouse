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
$date = $obj['date'];
$count = $obj['count'];
$user = $obj['user'];

$record = mysqli_fetch_assoc(mysqli_query($conn, "SELECT * FROM returned_items WHERE id = '$id'"));
$itemRecord = mysqli_fetch_assoc(mysqli_query($conn, "SELECT * FROM warehouse_items WHERE item_name = '$item'"));

$itemCount = $itemRecord['item_count'];
$currentCount = $record['count'];

if($count >= $currentCount){
    $updateCount = ($count - $currentCount) + $itemCount;
    mysqli_query($conn, "UPDATE warehouse_items SET item_count = '$updateCount' WHERE item_name = '$item'");
    mysqli_query($conn, "UPDATE returned_items SET description = '$description', count = '$count', date = '$date', user = '$user' WHERE id = '$id'");
    echo json_encode('updated');
}else if($count <= $currentCount){
    $updateCount = $itemCount - ($currentCount - $count);
    mysqli_query($conn, "UPDATE warehouse_items SET item_count = '$updateCount' WHERE item_name = '$item'");
    mysqli_query($conn, "UPDATE returned_items SET description = '$description', count = '$count', date = '$date', user = '$user' WHERE id = '$id'");
    echo json_encode('updated');
}


                                            
mysqli_close($conn);
?>