<!-- Generates webpage where the nnew equivalency is added to the equivalentTo table -->

<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Create equivalency</title>
<link rel="stylesheet" type="text/css" href="assignment3.css">
</head>
<body>
<?php
    include 'connectdb.php';
?>
<h1>Creating equivalency...</h1>
<ol>
<?php
    $westernNum= $_POST["westernNum"];
    $outside= explode(",",$_POST["outside"]);
// $outside received outsideNum and UID from getousidedata.php. So splitting it [0] and [1] provides the values separately
    $outsideNum= $outside[0];
    $outsideUID= $outside[1];
    $date=date("Y/m/d");
// $query1 checks if the equivalency is already in the table by seeing if there is already a row with both $westernNum and $outsideNum. If yes, then the dateDecided is updated to today
    $query1 = 'SELECT westernNum, outsideNum FROM equivalentTo';
    $query1array = (mysqli_query($connection, $query1));
  
    foreach ($query1array as $x) {
        echo $x[0].$x[1];
	if ($x[0] == $westernNum and $x[1] == $outsideNum){
            $query3= 'UPDATE equivalentTo SET dateDecided ="'.$date.'"';
            $result=mysqli_query($connection,$query3);
            if (!$result) {
                die("database query3 failed.");
            }
            return;
        }
    }
// $query2 does the insertion of the new equivalency after the previous test is passed
    $query2= 'INSERT INTO equivalentTo VALUES("'.$westernNum.'","'.$outsideNum.'",'.$outsideUID.',"'.$date.'")';
    $result=mysqli_query($connection,$query2);
    if (!$result) {
        die("database query2 failed.");
    }
    echo $westernNum." is now equivalent to ".$outsideNum.", decided on ".$date;
?>
</ol>
<?php
   mysqli_close($connection);
?>
</body>
</html>

