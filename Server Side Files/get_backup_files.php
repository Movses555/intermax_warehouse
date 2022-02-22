<?php

$dir = 'Backups/';

$files = array_diff(scandir($dir, 1), array('.','..'));

foreach($files as $file){
    $json_array[] = array('filename' => $file);
}

echo json_encode($json_array, JSON_UNESCAPED_UNICODE);
?>