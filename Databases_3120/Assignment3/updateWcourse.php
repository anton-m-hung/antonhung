<!-- Generates webpage when a course is updated at Western -->

<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Update Course</title>
<link rel="stylesheet" type="text/css" href="assignment3.css">
</head>
<body>
<?php
   include 'connectdb.php';
?>
<h1>Course updated:</h1>
<ol>
<?php
    $code=$_POST["westernNum"];
    $name=$_POST["westernName"];
    $weight=$_POST["weight"];
    $suffix=$_POST["suffix"];
// The following code checks which fields have been filled. If the field is filled, then that column is updated
    
    if ($name) {
        $query1 = 'UPDATE westernCourse SET westernName = "'.$name.'" WHERE westernNum = "'.$code.'"';
        mysqli_query($connection, $query1);
    }
    if ($weight) {
        $query2 = 'UPDATE westernCourse SET Weight = '.$weight.' WHERE westernNum = "'.$code.'"';
        mysqli_query($connection, $query2);
    }
    if ($suffix) {
        $query3 = 'UPDATE westernCourse SET suffix = "'.$suffix.'" WHERE westernNum = "'.$code.'"';
        mysqli_query($connection, $query3);
    }
    echo "Your course was updated!";
        
?>
<?php
    mysqli_close($connection);
?>
</ol>
</body>
</html>

