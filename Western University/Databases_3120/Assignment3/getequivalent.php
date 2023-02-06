<!-- Generates webpage to show the courses that the selected course is equivalent to-->

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
<h1>Here is some information about this course and other universities' courses that are equivalent to it:</h1>
<ol>
<?php
    $num= $_POST["westernNum"];
// $query1 shows information about the western course
    $query1 = 'SELECT * FROM westernCourse WHERE westernNum ="'.$num.'"';
    $result=mysqli_query($connection,$query1);
    if (!$result) {
        die("database query1 failed.");
    }
    while ($row=mysqli_fetch_assoc($result)) {
        echo "Western Name: ".$row[westernName]. "<br>Western Number: ".$row[westernNum]. "<br>Western Weight: ".$row[Weight]."<br>";
        break;
    }
    mysqli_free_result($result);
// $query2 shows information about all the equivalent courses
    $query2 = 'SELECT * FROM university, outsideCourse, equivalentTo
            WHERE equivalentTo.outsideNum = outsideCourse.outsideNum
            AND equivalentTo.UID = university.UID
            AND outsideCourse.UID = university.UID
            AND equivalentTo.westernNum = "'.$num.'"';
    
    $result=mysqli_query($connection,$query2);
    if (!$result) {
        die("database query2 failed.");
    }
    echo "----------<br>Here are universities with equivalent courses:<br>----------<br>";
    while ($row=mysqli_fetch_assoc($result)) {
        echo '<li>';
        echo "Outside University: ".$row[UName]. "<br>Outside Course Name: ".$row[outsideName]. "<br> Outside Course Number: ".$row[outsideNum]."<br>Outside Course Weight: ".$row[weight]. "<br> Date Equivalency Decided: ".$row[dateDecided]. "<br><br>";
    }
    mysqli_free_result($result);

?>
</ol>
<?php
   mysqli_close($connection);
?>
</body>
</html>

