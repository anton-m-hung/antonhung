<!-- Generates webpage when a new course is added to Western-->

<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>New Course</title>
<link rel="stylesheet" type="text/css" href="assignment3.css">
</head>
<body>
<?php
   include 'connectdb.php';
?>
<h1>Adding course:</h1>
<ol>
<?php
    $code="cs".$_POST["westernNum"];
    $name=$_POST["westernName"];
    $weight=$_POST["weight"];
    $suffix=$_POST["suffix"];

// $query1 checks if the coursecode is already being used by another course
    $query1 = 'SELECT westernNum FROM westernCourse';
    $query1array = (mysqli_query($connection, $query1));
    
    foreach ($query1array as $x) {
        if (implode(" ",$x) == $code){
            echo "Course code already exists";
            return;
        }
    }
// $query2 inserts the new course if the previous test is passed
    $query2 = 'INSERT INTO westernCourse VALUES ("'.$code.'","'.$name.'",'.$weight.',"'.$suffix.'")';
    if (!mysqli_query($connection, $query2)) {
        die("Error: insert failed" . mysqli_error($connection));
    }
    echo "Your course was added!";

    mysqli_close($connection);
?>
</ol>
</body>
</html>

