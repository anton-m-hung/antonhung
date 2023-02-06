<!-- Generates webpage when a course is updated at Western. The query deletes the row with that course code -->

<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Delete Course</title>
<link rel="stylesheet" type="text/css" href="assignment3.css">
</head>
<body>
<?php
   include 'connectdb.php';
?>
<ol>

<?php
    $code=$_POST["confirm"];
    if ($code=="No") {
        echo "Course NOT deleted";
    }
    else {
        $query = 'DELETE FROM westernCourse WHERE westernNum = "'.$code.'"';
        if (!mysqli_query($connection, $query)) {
            die("Error: delete failed" . mysqli_error($connection));
        }
        echo "Your course was deleted!";
    }
?>
<?php
    mysqli_close($connection);
?>

</ol>
</body>
</html>

