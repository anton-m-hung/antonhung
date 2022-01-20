<!-- Returns a list of all the outside courses in our database. To be selected to create a new equivalency. Passes the outsideNum and UID to equivalentwith.php -->
<?php
    $query = "SELECT * FROM outsideCourse, university WHERE university.UID=outsideCourse.UID";
    $result=mysqli_query($connection,$query);
    if (!$result) {
        die("database query2 failed.");
    }
    while ($row=mysqli_fetch_assoc($result)) {
        echo '<input type="radio" name="outside" value="';
        echo $row["outsideNum"].",".$row["UID"];
        echo '">'.$row[outsideNum]." from ".$row[UName]."<br>";
    }
    mysqli_free_result($result);
?>

