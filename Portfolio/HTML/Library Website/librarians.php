<?php
    include_once "database.php";
    $conn = getConn();

    $query = "SELECT * FROM librarians";

    try{
        $results = $conn->query($query);
        $output = "";

        while($row = $results->fetch_assoc()){
            $fName = $row["Librarian_FName"];
            $lName = $row["Librarian_LName"];
            $phone = $row["Librarian_Phone"];
            $email = $row["Librarian_Email"];

            $output .= "<tr>
                <td>$fName $lName</td>
                <td>$phone</td>
                <td>$email</td>
            </tr>";
        }
    }catch(Exception  $err){
        print("Error:  " . $err->getMessage());
    }
?>
<table>
    <tr>
        <th>Name</th>
        <th>Phone Number</th>
        <th>Email</th>
    </tr>
    <?php print $output ?>
</table>