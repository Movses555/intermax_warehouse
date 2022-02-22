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

$idOfFirstItem = $obj['first_item_id'];
$idOfSecondItem = $obj['second_item_id'];

$result = mysqli_query($conn, "SELECT MAX(id) FROM warehouse_items");
$row = mysqli_fetch_row($result);
$maxId = $row[0] + 1;


if($idOfFirstItem > $idOfSecondItem){
	for($i = $idOfFirstItem; $i > $idOfSecondItem; $i--){
		mysqli_query($conn, "UPDATE warehouse_items SET id = '999' WHERE id = '$i'-1");
	    mysqli_query($conn, "UPDATE warehouse_items SET id = '$i'-1 WHERE id = '$i'");
	    mysqli_query($conn, "UPDATE warehouse_items SET id = '$i' WHERE id = '999'");
	}
}else{
	for($i = $idOfFirstItem; $i < $idOfSecondItem; $i++){	
	    mysqli_query($conn, "UPDATE warehouse_items SET id = '999' WHERE id = '$i'+1");
	    mysqli_query($conn, "UPDATE warehouse_items SET id = '$i'+1 WHERE id = '$i'");
	    mysqli_query($conn, "UPDATE warehouse_items SET id = '$i' WHERE id = '999'");

	}
}


mysqli_query($conn, "ALTER TABLE warehouse_items AUTO_INCREMENT = $maxId" );
echo $maxId;
echo $conn-> error;


mysqli_close($conn);
?>