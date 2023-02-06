<!-- This is the FIRST/HOME PAGE where all the required tasks can be found except for UPDATE westernCourse and DELETE westernCourse (They are found on getwestern.php)-->
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Assignment3</title>
<link rel="stylesheet" type="text/css" href="assignment3.css">
</head>
<body>

<!-- connect to database -->
<?php
    include 'connectdb.php';
?>

<h1>Welcome to Assignment3</h1>
<img src="https://welcome.uwo.ca/img/top_10/Top_Ten_880x300_9.jpg" alt="Picture of campus">

<!-- See all of Western's courses -->
<h2>See Western University's Courses:</h2>
<form action="getwestern.php" method="post">
<?php
    include 'getwesterndata.php';
?>
<input type="submit" value="order">
</form>

<!-- Add a new course to Western -->
<p>
<hr>
<p>
<h2> Add a New Course to Western:</h2>
<form action="addnewWcourse.php" method="post">
Course Code (fill in the four digits that follow "cs"): cs<input type="number" name="westernNum" minlength="4" maxlength="4" required><br>
Course Name: <input type="text" name="westernName" required><br>
Course Weight: <br>
    <input type="radio" name="weight" value=0.5>0.5<br>
    <input type="radio" name="weight" value=1>1<br>
Course Suffix: <br>
    <input type="radio" name="suffix" value="A">A<br>
    <input type="radio" name="suffix" value="B">B<br>
    <input type="radio" name="suffix" value="A/B">A/B<br>
<input type="submit" value="Add New Western Course">
</form>

<!-- See all the courses from a university -->
<p>
<hr>
<p>
<form action="getuni.php" method="post">
<?php
    include 'getunidata.php';
?>
<input type="submit" value="university">
</form>

<!-- See all the universities in a province -->
<p>
<hr>
<p>
<form action="getprovince.php" method="post">
<?php
    include 'getprovincedata.php';
?>
<input type="submit" value="province">
</form>

<!-- See all the equivalenTo information -->
<p>
<hr>
<p>
<h2>Select a course to see its information along with equivalent courses from other universities</h2>
<form action="getequivalent.php" method="post">
<?php
    include 'getequivalentdata.php';
?>
<input type="submit" value="choose number">
</form>

<!-- See equivalentcy information for a selected date -->
<p>
<hr>
<p>
<h2>Enter a date (yyyy-mm-dd) and see all the equivalency information decided up until this date</h2>
<form action="getdate.php" method="post">
Choose Date: <input type="text" name="date"><br>

<input type="submit" value="choose date">
</form>

<!-- Creates button to make a new equivalency -->
<p>
<hr>
<p>
<h2>Select a course that you want to make a new equivalency with</h2>
<form action="equivalentwith.php" method="post">
<?php
    echo 'Select a course from Western:<br>';
    include 'getequivalentdata.php';
    echo "<br>";
    echo 'Select a course from an outside university:<br>';
    include 'getoutsidedata.php';
?><input type="submit" value="Create equivalency">
</form>

<!-- Creates button to redirect to nocourse page -->
<p>
<hr>
<p>
<h2>Click to see all the universities in the database that do not have any courses in our database</h2>
<form action="nocourse.php" method="post">
<input type="submit" value="GO">
</form>

<?php
    mysqli_close($connection);
?>


</body>
</html>











