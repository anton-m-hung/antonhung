<!-- Generates webpage to ask for confirmation of deletion and shows if there are any courses that the deleted course is equivalent to -->

<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Confirmation required</title>
<link rel="stylesheet" type="text/css" href="assignment3.css">
</head>
<body>
<?php
   include 'connectdb.php';
?>
<h1>Before deleting, here are the outside courses that this course is equivalent to:</h1>
<ol>
<form action="deletecourse.php" method="post">
<?php
    $code=$_POST["westernNum"];
// $query1 shows information for all the equivalent courses
    $query1 = 'SELECT * FROM equivalentTo, university WHERE university.UID = equivalentTo.UID AND westernNum = "'.$code.'"';
    $result=mysqli_query($connection,$query1);
    while ($row=mysqli_fetch_assoc($result)) {
        echo '<li>';
        echo $row[outsideNum]." at ".$row[UName]."<br>";    }
    mysqli_free_result($result);
// $query2 generates the message to ask confirmation
    $query2 = "SELECT * FROM westernCourse WHERE westernNum = '".$code."'";
    $result=mysqli_query($connection,$query2);
    if (!$result) {
        die("database query2 failed.");
    }
    while ($row=mysqli_fetch_assoc($result)) {
        echo "Are you sure that you want to delete the course: ".$code." ".$row[westernName]."<br>";
        break;
    }
    
    mysqli_free_result($result);
// Creates a button with yes or no to proceed to deltecourse.php
    echo '<input type="radio" name="confirm" value="'.$code.'">Yes<br>';
    echo '<input type="radio" name="confirm" value="No">No<br>';
?>
<input type="submit" value="confirm">
</form>


<?php
    mysqli_close($connection);
?>

</ol>
</body>
</html>

