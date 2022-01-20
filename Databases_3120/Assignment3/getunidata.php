
<h2>View all the data of a university</h2>
Which university? <br>
<?php
   $query = "SELECT * FROM university ORDER BY province";
   $result = mysqli_query($connection,$query);
   if (!$result) {
        die("databases query failed.");
    }
   while ($row = mysqli_fetch_assoc($result)) {
        echo '<input type="radio" name="university" value="';
        echo $row["UID"];
        echo '">'.$row[UName]."<br>";
   }
   mysqli_free_result($result);
?>

