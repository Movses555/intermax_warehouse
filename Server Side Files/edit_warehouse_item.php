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
  
$old_item_name = $obj['old_item_name'];
$item_name = $obj['item_name'];
$item_description = $obj['item_description'];
$item_price = $obj['item_price'];
$item_date = $obj['item_date'];
$item_count = $obj['item_count'];
$item_supplier = $obj['item_supplier'];
$item_photo = $obj['item_photo'];
$user = $obj['user'];

$allData = mysqli_query($conn, "SELECT * FROM warehouse_items WHERE item_name <> '$old_item_name'");
$row = mysqli_fetch_assoc(mysqli_query($conn, "SELECT * FROM warehouse_items WHERE item_name = '$old_item_name'"));


if(mysqli_num_rows($allData) == 0){
    mysqli_query($conn, "UPDATE warehouse_items SET item_name = '$item_name',
                                                    item_description = '$item_description',
                                                    item_price = '$item_price',
                                                    item_date = '$item_date',
                                                    item_count = '$item_count',
                                                    item_supplier = '$item_supplier',
                                                    item_photo = '$item_photo',													
													user = '$user' WHERE item_name = '$old_item_name'");    
    echo json_encode('item_edited');
}else{
    $allDataRow = mysqli_fetch_array($allData);
    if($item_name == $allDataRow['item_name']){
        echo json_encode('item_exists');
    }else{
        $updateQuery = mysqli_query($conn, "UPDATE warehouse_items SET item_name = '$item_name',
                                                        item_description = '$item_description',
                                                        item_price = '$item_price',
                                                        item_date = '$item_date',
                                                        item_count = '$item_count',
                                                        item_supplier = '$item_supplier', 
                                                        item_photo = '$item_photo',															
														user = '$user' WHERE item_name = '$old_item_name'");    
        echo json_encode('item_edited');
    }
}

mysqli_close($conn);
?>