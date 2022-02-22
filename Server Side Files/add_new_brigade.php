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
 
// Getting Suppler from $obj object.
$brigade_number = $obj['brigade_number'];
$brigade_members = $obj['brigade_members'];
$brigade_phone_number = $obj['brigade_phone_number'];
$brigade_photo = $obj['brigade_photo'];
 
// Checking whether suppier is Already Exist or not
$CheckSQL = "SELECT * FROM brigades WHERE brigade_number = '$brigade_number'";

// Executing supplier Check MySQL Query.
$check = mysqli_fetch_array(mysqli_query($conn, $CheckSQL));

if(isset($check)){

	$supplierExists = 'brigade_exists';
	 // Converting the message into JSON format.
	echo json_encode($supplierExists);
}else{
	    
        $sql_query = "INSERT INTO brigades (brigade_number, brigade_members, brigade_phone_number, brigade_photo) values ('$brigade_number', '$brigade_members', '$brigade_phone_number', '$brigade_photo')";
        
        if(mysqli_query($conn, $sql_query)){
	 
		 // If the record inserted successfully then show the message.
		$MSG = 'brigade_added' ;
		 
		// Converting the message into JSON format.
		$json = json_encode($MSG);
		 
		// Echo the message.
		 echo $json ;
	 
	 }
	 else{
	 
		echo $conn -> error;
	 
	 }
 }
mysqli_close($conn);
?>