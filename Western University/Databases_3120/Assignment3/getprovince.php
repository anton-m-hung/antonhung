<!-- Generates webpage to show the universities in the selected province-->

<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Province</title>
<link rel="stylesheet" type="text/css" href="assignment3.css">
</head>
<body>
<?php
    include 'connectdb.php';
?>
<h1>Here are universities in this province:</h1>
<ol>
<?php
    $province= $_POST["province"];

// Display the universities
    $query = 'SELECT * FROM university WHERE province = "'.$province.'"';
    $result=mysqli_query($connection,$query);
    if (!$result) {
        die("database query2 failed.");
    }
    while ($row=mysqli_fetch_assoc($result)) {
        echo '<li>';
        echo $row[UName].", Nickname: ".$row[nickname]."<br>";
    }
    mysqli_free_result($result);

?>
</ol>
<?php
   mysqli_close($connection);
?>
</body>
</html>

