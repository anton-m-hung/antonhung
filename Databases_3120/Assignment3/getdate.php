<!-- Generates webpage to show equivalencies that were decided before a certain date -->

<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Course Equivalencies</title>
<link rel="stylesheet" type="text/css" href="assignment3.css">
</head>
<body>
<?php
    include 'connectdb.php';
?>
<h1>Here is some equivalency information that was decided before your date:</h1>
<ol>
<?php
    $date= $_POST["date"];

    $query = 'SELECT * FROM westernCourse, university, outsideCourse, equivalentTo
            WHERE equivalentTo.westernNum = westernCourse.westernNum
            AND equivalentTo.outsideNum = outsideCourse.outsideNum
            AND equivalentTo.UID = university.UID
            AND outsideCourse.UID = university.UID
            AND dateDecided <= "'.$date.'"';
    
    $result=mysqli_query($connection,$query);
    if (!$result) {
        die("database query2 failed.");
    }
    
    while ($row=mysqli_fetch_assoc($result)) {
        echo '<li>';
        echo "Western Name: ".$row[westernName]. "<br>Western Number: ".$row[westernNum]. "<br>Western Weight: ".$row[Weight]."<br>Outside University: ".$row[UName]. "<br>Outside Course Name: ".$row[outsideName]. "<br> Outside Course Number: ".$row[outsideNum]."<br>Outside Course Weight: ".$row[weight]. "<br> Date Equivalency Decided: ".$row[dateDecided]. "<br>";
        echo "----------<br>";
    }
    mysqli_free_result($result);

?>
</ol>
<?php
   mysqli_close($connection);
?>
</body>
</html>

