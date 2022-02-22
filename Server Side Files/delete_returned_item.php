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
$user = $obj['user'];
mysqli_query($conn, "UPDATE returned_items SET user = '$user' WHERE id = '$id'");
$deleteQuery = mysqli_query($conn, "DELETE FROM returned_items WHERE id = '$id'");
if($deleteQuery){
    echo json_encode('deleted');
}


                                            
mysqli_close($conn);
?>