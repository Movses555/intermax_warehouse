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
  
$id = $obj['id'];
$brigade = $obj['brigade'];
$item_name = $obj['item_name'];
$description = $obj['description'];
$updated_date = $obj['date'];
$updated_count = $obj['count'];
$user = $obj['user'];

$allData = mysqli_query($conn, "SELECT * FROM issued_items WHERE id <> '$id'");
$record = mysqli_fetch_assoc(mysqli_query($conn, "SELECT * FROM issued_items WHERE id = '$id'"));
$itemRecord = mysqli_fetch_assoc(mysqli_query($conn, "SELECT * FROM warehouse_items WHERE item_name = '$item_name'"));


$itemCount = $itemRecord['item_count'];
$currentCount = $record['count'];

if(mysqli_num_rows($allData) == 0){
    if($currentCount >= $updated_count){
        $updatedCount = $currentCount - $updated_count + $itemCount;
        mysqli_query($conn, "UPDATE warehouse_items SET item_count = '$updatedCount' WHERE item_name = '$item_name'");
        mysqli_query($conn, "UPDATE reports SET description = '$description', date = '$updated_date', count = '$updated_count' WHERE id = '$id'");
        mysqli_query($conn, "UPDATE issued_items SET date = '$updated_date', description = '$description',
                                                     count = '$updated_count', user = '$user' WHERE id = '$id'");
                                            
       
        echo json_encode('issued_item_edited');  
                                                 
    }else if($currentCount <= $updated_count){
        $updatedCount = $itemCount - ($updated_count - $currentCount);
        if($updatedCount < 0){
            echo json_encode('not_enough_items');
        }else{
            mysqli_query($conn, "UPDATE warehouse_items SET item_count = '$updatedCount' WHERE item_name = '$item_name'");
            mysqli_query($conn, "UPDATE reports SET description = '$description', date = '$updated_date', count = '$updated_count' WHERE id = '$id'");
            mysqli_query($conn, "UPDATE issued_items SET date = '$updated_date', description = '$description',
                                                         count = '$updated_count', user = '$user' WHERE id = '$id'"); 
                                                               
            echo json_encode('issued_item_edited');                                           
          }
      }
}else{
    $row = mysqli_fetch_array($allData);
    if($row['description'] == $description){
        echo json_encode('item_already_issued');
    }else{
        if($currentCount >= $updated_count){
            $updatedCount = $currentCount - $updated_count + $itemCount;
            mysqli_query($conn, "UPDATE warehouse_items SET item_count = '$updatedCount' WHERE item_name = '$item_name'");
            mysqli_query($conn, "UPDATE issued_items SET date = '$updated_date', description = '$description',
                                                         count = '$updated_count', user = '$user' WHERE id = '$id'");
		    mysqli_query($conn, "UPDATE reports set description = '$description', date = '$updated_date', count = '$updated_count', WHERE id = '$id'");
											 
                                                
            echo json_encode('issued_item_edited');  
                                                     
        }else if($currentCount <= $updated_count){
            $updatedCount = $itemCount - ($updated_count - $currentCount);
            if($updatedCount < 0){
                echo json_encode('not_enough_items');
            }else{
                mysqli_query($conn, "UPDATE warehouse_items SET item_count = '$updatedCount' WHERE item_name = '$item_name'");
                mysqli_query($conn, "UPDATE issued_items SET date = '$updated_date', description = '$description',
                                                             count = '$updated_count', user = '$user' WHERE id = '$id'");
                mysqli_query($conn, "UPDATE reports set description = '$description', date = '$updated_date', count = '$updated_count', WHERE id = '$id'");
															 
                                                                   
                echo json_encode('issued_item_edited');                                           
              }
          }    
    }
}

mysqli_close($conn);
?>