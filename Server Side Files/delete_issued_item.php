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
$brigade = $obj['brigade'];
$description = $obj['description'];
$item = $obj['item'];
$count = $obj['count'];
$user = $obj['user'];

$filter = $obj['filter'];
$deleteQuery;


if($filter == 'no_returned'){
	mysqli_query($conn, "UPDATE issued_items SET user = '$user' WHERE id = '$id'");
   $deleteQuery = "DELETE FROM issued_items WHERE id = '$id'";	
}else if($filter == 'issued_by_mistake'){
	mysqli_query($conn, "UPDATE issued_items SET user = '$user' WHERE id = '$id'");
	$data = mysqli_query($conn, "SELECT * FROM warehouse_items WHERE item_name = '$item'");
	if($data > 0){
		while($row = mysqli_fetch_assoc($data)){
            $currentCount = $row['item_count'];
	        $updatedCount = $count + $currentCount;	
            mysqli_query($conn, "UPDATE warehouse_items SET item_count = '$updatedCount' WHERE item_name = '$item'");	
		}
	}
		$deleteQuery = "DELETE FROM issued_items WHERE id = '$id'";
}


if(mysqli_query($conn, $deleteQuery)){
	$MSG = 'issued_item_deleted';
	echo json_encode($MSG);
}else{
    $MSG = 'error';
	echo json_encode($MSG);
}
?>