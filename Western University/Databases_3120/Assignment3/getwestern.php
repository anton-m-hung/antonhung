<!-- Shows al the courses at western ordered by the selected field and in the selected direction. Also proides the option to update or delete courses -->

<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Western's Courses</title>
<link rel="stylesheet" type="text/css" href="assignment3.css">
</head>
<body>
<?php
    include 'connectdb.php';
?>
<h1>Here are Western's courses:</h1>
<ol>

<h2>Select a course to update its information</h2>

<!-- The following block of code creates the button for updating courses -->
<form action="updateWcourse.php" method="post">
<?php
    $orderby= $_POST["orderby"];
    $direction = $_POST["direction"];
    
    $query = "SELECT * FROM westernCourse ORDER BY ".$orderby." ".$direction;
    $result=mysqli_query($connection,$query);
    if (!$result) {
        die("database query2 failed.");
    }
    while ($row=mysqli_fetch_assoc($result)) {
        echo '<input type="radio" name="westernNum" value="';
        echo $row["westernNum"];
        echo '">'."Course number: ".$row[westernNum].", Course name: ".$row[westernName].", Weight: ".$row[Weight].", Suffix: ".$row[suffix]."<br>";
    }
    mysqli_free_result($result);
?>
What do you want to update? <br>
Course Name: <input type="text" name="westernName">
Course Weight:
    <input type="radio" name="weight" value=0.5>0.5
    <input type="radio" name="weight" value=1>1
Course Suffix: <input type="text" name="suffix"><br>
<input type="submit" value="update">
</form>

<p>
<hr>
<p>
<h2>Select a course to delete it (you will be asked to confirm your decision)</h2>
<!-- The following creates the delete button -->
<form action="deletecourseconfirm.php" method="post">
<?php
    $orderby= $_POST["orderby"];
    $direction = $_POST["direction"];
    
    $query = "SELECT * FROM westernCourse ORDER BY ".$orderby." ".$direction;
    $result=mysqli_query($connection,$query);
    if (!$result) {
        die("database query2 failed.");
    }
    while ($row=mysqli_fetch_assoc($result)) {
        echo '<input type="radio" name="westernNum" value="';
        echo $row["westernNum"];
        echo '">'."Course number: ".$row[westernNum].", Course name: ".$row[westernName].", Weight: ".$row[Weight].", Suffix: ".$row[suffix]."<br>";
    }
    mysqli_free_result($result);
?>
<input type="submit" value="delete">
</form>
</ol>

<?php
   mysqli_close($connection);
?>
</body>
</html>























