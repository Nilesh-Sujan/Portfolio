<?php
    include_once "database.php";
    $conn = getConn();

    $query = "SELECT * FROM Resources WHERE Resource_Classification = 'RP'";

    try{
        $results = $conn->query($query);
        $output = "";

        while($row = $results->fetch_assoc()){
            $title = $row["Resource_Title"];
            $createDate = $row["Resource_CreationDate"];
            $Availability = $row["Resource_Availiability"];

            $output .= "<tr>
                <td>$title</td>
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
        <th>Creation Date</th>
        <th>Availability</th>
    </tr>
    <?php
        print $output;
    ?>
</table>