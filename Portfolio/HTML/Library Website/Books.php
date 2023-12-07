<?php
    include_once "database.php";
    $conn = getConn();

    $query = "SELECT * FROM authors JOIN resources on authors.Author_ID = resources.Author_ID";

    try {
        $results = $conn->query($query);
        $output = "";

        while ($row = $results->fetch_assoc()) {
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