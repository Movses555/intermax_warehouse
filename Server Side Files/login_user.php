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
  
// Getting Email from $obj object.
$name = $obj['name'];
 
// Getting Password from $obj object.
$password = $obj['password'];

// Checking whether Email is Already Exist or Not in MySQL Table.
$CheckSQL = "SELECT * FROM users WHERE name ='$name' AND password = '$password'";

// Getting records in database.
$records = mysqli_query($conn,"SELECT * from users WHERE name = '$name'"); 

// Executing Email Check MySQL Query.
$check = mysqli_fetch_array(mysqli_query($conn,$CheckSQL));

if(isset($check)){

	 $accountExists = 'account_exists';
	 
	 // Converting the message into JSON format.
	$existsAccountJson = json_encode($accountExists);
	
	if(mysqli_num_rows($records) > 0){
	while($row = mysqli_fetch_array($records)){
	    $data = array('name' => $row['name'], 'status' => $accountExists);
		echo json_encode($data);
	}
}

  }else{
	  $accountDoesntExist = 'account_not_exists';
	  $data = array('status' => $accountDoesntExist);
	  
	  $notExistsAccountJson = json_encode($data);
	  echo $notExistsAccountJson;
  }
 mysqli_close($conn);
?>