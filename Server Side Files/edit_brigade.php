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
$brigade_number = $obj['brigade_number'];
$brigade_members = $obj['brigade_members'];
$brigade_phone_number = $obj['brigade_phone_number'];

$allData = mysqli_query($conn, "SELECT * FROM brigades WHERE id <> '$id'");
$row = mysqli_fetch_assoc(mysqli_query($conn, "SELECT * FROM brigades WHERE id = '$id'"));

$number = $row['brigade_number'];

if(mysqli_num_rows($allData) == 0){
    
    $updateQuery = mysqli_query($conn, "UPDATE brigades SET brigade_number = '$brigade_number',
                                                    brigade_members = '$brigade_members',
                                                    brigade_phone_number = '$brigade_phone_number' WHERE id = '$id'"); 
    mysqli_query($conn, "UPDATE issued_items SET brigade = '$brigade_number' WHERE brigade = '$number'"); 
    
    if($updateQuery){
        echo json_encode('brigade_edited');
    }else{
        echo json_encode('nothing_edited');
    }
}else{
    $allDataRow = mysqli_fetch_array($allData);
    if($allDataRow['brigade_number'] == $brigade_number){
        echo json_encode('brigade_exists');
    }else{
        $updateQuery = mysqli_query($conn, "UPDATE brigades SET brigade_number = '$brigade_number',
                                                        brigade_members = '$brigade_members',
                                                        brigade_phone_number = '$brigade_phone_number' WHERE id = '$id'"); 
        mysqli_query($conn, "UPDATE issued_items SET brigade = '$brigade_number' WHERE brigade = '$number'"); 
        
        if($updateQuery){
            echo json_encode('brigade_edited');
        }else{
            echo json_encode('nothing_edited');
        }  
    }
}



mysqli_close($conn);
?>