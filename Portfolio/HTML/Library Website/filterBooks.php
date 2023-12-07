<?php
    // $servername = "localhost";
    // $username = "root";
    // $password = "";
    // $dbname = "Library";

    // $conn = new mysqli($servername, $username, $password, $dbname);

    // if ($conn->connect_error) {
    //     die("Connection failed: " . $conn->connect_error);
    // }

    include_once "database.php";
    $conn = getConn();
    $searchVal = $_GET["searchVal"];

    $sql = "SELECT * FROM authors JOIN resources on authors.Author_ID = resources.Author_ID WHERE MATCH(resources.Resource_Title, authors.Author_FName, authors.Author_LName) AGAINST('$searchVal*' in boolean mode);";

    $output = "";
    try {
        $result = $conn->query($sql) or die("Query not run.");

        $resultArray = array();

        while ($row = $result->fetch_assoc()) {
            $title = $row["Resource_Title"];
            $fName =  $row["Author_FName"];
            $lName = $row["Author_LName"];
            $createDate = $row["Resource_CreationDate"];
            $Availability = $row["Resource_Availiability"];
            
            $output .= "<tr>
                <td>$title</td>
                <td>$fName $lName</td> 
                <td>$createDate</td>
                <td >$Availability</td>
            </tr>";
        }
    } catch(Exception $err){
        print("Error:  " . $err->getMessage());
    }
    $conn->close();
?>
<table>
    <tr>
        <th>Title</th>
        <th>Author</th>
        <th>Creation Date</th>
        <th>Availability</th>
    </tr>
    <?php
        print $output;
    ?>
</table>