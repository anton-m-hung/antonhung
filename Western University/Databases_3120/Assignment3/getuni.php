<!-- Shows outside university information and all the courses at the selected university -->

<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Canadian universities</title>
<link rel="stylesheet" type="text/css" href="assignment3.css">
</head>
<body>
<?php
    include 'connectdb.php';
?>
<h1>Here are courses from this university:</h1>
<ol>
<?php
    $universityID= $_POST["university"];

// Display the university's information
    $query1 = 'SELECT * FROM university WHERE UID = "'.$universityID.'"';
    $result=mysqli_query($connection,$query1);
    if (!$result) {
        die("database query2 failed.");
    }
    while ($row=mysqli_fetch_assoc($result)) {
        echo "University: ".$row[UName]."<br> University ID: ".$row[UID]."<br> Location: ".$row[city].", ".$row[province]."<br> Nickname: ".$row[nickname]."<br>";
    break;
    }
    mysqli_free_result($result);
    
    echo "<br>";
// Display the course information
    $query2 = 'SELECT * FROM outsideCourse, university WHERE outsideCourse.UID = university.UID AND university.UID="'.$universityID.'"';
       
    $result=mysqli_query($connection,$query2);
    if (!$result) {
            die("database query2 failed.");
    }
    while ($row=mysqli_fetch_assoc($result)) {
        echo '<li>';
        echo "Course number: ".$row[outsideNum].", Course name: ".$row[outsideName].", Year Offered:  ".$row[yearOffered].", Weight: ".$row[weight]."<br>";
    }
    mysqli_free_result($result);
?>
</ol>
<?php
   mysqli_close($connection);
?>
</body>
</html>

