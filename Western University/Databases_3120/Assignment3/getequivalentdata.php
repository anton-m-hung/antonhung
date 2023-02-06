<!-- Creates a radio button and passes the selected western code to getequivalent.php-->

<?php
    $query = "SELECT * FROM westernCourse";
    $result=mysqli_query($connection,$query);
    if (!$result) {
        die("database query2 failed.");
    }
    while ($row=mysqli_fetch_assoc($result)) {
        echo '<input type="radio" name="westernNum" value="';
        echo $row["westernNum"];
        echo '">'.$row[westernNum]."<br>";
    }
    mysqli_free_result($result);
?>



