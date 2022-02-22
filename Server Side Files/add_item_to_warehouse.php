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
$con = mysqli_connect($HostName,$HostUser,$HostPass,$DatabaseName);

// Getting item name from $obj object.
$item_name = $obj['item_name'];
 
// Getting item description from $obj object.
$item_description = $obj['item_description'];

// Getting item price from $obj object.
$item_price = $obj['item_price'];
 
// Getting item date from $obj object.
$item_date = $obj['item_date'];

// Getting item count from $obj object.
$item_count = $obj['item_count'];

// Getting item count options from $obj object
$item_count_options = $obj['item_count_options'];

// Getting item supplier from $obj object.
$item_supplier = $obj['item_supplier'];

// Getting item photo from $obj object.
$item_photo = $obj['item_photo'];

// Getting user name from $obj object.
$user = $obj['user'];

$checkQuery = "SELECT * FROM warehouse_items WHERE item_name = '$item_name'";
$check =  mysqli_fetch_array(mysqli_query($con,$checkQuery));

if(isset($check)){
    $errorMessage = 'item_exists';
    echo json_encode($errorMessage);
}else{
    	 
$Query = mysqli_query($con, "INSERT INTO warehouse_items (item_name, item_description, item_price, item_date, item_count, item_count_options, item_supplier, item_photo, user) values ('$item_name','$item_description','$item_price', '$item_date', '$item_count', '$item_count_options', '$item_supplier', '$item_photo', '$user')");

   if($Query){
	 
	// If the record inserted successfully then show the message.
	$MSG = 'item_added_successfully';
		 
        // Converting the message into JSON format.
	$json = json_encode($MSG);
		 
	// Echo the message.
	echo $json ;
	 
 }else{
	echo $con -> error;
}
}
 mysqli_close($con);
?>