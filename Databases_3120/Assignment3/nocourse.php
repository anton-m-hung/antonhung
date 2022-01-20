<!-- Generates webpage that shows the universities in our database with no associated courses -->

<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>No Courses</title>
<link rel="stylesheet" type="text/css" href="assignment3.css">
</head>
<body>
<?php
    include 'connectdb.php';
?>
<h1>Here are the universities with no courses in our database:</h1>
<ol>
<?php
    $query = 'SELECT * FROM university WHERE UID NOT IN (SELECT UID FROM outsideCourse)';
    $result=mysqli_query($connection,$query);
    if (!$result) {
        die("database query2 failed.");
    }
    while ($row=mysqli_fetch_assoc($result)) {
        echo '<li>';
        echo $row[UName].", Nickname: ".$row[nickname]."<br>";
    }
    mysqli_free_result($result);

?>
</ol>
<?php
   mysqli_close($connection);
?>
</body>
</html>

