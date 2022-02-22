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
 
// Getting name from $obj object.
$name = $obj['name'];
 
// Getting Password from $obj object.
$password = $obj['password'];

// Checking whether Email is Already Exist or Not in MySQL Table.
$CheckSQL = "SELECT * FROM users WHERE name = '$name'";

// Executing Email Check MySQL Query.
$check = mysqli_fetch_array(mysqli_query($conn,$CheckSQL));


if(isset($check)){

	 $emailExist = 'user_already_exists';
	 
	 // Converting the message into JSON format.
	$existEmailJSON = json_encode($emailExist);
	 
	// Echo the message on Screen.
	 echo $existEmailJSON ; 

  }
 else{
 
	 // Creating SQL query and insert the record into MySQL database table.
	 $Sql_Query = "INSERT INTO users (name, password) values ('$name', '$password')";
	 
	 
	 if(mysqli_query($conn,$Sql_Query)){
	 
		 // If the record inserted successfully then show the message.
		$MSG = 'user_registered' ;
		 
		// Converting the message into JSON format.
		$json = json_encode($MSG);
		 
		// Echo the message.
		 echo $json ;
	 
	 }
	 else{
	 
		echo 'Try Again';
	 
	 }
 }
 mysqli_close($conn);
?>