<?php
    $servername = "localhost";
    $username = "root";
    $password = "";
    $dbname = "Library";

    $conn = new mysqli($servername, $username, $password, $dbname);

    function getConn(){
        global $conn;

        return $conn;
    }

    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }
?>