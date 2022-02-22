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
$con = mysqli_connect($HostName, $HostUser, $HostPass, $DatabaseName);

// Getting brigade name from $obj object
$brigade = $obj['brigade'];

// Getting brigade members from $obj object
$members = $obj['members'];

// Getting item name from $obj object.
$item = $obj['item'];

// Getting item description from $obj object
$description = $obj['description'];

// Getting item date from $obj object.
$date = $obj['date'];

// Getting item count from $obj object.
$count = $obj['count'];

// Getting item count options from $obj object
$count_options = $obj['count_options'];

// Getting item photo from $obj object
$photo = $obj['photo'];

// Getting user name from $obj object
$user = $obj['user'];

$checkQuery = "SELECT * FROM issued_items WHERE item = '$item' AND description = '$description'";
$records = mysqli_query($con, "SELECT * FROM warehouse_items WHERE item_name = '$item'");

$check = mysqli_fetch_array(mysqli_query($con, $checkQuery));

while ($row = mysqli_fetch_assoc($records)) {
    $message = "";
    if ($count > $row['item_count']) {
        $message = 'not_enough_items';
        echo json_encode($message);
    } else if ($count_options != $row['item_count_options']) {
        $message = 'count_option_error';
        echo json_encode($message);
    } else {
        if (isset($check)) {
            $message = 'item_already_issued';
            echo json_encode($message);
        } else {
                $SQL_Query = "INSERT INTO issued_items (brigade, members, item, description, date, count, count_options, photo, user) values ('$brigade', '$members', '$item', '$description', '$date', '$count', '$count_options', '$photo', '$user')";
                mysqli_query($con, "INSERT INTO reports (brigade, members, item, description, date, count, count_options, user) values ('$brigade', '$members','$item', '$description', '$date', '$count', '$count_options', '$user')");
                if (mysqli_query($con, $SQL_Query)) {

                    // If the record inserted successfully then show the message.
                    $MSG = 'item_issued_successfully';

                    // Update data in warehouse items
                    $currentCount = $row['item_count'] - $count;
                    mysqli_query($con, "UPDATE warehouse_items SET item_count = '$currentCount' WHERE item_name = '$item'");

                    // Echo the message.
                    echo json_encode($MSG);

                } else {
                    echo $con->error;
                }
            }

        }
    }

mysqli_close($con);
?>